<#
.SYNOPSIS
    Applies system and gaming performance tweaks.

.DESCRIPTION
    Sets registry and system settings to optimize Windows for multimedia/gaming responsiveness, reduce latency, and improve system performance. Includes tweaks for MMCSS, GPU prioritization, and related parameters.

.EXPORTS
    Set-PerformanceTweaks
#>

function Set-PerformanceTweaks {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Write-Host "Applying system and gaming performance tweaks..." -ForegroundColor Green

    try {
        # Multimedia Class Scheduler Service (MMCSS) tweaks for gaming/multimedia
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 10
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF

        # GPU Priority Tweaks
        $gpuprofile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
        New-Item -Path $gpuprofile -Force | Out-Null
        Set-ItemProperty -Path $gpuprofile -Name "GPU Priority" -Value 8
        Set-ItemProperty -Path $gpuprofile -Name "Priority" -Value 6
        Set-ItemProperty -Path $gpuprofile -Name "Scheduling Category" -Value "High"
        Set-ItemProperty -Path $gpuprofile -Name "SFIO Priority" -Value "High"

        # JavaScript Timer Frequency (for low-latency scenarios)
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" -Name "explorer.exe" -Value 10

        # Optionally, you can add tweaks for disabling core parking, etc.
        # Note: Modern Windows manages this well automatically.

        Write-Host "Performance tweaks applied."
    } catch {
        Write-Warning "One or more performance tweaks failed to apply."
    }

    # Add additional performance or latency-related settings as needed
    # ...
}

Export-ModuleMember -Function Set-PerformanceTweaks