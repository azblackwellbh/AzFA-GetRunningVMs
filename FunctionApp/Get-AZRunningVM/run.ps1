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
    $Header + "<b>ALL VM'S IN THIS SUBSCRIPTION AUTO SHUT DOWN AT 7 PM AND START UP AT 6 AM EST DAILY!</b> <p> The Following VMs are not running <p>" + $NotRunningVmsHTML + "<p> To request a VM be turned on, email the name of the VM in the subject line to <a href=`"mailto:support_afcent_cloud_dl@afcentcloud.mil?Subject=Please%20turn%20on%20VM%20`">Support</a>. <p>" + "The Following VMs are currently running <p>" + $RunningVmsHTML

}
$HTML = Get-RunningVmHTML

Push-OutputBinding -Name Response -Value (@{
        StatusCode  = "ok"
        ContentType = "text/html"
        Body        = $HTML
    })



