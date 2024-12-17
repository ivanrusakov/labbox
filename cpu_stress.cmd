@echo off
setlocal enabledelayedexpansion
REM Default priority: REALTIME. Change this to lower value if you want to make the system more responsive.
set PRIORITY=REALTIME

REM Get the number of logical processors
set CPUs=%NUMBER_OF_PROCESSORS%
set msg=Starting CPU loops: %NUMBER_OF_PROCESSORS%
echo %date% %time% - %msg%
eventcreate /l System /t Information /id 102 /d "%msg%"

REM Loop to start stress processes
for /L %%a in (1,1,%CPUs%) do (
    set msg=Starting CPU loop #%%a
    echo %date% %time% - !msg!
    eventcreate /l System /t Information /id 103 /d "!msg!"
    cmd /c start /%PRIORITY% cscript.exe cpu_stress.vbs /DelayInSec:5
)

echo All CPU stress loops started.
endlocal
exit /b 0