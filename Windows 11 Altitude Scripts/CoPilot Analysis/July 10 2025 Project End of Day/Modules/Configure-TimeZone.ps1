<#
.SYNOPSIS
  Sets the system time zone.
.DESCRIPTION
  Validates against available zones.
.PARAMETER DryRun
  Show actions without applying.
.PARAMETER TimeZoneId
  Must be from Get-TimeZone â€“ListAvailable.Id
.PROJECT
  Altitude Windows 11 Field System Configurator
.VERSION
  2.1
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$DryRun,
    [ValidateScript({ (Get-TimeZone -ListAvailable).Id -contains $_ })]
    [string]$TimeZoneId = 'Pacific Standard Time'
)

$log = "C:\Logs\Configure-TimeZone.log"
Start-Transcript -Path $log -ErrorAction SilentlyContinue

try {
    if ($PSCmdlet.ShouldProcess("Set time zone to $TimeZoneId")) {
        if (-not $DryRun) { Set-TimeZone -Id $TimeZoneId }
        Write-Output "Time zone => $TimeZoneId" | Out-File $log -Append
    }
} catch {
    Write-Warning "Failed: $_"; Write-Output "ERROR: $_" | Out-File $log -Append
}

Stop-Transcript
Write-Host "Configure-TimeZone complete." -ForegroundColor Green
