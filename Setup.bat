@echo off
net file 1>nul 2>nul
if '%errorlevel%' == '0' ( goto gotAdmin ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' ( shift & goto gotAdmin )
set "batchPath=%~f0"
setlocal EnableDelayedExpansion
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPriv.vbs"
echo UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPriv.vbs"
"%temp%\OEgetPriv.vbs"
del "%temp%\OEgetPriv.vbs"
exit /B

:gotAdmin
pushd "%~dp0"
setlocal & cd /d %~dp0
:: ------------------------------------

echo Checking for Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Downloading and installing...
    
    :: Download using absolute path so it saves where the script is
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe' -OutFile '%~dp0python_install.exe'"
    
    :: Install using absolute path
    start /wait "" "%~dp0python_install.exe" /quiet InstallAllUsers=1 PrependPath=1
    
    :: Clean up
    del "%~dp0python_install.exe"
)

:: --- Existing FFmpeg, yt-dlp, and Deno logic remains here ---
chcp 65001 >nul
echo Setting up environment...

:: 1. Check/Install FFmpeg
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo Downloading FFmpeg...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile '%~dp0ffmpeg.zip'"
    echo Extracting...
    if not exist "C:\Tools" mkdir "C:\Tools"
    powershell -Command "Expand-Archive -Path '%~dp0ffmpeg.zip' -DestinationPath 'C:\Tools\ffmpeg_temp'"
    :: Move contents out of the nested folder that usually comes in the zip
    move "C:\Tools\ffmpeg_temp\ffmpeg-*-essentials_build\*" "C:\Tools\ffmpeg\"
    rmdir /s /q "C:\Tools\ffmpeg_temp"
    del "%~dp0ffmpeg.zip"
    setx /M PATH "%PATH%;C:\Tools\ffmpeg\bin"
)

:: 2. Check/Install yt-dlp
where yt-dlp >nul 2>nul
if %errorlevel% neq 0 (
    echo Downloading yt-dlp...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile 'C:\Tools\yt-dlp.exe'"
)

:: 3. Check/Install Deno
where deno >nul 2>nul
if %errorlevel% neq 0 (
    echo Downloading Deno...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/denoland/deno/releases/latest/download/deno-x86_64-pc-windows-msvc.zip' -OutFile 'deno.zip'"
    powershell -Command "Expand-Archive -Path 'deno.zip' -DestinationPath 'C:\Tools\'"
    del deno.zip
)

echo Setup complete. Starting the downloader...
python "לעריכת והורדת הקישורים.py"
pause