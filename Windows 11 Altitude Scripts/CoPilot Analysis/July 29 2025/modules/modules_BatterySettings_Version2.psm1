function Invoke-BatterySettings {
    Write-Host "Applying battery optimization settings..." -ForegroundColor Yellow
    # Example: Set battery saver threshold and enable battery saver
    powercfg /change standby-timeout-dc 10   # Sleep when on battery after 10 mins
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 20
    powercfg /setactive SCHEME_CURRENT
    Write-Host "Battery settings applied." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-BatterySettings