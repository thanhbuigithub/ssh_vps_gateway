@echo off
setlocal EnableDelayedExpansion

echo ==================================================
echo      Windows SSH Config for VPS Gateway
echo ==================================================
echo.
echo This script will configure your SSH client to easily connect to Kaggle
echo via your VPS Gateway.
echo.

set /p VPS_HOST="Enter your VPS IP Address (or Domain): "

if "%VPS_HOST%"=="" (
    echo Error: IP Address is required.
    pause
    exit /b
)

set SSH_DIR=%USERPROFILE%\.ssh
set CONFIG_FILE=%SSH_DIR%\config

if not exist "%SSH_DIR%" mkdir "%SSH_DIR%"

echo.
echo Adding configuration to %CONFIG_FILE%...

(
    echo.
    echo Host kaggle
    echo     HostName localhost
    echo     Port 2222
    echo     User root
    echo     ProxyJump tunnel@%VPS_HOST%
    echo     # KeepAlive to prevent timeouts
    echo     ServerAliveInterval 60
) >> "%CONFIG_FILE%"

echo.
echo ==================================================
echo [SUCCESS] Configuration added!
echo ==================================================
echo.
echo Usage:
echo   ssh kaggle
echo.
echo 1. First password prompt: For 'tunnel@%VPS_HOST%'
echo 2. Second password prompt: For 'root@localhost' (Kaggle)
echo.
pause
