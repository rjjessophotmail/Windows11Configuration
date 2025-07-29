function Invoke-NetworkTweaks {
    Write-Host "Applying network tweaks..." -ForegroundColor Yellow
    # Example: Disable SMBv1, enable DNS over HTTPS
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
    # Enable DNS over HTTPS (DoH) if supported
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "EnableAutoDoh" -Value 2 -Force
    Write-Host "Network tweaks applied." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-NetworkTweaks