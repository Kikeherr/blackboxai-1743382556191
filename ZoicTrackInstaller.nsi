; ZoicTrack Livestock Monitoring - Windows Installer
; NSIS 3.08+ Script
Unicode true
RequestExecutionLevel admin
CRCCheck on
SetCompressor /SOLID lzma
XPStyle on

; -------------------------------
; INCLUDES
; -------------------------------
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "x64.nsh"
!include "Sections.nsh"
!include "WordFunc.nsh"

; -------------------------------
; CONSTANTS
; -------------------------------
!define APP_NAME "ZoicTrack"
!define APP_VERSION "1.0"
!define COMPANY_NAME "ZoicTech"
!define INSTALLER_NAME "ZoicTrackInstaller"
!define REGISTRY_KEY "Software\${COMPANY_NAME}\${APP_NAME}"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

; -------------------------------
; INSTALLER CONFIGURATION
; -------------------------------
Name "${APP_NAME} ${APP_VERSION}"
OutFile "${INSTALLER_NAME}.exe"
InstallDir "$PROGRAMFILES64\${COMPANY_NAME}\${APP_NAME}"
InstallDirRegKey HKLM "${REGISTRY_KEY}" "InstallDir"
ShowInstDetails show
ShowUnInstDetails show

; -------------------------------
; VARIABLES
; -------------------------------
Var PythonDir
Var BlockchainConfig
Var DatabasePath
Var SelectedLanguage

; -------------------------------
; MODERN UI CONFIGURATION
; -------------------------------
!define MUI_ABORTWARNING
!define MUI_ICON "assets\installer.ico"
!define MUI_UNICON "assets\uninstaller.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "assets\welcome.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "assets\header.bmp"

; -------------------------------
; INSTALLER PAGES
; -------------------------------
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
Page custom SetLanguage
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

; Custom pages
Page custom PythonDirectory
Page custom BlockchainConfiguration
Page custom DatabaseConfiguration

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; -------------------------------
; LANGUAGES
; -------------------------------
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "French" 
!insertmacro MUI_LANGUAGE "Portuguese"

; -------------------------------
; INSTALLER SECTIONS
; -------------------------------
Section "Main Application" SEC_MAIN
  SectionIn RO
  
  SetOutPath "$INSTDIR"
  File /r "dist\*.*"
  
  ; Install VC++ Redist if needed
  IfFileExists "$SYSDIR\vcruntime140.dll" +2
  File "dependencies\vc_redist.x64.exe"
  ExecWait '"$INSTDIR\vc_redist.x64.exe" /install /quiet /norestart'
  
  ; Install .NET 4.8 if needed
  ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Release"
  ${If} $0 < 528040
    File "dependencies\dotnetfx48.exe"
    ExecWait '"$INSTDIR\dotnetfx48.exe" /q /norestart'
  ${EndIf}
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
  ; Registry entries
  WriteRegStr HKLM "${REGISTRY_KEY}" "InstallDir" "$INSTDIR"
  WriteRegStr HKLM "${REGISTRY_KEY}" "Version" "${APP_VERSION}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "${UNINSTALL_KEY}" "DisplayVersion" "${APP_VERSION}"
  WriteRegStr HKLM "${UNINSTALL_KEY}" "Publisher" "${COMPANY_NAME}"
  
  ; Start Menu shortcuts
  CreateDirectory "$SMPROGRAMS\${COMPANY_NAME}"
  CreateShortCut "$SMPROGRAMS\${COMPANY_NAME}\${APP_NAME}.lnk" "$INSTDIR\ZoicTrack.exe"
  CreateShortCut "$SMPROGRAMS\${COMPANY_NAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  
  ; Optional desktop shortcut
  ${If} $DesktopShortcut == 1
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\ZoicTrack.exe"
  ${EndIf}
  
  ; Add to PATH
  EnVar::AddValue "PATH" "$INSTDIR\bin"
SectionEnd

Section "Python 3.10 Embedded" SEC_PYTHON
  SetOutPath "$INSTDIR\python"
  File /r "dependencies\python-3.10-embed-amd64\*.*"
  StrCpy $PythonDir "$INSTDIR\python"
SectionEnd

Section "Blockchain Libraries" SEC_BLOCKCHAIN
  SetOutPath "$INSTDIR\blockchain"
  File /r "dependencies\blockchain\*.*"
SectionEnd

; -------------------------------
; CUSTOM PAGE FUNCTIONS
; -------------------------------
Function SetLanguage
  ; Language selection UI implementation
  ; Would load translations from locales/*.json
FunctionEnd

Function PythonDirectory
  ; Python installation directory selection
FunctionEnd

Function BlockchainConfiguration
  ; Blockchain config UI
FunctionEnd

Function DatabaseConfiguration
  ; Database setup UI
FunctionEnd

; -------------------------------
; UNINSTALLER SECTION
; -------------------------------
Section "Uninstall"
  ; Remove files
  RMDir /r "$INSTDIR"
  
  ; Remove shortcuts
  Delete "$SMPROGRAMS\${COMPANY_NAME}\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${COMPANY_NAME}\Uninstall.lnk"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  
  ; Remove registry keys
  DeleteRegKey HKLM "${REGISTRY_KEY}"
  DeleteRegKey HKLM "${UNINSTALL_KEY}"
  
  ; Remove from PATH
  EnVar::DeleteValue "PATH" "$INSTDIR\bin"
  
  ; Remove empty parent directories
  RMDir "$SMPROGRAMS\${COMPANY_NAME}"
  RMDir "$PROGRAMFILES64\${COMPANY_NAME}"
SectionEnd

; -------------------------------
; INSTALLER FUNCTIONS
; -------------------------------
Function .onInit
  ; System checks
  ${IfNot} ${AtLeastWin10}
    MessageBox MB_ICONSTOP|MB_OK "This application requires Windows 10 or later."
    Abort
  ${EndIf}
  
  ${IfNot} ${RunningX64}
    MessageBox MB_ICONSTOP|MB_OK "This application requires 64-bit Windows."
    Abort
  ${EndIf}
  
  ; Check RAM
  System::Call 'kernel32::GlobalMemoryStatusEx(i) i .r0'
  System::Call '*$0(i, l, l, l, l, l, l, l, l) i .r1, l .r2, l .r3'
  ${If} $3 < 4294967296 ; 4GB in bytes
    MessageBox MB_ICONEXCLAMATION|MB_OKCANCEL "Your system has less than 4GB RAM. Continue anyway?" IDOK +2
    Abort
  ${EndIf}
FunctionEnd

Function .onInstSuccess
  ; Launch application if selected
  ${If} $AutoLaunch == 1
    Exec '"$INSTDIR\ZoicTrack.exe"'
  ${EndIf}
FunctionEnd

; -------------------------------
; VERSION INFO
; -------------------------------
VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "CompanyName" "${COMPANY_NAME}"
VIAddVersionKey "FileVersion" "${APP_VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright © 2023 ${COMPANY_NAME}"
VIAddVersionKey "FileDescription" "${APP_NAME} Installer"