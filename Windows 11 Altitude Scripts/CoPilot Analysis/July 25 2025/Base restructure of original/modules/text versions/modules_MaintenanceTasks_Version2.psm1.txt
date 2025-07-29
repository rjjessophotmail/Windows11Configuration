<#
.SYNOPSIS
    Schedules and configures regular system maintenance tasks.

.DESCRIPTION
    Sets up scheduled tasks for system cleanup, disk optimization, update checks, and other maintenance activities. Ensures reliability and performance over time.

.EXPORTS
    Set-MaintenanceTasks
#>

function Set-MaintenanceTasks {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$DisableAutomaticMaintenance,
        [Parameter(Mandatory=$false)]
        [switch]$EnableCustomCleanupTask
    )

    Write-Host "Configuring scheduled system maintenance tasks..." -ForegroundColor Green

    if ($DisableAutomaticMaintenance) {
        try {
            # Disable Windows Automatic Maintenance via registry
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -Value 1 -Type DWord
            Write-Host "Windows Automatic Maintenance disabled."
        } catch {
            Write-Warning "Failed to disable Automatic Maintenance."
        }
    }

    if ($EnableCustomCleanupTask) {
        try {
            # Example: Schedule disk cleanup every Sunday at 2am
            $Action = New-ScheduledTaskAction -Execute "cleanmgr.exe" -Argument "/sagerun:1"
            $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
            $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
            Register-ScheduledTask -TaskName "WeeklyDiskCleanup" -Action $Action -Trigger $Trigger -Principal $Principal -Force
            Write-Host "Custom disk cleanup scheduled task created."
        } catch {
            Write-Warning "Failed to create custom disk cleanup scheduled task."
        }
    }

    # Example: Optimize drives (defrag) weekly
    try {
        $DefragAction = New-ScheduledTaskAction -Execute "defrag.exe" -Argument "C: /O"
        $DefragTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Saturday -At 3am
        $DefragPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        Register-ScheduledTask -TaskName "WeeklyDefrag" -Action $DefragAction -Trigger $DefragTrigger -Principal $DefragPrincipal -Force
        Write-Host "Weekly disk optimization (defrag) scheduled."
    } catch {
        Write-Warning "Failed to schedule disk optimization."
    }

    # Example: Windows Update check every Friday at 4am
    try {
        $WUAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"UsoClient StartScan`""
        $WUTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Friday -At 4am
        $WUPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        Register-ScheduledTask -TaskName "WeeklyUpdateCheck" -Action $WUAction -Trigger $WUTrigger -Principal $WUPrincipal -Force
        Write-Host "Weekly update check scheduled."
    } catch {
        Write-Warning "Failed to schedule update check."
    }

    # Add any additional maintenance tasks as required below
    # ...
}

Export-ModuleMember -Function Set-MaintenanceTasks