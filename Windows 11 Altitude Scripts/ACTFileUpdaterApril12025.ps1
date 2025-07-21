# Jessop April 2025 System configuration script Windows 24H2

#Allow scripts to run on device for the current session only.
# powershell.exe -ExecutionPolicy Bypass on startup
#or
# powershell.exe -ExecutionPolicy Bypass -File .\YourScript.ps1

# 1. Initial Windows Environment setups.
####################################################################################################################
## 1.1 Time Settings
Write-Host "Setting timezone to US Mountain Standard and turning DST off and Automatic Time Sync." -ForegroundColor Green

    #### Turn off Set time zone automatically
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 4

    #### Set Time zone & turn off DST change.
    #### Note that Mountain Standard Time (US & Canada) uses DST. Arizona UTC -7:00 is preferred because it does not to prevent accidental changes for DST.
    tzutil /s "US Mountain Standard Time_dstoff"

    #### Force synchronization with the time server prior to turning it off for field use.
    Write-Host "Forcing time sync" -ForegroundColor Green
    w32tm /resync

    #### Verify the synchronization status if desired for verification.
    #w32tm /query /status

    #### Turn off Set time automatically.
    #### **Note** To turn it back on, use "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters' -Name 'Type' -Value 'NTP'"
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters -Name "Type" -Value "NoSync"
    #### NOTE -PATH seems to work with or without Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters -Name "Type" -Value "NoSync"


####################################################################################################################
## 1.2 POWER OPTIONS

Write-Host "Creating & configuring Altitude Field power plan and removing alternate power plans..." -ForegroundColor Green

#### 1.2.1 Set Power Plan to High Performance and change the name to "Altitude Field"
    powercfg -SETACTIVE SCHEME_MIN
    powercfg /CHANGENAME 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c "Altitude Field"

#### 1.2.2 Remove unnecessary Power Plans: (Power saver, Balanced and Ultimate), citing specific GUIDs.  
#### *Note for restoration* 
#### Power saver powercfg -duplicatescheme a1841308-3541-4fab-bc81-f71556f20b4a
#### Balanced powercfg -duplicatescheme 381b4222-f694-41f0-9685-ff5bb260df2e
#### High Performance powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
#### Ultimate Performance powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg /delete a1841308-3541-4fab-bc81-f71556f20b4a
    powercfg /delete 381b4222-f694-41f0-9685-ff5bb260df2e
    powercfg /delete e9a42b02-d5df-448d-aa00-03f14749eb61

#### 1.2.3 Set /CHANGE Options
#### Set "Turn off the display" timeout to NEVER for AC & DC.
    powercfg /change /monitor-timeout-ac 0
    powercfg /change /monitor-timeout-dc 0

#### Set "Turn off hard disk after" timeout to Never for AC & DC.
    powercfg /change /disk-timeout-ac 0
    powercfg /change /disk-timeout-dc 0

#### Set Sleep timeout to Never for AC & DC.
    powercfg /change /standby-timeout-ac 0
    powercfg /change /standby-timeout-dc 0

#### Set hibernate timeout to NEVER for AC & DC. Disable hibernation for redundancy.
    powercfg /change /hibernate-timeout-ac 0
    powercfg /change /hibernate-timeout-dc 0
    powercfg /hibernate off

#### 1.2.4 SETACVALUEINDEX GUID based settings. *Note. In sequential order from "powercfg /query" order.

#### SUB_DISK\DISKIDLE\NEVER. Hard disk\Turn off hard disk after\NEVER (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0

#### Set JavaScript Timer Frequency\Maximum Performance. (1)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 8
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 6
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1

#### Set Desktop background settings\slideshow\PAUSED. (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 1

#### Set Wireless Adapter Settings\Maximum Performance. (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0

### Set SUB_SLEEP\STANDBYIDLE Sleep\Sleep after\NEVER. (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0

#### Set Allow hybrid sleep\HYBRIDSLEEP\Off, (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 0

#### Set Hibernate after\HIBERNATEIDLE\NEVER (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 0

#### Set Allow wake timers\RTCWAKE\Enable. (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1

#### Set USB settings\USB selective suspend settting\Disabled. (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0

#### Set Intel(R) Graphics Settings\Intel(R) Graphics Power Plan\Maximum Performance. (2)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 2
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 44f3beca-a7c0-460e-9df2-bb8b99e0cba6 3619c3f2-afb2-4afc-b0e9-e7fef372de36 2

#### Set SUB_BUTTONS\UIBUTTON_ACTION. Power buttons and lid\Start menu power button\Shut down. (2)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT a7066653-8d6c-40a8-910e-a1f54b84c7e5 a7066653-8d6c-40a8-910e-a1f54b84c7e5 2
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT a7066653-8d6c-40a8-910e-a1f54b84c7e5 a7066653-8d6c-40a8-910e-a1f54b84c7e5 2

#### Set SUB_PCIEXPRESS\ASPM. PCI Express\Link State Power Management\Off. (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0

#### Set SUB_PROCESSOR\PROCTHROTTLEMIN. Processor power managment\Minimum processor state\5%. (5)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 5

#### Set SUB_PROCESSOR\SYSCOOLPOL. System Cooling Policy\Active. (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 1

#### Set SUB_PROCESSOR\PROCTHROTTLEMAX. Processor power managment\Maximum processor state\100% (64) CHECK THIS ONE FOR NEW PERFORMANCE/ECO CORE COMBO!!!!!!!!!!!!!!!!!!!!!!!!!!!
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 64
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 64

#### Set SUB_VIDEO\VIDEOIDLE.  Display\Turn off display after\NEVER (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0

#### Set SUB_VIDEO. Display\Display brightness\50% (50)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 50
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 50

#### Set Display\Dimmed display brightness\33% (33)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 33
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 33

#### Set ADAPTBRIGHT. Display\Enable adaptive brightness\On (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 1

#### Set Multimedia settings\When sharing media\Prevent idling to sleep (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1

#### Set Multimedia settings\When playing video\Optimize video quality\Balanced (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 1

#### Set SUB_BATTERY\BATFLAGSCRIT Battery\Critical battery notification\On (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 5dbb7c9f-38e9-40d2-9749-4f8a0e9f640f 1

#### Set SUB_BATTERY\BATACTIONCRIT Battery\Critical battery action\Do nothing (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 1

#### Set SUB_BATTERY\BATLEVELLOW Battery\Low battery level\15% (15)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 15
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 15

#### Set SUB_BATTERY\BATLEVELCRIT Battery\Critical battery level\5% (5)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 5
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 5

#### Set SUB_BATTERY\BATFLAGSLOW Battery\Low battery notification\On (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 1

#### Set SUB_BATTERY Battery\Reserve battery level\7% (7)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 7
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 7


#### 1.2.5 Hidden power button and lid GUID based settings
#### Reference: https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/lid-open-wake-action

#### Set SUB_BUTTONS\LIDOPENWAKE Common\Power\Policy\Settings\Button\LidOpenWake\Turn on the display (1)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 99ff10e7-23b1-4c07-a9d1-5c3206d741b4 1
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 99ff10e7-23b1-4c07-a9d1-5c3206d741b4 1

#### Set SUB_BUTTONS\LIDACTION Common\Power\Policy\Settings\ButtonLidAction\Do Nothing (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0

#### Set SUB_BUTTONS\PBUTTONACTION Common\Power\Policy\Settings\Button\PowerButtonAction\Do Nothing (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0

#### Set SUB_BUTTONS\SHUTDOWN Common\Power\Policy\Settings\Button\PowerButtonAction\Off (0) ***Normal shutdown with save file warnings.***
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 833a6b62-dfa4-46d1-82f8-e09e34d029d6 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 833a6b62-dfa4-46d1-82f8-e09e34d029d6 0

#### Set SUB_BUTTONS\SleepButtonAction Common\Power\Policy\Settings\Button\SleepButtonAction\Do Nothing (0)
    powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0


####################################################################################################################
## 1.3 Set sysetem environment to show nonpresent & detached devices. Primarily to avoid COM port address duplicate overwrites.
## *** Note, user must activate via devmgmt.msc\View\Show hidden devices ***
    Write-Host "Setting Environment Variable to show nonpresent devices in devmgmt.msc console." -ForegroundColor Green
    [System.Environment]::SetEnvironmentVariable("DEVMGR_SHOW_NONPRESENT_DEVICES", "1", "Machine")

####################################################################################################################

# 1.4 Disable serial mouse detection (4 = Disabled to prevent serial device detection to prevent issues in the case of a COM device sharing the same port as a touch screen)
Write-Host "Disabling serial mouse detection to prevent touchscreen/COM port conflicts." -ForegroundColor Green
    # (Options: 0 Boot (loaded by kernel loader). Components of the driver stack for the boot (startup) volume must be loaded by the kernel loader.
    # 1. System (loaded by I/O subsystem). Specifies that the driver is loaded at kernel initialization.
    # 2. Automatic (loaded by Service Control Manager). Specifies that the service is loaded or started automatically.
    # 3. Specifies that the service does not start until the user starts it manually, such as by using Device Manager.
    # 4. Disabled. Specifies that the service should not be started.
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\sermouse -Name Start -Type DWord -Value 4




## 1.4 System Properties\Performance Settings

# Expected in UserPreferenceMask
    Write-Host "Setting Desktop Performance settings" -ForegroundColor Green



# Visual effects
    # Preliminary set UserPreferenceMask
    $Value = ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
    Set-ItemProperty -Path HKCU:\Control Panel\Desktop -Name UserPreferencesMask -Type Binary -Value $Value
	
	# Set Select the settings you want to use for the appearance and performance of Windows on this computer.
	# Let windows choose what's best for my computer (3 = Custom)
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name VisualFXSetting -Value 3
    Set-ItemProperty -Path HKCU:\Control Panel\Desktop\WindowMetrics -Name MinAnimate -Type String -Value 0

	# Custom checkbox options:

        # 01. Animate controls and elements inside windows (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name ControlAnimations -Type DWord -Value 0

        # 02. Animate Windows when minimizing and maximizing (Off = 0)
		Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name AnimateMinMax -Type DWord -Value 0
      
		# 03. Animations in the taskbar (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name TaskbarAnimations -Type DWord -Value 0
		# Alternate: Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0
		
        # 04. Enable Pee
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name DWMAeroPeekEnabled -Type DWord -Value 0
		# Alternate: Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0

        # 05. Fade or slide menus into view (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name MenuAnimation -Type DWord -Value 0
        
        # 06 Fade or slide ToolTips into view (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name TooltipAnimation -Type DWord -Value 0

        # 07. Fade out menu items after clicking (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name SelectionFade -Type DWord -Value 0

        # 08. Save taskbar thumbnail previews (On = 1)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name DWMSaveThumbnailEnabled -Type DWord -Value 0

        # 09. Show shadows under mouse pointer (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name CursorShadow -Type DWord -Value 0
        
        # 10. Show shadows under windows (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name DropShadow -Type DWord -Value 0

        # 11. Show thumbnails instead of icons (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name ThumbnailsOrIcon -Type DWord -Value 0
	
	    # 12. Show translucent selection rectangle (Off = 0)
		Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name ListviewAlphaSelect -Type DWord -Value 0
	
		# 13. Show Windows contents while dragging (On = 1)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name DragFullWindows -Type DWord -Value 1

        # 14. Slide open combo boxes (Off = 0)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name ComboBoxAnimation -Type DWord -Value 0

        # 15. Smooth edges of screen fonts (On = 1)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name FontSmoothing -Type DWord -Value 1

        # 16. Smooth-scroll list boxes (Off = 1)
        Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name ListBoxSmoothScrolling -Type DWord -Value 1

		# 17. Use drop shadows for icon labels on the desktop (Off = 0)
		Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects -Name ListviewShadow -Type DWord -Value 0


##### Network settings

    # Private Networks
        # 1. Set all existing network profiles to private.
        $profiles = Get-NetConnectionProfile

        # Loop through each profile and set it to private
        foreach ($profile in $profiles) {
        Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private
        }
        # Set the default network category for new networks to private
        New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" -Name "Default" -Value 1 -PropertyType DWord -Force

#### Set all Wi-Fi connections to Metered.
        # 1. Windows Update will only download priority updates.
        # 2. Apps updating / downloading from the Microsoft Store paused.
        # 3. Offline files might not sync automatically in Microsoft apps.
        
    # Get all Wi-Fi adapters
    $wifiAdapters = Get-NetAdapter | Where-Object {$_.MediaType -eq '802.11'}

    # Set each Wi-Fi adapter to metered connection
    foreach ($adapter in $wifiAdapters) {
        Set-NetConnectionProfile -InterfaceAlias $adapter.Name -NetworkCategory Private
        Set-NetConnectionProfile -InterfaceAlias $adapter.Name -NetworkCost Metered
    }
    Write-Output "All Wi-Fi connections have been set to metered."



#### GUI & File Explorer tweaks

    # Disable Autoplay
    Write-Host "Disabling Autoplay..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

    # Show recommendations for tips, shortcuts, new apps and more (On = 1 Off = 0)
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name "Start_IrisRecommendations" -Type DWord -Value 0

    # Enables showing the desktop by clicking the far corner of the taskbar (On = 1 Off = 0)
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name "TaskbarSd" -Type DWord -Value 0

    # Specifies whether the task view button is shown on the taskbar. (On = 1 Off = 0)
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name "ShowTaskViewButton" -Type DWord -Value 1
    
    # Specifies whether the Widgets button is shown on the taskbar. (On = 1 Off = 0)
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name "SystemSettings_DesktopTaskbar_Da" -Type DWord -Value 1

    # Enable remember window locations based on monitor conection. (Enabled = 0, Disabled = 1)
    Set-ItemProperty -Path HKCU:\Control Panel\Desktop -Name RestorePreviousStateRecalcBehavior -Type DWord -Value 1

    # Disable Autorun for all drives
    Write-Host "Disabling Autorun for all drives..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

	# Change Window menu delay time 
	Set-ItemProperty -Path HKCU:\Control Panel\Desktop -Name MenuShowDelay -Type String -Value 400
   
    # Change "Open File Explorer to" value from the default "Quick Access" (2) to "This PC" (1) 
    Set-ItemProperty -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1

    # Hide extensions for known file types
    Set-ItemProperty -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Tyep DWord -Value 0

    # File Explorer navigation pane set to automatically "Expand to open folder" (Default Off = 0) (On = 1)
    Set-ItemProperty -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Type Dword -Value 1 -Force

    # File Explorer navigation pane set to "Show all folders" (Default Off = 0) (On = 1)
    Set-ItemProperty -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Type Dword -Value 1 -Force

    #### Turn off Sticky Keys
        # Disable Sticky Keys prompt
        Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
        # Disable Toggle Keys tone prompt (Options Disabled = 58, Off=62, On=63)  
        Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "58"

    # Unpin Store from Taskbar
    if ((Test-Path -LiteralPath "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer") -ne $true) {
    New-Item "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force -ea SilentlyContinue
    };
    New-ItemProperty -LiteralPath 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'NoPinningStoreToTaskbar' -Value 1 -PropertyType DWord -Force -ea SilentlyContinue;

    # Hides redundant search box from taskbar
    Write-Host "Hiding Search Box / Button..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force
    

####################################################################################################################
#### Maintenance


    #### Weekly Disk Cleanup via CLEANMGR.EXE
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2:00AM
    $action = New-ScheduledTaskAction -Execute 'cleanmgr.exe'
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Weekly Disk Cleanup"


#### Storage Sense
    # https://stealthpuppy.com/windows-10-storage-sense-intune/
    # Storage Sense On  
    
    # Name '01 is the toggle (Options: Off = 0, On = 1)
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 01 -Type DWord -Value 1
    
    # Name '2048' is the frequency (Options: 0 = During low free disk space, 1 = Every day, 7 = Every week, 30 = Every month)
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 2048 -Type DWord -Value 7

    # Enable "Delete temporary files that my apps aren't using" (Options: Off = 0, On = 1)
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 04 -Type DWord -Value 1

    # "Delete files in my recycle bin if they have been there for over:
    # Name '08' is the toggle.  (Off = 0, On = 1) 
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 08 -Type DWord -Value 1
    # Name '256 is duration. (Never = 0, Days = 1, 14, 30 or 60)
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 256 -Type DWord -Value 60

    # Set ‘Delete files in my Downloads folder if they have been there for over
    # Name '32' is the toggle. (Off = 0, On = 1)
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 32 -Type DWord -Value 1
    # Name '512" is the frequency. (Never = 0. Days = 1, 14, 30 or 60
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Name 512 -Type DWord -Value 0

    # Set value that Storage Sense has already notified the user
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy -Type DWord -Value 1

####UAC (User Account Control pop-up settings. 
    #Note that this is a combination of three registry settings, PromptOnSecureDesktop, EnableLUA & ConsentPromptBehaviorAdmin
    # The setting level combinations are as follows and can affect final behaviour if not adhered to:
        # PromptOnSecureDesktop = 1, EnableLUA = 1, ConsentPromptBehaviorAdmin = 2: AlwaysNotify
        # PromptOnSecureDesktop = 1, EnableLUA = 1, ConsentPromptBehaviorAdmin = 5: Notify me only when apps try to make changes to my computer (do not dim my desktop)
        # PromptOnSecureDesktop = 0, EnableLUA = 1, ConsentPromptBehaviorAdmin = 5: Default with screen dimming): Notify me only when apps try to make changes to my computer (Default)
        # PromptOnSecureDesktop = 0, EnableLUA = 1, ConsentPromptBehaviorAdmin = 0: Never notify me
    # Prompt on secure desktop (Dims screen during prompt) Options: (On = 1, Off  = 0)
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name PromptOnSecureDesktop -Value 0

    # Notify user when programs try to make changes to the computer Options: (On = 1, Off  = 0)
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 0

    # UAC Password prompt (Off = 5, On = 1)
        # Value Meanings:
        # 0. 0x00000000: This option allows the Consent Admin to perform an operation that requires elevation without consent or credentials.
        # 1. 0x00000001: This option prompts the Consent Admin to enter their user name and password (or another valid admin) when an operation requires elevation of privilege. This operation occurs on the secure desktop.
        # 2. 0x00000002: This option prompts the administrator in Admin Approval Mode to select either "Permit" or "Deny" an operation that requires elevation of privilege. If the Consent Admin selects Permit, the operation will continue with the highest available privilege. This operation occurs on the secure desktop.
        # 3. 0x00000003: This option prompts the Consent Admin to enter their user name and password (or that of another valid admin) when an operation requires elevation of privilege.
        # 4. 0x00000004: This prompts the administrator in Admin Approval Mode to select either "Permit" or "Deny" an operation that requires elevation of privilege. If the Consent Admin selects Permit, the operation will continue with the highest available privilege.
        # 5. 0x00000005: This option is the default. It is used to prompt the administrator in Admin Approval Mode to select either "Permit" or "Deny" for an operation that requires elevation of privilege for any non-Windows binaries. If the Consent Admin selects Permit, the operation will continue with the highest available privilege. This operation will happen on the secure desktop
        # Note: "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0"
        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0


# File Explorer Classic





######
# Privacy Settings
# Disable Find my Device
Set-ItemProperty -Path HKLM:









# ***********NOT WORKING UPDATEDisables Automatic Microsoft Updates and sets to Manual
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1

# Enables updates for all Microsoft products in Windows Update App
(New-Object -com "Microsoft.Update.ServiceManager").AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")

# Disable Windows welcome experience after updates
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Value 0

# Disable automatic installation of suggested apps
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1

# Disable suggested apps in Start menu
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0

# Disable EOSNotify task
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Setup\EOSNotify"

# Disable EOSNotify2 task
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Setup\EOSNotify2"

# Disable OobeUpdater task
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Setup\OobeUpdater"

# Configure Automatic Updates Local User
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 1 -Type DWord -Force

# Disable Daylight Savings Time Switch
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name DynamicDaylightTimeDisabled -Value 1 -Type DWord -Force

# Disable Automatic TimeZone Switch
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name Start -Value 4 -Type DWord -Force

# Disable Automatic Time Sync
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name Type -Value "NoSync"


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



# Install NuGet and set PSGallery as trusted package manager
Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Install-Module packagemanagement -Force



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