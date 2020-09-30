#LogScrubber - searches unstructured data and scrubs it while maintaining a log of what was scrubbed


<#Functions


    - Invoke-LSScrub - user facing function to initiate log scrubbing
        Parameters
            -LogFile - the name of the file to scrub
            -BatchFile - a file contains a list of files to scrub
            -IP - scrubs ipv4 IPs
            -IP1 - scrubs ipv4 first octet only
            -IP2 - scrubs ipv4 first and second octet only
            -IP3 - scrubs ipv4 first, second, and third octets only
            -IPv6 - scrubs ipv6 IPs
            -Hostnames - scrubs hostnames
            -HostnameFile - source for hostnames



    - Find-LSIPs - locates IPs and stores a copy of them in <filename-IPs>
        -Parameters
            - LogFile - name of the file to scrub
            - 
    - Find-LSBadWords - locates bad words and stores a copy of them in <filename-badwords> (for example hostnames, domain names, etc.)

    - New-LSIPs - Generates fake IPs and stores them in <filename-IPs>
    - New-LSBadWords - Generates fake bad words and stores them in <filename-badwords> (for example hostnames, domain names, etc.)

    - Set-LSIPs - Makes a new log file with fake IPs

    Order: Find,New,Set
#>

#Stuff to put in Invoke-LSScrub:


$IPRegex = ‘\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b’

#    $IPListFile = $LogFileName + "-IPs"
#    If(Test-Path $IPListFile){rm -Force $IPListFile} #should probably be nice and ask first

Function Invoke-LSScrub{
    Param
    (
        # LogFileName The path and name of the log file to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName,
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   Position=1)]
        [Alias("Bad")] 
        $BadWordFile
    )
    
    Invoke-LSIPScrub -LogFileName $LogFileName
    If(Test-Path $BadWordFile){
        Invoke-LSBadWordScrub -LogFileName ($LogFileName+"-IPScrubbed") -BadWordFile $BadWordFile -BadWordKeyFile ($LogFileName+"-BadWordKey") -OriginalLogFileName $LogFileName
        Write-Host "BadWord KeyFile: $LogFileName-BadWordKey"
        Write-Host "Scrubbed Log: $LogFileName-Scrubbed"
    }Else{
        Write-Host "No BadWordFile entered or file does not exist, only IPs scrubbed, not bad words."
        Write-Host "Log file with only IPs scrubbed: $LogFileName-IPScrubbed"        
    }

}

Function Clear-LSScrubFiles{
    Param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName
    )
    rm -Force ($LogFileName+"-IPScrubbed"),($LogFileName+"-IPScrubbed-Scrubbed"),($LogFileName+"-IPsKey"),($LogFileName+"-BadWordKey"),($LogFileName+"-Scrubbed") -ea 0
}

Function Invoke-LSIPScrub{
    Param
    (
        # LogFileName The path and name of the log file to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName
    )

    Find-LSIPs -LogFileName $LogFileName
    New-LSIPs -IPList ($LogFileName+"-IPs")
    Set-LSIPs -LogFile $LogFileName -IPKeyList ($LogFileName+"-IPsKey")
    
    Write-Host "Original Log: $LogFileName"
    Write-Host "IP Key: " ($LogFileName+"-IPsKey")
    #Write-Host "Scrubbed Log: " ($LogFileName+"-IPScrubbed")
}

Function Invoke-LSBadWordScrub{
    Param
    (
        # LogFileName The path and name of the log file to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [Alias("Bad")] 
        $BadWordFile,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [Alias("BadKey")] 
        $BadWordKeyFile,
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$false,
                    Position=3)]
        [ValidateNotNullOrEmpty()]
        $OriginalLogFileName
    )

    Find-LSBadWords -LogFileName $LogFileName -BadWordFile $BadWordFile -BadWordKeyFile $BadWordKeyFile
    New-LSBadWords -LogFileName $LogFileName -BadWordFile $BadWordFile -BadWordKeyFile $BadWordKeyFile
    Set-LSBadWords -LogFile $LogFileName -BadWordsKeyList $BadWordKeyFile -BadWordKeyFile $BadWordKeyFile -OutputFileName ($OriginalLogFileName+"-Scrubbed")


}


Function Find-LSIPs{
    Param
    (
        # LogFileName The path and name of the log file to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName
    )
    $IPListFile = $LogFileName + "-IPs"
    ((select-string -Path $LogFileName -Pattern $IPRegex -AllMatches).Matches).Value | select @{N="IP";E={$_}} -Unique | Export-Csv $IPListFile -NoTypeInformation  #Out-File $IPListFile
}

Function New-LSIPs{
    Param
    (
        # IPList The list of IPs
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("I")] 
        $IPList
    )
    #include options for different formats of fake IPs
    
    #this could be made more efficient for larger files
    $RequiredLength = ((gc $IPList | measure -Line).Lines).ToString().Length
    $formatter = "{0:d"+$FakeIPLength+"}"
    $FakeIPList = $IPList+"Key"
    $IPNum = 0
    If(Test-Path $FakeIPList){rm $FakeIPList}

    'IP,FakeIP' | Out-File $FakeIPList
    Import-Csv $IPList | ForEach-Object {
        Add-Member -MemberType NoteProperty -InputObject $_ -Name FakeIP -Value ("<FakeIP{0:d$($RequiredLength)}>" -f $IPNum) -PassThru
        $IPNum++
    } | Export-Csv $FakeIPList -Force -NoTypeInformation
    rm $IPList
}

Function Set-LSIPs{
    Param
    (
        # LogFile The log to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $LogFile,
        # IPKeyList The list of IPs and fake IPs
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $IPKeyList
    )
    If(Test-Path ($LogFile+"-IPScrubbed")){rm ($LogFile+"-IPScrubbed")}

    $LogFileContents = gc $LogFile
    ForEach($line in (Import-Csv $IPKeyList)){
        $LogFileContents = $LogFileContents.Replace($line.IP,$Line.FakeIP)
    }
    $LogFileContents | Out-File ($LogFile+"-IPScrubbed")
}


Function Find-LSBadWords{
    Param
    (
        # LogFileName The path and name of the log file to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [Alias("Bad")] 
        $BadWordFile,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [Alias("BadKey")] 
        $BadWordKeyFile
    )
#    If(Test-Path ($LogFileName+"-BadWords")){rm ($LogFileName+"-BadWords") -Force}
    If(Test-Path $BadWordKeyFile){rm $BadWordKeyFile -Force}

    #$LogFileContents = gc $LogFileName
    $BadWords = @()
    #Import-Csv $BadWordFile -Header "Word"| % {$BadWords+=$_}
    gc $BadWordFile | %{$BadWords += $_}
    #Write-Host "bad words"
    #$BadWords
    ((gc $LogFileName | Select-String $BadWords -AllMatches).Matches).Value | select @{N="BadWord";E={$_}} -Unique | Export-Csv ($BadWordKeyFile <#$LogFileName+"-BadWords"#>) -NoTypeInformation
}

Function New-LSBadWords{
    Param
    (
        # LogFileName The path and name of the log file to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [Alias("Bad")] 
        $BadWordFile,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [Alias("BadKey")] 
        $BadWordKeyFile
    )
    #include options for different formats of fake bad words
    
    #this could be made more efficient for larger files
    $RequiredLength = ((gc $BadWordFile | measure -Line).Lines).ToString().Length
    $formatter = "{0:d"+$FakeIPLength+"}"
    #$BadWordKey = $LogFileName+"-BadWordKey"
    $BadWordNum = 0
    #If(Test-Path $BadWordKey){rm $BadWordKey}
    If(Test-Path $BadWordKeyFile){rm $BadWordKeyFile}

    #'BadWord,FakeBadWord' | Out-File $BadWordKey
    'BadWord,FakeBadWord' | Out-File $BadWordKeyFile
    Import-Csv $BadWordFile | ForEach {
        #write-host $_
        Add-Member -MemberType NoteProperty -InputObject $_ -Name FakeBadWord -Value ("<FakeBadWord{0:d$($RequiredLength)}>" -f $BadWordNum) -PassThru
        $BadWordNum++
    } | Export-Csv $BadWordKeyFile <# $BadWordKey#>  -NoTypeInformation

    #Write-Host "BadWordKeyFile = $BadWordKeyFile"
    #cat $BadWordKeyFile
    #Cat $BadWordKey
    #rm $BadWordFile

}


Function Set-LSBadWords{
    Param
    (
        # LogFile The log to scrub
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $LogFile,
        # IPKeyList The list of IPs and fake IPs
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        $BadWordsKeyList,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [Alias("BadKey")] 
        $BadWordKeyFile,
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$false,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [Alias("O")] 
        $OutputFileName
    )
    #If(Test-Path ($LogFile+"-BadWordScrubbed")){rm ($LogFile+"-BadWordScrubbed")}
    If(Test-Path $OutputFileName){rm $OutputFileName}
    #If(Test-Path $BadWordKeyFile){rm $BadWordKeyFile}

    $LogFileContents = gc $LogFile
    ForEach($line in (Import-Csv $BadWordKeyFile)){
        #Write-Host $Line
        #$LogFileContents = $LogFileContents.Replace($line.BadWord,$Line.FakeBadWord)
        $LogFileContents = $LogFileContents -Replace $line.BadWord, $Line.FakeBadWord
    }
    #Write-Host "OutputFileName = $OutputFileName"
    $LogFileContents | Out-File $OutputFileName #($LogFile+"-Scrubbed")
}

<#
.Synopsis
   Gets the IPs used by Log Scrubber
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-LSIPs
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("sun", "moon", "earth")]
        [Alias("p1")] 
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0,5)]
        [int]
        $Param2,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]
        $Param3
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
        }
    }
    End
    {
    }
}