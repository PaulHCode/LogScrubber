Function Clear-LSScrubFiles {
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
    Param(
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias("N")] 
        $LogFileName
    )
    Remove-Item -Force ($LogFileName + "-IPScrubbed"), ($LogFileName + "-IPScrubbed-Scrubbed"), ($LogFileName + "-IPsKey"), ($LogFileName + "-BadWordKey"), ($LogFileName + "-Scrubbed") -ea 0
}
