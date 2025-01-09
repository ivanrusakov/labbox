@echo off
setlocal enabledelayedexpansion

:: Deploy script for CPU Stress Test used in the lab and configured in JSON template

:: Set default values
set "DELAY_SECONDS=60"
set "TASK_NAME=Server Initial Configuration Task"
set "SCRIPT_NAME=cpu_stress.cmd"
set "INSTALL_PATH="

:: Override defaults with command-line arguments if provided
if not "%~1"=="" set "DELAY_SECONDS=%~1"
if not "%~2"=="" set "TASK_NAME=%~2"
if not "%~3"=="" set "SCRIPT_NAME=%~3"
if not "%~4"=="" set "INSTALL_PATH=%~4"

:: Start logging
echo [%date% %time%] - Starting deployment script...

:: Install the main task to run on startup
if "%INSTALL_PATH%"=="" (
    echo %date% %time% - Error: INSTALL_PATH is not set.
    endlocal
    exit /b 1
)
call install_task.cmd "%TASK_NAME%" "%SCRIPT_NAME%" "%INSTALL_PATH%"
if %errorlevel% neq 0 (
    echo %date% %time% - Error installing main task.
    endlocal
    exit /b 1
)
echo [%date% %time%] - Primary task installation completed.

:: Start the main task
echo [%date% %time%] - Starting main task...
schtasks /run /tn "%TASK_NAME%"

echo [%date% %time%] - Deployment script completed.

endlocal