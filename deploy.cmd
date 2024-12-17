@echo off
:: Deploy script for CPU Stress Test used in the lab and configured in JSON template
set TASK_NAME="Server Initial Configuration Task"
set SCRIPT_NAME="cpu_stress.cmd"
set INSTALL_PATH=
cmd /c start install_task.cmd %TASK_NAME% %SCRIPT_NAME% %INSTALL_PATH%
:: How many seconds to wait before cleanup and running the task
timeout /t 10 /nobreak
cmd /c start del /q *
::cmd /c start schtasks /run /tn %TASK_NAME%
echo Deployed script completed.