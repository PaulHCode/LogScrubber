
Function Set-LSIPs {
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