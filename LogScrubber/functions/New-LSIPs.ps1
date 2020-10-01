Function New-LSIPs {
    <#
.SYNOPSIS
Generates a list of Fake IPs to match with each IP taken out of the log file
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
        # IPList The list of IPs
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        $IPList
    )
    #include options for different formats of fake IPs
    
    #this could be made more efficient for larger files
    $RequiredLength = ((Get-Content $IPList | Measure-Object -Line).Lines).ToString().Length
    #$formatter = "{0:d" + $FakeIPLength + "}"
    $FakeIPList = $IPList + "Key"
    $IPNum = 0
    If (Test-Path $FakeIPList) { Remove-Item $FakeIPList }

    'IP,FakeIP' | Out-File $FakeIPList
    Import-Csv $IPList | ForEach-Object {
        Add-Member -MemberType NoteProperty -InputObject $_ -Name FakeIP -Value ("<FakeIP{0:d$($RequiredLength)}>" -f $IPNum) -PassThru
        $IPNum++
    } | Export-Csv $FakeIPList -Force -NoTypeInformation
    Remove-Item $IPList
}