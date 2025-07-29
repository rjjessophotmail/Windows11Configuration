function Invoke-PowerPlan {
    Write-Host "Configuring power plan..." -ForegroundColor Yellow
    # Example: Set to High performance plan
    $highPerf = powercfg -list | Select-String -Pattern "High performance"
    if ($highPerf) {
        $guid = ($highPerf -split ':')[1].Trim().Split(' ')[0]
        powercfg -setactive $guid
    }
    Write-Host "Power plan configuration applied." -ForegroundColor Green
}
Export-ModuleMember -Function Invoke-PowerPlan