Function Invoke-LSBadWordScrub {
    <#
.SYNOPSIS
.DESCRIPTION
.PARAMETER ScriptBlock
.PARAMETER LogFileName
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
        $BadWordKeyFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 3)]
        [ValidateNotNullOrEmpty()]
        $OriginalLogFileName
    )

    Find-LSBadWords -LogFileName $LogFileName -BadWordFile $BadWordFile -BadWordKeyFile $BadWordKeyFile
    New-LSBadWords -LogFileName $LogFileName -BadWordFile $BadWordFile -BadWordKeyFile $BadWordKeyFile
    Set-LSBadWords -LogFile $LogFileName -BadWordsKeyList $BadWordKeyFile -BadWordKeyFile $BadWordKeyFile -OutputFileName ($OriginalLogFileName + "-Scrubbed")


}
