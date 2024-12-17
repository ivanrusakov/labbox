@echo off
rem This script creates a scheduled task to run cpu_stress.cmd at system startup.
rem It uses the current script directory to determine the path to cpu_stress.cmd.

set -e
set SCRIPT_DIR=%~dp0
set SCRIPT_PATH="%SCRIPT_DIR%cpu_stress.cmd"
set TASK_NAME=%TASK_NAME%

echo Creating scheduled task %TASK_NAME% to run at startup...
schtasks /create /f /sc onstart /ru "SYSTEM" /tn %TASK_NAME% /tr %SCRIPT_PATH%

if %ERRORLEVEL%==0 (
    echo Scheduled task created successfully.
) else (
    echo Failed to create scheduled task.
    exit /b 1
)
eventcreate /l System /t Information /id 1001 /d "Task installed successfully: %TASK_NAME%"