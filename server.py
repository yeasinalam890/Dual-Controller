@echo off
title Android Mirror - Cable & WiFi Universal Launcher
cd /d "C:\Users\yeasi\OneDrive\Desktop\scrcpy\scrcpy-win64-v2.4"
cls

echo ======================================================
echo       SCRCPY DUAL CONTROLLER (Cable & WiFi)
echo ======================================================
echo.
echo  [1] USB Cable Mode (Ultra-Fast 120 FPS / Zero Lag)
echo  [2] WiFi Mode      (Wireless over same Network)
echo  [3] One-Time WiFi Setup (Enable Port 5555 via Cable)
echo  [4] Exit
echo.
echo ======================================================
set /p mode="Choose connection type (1/2/3/4): "

if "%mode%"=="1" goto USB_MODE
if "%mode%"=="2" goto WIFI_MODE
if "%mode%"=="3" goto SETUP_WIFI
if "%mode%"=="4" exit

:USB_MODE
cls
echo [Connecting via USB Cable]...
scrcpy.exe -d --no-audio --display-buffer=0 --max-fps=120 --video-bit-rate=16M --max-size=1080 --stay-awake
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Running USB fallback mode...
    scrcpy.exe -d --no-audio --max-size=1080
)
goto END

:WIFI_MODE
cls
echo [Connecting via WiFi]...
set /p phone_ip="Enter your Phone IP Address (e.g. 192.168.1.2): "
adb.exe connect %phone_ip%:5555
echo.
scrcpy.exe -e --no-audio --display-buffer=0 --max-fps=90 --video-bit-rate=10M --max-size=1080 --stay-awake
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Running WiFi fallback mode...
    scrcpy.exe -e --no-audio --max-size=1080
)
goto END

:SETUP_WIFI
cls
echo ======================================================
echo ONE-TIME SETUP: Plug your phone into USB cable first!
echo ======================================================
echo.
adb.exe kill-server
adb.exe start-server
adb.exe tcpip 5555
echo.
echo Port 5555 enabled! You can now unplug the cable.
echo Use option [2] to connect wirelessly.
echo.
pause
goto END

:END
echo.
pause
