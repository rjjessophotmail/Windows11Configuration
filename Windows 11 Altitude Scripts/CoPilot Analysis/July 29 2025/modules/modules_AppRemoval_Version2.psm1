function Invoke-AppRemoval {
    Write-Host "Removing unwanted preinstalled apps..." -ForegroundColor Yellow
    # Example: Remove Xbox and other unwanted apps
    $apps = @(
        "Microsoft.XboxGameCallableUI",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxApp"
    )
    foreach ($app in $apps) {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
    Write-Host "Unwanted apps removed." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-AppRemoval