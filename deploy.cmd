@echo off
:: Deploy script for CPU Stress Test used in the lab and configured in JSON template

set TASK_NAME="Server Initial Configuration Task"
set SCRIPT_NAME="cpu_stress.cmd"
set INSTALL_PATH=
:: Set default WAIT_TIME to 5 if not provided as a parameter
set WAIT_TIME=5

:: Check if WAIT_TIME is provided as an argument, and override default if it is
if not "%~1"=="" set WAIT_TIME=%~1

echo %date% %time% - Starting deployment script...
:: Install the task
call install_task.cmd %TASK_NAME% %SCRIPT_NAME% %INSTALL_PATH% >nul

:: How many seconds to wait before running the task and cleaning up
echo %date% %time% - Waiting for %WAIT_TIME% second(s)...
choice /d y /t %WAIT_TIME% > nul

:: Run the installed task. Consider that task may have own delay.
schtasks /run /tn %TASK_NAME% >nul

:: Cleanup files
del /q * >nul
echo %date% %time% - Deployment script completed.