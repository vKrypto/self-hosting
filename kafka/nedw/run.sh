@echo off
setlocal enabledelayedexpansion

REM Step 1: Detect local IP address with subnet 192.168.102.*
set "LOCAL_IP="

for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /R "IPv4.*192\.168\.102\."') do (
    set "IP=%%A"
    set "IP=!IP:~1!"
    if not defined LOCAL_IP (
        set "LOCAL_IP=!IP!"
    )
)

if not defined LOCAL_IP (
    echo ERROR: No IP address found on subnet 192.168.102.*
    pause
    exit /b 1
)

echo Detected local IP: %LOCAL_IP%

REM Step 2: Check if node is already part of a swarm
docker info --format "{{.Swarm.LocalNodeState}}" > temp_swarm_state.txt 2>nul

set /p SWARM_STATE=<temp_swarm_state.txt
del temp_swarm_state.txt

if /I "%SWARM_STATE%"=="active" (
    echo Docker Swarm is already active on this node.
    REM Step 3: Check if node is manager
    docker info --format "{{.Swarm.ControlAvailable}}" > temp_manager_state.txt 2>nul
    set /p IS_MANAGER=<temp_manager_state.txt
    del temp_manager_state.txt

    if /I "%IS_MANAGER%"=="true" (
        echo This node is already a swarm manager.
    ) else (
        echo This node is a worker node. Please run docker swarm leave and then re-run this script to become manager.
        pause
        exit /b 1
    )
) else (
    REM Step 3: Initialize swarm manager
    echo Initializing Docker Swarm manager on %LOCAL_IP%...
    docker swarm init --advertise-addr %LOCAL_IP%
    if errorlevel 1 (
        echo Failed to initialize Docker Swarm.
        pause
        exit /b 1
    )
    echo Docker Swarm initialized successfully.
)

pause
