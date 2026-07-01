@echo off
setlocal

:: --- ADMIN ESCALATION BLOCK ---
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' ( goto gotPrivileges )
echo Requesting administrative privileges...
powershell -Command "Start-Process '%~f0' -ArgumentList 'ELEV' -Verb RunAs"
exit /b

:gotPrivileges
cd /d %~dp0

set "PROJECT_DIR=C:\Tools\ModiUTubeDownloader"
set "DESKTOP_DIR=%USERPROFILE%\Desktop"

:: --- 1. CREATE DIRECTORIES ---
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
if not exist "%DESKTOP_DIR%\Audio_Downloads" mkdir "%DESKTOP_DIR%\Audio_Downloads"
if not exist "%DESKTOP_DIR%\Video_Downloads" mkdir "%DESKTOP_DIR%\Video_Downloads"

echo ========================================================
echo Creating configuration files with exact content...
echo ========================================================

:: --- 2. CREATE DATA FILES ---
:: Audio.txt
(
    echo https://www.youtube.com/watch?v=zXzzMjrrrFU^&list=OLAK5uy_leg-jn0nMirTa-8gy9m9trbLsvULL1IWs^&index=6
    echo https://www.youtube.com/watch?v=5kw5smhdnN8
    echo https://www.youtube.com/watch?v=0QXvpDsgJr8
    echo https://www.youtube.com/watch?v=zGFbeLY-2zg^&list=TLGGgVtqCcdCT18zMDA2MjAyNg^&index=12
    echo.
) > "%PROJECT_DIR%\Audio.txt"

:: Video.txt
(
    echo https://www.youtube.com/watch?v=kcco0vGx_xE
    echo https://www.youtube.com/watch?v=uuGyA-lmCho
    echo.
) > "%PROJECT_DIR%\Video.txt"

echo Setup complete! Your files are now exactly as specified.
pause