Function Invoke-LSScrub {
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
        [Parameter(Mandatory = $false, 
            ValueFromPipeline = $false,
            Position = 1)]
        [Alias("Bad")] 
        $BadWordFile
    )
    
    Invoke-LSIPScrub -LogFileName $LogFileName
    If (Test-Path $BadWordFile) {
        Invoke-LSBadWordScrub -LogFileName ($LogFileName + "-IPScrubbed") -BadWordFile $BadWordFile -BadWordKeyFile ($LogFileName + "-BadWordKey") -OriginalLogFileName $LogFileName
        Write-Host "BadWord KeyFile: $LogFileName-BadWordKey"
        Write-Host "Scrubbed Log: $LogFileName-Scrubbed"
    }
    Else {
        Write-Host "No BadWordFile entered or file does not exist, only IPs scrubbed, not bad words."
        Write-Host "Log file with only IPs scrubbed: $LogFileName-IPScrubbed"        
    }

}