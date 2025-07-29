<#
.SYNOPSIS
    Configures the system power plan and applies advanced power settings.

.DESCRIPTION
    This module selects the preferred power plan (e.g., High Performance), and sets detailed power options using powercfg and registry tweaks according to organizational standards.

.EXPORTS
    Set-AltitudePowerPlan
#>

function Set-AltitudePowerPlan {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("High Performance", "Balanced", "Power Saver")]
        [string]$PowerPlan = "High Performance"
    )

    Write-Host "Configuring system power plan and advanced power options..." -ForegroundColor Green

    # Select the base power plan
    $planGuid = switch ($PowerPlan) {
        "High Performance" { "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" }
        "Balanced"         { "381b4222-f694-41f0-9685-ff5bb260df2e" }
        "Power Saver"      { "a1841308-3541-4fab-bc81-f71556f20b4a" }
        default            { "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" }
    }
    try {
        powercfg /S $planGuid
        Write-Host "Power plan set to $PowerPlan."
    } catch {
        Write-Warning "Could not set $PowerPlan power plan."
    }

    # Example advanced power options (expand or modify as needed)
    try {
        # Set display turn off timeout (AC: 30 min, DC: 10 min)
        powercfg /SETACVALUEINDEX $planGuid SUB_VIDEO VIDEOIDLE 1800
        powercfg /SETDCVALUEINDEX $planGuid SUB_VIDEO VIDEOIDLE 600

        # Set sleep after (AC: Never, DC: 30 min)
        powercfg /SETACVALUEINDEX $planGuid SUB_SLEEP STANDBYIDLE 0
        powercfg /SETDCVALUEINDEX $planGuid SUB_SLEEP STANDBYIDLE 1800

        Write-Host "Advanced power settings applied."
    } catch {
        Write-Warning "Failed to apply advanced power settings."
    }

    # Add additional powercfg or registry tweaks for your org below as needed
    # ...

}

Export-ModuleMember -Function Set-AltitudePowerPlan