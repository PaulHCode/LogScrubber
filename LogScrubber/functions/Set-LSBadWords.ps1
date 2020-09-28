Function Set-LSBadWords {
    <#
.SYNOPSIS
    Generates fake bad words to replace real bad words in the log file
.DESCRIPTION
    
.PARAMETER LogFileName
The path\name of the log file to scrub
.PARAMETER BadWordsKeyList

.PARAMETER BadWordKeyFile
The path\name to output the BadWordKeyFile to
.PARAMETER OutputFileName

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
        # LogFile The log to scrub
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        $LogFile,
        # IPKeyList The list of IPs and fake IPs
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        $BadWordsKeyList,
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $false,
            Position = 2)]
        [ValidateNotNullOrEmpty()]
        [Alias("BadKey")] 
        $BadWordKeyFile,
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $false,
            Position = 2)]
        [ValidateNotNullOrEmpty()]
        [Alias("O")] 
        $OutputFileName
    )
    #If(Test-Path ($LogFile+"-BadWordScrubbed")){rm ($LogFile+"-BadWordScrubbed")}
    If (Test-Path $OutputFileName) { Remove-Item $OutputFileName }
    #If(Test-Path $BadWordKeyFile){rm $BadWordKeyFile}

    $LogFileContents = Get-Content $LogFile
    ForEach ($line in (Import-Csv $BadWordKeyFile)) {
        #Write-Host $Line
        #$LogFileContents = $LogFileContents.Replace($line.BadWord,$Line.FakeBadWord)
        $LogFileContents = $LogFileContents -Replace $line.BadWord, $Line.FakeBadWord
    }
    #Write-Host "OutputFileName = $OutputFileName"
    $LogFileContents | Out-File $OutputFileName #($LogFile+"-Scrubbed")
}