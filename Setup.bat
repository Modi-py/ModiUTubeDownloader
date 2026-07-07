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

set "TOOLS_DIR=C:\Tools"
if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"

set "PROJECT_DIR=C:\Tools\ModiUTubeDownloader"
set "DESKTOP_DIR=%USERPROFILE%\Desktop"

if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
if not exist "%DESKTOP_DIR%\Audio_Downloads" mkdir "%DESKTOP_DIR%\Audio_Downloads"
if not exist "%DESKTOP_DIR%\Video_Downloads" mkdir "%DESKTOP_DIR%\Video_Downloads"

:: Configure Video_Downloads with a system icon from shell32.dll
(
echo [.ShellClassInfo]
echo IconResource=%SystemRoot%\System32\shell32.dll,129
) > "%DESKTOP_DIR%\Video_Downloads\desktop.ini"

:: Configure Audio_Downloads with a system icon from shell32.dll
(
echo [.ShellClassInfo]
echo IconResource=%SystemRoot%\System32\shell32.dll,128
) > "%DESKTOP_DIR%\Audio_Downloads\desktop.ini"

:: Apply required attributes for Windows to process the desktop.ini
attrib +s +h "%DESKTOP_DIR%\Video_Downloads\desktop.ini"
attrib +s +h "%DESKTOP_DIR%\Audio_Downloads\desktop.ini"
attrib +r "%DESKTOP_DIR%\Video_Downloads"
attrib +r "%DESKTOP_DIR%\Audio_Downloads"

echo ========================================================
echo Creating configuration files with exact content...
echo ========================================================

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

:: --- INSTALL LATEST VERSIONS VIA WINGET ---
echo Checking and installing software...

:: --- CHECK FOR WINGET ---
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo ========================================================
    echo ERROR: Windows Package Manager (winget) is not found.
    echo.
    echo To fix this, please:
    echo 1. Open the Microsoft Store.
    echo 2. Search for 'App Installer'.
    echo 3. Install/Update it.
    echo.
    echo Alternatively, run this in PowerShell as Administrator:
    echo Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
    echo ========================================================
    pause
    exit /b
)

:: FFmpeg
winget list --id Gyan.FFmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing FFmpeg...
    winget install --id Gyan.FFmpeg -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\FFmpeg"
	setx /M PATH "%PATH%;%TOOLS_DIR%\FFmpeg\bin"
) else (
    echo FFmpeg is already installed, skipping.
)

:: Python 3
winget list --id Python.Python.3.12 >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Python 3.12...
    winget install --id Python.Python.3.12 -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\Python312"
	setx /M PATH "%PATH%;%TOOLS_DIR%\Python312"
) else (
    echo Python 3.12 is already installed, skipping.
)

:: yt-dlp
winget list --id yt-dlp.yt-dlp >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing yt-dlp...
    winget install --id yt-dlp.yt-dlp -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%"
	setx /M PATH "%PATH%;%TOOLS_DIR%"
) else (
    echo yt-dlp is already installed, skipping.
)

:: Deno
winget list --id DenoLand.Deno >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing Deno...
    winget install --id DenoLand.Deno -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\Deno"
	setx /M PATH "%PATH%;%TOOLS_DIR%\Deno"
) else (
    echo Deno is already installed, skipping.
)


echo Setup complete! Your files are now exactly as specified.
pause