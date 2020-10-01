Function Find-LSIPs {
    <#
.SYNOPSIS
Finds all IPs in $LogFileName and outputs them as a list to $LogFileName-IPs
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
    $IPListFile = $LogFileName + "-IPs"
    ((select-string -Path $LogFileName -Pattern $IPRegex -AllMatches).Matches).Value | Select-Object @{N = "IP"; E = { $_ } } -Unique | Export-Csv $IPListFile -NoTypeInformation  #Out-File $IPListFile
}
