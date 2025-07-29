<#
.SYNOPSIS
    Configures display and multimedia-related power settings.

.DESCRIPTION
    Sets timeouts and behaviors for display power, dimming, adaptive brightness, multimedia playback, and screen saver features.

.EXPORTS
    Set-DisplayAndMultimedia
#>

function Set-DisplayAndMultimedia {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [int]$DisplayTimeoutAC = 30,   # Minutes before display turns off (AC)
        [Parameter(Mandatory=$false)]
        [int]$DisplayTimeoutDC = 10,   # Minutes before display turns off (Battery)
        [Parameter(Mandatory=$false)]
        [int]$DimTimeoutAC = 5,        # Minutes before display dims (AC)
        [Parameter(Mandatory=$false)]
        [int]$DimTimeoutDC = 2,        # Minutes before display dims (Battery)
        [Parameter(Mandatory=$false)]
        [int]$BrightnessAC = 100,      # Brightness level (AC)
        [Parameter(Mandatory=$false)]
        [int]$BrightnessDC = 80        # Brightness level (Battery)
    )

    Write-Host "Configuring display and multimedia power settings..." -ForegroundColor Green

    # Get the current power scheme (active GUID)
    $scheme = (powercfg /getactivescheme) -replace '.*: ([a-f0-9\-]+) .*','$1'

    try {
        # Set display turn-off timeouts
        powercfg /SETACVALUEINDEX $scheme SUB_VIDEO VIDEOIDLE ($DisplayTimeoutAC * 60)
        powercfg /SETDCVALUEINDEX $scheme SUB_VIDEO VIDEOIDLE ($DisplayTimeoutDC * 60)

        # Set display dim timeouts (if supported)
        powercfg /SETACVALUEINDEX $scheme SUB_VIDEO VIDEODIM ($DimTimeoutAC * 60)
        powercfg /SETDCVALUEINDEX $scheme SUB_VIDEO VIDEODIM ($DimTimeoutDC * 60)

        # Set display brightness
        powercfg /SETACVALUEINDEX $scheme SUB_VIDEO ADAPTBRIGHT 0
        powercfg /SETDCVALUEINDEX $scheme SUB_VIDEO ADAPTBRIGHT 0

        powercfg /SETACVALUEINDEX $scheme SUB_VIDEO VIDEOBRIGHTNESS $BrightnessAC
        powercfg /SETDCVALUEINDEX $scheme SUB_VIDEO VIDEOBRIGHTNESS $BrightnessDC

        # Set multimedia playback to prevent sleep (AC and DC)
        powercfg /SETACVALUEINDEX $scheme SUB_VIDEO MULTIMEDIA 2
        powercfg /SETDCVALUEINDEX $scheme SUB_VIDEO MULTIMEDIA 2

        # Disable screen saver timeout (set to zero)
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveTimeOut" -Value "0"

        Write-Host "Display, brightness, and multimedia settings applied."
    } catch {
        Write-Warning "Failed to set one or more display or multimedia settings."
    }

    # Add additional display or multimedia settings below as needed
    # ...
}

Export-ModuleMember -Function Set-DisplayAndMultimedia