@echo off
setlocal enabledelayedexpansion

:: Deploy script for CPU Stress Test used in the lab and configured in JSON template

:: Set default values
set "TASK_NAME=Server Initial Configuration Task"
set "SCRIPT_NAME=cpu_stress.cmd"
set "INSTALL_PATH="

:: Override defaults with command-line arguments if provided
if not "%~1"=="" set "TASK_NAME=%~2"
if not "%~2"=="" set "SCRIPT_NAME=%~3"
if not "%~3"=="" set "INSTALL_PATH=%~4"

:: Start logging
echo [%date% %time%] - Starting deployment script...

call install_task.cmd "%TASK_NAME%" "%SCRIPT_NAME%" "%INSTALL_PATH%"
if %errorlevel% neq 0 (
    echo %date% %time% - Error installing main task.
    endlocal
    exit /b 1
)
echo [%date% %time%] - Primary task installation completed.

:: Start the main task
echo [%date% %time%] - Starting main task...
schtasks /run /tn "%TASK_NAME%" >nul
if %errorlevel% neq 0 (
    echo %date% %time% - Error running the main task.
    endlocal
    exit /b 1
)

echo [%date% %time%] - Deployment script completed.

endlocal