<#
.SYNOPSIS
    Applies privacy and telemetry reduction tweaks to Windows.

.DESCRIPTION
    Disables or restricts diagnostics, feedback, advertising, and data collection features for improved privacy. Applies registry and scheduled task changes where appropriate.

.EXPORTS
    Set-PrivacyTweaks
#>

function Set-PrivacyTweaks {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Write-Host "Applying privacy and telemetry reduction tweaks..." -ForegroundColor Green

    try {
        # Disable Telemetry (Windows 10/11 Pro/Enterprise/Education)
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord

        # Disable Feedback frequency
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -Value 0 -Type DWord

        # Disable Tailored Experiences
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Value 1 -Type DWord

        # Disable Advertising ID
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1 -Type DWord

        # Disable Cortana
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord

        # Disable location tracking
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -Type DWord

        # Disable Activity History
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Type DWord

        # Disable WiFi Sense (public hotspot auto-connect, sharing)
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Value 0 -Type DWord
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Value 0 -Type DWord

        # Remove scheduled telemetry tasks
        $tasks = @(
            "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
            "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
            "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
            "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
        )
        foreach ($task in $tasks) {
            try {
                Unregister-ScheduledTask -TaskPath $task -Confirm:$false -ErrorAction SilentlyContinue
            } catch {}
        }

        Write-Host "Privacy and telemetry tweaks applied."
    } catch {
        Write-Warning "Failed to apply one or more privacy tweaks."
    }

    # Add additional privacy-related registry or policy settings below as needed
    # ...
}

Export-ModuleMember -Function Set-PrivacyTweaks