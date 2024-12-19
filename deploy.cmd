@echo off
setlocal enabledelayedexpansion

:: Deploy script for CPU Stress Test used in the lab and configured in JSON template

:: Set default values
set TASK_NAME="Server Initial Configuration Task"
set SCRIPT_NAME="cpu_stress.cmd"
set INSTALL_PATH=
set DELAY_SECONDS=60
set START_TASK_NAME="Praparing Initial Configuration Task"

:: Override defaults with command-line arguments if provided
if not "%~1"=="" set "TASK_NAME=%~1"
if not "%~2"=="" set "SCRIPT_NAME=%~2"
if not "%~3"=="" set "INSTALL_PATH=%~3"
if not "%~4"=="" set "DELAY_SECONDS=%~4"
if not "%~5"=="" set "START_TASK_NAME=%~5"

echo %date% %time% - Starting deployment script...

:: Install the main task
call install_task.cmd %TASK_NAME% %SCRIPT_NAME% %INSTALL_PATH%
echo %date% %time% - Main task installation completed.

:: Create a secondary task to start the main task after a delay
:: Get the current date and time
for /f "tokens=1,2 delims= " %%A in ('cscript //nologo date_add.vbs %DELAY_SECONDS%') do (
    set "start_date=%%A"
    set "start_time=%%B"
)
:: Print the new time and date
echo The time %DELAY_SECONDS% seconds from now will be: %start_date% %start_time%

:: Create the secondary task
schtasks /create /tn "%START_TASK_NAME%" /tr "schtasks /run /tn \"%TASK_NAME%\"" /sc once /st %start_time% /sd %start_date% /f >nul
if %errorlevel% neq 0 (
    echo %date% %time% - Error creating secondary task.
    schtasks /run /tn "%TASK_NAME%" /f >nul
)

echo %date% %time% - Secondary task created to start the main task after %DELAY_SECONDS% seconds.

endlocal
:: Final log
echo %date% %time% - Deployment script completed.
