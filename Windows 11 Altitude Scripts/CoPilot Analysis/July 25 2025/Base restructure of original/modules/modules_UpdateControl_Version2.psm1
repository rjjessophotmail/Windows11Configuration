<#
.SYNOPSIS
    Configures Windows Update settings for greater control and reduced interruptions.

.DESCRIPTION
    Applies policies to defer, pause, or disable Windows updates, automatic restarts, driver updates, and related behaviors. Useful for managed or optimized deployment environments.

.EXPORTS
    Set-UpdateControl
#>

function Set-UpdateControl {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("Disable", "Defer", "Default")]
        [string]$WindowsUpdatePolicy = "Defer",
        [Parameter(Mandatory=$false)]
        [int]$DeferFeatureUpdatesDays = 30,
        [Parameter(Mandatory=$false)]
        [int]$DeferQualityUpdatesDays = 14
    )

    Write-Host "Applying Windows Update control and deferral settings..." -ForegroundColor Green

    try {
        # Disable automatic driver updates
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Value 0 -Type DWord

        # Disable automatic restarts for updates
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord

        switch ($WindowsUpdatePolicy) {
            "Disable" {
                # Completely disable Windows Update
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -Type DWord
                Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
                Set-Service -Name wuauserv -StartupType Disabled
                Write-Host "Windows Update disabled."
            }
            "Defer" {
                # Enable update deferral
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdates" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdatesPeriodInDays" -Value $DeferFeatureUpdatesDays -Type DWord
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdates" -Value 1 -Type DWord
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdatesPeriodInDays" -Value $DeferQualityUpdatesDays -Type DWord
                Write-Host "Windows Update deferral applied: $DeferFeatureUpdatesDays days (feature), $DeferQualityUpdatesDays days (quality)."
            }
            "Default" {
                # Remove custom policies, revert to default update behavior
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdates" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdates" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdatesPeriodInDays" -ErrorAction SilentlyContinue
                Set-Service -Name wuauserv -StartupType Automatic
                Start-Service -Name wuauserv -ErrorAction SilentlyContinue
                Write-Host "Windows Update settings reverted to default."
            }
        }

        # Additional recommended tweaks:
        # Disable automatic update for Microsoft Store apps
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "AutoDownload" -Value 2 -Type DWord

        Write-Host "Update control policies applied."
    } catch {
        Write-Warning "Failed to apply one or more update control settings."
    }

    # Add additional update/patch management tweaks as needed
    # ...
}

Export-ModuleMember -Function Set-UpdateControl