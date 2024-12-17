@echo off
REM Get the number of logical processors
set CPUs=%NUMBER_OF_PROCESSORS%

for /L %%a in (1,1,%CPUs%) do (
    date /t & time /t & echo Starting CPU loop #%%a
    cmd /c start /REALTIME cscript.exe cpu_stress.vbs
)