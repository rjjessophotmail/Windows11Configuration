function Apply-AllSettings {
    Write-Host "Starting Windows 11 Altitude configuration..." -ForegroundColor Cyan

    Import-Module "$PSScriptRoot\AppRemoval.psm1" -Force
    Invoke-AppRemoval

    Import-Module "$PSScriptRoot\BatterySettings.psm1" -Force
    Invoke-BatterySettings

    Import-Module "$PSScriptRoot\DisplayAndMultimedia.psm1" -Force
    Invoke-DisplayAndMultimedia

    Import-Module "$PSScriptRoot\MaintenanceTasks.psm1" -Force
    Invoke-MaintenanceTasks

    Import-Module "$PSScriptRoot\NetworkTweaks.psm1" -Force
    Invoke-NetworkTweaks

    Import-Module "$PSScriptRoot\PerformanceTweaks.psm1" -Force
    Invoke-PerformanceTweaks

    Import-Module "$PSScriptRoot\PowerPlan.psm1" -Force
    Invoke-PowerPlan

    Import-Module "$PSScriptRoot\PrivacyTweaks.psm1" -Force
    Invoke-PrivacyTweaks

    Import-Module "$PSScriptRoot\SleepAndHibernate.psm1" -Force
    Invoke-SleepAndHibernate

    Import-Module "$PSScriptRoot\TimeSettings.psm1" -Force
    Invoke-TimeSettings

    Import-Module "$PSScriptRoot\UpdateControl.psm1" -Force
    Invoke-UpdateControl

    Write-Host "Windows 11 Altitude configuration complete." -ForegroundColor Green
}
Export-ModuleMember -Function Apply-AllSettings