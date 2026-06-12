@echo off
cd /d "%~dp0"

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Verify the PowerShell script exists in the current directory
if not exist "MS_Office_Installer.ps1" (
    echo Error: MS_Office_Installer.ps1 not found in this folder.
    pause
    exit /b
)

:: Run the script with bypassed execution policy
echo Running MS_Office_Installer.ps1 with full access...
powershell -NoProfile -ExecutionPolicy Bypass -File "MS_Office_Installer.ps1"

echo.
echo Process completed.
pause
