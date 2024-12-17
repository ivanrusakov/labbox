@echo off
rem This script creates a scheduled task to run cpu_stress.cmd at system startup.
rem It uses the current script directory to determine the path to cpu_stress.cmd.

set SCRIPT_DIR=%~dp0
set SCRIPT_PATH="%SCRIPT_DIR%cpu_stress.cmd"
set TASK_NAME=""
set TASK_NAME=%TASK_NAME%

echo Creating scheduled task %TASK_NAME% to run at startup...
echo schtasks /create /f /sc onstart /ru "SYSTEM" /tn %TASK_NAME% /tr %SCRIPT_PATH% || goto :err

if %ERRORLEVEL%==0 (
    echo Scheduled task created successfully.
) else (
    echo Failed to create scheduled task.
    exit /b 1
)
echo eventcreate /l System /t Information /id 101 /d "Task installed successfully: %TASK_NAME%" || goto :err

goto :EOF
:err
echo Script failed with error #%errorlevel%.
exit /b %errorlevel%