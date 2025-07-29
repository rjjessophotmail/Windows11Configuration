function Invoke-PrivacyTweaks {
    Write-Host "Applying privacy tweaks..." -ForegroundColor Yellow
    # Example: Disable advertising ID, feedback, and telemetry
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Force
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0 -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
    Write-Host "Privacy tweaks applied." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-PrivacyTweaks