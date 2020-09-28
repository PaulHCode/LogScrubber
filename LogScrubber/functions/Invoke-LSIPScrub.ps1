

Function Invoke-LSIPScrub {
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
        $LogFileName
    )

    Find-LSIPs -LogFileName $LogFileName
    New-LSIPs -IPList ($LogFileName + "-IPs")
    Set-LSIPs -LogFile $LogFileName -IPKeyList ($LogFileName + "-IPsKey")
    
    Write-Host "Original Log: $LogFileName"
    Write-Host "IP Key: " ($LogFileName + "-IPsKey")
    #Write-Host "Scrubbed Log: " ($LogFileName+"-IPScrubbed")
}