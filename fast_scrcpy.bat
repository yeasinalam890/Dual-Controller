@echo off
title Android Mirror - Universal Controller & Keymapper
cd /d "%~dp0"
cls

if not exist "adb.exe" (
    echo [ERROR] adb.exe not found!
    pause
    exit /b
)

:: Detect Python executable safely
set "PY_CMD="
where pythonw >nul 2>nul && set "PY_CMD=pythonw"
if not defined PY_CMD (
    where python >nul 2>nul && set "PY_CMD=python"
)
if not defined PY_CMD (
    if exist "%LocalAppData%\Programs\Python\Python*\pythonw.exe" (
        for /d %%I in ("%LocalAppData%\Programs\Python\Python*") do set "PY_CMD=%%I\pythonw.exe"
    ) else if exist "C:\Python*\pythonw.exe" (
        for /d %%I in ("C:\Python*") do set "PY_CMD=%%I\pythonw.exe"
    )
)

:MENU
cls
echo ======================================================
echo           SCRCPY CONTROLLER + KEYMAPPER
echo ======================================================
echo.
echo  [1] USB Cable Mode (120 FPS / Lowest Latency)
echo  [2] WiFi Mode (Connect via Saved / Manual IP)
echo  [3] Wireless Pairing (Android 11+ No-Cable Setup)
echo  [4] Legacy Cable Setup (Port 5555 via USB Cable)
echo  [5] Reset Saved WiFi IP Address
echo  [6] Exit
echo.
echo ======================================================
set /p mode="Choose connection type (1/2/3/4/5/6): "

if "%mode%"=="1" goto USB_MODE
if "%mode%"=="2" goto WIFI_MODE
if "%mode%"=="3" goto PAIR_MODE
if "%mode%"=="4" goto LEGACY_SETUP
if "%mode%"=="5" goto RESET_IP
if "%mode%"=="6" exit
goto MENU

:USB_MODE
cls
if defined PY_CMD (
    if exist "server.py" start "" "%PY_CMD%" server.py
)
echo [Connecting via USB Cable]...
scrcpy.exe -d --audio-codec=aac --audio-buffer=40 --display-buffer=0 --max-fps=120 --video-bit-rate=16M --max-size=1080 --stay-awake
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Running USB fallback mode...
    scrcpy.exe -d --no-audio --max-size=1080
)
goto END

:WIFI_MODE
cls
echo [Connecting via WiFi]...
if exist "phone_target.txt" (
    set /p phone_target=<phone_target.txt
    echo Using saved target: %phone_target%
) else (
    set /p phone_target="Enter Phone IP:Port (e.g. 192.168.1.2:42845): "
    echo %phone_target%>phone_target.txt
)

echo Connecting to %phone_target%...
adb.exe connect %phone_target%
echo.

if defined PY_CMD (
    if exist "server.py" start "" "%PY_CMD%" server.py
)

scrcpy.exe -s %phone_target% --audio-codec=aac --audio-buffer=50 --display-buffer=0 --max-fps=90 --video-bit-rate=10M --max-size=1080 --stay-awake
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Running WiFi fallback mode...
    scrcpy.exe -s %phone_target% --no-audio --max-size=1080
)
goto END

:PAIR_MODE
cls
echo ======================================================
echo            WIRELESS DEBUGGING PAIRING (Android 11+)
echo ======================================================
echo.
set /p pair_target="Enter Pairing IP & Port: "
set /p pair_code="Enter 6-Digit Pairing Code: "
echo.
adb.exe pair %pair_target% %pair_code%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Pairing failed. Ensure your PC and phone are on the exact same Wi-Fi.
    pause
    goto MENU
)

echo.
echo ------------------------------------------------------
echo Pairing successful!
echo Look at your main Wireless debugging screen for the
echo Connection IP:Port (the port differs from the pair port).
echo ------------------------------------------------------
set /p phone_target="Enter Main Connection IP:Port: "
echo %phone_target%>phone_target.txt
echo.
echo Connecting...
adb.exe connect %phone_target%
echo.
echo Target saved. Choose option [2] anytime to mirror.
pause
goto END

:LEGACY_SETUP
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
set /p phone_ip="Enter Phone Local IP (e.g. 192.168.1.2): "
echo %phone_ip%:5555>phone_target.txt
echo Saved target %phone_ip%:5555. Choose option [2] to connect wirelessly.
pause
goto END

:RESET_IP
cls
if exist "phone_target.txt" (
    del /f /q "phone_target.txt"
    echo Saved IP target has been deleted.
) else (
    echo No saved IP address found.
)
pause
goto MENU

:END
echo.
pause