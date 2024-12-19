@echo off
setlocal enabledelayedexpansion

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
:: Get the current date and time
<<<<<<< HEAD
for /f "tokens=1,2 delims= " %%A in ('cscript //nologo date_add.vbs %DELAY_SECONDS%') do (
    set "start_date=%%A"
    set "start_time=%%B"
)
:: Print the new time and date
echo The time %DELAY_SECONDS% seconds from now will be: %start_date% %start_time%

:: Create the secondary task
schtasks /create /tn "%START_TASK_NAME%" /tr "schtasks /run /tn \"%TASK_NAME%\"" /sc once /st %start_time% /sd %start_date% /f >nul
=======
for /f "tokens=1-4 delims=:." %%A in ("%time%") do (
    set hour=%%A
    set minute=%%B
    set second=%%C
    set centisecond=%%D
)
set currentDate=%date%

:: Normalize hour if it's in 12-hour format
if %hour% lss 10 set hour=0%hour%

:: Convert current time to seconds
set /a currentSeconds=(%hour% * 3600) + (%minute% * 60) + %second%

:: Add the specified number of seconds
set /a newTimeInSeconds=currentSeconds + DELAY_SECONDS

:: Handle overflow and adjust date if needed
if %newTimeInSeconds% geq 86400 (
    set /a newTimeInSeconds=newTimeInSeconds %% 86400
    for /f "tokens=1-3 delims=/" %%A in ("%currentDate%") do (
        set day=%%A
        set month=%%B
        set year=%%C
    )
    set /a day+=1
    :: Adjust for month and year overflow (simple handling for demo purposes)
    if %day% gtr 31 set /a day=1 & set /a month+=1
    if %month% gtr 12 set /a month=1 & set /a year+=1
    set currentDate=%day%/%month%/%year%
)

:: Calculate new hour, minute, and second
set /a newHour=newTimeInSeconds / 3600
set /a remainingSeconds=newTimeInSeconds %% 3600
set /a newMinute=remainingSeconds / 60
set /a newSecond=remainingSeconds %% 60

:: Format the output to ensure two digits for each component
if %newHour% lss 10 set newHour=0%newHour%
if %newMinute% lss 10 set newMinute=0%newMinute%
if %newSecond% lss 10 set newSecond=0%newSecond%

set start_time=%newHour%:%newMinute%:%newSecond%
:: Print the new time and date
echo The time %DELAY_SECONDS% seconds from now will be: %start_time% on %currentDate%
:: Create actual task
schtasks /create /tn "%START_TASK_NAME%" /tr "schtasks /run /tn \"%TASK_NAME%\"" /sc once /st %start_time% /sd %currentDate% /f >nul
>>>>>>> main
if %errorlevel% neq 0 (
    echo %date% %time% - Error creating secondary task.
    schtasks /run /tn "%TASK_NAME%" /f >nul
)

echo %date% %time% - Secondary task created to start the main task after %DELAY_SECONDS% seconds.

<<<<<<< HEAD
=======
endlocal
>>>>>>> main
:: Final log
echo %date% %time% - Deployment script completed.
