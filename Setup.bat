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
echo.
echo Downloading 'Download the links.py' to %PROJECT_DIR...
echo.
set "GITHUB_URL_1=https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/Download_the_links.py"
curl -L -o "%PROJECT_DIR%\Download_the_links.py" "%GITHUB_URL_1%"
echo.
echo Creating shortcut on Desktop...
echo.
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP_DIR%\Download_the_links.lnk');$s.TargetPath='%PROJECT_DIR%\Download_the_links.py';$s.Save()"

:: Modify the existing shortcut icon using PowerShell
powershell -Command "$sh = New-Object -ComObject WScript.Shell; $s = $sh.CreateShortcut('%USERPROFILE%\Desktop\download_the_links.lnk'); $s.IconLocation = '%SystemRoot%\System32\SHELL32.dll, 122'; $s.Save()"
echo The icon for 'download_the_links.lnk' has been updated.
echo.


if exist "%PROJECT_DIR%\Download_the_links.py" (
    echo File downloaded and shortcut created successfully!
) else (
    echo ERROR: Failed to download the python script.
)
echo.

:: --- DOWNLOAD AUDIO & TEXT files FROM GITHUB and putting them in the TOOLS FOLDER ---
echo Downloading 'Audio.txt' and 'Video.txt' to %PROJECT_DIR...
echo.

set "GITHUB_AUDIO_URL=https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/Audio.txt"
set "GITHUB_VIDEO_URL=https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/Video.txt"
curl -L -o "%PROJECT_DIR%\Audio.txt" "%GITHUB_AUDIO_URL%"
echo.
curl -L -o "%PROJECT_DIR%\Video.txt" "%GITHUB_VIDEO_URL%"
echo.

if exist "%PROJECT_DIR%\Audio.txt" (
    echo Download Audio.txt successful!
) else (
    echo ERROR: Failed to download the Audio.txt file. Please check the URL.
)
echo.
if exist "%PROJECT_DIR%\Video.txt" (
    echo Download Video.txt successful!
) else (
    echo ERROR: Failed to download the Video.txt file. Please check the URL.
)

echo.
echo ========================================================
echo Creating configuration files with exact content...
echo ========================================================
echo.

echo Checking and installing software...
echo.

:: Installing using winget
::winget install --id Gyan.FFmpeg -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\FFmpeg"
::winget install --id Python.Python.3.12 -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\Python312"
::winget install --id yt-dlp.yt-dlp -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%"
::winget install --id DenoLand.Deno -e --silent --accept-source-agreements --accept-package-agreements --install-location "%TOOLS_DIR%\Deno"

:: Installing without winget:

:: 1. Python Installation
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Python is already installed. Skipping.
) else (
    echo Downloading and installing Python 3.12...
    curl -L -o "%TEMP%\python_installer.exe" "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"
    start /wait "" "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del "%TEMP%\python_installer.exe"
)
	:: IMPORTANT: Since the previous line contains "PrependPath=1", the PATH is been automatically added.

:: 2. FFmpeg
where ffmpeg >nul 2>&1
if %errorlevel% equ 0 (
    echo FFmpeg is already installed. Skipping.
) else (
    echo Downloading and setting up FFmpeg...
    curl -L -o "%TOOLS_DIR%\ffmpeg.zip" "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    powershell -Command "Expand-Archive -Path '%TOOLS_DIR%\ffmpeg.zip' -DestinationPath '%TOOLS_DIR%\temp_ffmpeg' -Force"
    for /d %%D in ("%TOOLS_DIR%\temp_ffmpeg\ffmpeg-*") do move "%%D" "%TOOLS_DIR%\FFmpeg"
    del "%TOOLS_DIR%\ffmpeg.zip"
    rd /s /q "%TOOLS_DIR%\temp_ffmpeg"
	powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';%TOOLS_DIR%\FFmpeg\bin', 'Machine')"
)

:: 3. yt-dlp
where yt-dlp >nul 2>&1
if %errorlevel% equ 0 (
    echo yt-dlp is already installed. Skipping.
) else (
    echo Downloading yt-dlp...
    curl -L -o "%TOOLS_DIR%\yt-dlp.exe" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
	powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';%TOOLS_DIR%', 'Machine')"
)

:: 4. Deno
where deno >nul 2>&1
if %errorlevel% equ 0 (
    echo Deno is already installed. Skipping.
) else (
    echo Setting up Deno...
    curl -L -o "%TOOLS_DIR%\deno.zip" "https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip"
    powershell -Command "Expand-Archive -Path '%TOOLS_DIR%\deno.zip' -DestinationPath '%TOOLS_DIR%\Deno' -Force"
    del "%TOOLS_DIR%\deno.zip"
	powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';%TOOLS_DIR%\Deno', 'Machine')"
)
echo.

:: This is a better way of updating PATHs, instead of using CMD to add new PATHs as this code below:
::setx /M PATH "%PATH%;%TOOLS_DIR%\Deno"
::setx /M PATH "%PATH%;%TOOLS_DIR%\FFmpeg\bin"
::setx /M PATH "%PATH%;%TOOLS_DIR%"



:: pyperclip: Check if installed, and if no - install it.
:: --- PREFER LOCAL PYTHON, FALL BACK TO SYSTEM ---
if exist "%TOOLS_DIR%\Python312\python.exe" (
    set "PYTHON_EXE=%TOOLS_DIR%\Python312\python.exe"
) else (
    set "PYTHON_EXE=python"
)

echo Using Python at: %PYTHON_EXE%

:: --- CHECK AND INSTALL PYPERCLIP ---
echo Checking for pyperclip...
"%PYTHON_EXE%" -m pip show pyperclip >nul 2>&1

if %errorlevel% neq 0 (
    echo pyperclip not found. Installing...
    "%PYTHON_EXE%" -m pip install pyperclip
) else (
    echo pyperclip is already installed.
)



set "GITHUB_URL_2=https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/README.txt"
curl -L -o "%PROJECT_DIR%\README.txt" "%GITHUB_URL_2%"
echo.
if exist "%PROJECT_DIR%\README.txt" (
    echo Download README.txt successful!
) else (
    echo ERROR: Failed to download the README.txt file. Please check the URL.
)
echo.

echo Opening the README file from your project folder...
echo.
start "" notepad "%PROJECT_DIR%\README.txt"
pause
