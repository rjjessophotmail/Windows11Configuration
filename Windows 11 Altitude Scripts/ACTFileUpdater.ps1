#Jessop Updater for systems imaged by IT prior to SentinelOne Migration.

# Hides useless search from taskbar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force

# Disables Automatic Microsoft Updates and sets to Manual
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1

# Enables updates for all Microsoft products in Windows Update App
(New-Object -com "Microsoft.Update.ServiceManager").AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")

# Configure Automatic Updates Local User
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1 -Type DWord -Force

# Disable Daylight Savings Time Switch
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name DynamicDaylightTimeDisabled -Value 1 -Type DWord -Force

# Disable Automatic TimeZone Switch
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name Start -Value 4 -Type DWord -Force

# Disable Automatic Time Sync
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name Type -Value "NoSync"

# Configure All networks to private
(Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles").Name | foreach{REG ADD "$_" /v "Category" /t REG_DWORD /d 1 /f}

# Remove old software from C:\Cathedral Energy Services Ltd
Remove-Item "C:\Cathedral Energy Services Ltd\*Cat MMR*" -Force -Recurse
Remove-Item "C:\Cathedral Energy Services Ltd\*CAT MWD Decoder*" -Force -Recurse
Remove-Item "C:\Cathedral Energy Services Ltd\*Cat MWD Detect*" -Force -Recurse
Remove-Item "C:\Cathedral Energy Services Ltd\*Cat MWD Interface*" -Force -Recurse
Remove-Item "C:\Cathedral Energy Services Ltd\*CAT RT Log Builder*" -Force -Recurse
Remove-Item "C:\Cathedral Energy Services Ltd\*HDGMGUI*" -Force -Recurse

# Remove old MWD Desktop shortcuts
Remove-Item "C:\Users\MWD\Desktop\*cat*.*"
Remove-Item "C:\Users\MWD\Desktop\HDGMGUI.*"
Remove-Item "C:\Users\MWD\Desktop\Mezintel*.*"
Remove-Item "C:\Users\DD\Desktop\*cat*.*"
Remove-Item "C:\Users\DD\Desktop\kelly*.*"

# Remove old DD Desktop shortcuts
Remove-Item "D:\MWDField\DD\KellyDown_Setup_4.00.03.00" -Force -Recurse
Remove-Item "D:\MWDField\MWD\Innova Watson\Innova Watson.zip" -Force -Recurse
# Remove-Item "D:\MWDField\SyndiCATe_Downloads" -Force -Recurse

# Remove Old Mezintel and DB
Remove-Item 'C:\Program Files (x86)\Mezintel Gamma' -Force -Recurse
Remove-Item 'C:\DBFILES\*.*' -Force -Recurse
#### *NOTE, Redundant, updated in replacement Mezintel folder" Remove-Item 'C:\Program Files (x86)\Mezintel Gamma\DATABASE MANAGER\SUPPORT FILES\DB FILES\Mezintel*.*' -Force -Recurse
# Remove-Item 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\Mezintel*.*' -Force -Recurse

# Remove Trend installable
Remove-Item "D:\IT\agent_cloud_x64_Nov2023.msi"

# Copy replacement directories and files
RoboCopy "E:\.1\Altitude Apps\Cathedral Energy Services Ltd" "C:\Cathedral Energy Services Ltd" /E
RoboCopy "E:\.1\Altitude Apps\Shortcuts" "C:\Users\MWD\Desktop" /E
RoboCopy "E:\.1\MWDField" "D:\MWDField" /E
RoboCopy "E:\.1\IT" "D:\IT" /E
RoboCopy "E:\Jessop\Mezintel\Mezintel Gamma" "C:\Program Files (x86)\Mezintel Gamma" /E

# Copy Mezintel DB Files
RoboCopy 'E:\Jessop\Mezintel\CESMezintelJan112023' 'C:\DBFILES' /E
# RoboCopy 'E:\Jessop\Mezintel\CESMezintelJan112023' 'C:\Program Files (x86)\Mezintel Gamma\DATABASE MANAGER\SUPPORT FILES\DB FILES' /E
RoboCopy 'E:\Jessop\Mezintel\CESMezintelJan112023' 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA' /E

#Run KellyDown Installer
D:\MWDField\DD\kellydown_setup_4.01.07.00\Setup.exe

#Run Syndicate Installer
& 'D:\MWDField\Syndicate Install\setup.exe'

# Activate Office
cd 'C:\Program Files (x86)\Microsoft Office\Office16'
cscript ospp.vbs /act

# Clear Recently Used
$Namespace = "shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}"
$QuickAccess = New-Object -ComObject shell.application
$RecentFiles = $QuickAccess.Namespace($Namespace).Items()
$FilteredFiles = $RecentFiles | ? {$_.Path -like "*.*"}
$FilteredFiles | % {$_.InvokeVerb("remove")}

# Initiate all Microsoft updates and accept all
# Note. "-Confirm:$false" throughout vs "| ECHO Y" route
Set-ExecutionPolicy RemoteSigned -Confirm:$false -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force
Install-Module -Name PSWindowsUpdate -Confirm:$false -Force

#Install-Module PSWindowsUpdate -Confirm:$false

Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
Get-WindowsUpdate -Confirm:$false

#Original, needs manual intervention
#Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot

#Twice ignore reboot to pick up missing updates unlocked by prior and then update with reboot.  Time consuming?
Install-WindowsUpdate -Install -AcceptAll -UpdateType Driver -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot -ErrorAction SilentlyContinue
Install-WindowsUpdate -Install -AcceptAll -UpdateType Driver -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot -ErrorAction SilentlyContinue
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot

# Doing it again: Twice ignore reboot to pick up missing updates unlocked by prior and then update with reboot.  Time consuming?
Install-WindowsUpdate -Install -AcceptAll -UpdateType Driver -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot -ErrorAction SilentlyContinue
Install-WindowsUpdate -Install -AcceptAll -UpdateType Driver -MicrosoftUpdate -ForceDownload -ForceInstall -IgnoreReboot -ErrorAction SilentlyContinue
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot


# End OneDrive Process and Uninstall
taskkill /f /im OneDrive.exe
cmd -c "%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall"