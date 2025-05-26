@echo off
setlocal enabledelayedexpansion
REM Get Wi-Fi SSID (network name)
for /f "tokens=2 delims=:" %%A in ('netsh wlan show interfaces ^| findstr /R "^\s*SSID"') do (
    set "SSID=%%A"
)
REM Trim spaces from SSID
set "SSID=%SSID:~1%"

REM Get local IP for Wi-Fi interface (starts with 192.168.102.)
for /f "tokens=14" %%A in ('ipconfig ^| findstr /R "IPv4.*192\.168\.102\."') do (
    set "LOCAL_IP=%%A"
)
echo Network Name (SSID): %SSID%
echo Local IP Address: %LOCAL_IP%





REM Initialize Docker Swarm
docker swarm init --advertise-addr %LOCAL_IP%

