function Invoke-TimeSettings {
    Write-Host "Configuring time and region settings..." -ForegroundColor Yellow
    # Example: Set time zone to Pacific Standard Time
    Set-TimeZone -Id "Pacific Standard Time"
    # Set Windows to synchronize time automatically
    w32tm /resync
    Write-Host "Time and region settings configured." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-TimeSettings