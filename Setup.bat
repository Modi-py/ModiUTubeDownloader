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
set "PROJECT_DIR=C:\Tools\ModiUTubeDownloader"
set "DESKTOP_DIR=%USERPROFILE%\Desktop"

if not exist "%TOOLS_DIR%" mkdir "%TOOLS_DIR%"
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
if not exist "%DESKTOP_DIR%\Audio_Downloads" mkdir "%DESKTOP_DIR%\Audio_Downloads"
if not exist "%DESKTOP_DIR%\Video_Downloads" mkdir "%DESKTOP_DIR%\Video_Downloads"

attrib -r "%DESKTOP_DIR%\Video_Downloads"
attrib -r "%DESKTOP_DIR%\Audio_Downloads"

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


:: --- DOWNLOAD PYTHON SCRIPT FROM GITHUB ---
echo Downloading 'Download the links.py' to Desktop...
set "GITHUB_URL=https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/Download%%20the%%20links.py"
curl -L -o "%DESKTOP_DIR%\Download_the_links.py" "%GITHUB_URL%"

if exist "%DESKTOP_DIR%\Download_the_links.py" (
    echo Download successful!
) else (
    echo ERROR: Failed to download the python script. Please check the URL.
)


:: --- DOWNLOAD AUDIO & TEXT files FROM GITHUB and putting them in the TOOLS FOLDER ---
echo Downloading 'Audio.txt' and 'Video.txt' to Tools Folder...
set "GITHUB_AUDIO_URL=https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/Audio.txt"
set "GITHUB_VIDEO_URL=https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/Video.txt"
curl -L -o "%TOOLS_DIR%\Audio.txt" "%GITHUB_AUDIO_URL%"
curl -L -o "%TOOLS_DIR%\Video.txt" "%GITHUB_VIDEO_URL%"

if exist "%TOOLS_DIR%\Audio.txt" (
    echo Download Audio.txt successful!
) else (
    echo ERROR: Failed to download the Audio.txt file. Please check the URL.
)
if exist "%TOOLS_DIR%\Video.txt" (
    echo Download Video.txt successful!
) else (
    echo ERROR: Failed to download the Video.txt file. Please check the URL.
)


echo ========================================================
echo Creating configuration files with exact content...
echo ========================================================


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

:: Helper function to add to PATH only if not present
set "ADD_PATH_VAR=false"
if not "%PATH%"=="%PATH:C:\Tools\FFmpeg\bin=%" set "ADD_PATH_VAR=true"

:: Install/Check logic
winget install --id Gyan.FFmpeg -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\FFmpeg"
if not "%PATH%"=="%PATH:C:\Tools\FFmpeg\bin=%" (echo FFmpeg path exists) else (setx /M PATH "%PATH%;%TOOLS_DIR%\FFmpeg\bin")

winget install --id Python.Python.3.12 -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\Python312"
if not "%PATH%"=="%PATH:C:\Tools\Python312=%" (echo Python path exists) else (setx /M PATH "%PATH%;%TOOLS_DIR%\Python312")

winget install --id yt-dlp.yt-dlp -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%"
if not "%PATH%"=="%PATH:C:\Tools=%" (echo yt-dlp path exists) else (setx /M PATH "%PATH%;%TOOLS_DIR%")

winget install --id DenoLand.Deno -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\Deno"
if not "%PATH%"=="%PATH:C:\Tools\Deno=%" (echo Deno path exists) else (setx /M PATH "%PATH%;%TOOLS_DIR%")



echo Setup complete! Your files are now exactly as specified.
pause