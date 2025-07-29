function Invoke-MaintenanceTasks {
    Write-Host "Configuring maintenance tasks..." -ForegroundColor Yellow
    # Example: Disable scheduled defrag if using SSD
    $ssd = Get-PhysicalDisk | Where-Object MediaType -eq 'SSD'
    if ($ssd) {
        Disable-ScheduledTask -TaskName 'Microsoft\Windows\Defrag\ScheduledDefrag' -ErrorAction SilentlyContinue
    }
    # Enable Storage Sense
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Value 1 -Force
    Write-Host "Maintenance tasks configured." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-MaintenanceTasks