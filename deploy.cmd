@echo off
:: Deploy script for CPU Stress Test used in the lab and configured in JSON template

:: Set default values
set TASK_NAME="Server Initial Configuration Task"
set SCRIPT_NAME="cpu_stress.cmd"
set INSTALL_PATH=
set DELAY_SECONDS=60
set START_TASK_NAME="Praparing Initial Configuration Task"

:: Override defaults with command-line arguments if provided
if not "%~1"=="" set "TASK_NAME=%~1"
if not "%~2"=="" set "SCRIPT_NAME=%~2"
if not "%~3"=="" set "INSTALL_PATH=%~3"
if not "%~4"=="" set "DELAY_SECONDS=%~4"
if not "%~5"=="" set "START_TASK_NAME=%~5"

echo %date% %time% - Starting deployment script...

:: Install the main task
call install_task.cmd %TASK_NAME% %SCRIPT_NAME% %INSTALL_PATH%
echo %date% %time% - Main task installation completed.

:: Create a secondary task to start the main task after a delay
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /a hh=%%a, mm=1%%b+%DELAY_SECONDS%/60, ss=1%%c+%DELAY_SECONDS% %% 60
    if %mm% geq 60 set /a hh=hh+1, mm=mm-60
    if %hh% geq 24 set hh=hh-24
    set hh=00%hh%
    set start_time=%hh%:%mm:~1%:%ss:~1%
    set ss=00%ss%
    set start_time=%start_time:~-8%
    set start_time=00%hh%:00%mm%:00%ss%
)
set start_time=%start_time:~-2,2%:%start_time:~-4,2%:%start_time:~-6,2%
schtasks /create /tn "%START_TASK_NAME%" /tr "schtasks /run /tn \"%TASK_NAME%\"" /sc once /st %start_time% /sd %date% /f >nul
if %errorlevel% neq 0 (
    echo %date% %time% - Error creating secondary task.
    schtasks /run /tn "%TASK_NAME%" /f >nul
)

echo %date% %time% - Secondary task created to start the main task after %DELAY_SECONDS% seconds.

:: Run the secondary task immediately
echo %date% %time% - Running the main task immediately...
schtasks /run /tn "%START_TASK_NAME%" >nul

:: Final log
echo %date% %time% - Deployment script completed.
