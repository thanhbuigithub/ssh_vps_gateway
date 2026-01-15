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

echo.
echo [Optional] To use a Private Key for the VPS connection (instead of password),
echo provide the full path to the key file.
echo Example: C:\Users\YourName\.ssh\my_key
set /p KEY_PATH="Enter path to Private Key (Leave empty to use Password): "

set SSH_DIR=%USERPROFILE%\.ssh
set CONFIG_FILE=%SSH_DIR%\config

if not exist "%SSH_DIR%" mkdir "%SSH_DIR%"

echo.
echo Adding configuration to %CONFIG_FILE%...

(
    echo.
    echo # Gateway Host Configuration
    echo Host vps-gateway
    echo     HostName %VPS_HOST%
    echo     User tunnel
    if not "%KEY_PATH%"=="" (
        echo     IdentityFile %KEY_PATH%
    )
    echo.
    echo # Target Host Configuration
    echo Host kaggle
    echo     HostName localhost
    echo     Port 2222
    echo     User root
    echo     ProxyJump vps-gateway
    echo     # KeepAlive to prevent timeouts
    echo     ServerAliveInterval 60
) >> "%CONFIG_FILE%"

echo.
echo ==================================================
echo [SUCCESS] Configuration updated!
echo ==================================================
echo.
echo Usage:
echo   ssh kaggle
echo.
echo Troubleshooting:
echo - If you provided a key, ensure the path is correct and accessible.
echo - If you didn't, you will be prompted for the 'tunnel' password.
echo.
pause
