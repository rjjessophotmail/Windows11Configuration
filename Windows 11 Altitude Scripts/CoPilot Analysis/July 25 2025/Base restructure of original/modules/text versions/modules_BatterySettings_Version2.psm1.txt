<#
.SYNOPSIS
    Configures system battery thresholds, notifications, and critical actions.

.DESCRIPTION
    Sets battery low/critical/reserve thresholds and configures system actions for each event. 
    Helps ensure consistent battery management and user notification on Windows devices.

.EXPORTS
    Set-BatterySettings
#>

function Set-BatterySettings {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [int]$LowLevel = 20,          # Low battery threshold (%)
        [Parameter(Mandatory=$false)]
        [int]$CriticalLevel = 10,     # Critical battery threshold (%)
        [Parameter(Mandatory=$false)]
        [int]$ReserveLevel = 7        # Reserve battery threshold (%)
    )

    Write-Host "Configuring battery thresholds and actions..." -ForegroundColor Green

    # Get the current power scheme (active GUID)
    $scheme = (powercfg /getactivescheme) -replace '.*: ([a-f0-9\-]+) .*','$1'

    try {
        # Set battery thresholds (AC and DC, for good measure)
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATACTIONCRIT $CriticalLevel
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATACTIONLOW $LowLevel
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATACTIONRES $ReserveLevel

        # Set actions for low/critical/reserve battery events
        # (1 = Sleep, 2 = Hibernate, 0 = Do nothing, 3 = Shut down)
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATACTIONCRIT 2   # Hibernate at critical
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATACTIONLOW 1    # Sleep at low
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATACTIONRES 0    # No action at reserve

        # Enable battery notifications
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATNOTIFYCRIT 1
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATNOTIFYLOW 1
        powercfg /SETDCVALUEINDEX $scheme SUB_BATTERY BATNOTIFYRES 1

        Write-Host "Battery thresholds and notifications set."
    } catch {
        Write-Warning "Failed to set one or more battery thresholds or actions."
    }

    # Add additional battery-related settings as needed below
    # ...
}

Export-ModuleMember -Function Set-BatterySettings