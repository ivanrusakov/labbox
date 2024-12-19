@echo off
:: Set default WAIT_TIME to 5 if not provided as a parameter
set WAIT_TIME=5
:: Check if WAIT_TIME is provided as an argument, and override default if it is
if not "%~1"=="" set WAIT_TIME=%~1

:: Get the script's full path
set SCRIPT_PATH="%~f0"

:: How many seconds to wait before running the task and cleaning up
echo %date% %time% - Waiting for %WAIT_TIME% second(s)...
choice /d y /t %WAIT_TIME% >nul

:: Cleanup files
echo %date% %time% - Running cleanup...
for %%f in (*) do (
    if not "%%~f"==%SCRIPT_PATH% del /q "%%f" >nul
)

echo %date% %time% - Cleanup script completed.