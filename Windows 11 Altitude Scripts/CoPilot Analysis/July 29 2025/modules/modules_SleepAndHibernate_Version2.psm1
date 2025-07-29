function Invoke-SleepAndHibernate {
    Write-Host "Configuring sleep and hibernate settings..." -ForegroundColor Yellow
    # Example: Disable hibernate and adjust sleep settings
    powercfg /hibernate off
    powercfg /change standby-timeout-ac 20
    powercfg /change standby-timeout-dc 10
    Write-Host "Sleep and hibernate settings configured." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-SleepAndHibernate