Function New-LSBadWords {
    <#
.SYNOPSIS
    Generates fake bad words to replace real bad words in the log file
.DESCRIPTION
    
.PARAMETER LogFileName
The path\name of the log file to scrub
.PARAMETER BadWordFile
The path\name of the BadWordFile generated by Find-LSBadWords
.PARAMETER BadWordKeyFile
The path\name to output the BadWordKeyFile to
.EXAMPLE
.EXAMPLE
.INPUTS
    [string]
.OUTPUTS
.NOTES
    Author:  Paul Harrison
#>
    Param
    (
        # LogFileName The path and name of the log file to scrub
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName,
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $false,
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias("Bad")] 
        $BadWordFile,
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $false,
            Position = 2)]
        [ValidateNotNullOrEmpty()]
        [Alias("BadKey")] 
        $BadWordKeyFile
    )
    #include options for different formats of fake bad words
    
    #this could be made more efficient for larger files
    $RequiredLength = ((Get-Content $BadWordFile | Measure-Object -Line).Lines).ToString().Length
    $formatter = "{0:d" + $FakeIPLength + "}"
    #$BadWordKey = $LogFileName+"-BadWordKey"
    $BadWordNum = 0
    #If(Test-Path $BadWordKey){rm $BadWordKey}
    If (Test-Path $BadWordKeyFile) { Remove-Item $BadWordKeyFile }

    #'BadWord,FakeBadWord' | Out-File $BadWordKey
    'BadWord,FakeBadWord' | Out-File $BadWordKeyFile
    Import-Csv $BadWordFile | ForEach-Object {
        #write-host $_
        Add-Member -MemberType NoteProperty -InputObject $_ -Name FakeBadWord -Value ("<FakeBadWord{0:d$($RequiredLength)}>" -f $BadWordNum) -PassThru
        $BadWordNum++
    } | Export-Csv $BadWordKeyFile <# $BadWordKey#>  -NoTypeInformation

    #Write-Host "BadWordKeyFile = $BadWordKeyFile"
    #cat $BadWordKeyFile
    #Cat $BadWordKey
    #rm $BadWordFile

}
