@echo off
setlocal enabledelayedexpansion

:: Check if DELAYINSEC is provided as an argument, and override default if it is. Set delay in seconds for each CPU loop before start.
if not "%~1"=="" (
    set DELAYINSEC=%~1
) else (
    set DELAYINSEC=2
)
:: Get the number of logical processors, or use provided argument if available
if not "%~2"=="" (
    set CPUs=%~2
) else (
    set CPUs=%NUMBER_OF_PROCESSORS%
)
:: Check if PRIORITY is provided as an argument, and override default if it is. Default Priority: REALTIME. The system may (will) become unresponsive. To improve responsiveness during execution, consider lowering this value (see start /?).
if not "%~3"=="" (
    set PRIORITY=%~3
) else (
    set PRIORITY=REALTIME
)
:: Check if INITIAL_DELAY is provided as an argument, and override default if it is. Set initial delay in seconds before starting the loop.
if not "%~4"=="" (
    set INITIAL_DELAY=%~4
) else (
    set INITIAL_DELAY=60
)

set msg=Starting CPU loops: %NUMBER_OF_PROCESSORS% with %DELAYINSEC% second delay between each loop, priority set to %PRIORITY%, and initial delay of %INITIAL_DELAY% seconds.
echo %date% %time% - %msg%
eventcreate /l System /t Information /id 102 /d "%msg%" >nul

:: Initial delay before starting the loop
echo Waiting for %INITIAL_DELAY% seconds before starting the CPU stress loops...
timeout /t %INITIAL_DELAY% /nobreak >nul

:: Loop to start stress processes
for /L %%a in (1,1,%CPUs%) do (
    set msg=Starting CPU loop #%%a
    echo %date% %time% - !msg!
    eventcreate /l System /t Information /id 103 /d "!msg!" >nul
    cmd /c start /%PRIORITY% cscript.exe cpu_stress.vbs /DelayInSec:%DELAYINSEC% >nul
)

echo All CPU stress loops started.
endlocal