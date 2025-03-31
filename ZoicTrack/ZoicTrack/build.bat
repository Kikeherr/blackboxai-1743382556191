@echo off
REM Build script for Windows x64

set PYTHON=python
set VENV_ACTIVATE=venv\Scripts\activate

echo Creating Python virtual environment...
%PYTHON% -m venv venv
call %VENV_ACTIVATE%

echo Installing build requirements...
pip install --upgrade pip
pip install -r requirements_build.txt

echo Building executable...
python build_windows.py

if exist "dist\windows\ZoicTrack.exe" (
    echo Build successful! Executable created at:
    echo %cd%\dist\windows\ZoicTrack.exe
) else (
    echo Build failed! Check for errors above.
)

pause