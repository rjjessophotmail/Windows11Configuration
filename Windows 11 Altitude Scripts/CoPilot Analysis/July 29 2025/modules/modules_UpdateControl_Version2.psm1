function Invoke-UpdateControl {
    Write-Host "Configuring update control..." -ForegroundColor Yellow
    # Example: Set Windows Updates to notify before download and install
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
        -Name "AUOptions" -Value 2 -Force
    Write-Host "Update control settings applied." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-UpdateControl