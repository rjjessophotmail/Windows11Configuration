# Windows 11 Altitude Scripts – Base Restructure

This repository provides a modular and streamlined way to apply a comprehensive set of configuration tweaks and optimizations for Windows 11. Each major configuration area is encapsulated in its own PowerShell module, and all can be applied in sequence with a single command.

## 📦 Folder Structure

```
Base restructure of original/
│
├── AllSetup.ps1
├── modules/
│   ├── AppRemoval.psm1
│   ├── ApplyAllSettings.psm1
│   ├── BatterySettings.psm1
│   ├── DisplayAndMultimedia.psm1
│   ├── MaintenanceTasks.psm1
│   ├── NetworkTweaks.psm1
│   ├── PerformanceTweaks.psm1
│   ├── PowerPlan.psm1
│   ├── PrivacyTweaks.psm1
│   ├── SleepAndHibernate.psm1
│   ├── TimeSettings.psm1
│   └── UpdateControl.psm1
└── README.md
```

## 🚀 Usage

1. **Open PowerShell as Administrator.**
2. Navigate to the root of this folder.
3. Run the following command:

```powershell
.\AllSetup.ps1
```

This will automatically import all modules and apply all configuration settings.

## 🛠️ Adding or Customizing Modules

- To add new tweaks, create a new `.psm1` module in the `modules/` folder and add an appropriate `Invoke-<Something>` function.
- Edit `ApplyAllSettings.psm1` to import and run your new module.
- All modules should export only their main entry-point function.

## ℹ️ Notes

- All scripts are designed for Windows 11. Some settings may not apply or may behave differently on earlier versions.
- **Back up your system or test in a virtual machine before running in production.**
- For questions or improvements, open an issue or PR!

---