@echo off
REM ZoicTrack Installer Build Script
REM Requires NSIS 3.08+ to be installed

set INSTALLER_NAME=ZoicTrackInstaller
set NSIS_PATH="C:\Program Files (x86)\NSIS\makensis.exe"

echo Creating directory structure...
if not exist dist mkdir dist
if not exist dependencies mkdir dependencies

echo Verifying NSIS installation...
if not exist %NSIS_PATH% (
    echo Error: NSIS not found at %NSIS_PATH%
    pause
    exit /b 1
)

echo Building installer...
%NSIS_PATH% /V4 %INSTALLER_NAME%.nsi

if errorlevel 1 (
    echo Build failed with error %errorlevel%
    pause
    exit /b 1
)

echo Successfully built %INSTALLER_NAME%.exe
dir %INSTALLER_NAME%.exe

pause