Function Set-LSIPs {
    <#
.SYNOPSIS
Replaces the IPs in $LogFile with the Fake IPs in $IPKeyList then outputs the result to $LogFile-IPScrubbed
.DESCRIPTION
.PARAMETER LogFile
The name of the unmodified log file
.PARAMETER IPKeyList
The name of the unmodified IPKeyList
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
        $IPKeyList
    )
    If (Test-Path ($LogFile + "-IPScrubbed")) { Remove-Item ($LogFile + "-IPScrubbed") }

    $LogFileContents = Get-Content $LogFile
    ForEach ($line in (Import-Csv $IPKeyList)) {
        $LogFileContents = $LogFileContents.Replace($line.IP, $Line.FakeIP)
    }
    $LogFileContents | Out-File ($LogFile + "-IPScrubbed")
}