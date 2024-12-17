@echo off
rem This script creates a scheduled task to run cpu_stress.cmd at system startup.
rem It uses the current script directory to determine the path to cpu_stress.cmd.

set SCRIPT_DIR=%~dp0
set SCRIPT_PATH="%SCRIPT_DIR%cpu_stress.cmd"

echo Creating scheduled task "CPU_Stress_Task" to run at startup...
schtasks /create /f /sc onstart /ru "SYSTEM" /tn "CPU_Stress_Task" /tr %SCRIPT_PATH%

if %ERRORLEVEL%==0 (
    echo Scheduled task created successfully.
) else (
    echo Failed to create scheduled task.
    exit /b 1
)
