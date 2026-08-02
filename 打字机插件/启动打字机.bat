@echo off
title Typewriter
cd /d "%~dp0"

REM Use portable AutoHotkey64.exe (no install needed)
set "AHK=%~dp0AutoHotkey\AutoHotkey64.exe"

if not exist "%AHK%" (
    echo [Error] AutoHotkey64.exe not found
    echo Please make sure AutoHotkey folder is in the same directory.
    pause
    exit /b 1
)

echo Starting Typewriter...
echo.
echo   Ctrl+Alt+D  Toggle Typewriter Mode
echo     ON:  Ctrl+V types clipboard char-by-char
echo     OFF: Ctrl+V normal paste
echo   Ctrl+Alt+T  Manual start typing
echo   Ctrl+Alt+P  Pause/Resume
echo   Ctrl+Alt+S  Stop
echo   Ctrl+Alt++  Speed up
echo   Ctrl+Alt+-  Slow down
echo   Ctrl+Alt+Q  Quit
echo.
echo This window can be closed. Plugin runs in background (tray icon visible).
start "" "%AHK%" "%~dp0Typewriter.ahk"
timeout /t 2 >nul
exit
