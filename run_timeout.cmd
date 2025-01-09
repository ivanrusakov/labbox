@echo off
setlocal

if "%~1"=="" (
    echo Please provide the waiting time in seconds.
    exit /b 1
)

if "%~2"=="" (
    echo Please provide the command to execute.
    exit /b 1
)

set wait_time=%~1
set command_to_execute=%~2

echo Executing command: %command_to_execute% with timeout of %wait_time% seconds...
timeout /t %wait_time% /nobreak >nul
%command_to_execute%

endlocal