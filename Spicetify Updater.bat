@echo off
start "" /b powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0SU_Installer.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0SU_Initialize.ps1"
exit