@echo off
:: Deploy script for CPU Stress Test used in the lab and configured in JSON template
set TASK_NAME="Server Initial Configuration Task"
set SCRIPT_NAME="cpu_stress.cmd"
set INSTALL_PATH=
set WAIT_TIME=20
:: Install the task
cmd /c start install_task.cmd %TASK_NAME% %SCRIPT_NAME% %INSTALL_PATH%
:: How many seconds to wait before cleanup and running the task (default 20)
choice /d y /t %WAIT_TIME% > nul
:: Run the installed task
cmd /c start schtasks /run /tn %TASK_NAME%
:: Cleanup files
cmd /c start del /q *
echo Deployment script completed.