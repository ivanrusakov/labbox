@echo off
setlocal enabledelayedexpansion
:: Default Priority: REALTIME. The system may become unresponsive. To improve responsiveness during execution, consider lowering this value (see start /?).
set PRIORITY=REALTIME
:: Set delay in seconds for each CPU loop
set DELAYINSEC=180

:: Check if DELAYINSEC is provided as an argument, and override default if it is
if not "%~1"=="" set DELAYINSEC=%~1

:: Get the number of logical processors
set CPUs=%NUMBER_OF_PROCESSORS%

set msg=Starting CPU loops: %NUMBER_OF_PROCESSORS%
echo %date% %time% - %msg%
eventcreate /l System /t Information /id 102 /d "%msg%" >nul

:: Loop to start stress processes
for /L %%a in (1,1,%CPUs%) do (
    set msg=Starting CPU loop #%%a
    echo %date% %time% - !msg!
    eventcreate /l System /t Information /id 103 /d "!msg!" >nul
    cmd /c start /%PRIORITY% cscript.exe cpu_stress.vbs /DelayInSec:%DELAYINSEC% >nul
)

echo All CPU stress loops started.
endlocal