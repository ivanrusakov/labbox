@echo off
REM Default priority: REALTIME. Change this to lower value if you want to make system more responsive (see start /?).
set PRIORITY=REALTIME
REM Get the number of logical processors
set CPUs=%NUMBER_OF_PROCESSORS%
eventcreate /l System /t Information /id 102 /d "Starting CPU loops: %NUMBER_OF_PROCESSORS%"
for /L %%a in (1,1,%CPUs%) do (
    set msg=Starting CPU loop #%%a
    echo date /t & time /t & echo %msg%
    echo eventcreate /l System /t Information /id 103 /d "%msg%"
    echo cmd /c start /%PRIORITY% cscript.exe cpu_stress.vbs
)