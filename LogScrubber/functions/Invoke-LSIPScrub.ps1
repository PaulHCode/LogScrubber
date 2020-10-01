Function Invoke-LSIPScrub {
    <#
.SYNOPSIS
Scrubs the IPs from $LogFileName
.DESCRIPTION
This command generates a list of IPs in the log file as well as a list 
of fake IPs associated with them then outputs a copy of a log file with 
the IPs replaced with the fake IPs.  

If an IP appears multiple times in the log file then it is replaced with
the same fake IP each time.
.PARAMETER LogFileName
The name of the log file to scrub.
.EXAMPLE
    Invoke-LSIPScrub -LogFileName MyLog.txt
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
    
    Write-Verbose "Original Log: $LogFileName"
    Write-Verbose "IP Key: " ($LogFileName + "-IPsKey")
    Write-Verbose "Scrubbed Log: " ($LogFileName + "-IPScrubbed")
}