Function Find-LSBadWords {
    <#
.SYNOPSIS
    Finds bad words in the log file
.DESCRIPTION
    Find all words from $BadWordFile that are in $LogFileName then output them to $BadWordKeyFile
.PARAMETER LogFileName
.PARAMETER BadWordFile
.PARAMETER BadWordKeyFile
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
        $LogFileName,
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $false,
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        $BadWordFile,
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $false,
            Position = 2)]
        [ValidateNotNullOrEmpty()]
        $BadWordKeyFile
    )
    #    If(Test-Path ($LogFileName+"-BadWords")){rm ($LogFileName+"-BadWords") -Force}
    If (Test-Path $BadWordKeyFile) { Remove-Item $BadWordKeyFile -Force }

    #$LogFileContents = gc $LogFileName
    $BadWords = @()
    #Import-Csv $BadWordFile -Header "Word"| % {$BadWords+=$_}
    Get-Content $BadWordFile | ForEach-Object { $BadWords += $_ }
    #Write-Host "bad words"
    #$BadWords
    ((Get-Content $LogFileName | Select-String $BadWords -AllMatches).Matches).Value | Select-Object @{N = "BadWord"; E = { $_ } } -Unique | Export-Csv ($BadWordKeyFile <#$LogFileName+"-BadWords"#>) -NoTypeInformation
}
