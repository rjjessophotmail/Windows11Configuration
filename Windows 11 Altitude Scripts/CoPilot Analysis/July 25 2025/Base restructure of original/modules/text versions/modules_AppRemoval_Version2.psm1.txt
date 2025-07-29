<#
.SYNOPSIS
    Removes or disables unwanted built-in and preinstalled apps ("bloatware") from Windows 11.

.DESCRIPTION
    Uninstalls selected Microsoft Store apps, disables their reinstallation, and optionally disables Microsoft Store access.

.EXPORTS
    Set-AppRemoval
#>

function Set-AppRemoval {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [string[]]$AppsToRemove = @(
            "Microsoft.ZuneMusic",         # Groove Music
            "Microsoft.ZuneVideo",         # Movies & TV
            "Microsoft.BingWeather",
            "Microsoft.XboxApp",
            "Microsoft.XboxGameOverlay",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.Xbox.TCUI",
            "Microsoft.XboxIdentityProvider",
            "Microsoft.XboxGameCallableUI",
            "Microsoft.People",
            "Microsoft.Microsoft3DViewer",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.OneConnect",
            "Microsoft.SkypeApp",
            "Microsoft.Wallet",
            "Microsoft.WindowsAlarms",
            "Microsoft.WindowsCamera",
            "Microsoft.WindowsCommunicationsApps",
            "Microsoft.WindowsFeedbackHub",
            "Microsoft.WindowsMaps",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.YourPhone",
            "Microsoft.MSPaint",
            "Microsoft.ScreenSketch",
            "Microsoft.MixedReality.Portal",
            "Microsoft.GamingApp",
            "Microsoft.Todos",
            "Microsoft.Whiteboard"
        ),
        [Parameter(Mandatory=$false)]
        [switch]$DisableStore
    )

    Write-Host "Removing unwanted built-in and provisioned apps..." -ForegroundColor Green

    foreach ($app in $AppsToRemove) {
        try {
            # Remove for current user
            Get-AppxPackage -Name $app -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            # Remove provisioned app (for future users)
            Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
            Write-Host "Removed $app"
        } catch {
            Write-Warning "Failed to remove $app"
        }
    }

    if ($DisableStore) {
        try {
            # Disable Microsoft Store via group policy (works on Pro/Enterprise/Education)
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RemoveWindowsStore" -Value 1 -Type DWord
            Write-Host "Microsoft Store access disabled."
        } catch {
            Write-Warning "Failed to disable Microsoft Store."
        }
    }

    # Optionally: Prevent auto-reinstallation of removed apps
    try {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord
        Write-Host "Prevention of auto-reinstall of removed apps enabled."
    } catch {
        Write-Warning "Failed to set app auto-reinstall prevention."
    }
}

Export-ModuleMember -Function Set-AppRemoval