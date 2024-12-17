@echo off
set TASK_NAME="Server Initial Configuration Task"
set SCRIPT_NAME="cpu_stress.cmd"
set INSTALL_PATH=
cmd /c start install_task.cmd %TASK_NAME% %SCRIPT_NAME% %INSTALL_PATH%
timeout /t 15 /nobreak
cmd /c start schtasks /run /tn %TASK_NAME%
cmd /c start del /q *