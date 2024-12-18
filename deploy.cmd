@echo off
:: Deploy script for CPU Stress Test used in the lab and configured in JSON template

set TASK_NAME="Server Initial Configuration Task"
set SCRIPT_NAME="cpu_stress.cmd"
set INSTALL_PATH=

echo %date% %time% - Starting deployment script...
:: Install the task
call install_task.cmd %TASK_NAME% %SCRIPT_NAME% %INSTALL_PATH% >nul
echo %date% %time% - Deployment script completed.

:: Run the installed task. Consider that task may have own delay.
echo %date% %time% - Running the task...
schtasks /run /tn %TASK_NAME% >nul