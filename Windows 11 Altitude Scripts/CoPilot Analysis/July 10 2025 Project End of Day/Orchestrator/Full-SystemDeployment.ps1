<#
.SYNOPSIS
  Interactive orchestrator for Altitude Windows 11 Field System Configurator.
.DESCRIPTION
  Prompts for test-signing (10s default=Yes), module selection (30s default=All),
  then executes chosen modules with ShouldProcess support.
.PARAMETER DryRun
  Show actions without applying.
.PARAMETER DisableSuggestions
  Pass-through to PrivacyAndUpdates.
.PARAMETER RemoveApps
  Pass-through to AppRemoval.
.PROJECT
  Altitude Windows 11 Field System Configurator
.VERSION
  2.8
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$DryRun,
    [switch]$DisableSuggestions,
    [switch]$RemoveApps
)

# Elevation check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent())
      .IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Warning "Administrator privileges required."; exit
}

# 1) Test-Signing Prompt (10s default=Yes)
Write-Host "Enable test-signing mode? (Yes/No)  [Default=Yes in 10s]" -ForegroundColor Cyan
$tskTS = [System.Threading.Tasks.Task[string]]::Run({ Read-Host })
if ($tskTS.Wait(10000)) { $ans = $tskTS.Result.Trim() } else {
    Write-Host "No response in 10s; defaulting to Yes." -ForegroundColor Yellow
    $ans = "Yes"
}
$enableTS = $ans.ToLower().StartsWith('y')
Write-Host "Test-signing enabled: $enableTS" -ForegroundColor Green

# 2) Moduleâ€Selection Prompt (30s default=All)
$allModules = @(
  "Configure-TimeZone.ps1",
  "Configure-PowerPlan.ps1",
  "Configure-Maintenance.ps1",
  "Configure-PrivacyAndUpdates.ps1",
  "Configure-AccountPolicies.ps1",
  "Configure-VisualEffects.ps1",
  "Configure-DeviceSettings.ps1",
  "Configure-DriverSigning.ps1",
  "Configure-DotNetFeatures.ps1",
  "Configure-LockScreen.ps1",
  "Configure-SecurityCenter.ps1",
  "Configure-NetworkPrivacy.ps1",
  "Configure-Edge.ps1",
  "Configure-AppRemoval.ps1",
  "Configure-CleanupAndUpdates.ps1",
  "Configure-CleanupUserHistories.ps1"
)

Write-Host "`nSelect modules to run:" -ForegroundColor Cyan
Write-Host "  [A] All Modules" -ForegroundColor Cyan
for ($i=0; $i -lt $allModules.Count; $i++) {
    Write-Host "  [$($i+1)] $($allModules[$i])"
}
Write-Host "`nEnter numbers or 'A' [Default=All in 30s]" -ForegroundColor Cyan
$tskSel = [System.Threading.Tasks.Task[string]]::Run({ Read-Host "Your selection" })
if ($tskSel.Wait(30000)) { $sel = $tskSel.Result.Trim() } else {
    Write-Host "No input in 30s; defaulting to All modules." -ForegroundColor Yellow
    $sel = "A"
}

if ($sel -match '^[Aa]$') {
    $selected = $allModules.Clone()
} else {
    $nums = $sel -split '\D+' | Where{$_} | ForEach-Object{[int]$_}
    $selected = $nums | Where{$_ -ge 1 -and $_ -le $allModules.Count} |
                ForEach-Object{ $allModules[$_-1] }
}

# 3) Skip DriverSigning if test-signing disabled
if (-not $enableTS) {
    $selected = $selected | Where{$_ -ne "Configure-DriverSigning.ps1"}
    Write-Host "Skipping Configure-DriverSigning.ps1 (test-signing OFF)" -ForegroundColor Yellow
}

Write-Host "`nModules to run:" -ForegroundColor Cyan
$selected | ForEach-Object{ Write-Host "  â€¢ $_" -ForegroundColor Green }

# 4) Execute selected modules
$ts        = Get-Date -Format "yyyyMMdd_HHmm"
$masterLog = "C:\Logs\SystemDeploy_$ts.log"
Start-Transcript -Path $masterLog -ErrorAction SilentlyContinue

$results = @()
foreach ($mod in $selected) {
    if ($PSCmdlet.ShouldProcess($mod,'Execute')) {
        Write-Host "`nâ–¶ Running $mod" -ForegroundColor Cyan
        try {
            switch ($mod) {
              "Configure-PrivacyAndUpdates.ps1" {
                & ".\$mod" -DryRun:$DryRun -DisableSuggestions:$DisableSuggestions
              }
              "Configure-AppRemoval.ps1" {
                & ".\$mod" -DryRun:$DryRun -RemoveApps:$RemoveApps
              }
              default {
                & ".\$mod" -DryRun:$DryRun
              }
            }
            $stat = if ($DryRun){'DryRun'}else{'Success'}
        } catch {
            Write-Warning "Error in $mod: $_"; $stat = 'Failed'
        }
        $results += [pscustomobject]@{Module=$mod;Status=$stat;Time=(Get-Date).ToString('o')}
    }
}

Stop-Transcript

# 5) Summary
Write-Host "`nðŸ“˜ Run Summary:" -ForegroundColor Cyan
$results | ForEach-Object{
    $c = if ($_.Status -eq 'Success'){'Green'} elseif ($_.Status -eq 'DryRun'){'Yellow'} else{'Red'}
    Write-Host "  $($_.Module): $($_.Status)" -ForegroundColor $c
}

Write-Host "`nâœ… Deployment complete." -ForegroundColor Green
