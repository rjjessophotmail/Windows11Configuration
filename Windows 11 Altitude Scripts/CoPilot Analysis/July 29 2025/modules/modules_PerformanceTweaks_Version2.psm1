function Invoke-PerformanceTweaks {
    Write-Host "Applying performance tweaks..." -ForegroundColor Yellow
    # Example: Disable visual effects for best performance
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 2 -Force
    # Set processor scheduling to programs
    Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 26 -Force
    Write-Host "Performance tweaks applied." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-PerformanceTweaks