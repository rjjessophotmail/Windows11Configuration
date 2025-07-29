<#
.SYNOPSIS
    Configures sleep, hibernate, and wake timer settings.

.DESCRIPTION
    Sets or disables sleep/hibernate timeouts, hybrid sleep, fast startup, and wake timers for both AC and DC power states.

.EXPORTS
    Set-SleepAndHibernate
#>

function Set-SleepAndHibernate {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [int]$SleepTimeoutAC = 0,     # Minutes; 0 = Never sleep (AC)
        [Parameter(Mandatory=$false)]
        [int]$SleepTimeoutDC = 30,    # Minutes on battery before sleep
        [Parameter(Mandatory=$false)]
        [int]$HibernateTimeoutAC = 0, # Minutes; 0 = Never hibernate (AC)
        [Parameter(Mandatory=$false)]
        [int]$HibernateTimeoutDC = 60,# Minutes on battery before hibernate
        [Parameter(Mandatory=$false)]
        [bool]$DisableHybridSleep = $true,
        [Parameter(Mandatory=$false)]
        [bool]$DisableWakeTimers = $true,
        [Parameter(Mandatory=$false)]
        [bool]$DisableFastStartup = $true
    )

    Write-Host "Configuring sleep, hibernate, and wake timer settings..." -ForegroundColor Green

    # Get the current power scheme (active GUID)
    $scheme = (powercfg /getactivescheme) -replace '.*: ([a-f0-9\-]+) .*','$1'

    try {
        # Set sleep timeouts
        powercfg /SETACVALUEINDEX $scheme SUB_SLEEP STANDBYIDLE ($SleepTimeoutAC * 60)
        powercfg /SETDCVALUEINDEX $scheme SUB_SLEEP STANDBYIDLE ($SleepTimeoutDC * 60)

        # Set hibernate timeouts
        powercfg /SETACVALUEINDEX $scheme SUB_SLEEP HIBERNATEIDLE ($HibernateTimeoutAC * 60)
        powercfg /SETDCVALUEINDEX $scheme SUB_SLEEP HIBERNATEIDLE ($HibernateTimeoutDC * 60)

        # Disable or enable hybrid sleep
        $hybrid = if ($DisableHybridSleep) {0} else {1}
        powercfg /SETACVALUEINDEX $scheme SUB_SLEEP HYBRIDSLEEP $hybrid
        powercfg /SETDCVALUEINDEX $scheme SUB_SLEEP HYBRIDSLEEP $hybrid

        # Disable or enable wake timers
        $wakeup = if ($DisableWakeTimers) {0} else {1}
        powercfg /SETACVALUEINDEX $scheme SUB_SLEEP RTCWAKE $wakeup
        powercfg /SETDCVALUEINDEX $scheme SUB_SLEEP RTCWAKE $wakeup

        Write-Host "Sleep, hibernate, hybrid sleep, and wake timer settings applied."
    } catch {
        Write-Warning "Failed to apply one or more sleep/hibernate settings."
    }

    # Disable Fast Startup (system-wide; registry and powercfg)
    if ($DisableFastStartup) {
        try {
            powercfg /hibernate on
            powercfg /SETACVALUEINDEX $scheme SUB_BUTTONS FASTSTARTUP 0
            Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0
            Write-Host "Fast Startup disabled."
        } catch {
            Write-Warning "Could not disable Fast Startup."
        }
    }

    # Add additional sleep/hibernate settings as needed
    # ...
}

Export-ModuleMember -Function Set-SleepAndHibernate