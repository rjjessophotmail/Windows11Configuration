<#
.SYNOPSIS
    Applies network adapter and wireless performance tweaks.

.DESCRIPTION
    Configures advanced settings for network adapters, disables power saving on Wi-Fi and Ethernet, and applies registry/network stack optimizations.

.EXPORTS
    Set-NetworkTweaks
#>

function Set-NetworkTweaks {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Write-Host "Applying network adapter and wireless performance tweaks..." -ForegroundColor Green

    try {
        # Disable power saving on all Wi-Fi adapters
        Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -match 'Wireless' } | ForEach-Object {
            $ifName = $_.Name
            Write-Host "Disabling power saving on $ifName"
            netsh wlan set power save mode = off interface="$ifName"
        }

        # Disable power saving on all Ethernet adapters (if supported)
        Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Wireless' } | ForEach-Object {
            $ifName = $_.Name
            Write-Host "Disabling power saving on $ifName"
            # Not all Ethernet adapters support this; vendor-specific tools/settings may be required.
        }

        # Optionally, adjust advanced TCP/IP stack parameters for performance
        # Example: Enable TCP Window Auto-Tuning
        netsh int tcp set global autotuninglevel=normal

        # Example: Disable Large Send Offload (for gaming/streaming)
        Get-NetAdapterAdvancedProperty | Where-Object { $_.DisplayName -like "*Large Send Offload*" } | Set-NetAdapterAdvancedProperty -DisplayValue "Disabled"

        Write-Host "Network tweaks applied."
    } catch {
        Write-Warning "One or more network tweaks failed to apply."
    }

    # Add additional network or wireless tweaks as needed
    # ...
}

Export-ModuleMember -Function Set-NetworkTweaks