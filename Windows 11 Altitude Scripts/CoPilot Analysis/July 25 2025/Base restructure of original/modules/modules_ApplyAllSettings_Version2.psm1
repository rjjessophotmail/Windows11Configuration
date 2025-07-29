<#
.SYNOPSIS
    Runs all optimization and configuration modules in sequence for a complete system setup.

.DESCRIPTION
    Invokes all primary configuration functions: power, battery, display, sleep, performance, network, privacy, update control, app removal, and maintenance. Intended as a one-step setup for new Windows installations or post-upgrade tuning.

.EXPORTS
    Apply-AllSettings
#>

function Apply-AllSettings {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [string]$PowerPlan = "High Performance",
        [Parameter(Mandatory=$false)]
        [switch]$DisableAutomaticMaintenance,
        [Parameter(Mandatory=$false)]
        [switch]$EnableCustomCleanupTask,
        [Parameter(Mandatory=$false)]
        [switch]$DisableStore
    )

    Write-Host "Applying all system configuration and optimization modules..." -ForegroundColor Cyan

    # Import all required modules (assumes scripts are in the same directory or imported elsewhere)
    Import-Module "$PSScriptRoot\PowerPlan.psm1" -Force
    Import-Module "$PSScriptRoot\BatterySettings.psm1" -Force
    Import-Module "$PSScriptRoot\DisplayAndMultimedia.psm1" -Force
    Import-Module "$PSScriptRoot\SleepAndHibernate.psm1" -Force
    Import-Module "$PSScriptRoot\PerformanceTweaks.psm1" -Force
    Import-Module "$PSScriptRoot\NetworkTweaks.psm1" -Force
    Import-Module "$PSScriptRoot\PrivacyTweaks.psm1" -Force
    Import-Module "$PSScriptRoot\UpdateControl.psm1" -Force
    Import-Module "$PSScriptRoot\AppRemoval.psm1" -Force
    Import-Module "$PSScriptRoot\MaintenanceTasks.psm1" -Force

    # Apply each configuration step in sequence
    Set-AltitudePowerPlan -PowerPlan $PowerPlan
    Set-BatterySettings
    Set-DisplayAndMultimedia
    Set-SleepAndHibernate
    Set-PerformanceTweaks
    Set-NetworkTweaks
    Set-PrivacyTweaks
    Set-UpdateControl
    Set-AppRemoval -DisableStore:$DisableStore
    Set-MaintenanceTasks -DisableAutomaticMaintenance:$DisableAutomaticMaintenance -EnableCustomCleanupTask:$EnableCustomCleanupTask

    Write-Host "All settings applied. Please reboot your system for all changes to take effect." -ForegroundColor Green
}

Export-ModuleMember -Function Apply-AllSettings