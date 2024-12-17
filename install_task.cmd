REM @echo off
rem This script installs files listed in a configuration file and creates/updates a scheduled task.

setlocal enabledelayedexpansion

:: Check for required parameters
if "%~1"=="" (
    echo Usage: %~nx0 TASK_NAME SCRIPT_NAME [INSTALL_PATH]
    echo Example: %~nx0 "MyStartupTask" "MyScript.cmd" "C:\MyCustomFolder"
    exit /b 1
)

:: Parameters
set TASK_NAME=%~1
set SCRIPT_NAME=%~2
set INSTALL_PATH=%~3

:: Derive CONFIG_FILE from SCRIPT_NAME
set CONFIG_FILE=%~n2.cfg

:: Set default installation path if none provided
if "%INSTALL_PATH%"=="" (
    set INSTALL_PATH=%ProgramData%\%TASK_NAME%
)

:: Resolve paths
set SCRIPT_DIR=%~dp0
set CONFIG_PATH=%SCRIPT_DIR%%CONFIG_FILE%
set SCRIPT_SRC=%SCRIPT_DIR%%SCRIPT_NAME%
set SCRIPT_DEST=%INSTALL_PATH%\%SCRIPT_NAME%

:: Validate SCRIPT_NAME existence
if not exist "%SCRIPT_SRC%" (
    echo Error: Main script "%SCRIPT_NAME%" not found in "%SCRIPT_DIR%".
    exit /b 1
)

:: Create installation directory if it does not exist
if not exist "%INSTALL_PATH%" (
    echo Creating installation folder: "%INSTALL_PATH%"...
    mkdir "%INSTALL_PATH%"
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to create installation folder "%INSTALL_PATH%".
        exit /b 1
    )
)

:: Copy the main script (always included)
echo Copying main script "%SCRIPT_NAME%" to "%INSTALL_PATH%"...
copy /Y "%SCRIPT_SRC%" "%SCRIPT_DEST%" >nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to copy main script "%SCRIPT_NAME%".
    exit /b 1
)

echo DBG "%CONFIG_PATH%"
:: Process the configuration file if it exists
if exist "%CONFIG_PATH%" (
    echo Reading files from configuration file "%CONFIG_FILE%"...
) else (
    echo Warning: Configuration file "%CONFIG_FILE%" not found. Only main script is copied.
)

:: Set task path to the main script
set TASK_PATH="%INSTALL_PATH%\%SCRIPT_NAME%"

:: Create or update the scheduled task
echo Creating/updating scheduled task "%TASK_NAME%" to run "%TASK_PATH%" at startup...
schtasks /create /f /sc onstart /ru "SYSTEM" /tn "%TASK_NAME%" /tr %TASK_PATH% >nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to create or update scheduled task "%TASK_NAME%".
    exit /b 1
)

:: Log success to the event log
eventcreate /l System /t Information /id 101 /d "Task installed successfully: %TASK_NAME%"
if %ERRORLEVEL% NEQ 0 (
    echo Warning: Failed to write success log to the event log.
)

echo Installation and task setup complete.
exit /b 0
