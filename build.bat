@echo off
cd /d "%~dp0"
title CompressPro Build

echo ============================================
echo   CompressPro Build - Self-contained
echo ============================================
echo.

:: Step 0: Download 7z.dll
echo [0/4] Checking 7z.dll ...
if not exist "external\7z.dll" (
    echo [*] 7z.dll not found, running download script ...
    if not exist "external\download_7z_dll.bat" (
        echo [ERROR] external\download_7z_dll.bat not found
        pause
        exit /b 1
    )
    call "external\download_7z_dll.bat"
    if errorlevel 1 (
        echo [ERROR] Failed to get 7z.dll
        pause
        exit /b 1
    )
)
cd /d "%~dp0"
echo [OK] 7z.dll ready
echo.

:: Step 1: Check .NET SDK
set "DOTNET=dotnet"
dotnet --version >nul 2>&1
if errorlevel 1 (
    if exist "%ProgramFiles%\dotnet\dotnet.exe" set "DOTNET=%ProgramFiles%\dotnet\dotnet.exe"
    if exist "%ProgramFiles(x86)%\dotnet\dotnet.exe" set "DOTNET=%ProgramFiles(x86)%\dotnet\dotnet.exe"
    if exist "%LOCALAPPDATA%\Microsoft\dotnet\dotnet.exe" set "DOTNET=%LOCALAPPDATA%\Microsoft\dotnet\dotnet.exe"
)
"%DOTNET%" --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK not found
    echo        Install from https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)
for /f %%i in ('"%DOTNET%" --version') do echo [OK] .NET SDK %%i
echo.

:: Step 2: Restore
echo [2/5] Restoring packages ...
call "%DOTNET%" restore
if errorlevel 1 ( echo [ERROR] Restore failed & pause & exit /b 1 )
echo [OK] Restore complete
echo.

:: Step 3: Self-contained publish
echo [3/5] Publishing self-contained (includes .NET runtime) ...
rmdir /s /q "publish-app" >nul 2>&1
call "%DOTNET%" publish src\CompressPro.Gui\CompressPro.Gui.csproj -c Release -r win-x64 --self-contained -o publish-app
if errorlevel 1 ( echo [ERROR] Publish failed & pause & exit /b 1 )
echo [OK] Publish complete
echo.

:: Step 4: Copy 7z.dll/exe to publish output
echo [4/5] Copying runtime dependencies ...
if exist "external\7z.dll" copy /y "external\7z.dll" "publish-app\" >nul
if exist "external\7z.exe" copy /y "external\7z.exe" "publish-app\" >nul
for /f %%i in ('dir /s /a-d "publish-app\*" 2^>nul ^| find "File(s)"') do echo [OK] Total: %%i
echo.

:: Step 5: Build installer (if NSIS available)
echo [5/5] Checking NSIS for installer build ...
set "APP_DIR=publish-app"
set "NSIS_PATH=C:\Program Files (x86)\NSIS\makensis.exe"
if exist "%NSIS_PATH%" (
    echo [*] Building setup.exe ...
    "%NSIS_PATH%" "installer\setup.nsi"
    if exist "installer\CompressPro_Setup.exe" (
        copy /y "installer\CompressPro_Setup.exe" "publish-app\" >nul
        echo [OK] CompressPro_Setup.exe built
    ) else (
        echo [WARN] Installer build failed
    )
) else (
    echo [SKIP] NSIS not found
)
echo.

echo ============================================
echo  [SUCCESS] Build OK!
echo   App:       publish-app\CompressPro.exe
echo   Installer: publish-app\CompressPro_Setup.exe
echo   Total size:
dir /s "publish-app\CompressPro.exe" 2>nul
echo ============================================
pause
