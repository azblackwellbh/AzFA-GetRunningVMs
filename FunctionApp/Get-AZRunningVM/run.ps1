using namespace System.Net

# Input bindings are passed in via param block.
param($Request)
Function Get-RunningVM {
    get-Azvm -Status | Where-Object { $_.PowerState -eq "VM running" }
}
Function Get-RunningVmHTML {
    # HTML header for a nice look
    $Header = @"
<style>
BODY {font-family:verdana;}
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px; background-color: #d1c3cd;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px}
</style>
"@

    # Get all Deallocated VMs
    $NotRunningVMs = get-Azvm -Status | where-object { $_.PowerState -eq "VM Deallocated" }
    $NotRunningVmsHTML = $NotRunningVMs | ConvertTo-Html -property "ResourceGroupName", "Name", "OsType", "PowerState"

    $RunningVMs = get-Azvm -Status | where-object { $_.PowerState -eq "VM Running" }
    $RunningVmsHTML = $RunningVMs | ConvertTo-Html -property "ResourceGroupName", "Name", "OsType", "PowerState"

    # Combine HTML elements for output
    $Header + "The Following VMs are not running <p>" + $NotRunningVmsHTML
    $Header + "The Following VMs are currently running <p>" + $RunningVmsHTML

}
$HTML = Get-RunningVmHTML

Push-OutputBinding -Name Response -Value (@{
        StatusCode  = "ok"
        ContentType = "text/html"
        Body        = $HTML
    })



