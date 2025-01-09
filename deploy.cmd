@echo off
setlocal enabledelayedexpansion

:: Description: This script is used to deploy and run a task to the Windows Task Scheduler.

:: Set default values
set "TASK_NAME=Task Name"
set "SCRIPT_NAME=script.cmd"
set "INITIAL_DELAY=60"
set "INSTALL_PATH="

:: Override defaults with command-line arguments if provided
if not "%~1"=="" set "TASK_NAME=%~1"
if not "%~2"=="" set "SCRIPT_NAME=%~2"
if not "%~3"=="" set "INITIAL_DELAY=%~3"
if not "%~4"=="" set "INSTALL_PATH=%~4"

:: Start logging
echo [%date% %time%] - Starting deployment script...

rem call install_task.cmd "%TASK_NAME%" "%SCRIPT_NAME%" "%INSTALL_PATH%"
if %errorlevel% neq 0 (
    echo %date% %time% - Error installing main task.
    endlocal
    exit /b 1
)
echo [%date% %time%] - Primary task installation completed.

echo [%date% %time%] - Starting main task in background with delay in %INITIAL_DELAY% seconds...
start run_timeout.cmd %INITIAL_DELAY% "schtasks /run /tn "%TASK_NAME%" >nul"
if %errorlevel% neq 0 (
    echo %date% %time% - Error running the main task.
    endlocal
    exit /b 1
)

echo [%date% %time%] - Deployment script completed.

endlocal