# ZoicTrack Installer - Complete Guide

## Installation Instructions

### System Requirements
- Windows 10/11 64-bit
- 4GB RAM minimum
- 500MB disk space
- Administrator rights for system-wide install

### Installation Methods

#### Interactive Installation
1. Run `ZoicTrackInstaller.exe`
2. Follow the setup wizard:
   - Select language
   - Accept license
   - Choose components:
     - Main Application (required)
     - Python 3.10
     - Blockchain Libraries
   - Set install location
   - Configure options:
     - Desktop shortcut
     - Add to PATH
     - Launch after install
3. Click "Install" and wait for completion

#### Silent Installation
```cmd
ZoicTrackInstaller.exe /S /D=C:\Path /LANG=en /NOPYTHON /NORESTART
```
**Parameters**:
- `/S` - Silent mode
- `/D` - Install directory (must be last)
- `/LANG` - Language (en/es/fr/pt)
- `/NOPYTHON` - Skip Python
- `/NORESTART` - No reboot

### Verifying Installation
1. Check files:
   ```cmd
   dir "%ProgramFiles%\ZoicTech\ZoicTrack"
   ```
2. Test shortcuts:
   - Start Menu → ZoicTech
   - Desktop (if selected)
3. Launch application

### Uninstalling
#### Standard:
- Control Panel → Uninstall
- Choose to keep/remove user data

#### Silent:
```cmd
"C:\Program Files\ZoicTech\ZoicTrack\uninstall.exe" /S
```

## Building the Installer
1. Prepare files:
   ```bash
   mkdir dist dependencies
   # Add ZoicTrack.exe to /dist
   # Add VC++/.NET to /dependencies
   ```
2. Compile:
   ```bash
   makensis ZoicTrackInstaller.nsi
   ```

## Troubleshooting
- **Logs**: `%TEMP%\ZoicTrack_install.log`
- **Common Errors**:
  - 1601: Missing .NET
  - 1603: General failure
  - 3010: Reboot needed

## Customization
1. Replace assets:
   - Icons: `/assets/installer.ico`
   - Images: `/assets/welcome.bmp`
2. Update translations in `/locales`
3. Recompile installer