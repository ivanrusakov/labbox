@echo off
setlocal enabledelayedexpansion

:: Deploy script for CPU Stress Test used in the lab and configured in JSON template

:: Set default values
set "DELAY_SECONDS=60"
set "TASK_NAME=Server Initial Configuration Task"
set "SCRIPT_NAME=cpu_stress.cmd"
set "INSTALL_PATH="
set "START_TASK_NAME=Preparing Initial Configuration Task"
set "LOG_FILE=deployment.log"

:: Override defaults with command-line arguments if provided
if not "%~1"=="" set "DELAY_SECONDS=%~1"
if not "%~2"=="" set "TASK_NAME=%~2"
if not "%~3"=="" set "SCRIPT_NAME=%~3"
if not "%~4"=="" set "INSTALL_PATH=%~4"
if not "%~5"=="" set "START_TASK_NAME=%~5"

:: Start logging
echo %date% %time% - Starting deployment script...

:: Install the main task
call install_task.cmd "%TASK_NAME%" "%SCRIPT_NAME%" "%INSTALL_PATH%"
if %errorlevel% neq 0 (
    echo %date% %time% - Error installing main task.
    endlocal
    exit /b 1
)
echo %date% %time% - Primary task installation completed.

:: Calculating the start time for the secondary task
echo %date% %time% - Calculating start time for secondary task...
for /f "tokens=1,2 delims= " %%A in ('cscript //nologo date_add.vbs "/seconds=%DELAY_SECONDS%" "/outputType=both" "/timeFormat=local"') do (
    set "start_date=%%A"
)
for /f "tokens=1,2 delims=T " %%A in ('cscript //nologo date_add.vbs "/seconds=%DELAY_SECONDS%" "/outputType=both" "/timeFormat=UTC"') do (
    set "start_time=%%B"
)

schtasks /run /tn "%TASK_NAME%"

echo %date% %time% - Deployment script completed.

endlocal