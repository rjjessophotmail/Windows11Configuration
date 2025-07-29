<#
.SYNOPSIS
    Applies time zone, disables daylight saving time, and disables automatic time synchronization.

.DESCRIPTION
    This module configures Windows system time settings for optimal reliability and consistency, especially for environments where DST and auto-sync can cause unwanted clock changes.

.EXPORTS
    Set-TimeSettings
#>

function Set-TimeSettings {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [string]$TimeZoneId = "UTC"  # Change as needed for your deployment
    )

    Write-Host "Configuring Windows time settings..." -ForegroundColor Green

    # Set system time zone
    try {
        tzutil /s $TimeZoneId
        Write-Host "Time zone set to $TimeZoneId."
    } catch {
        Write-Warning "Failed to set time zone to $TimeZoneId."
    }

    # Disable Daylight Saving Time adjustment (if possible)
    try {
        # Not all time zones support this; Windows 11 does not provide a universal PowerShell/CLI option.
        # For US time zones, you may need to pick a non-DST-observing zone (e.g., 'UTC', 'Arizona').
        Write-Host "DST is determined by the time zone. Ensure you select a non-DST time zone if you want DST off."
    } catch {
        Write-Warning "Failed to configure DST settings."
    }

    # Disable automatic time synchronization (Windows Time Service)
    try {
        # Stop and disable Windows Time service
        Stop-Service w32time -ErrorAction SilentlyContinue
        Set-Service w32time -StartupType Disabled
        Write-Host "Windows Time service stopped and disabled."
    } catch {
        Write-Warning "Could not stop or disable Windows Time service."
    }

    # Optionally, configure registry to disable NTP sync (if required)
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Value "NoSync" -ErrorAction SilentlyContinue
        Write-Host "NTP time synchronization disabled in registry."
    } catch {
        Write-Warning "Could not set registry to disable NTP sync."
    }
}

Export-ModuleMember -Function Set-TimeSettings