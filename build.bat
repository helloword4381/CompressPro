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
        echo        Current dir: %cd%
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
:: Reset working dir (download script may change it)
cd /d "%~dp0"
echo [OK] 7z.dll ready
echo.

:: Step 1: Check .NET SDK
set "DOTNET=dotnet"

:: Try env PATH first
dotnet --version >nul 2>&1
if errorlevel 1 (
    :: Try common install locations
    if exist "%ProgramFiles%\dotnet\dotnet.exe" set "DOTNET=%ProgramFiles%\dotnet\dotnet.exe"
    if exist "%ProgramFiles(x86)%\dotnet\dotnet.exe" set "DOTNET=%ProgramFiles(x86)%\dotnet\dotnet.exe"
    if exist "%LOCALAPPDATA%\Microsoft\dotnet\dotnet.exe" set "DOTNET=%LOCALAPPDATA%\Microsoft\dotnet\dotnet.exe"
)
"%DOTNET%" --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK not found
    echo        Install from https://dotnet.microsoft.com/download/dotnet/8.0
    echo        Or add dotnet to your PATH
    pause
    exit /b 1
)
for /f %%i in ('"%DOTNET%" --version') do echo [OK] .NET SDK %%i
echo.

:: Step 2: Restore
echo [2/4] Restoring NuGet packages ...
call "%DOTNET%" restore
if errorlevel 1 (
    echo [ERROR] Restore failed
    pause
    exit /b 1
)
echo [OK] Restore complete
echo.

:: Step 3: Build
echo [3/4] Building Release ...
call "%DOTNET%" build -c Release --no-restore
if errorlevel 1 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)
echo [OK] Build complete
echo.

:: Step 4: Copy 7z.dll to output
echo [4/4] Copying runtime dependencies ...
set "OUT=src\CompressPro.Gui\bin\Release\net8.0-windows"
if exist "external\7z.dll" copy /y "external\7z.dll" "%OUT%\" >nul
if exist "external\7z.exe" copy /y "external\7z.exe" "%OUT%\" >nul
echo [OK] Dependencies copied
echo.

echo ============================================
echo  [SUCCESS] Build OK!
echo   Output: %OUT%
echo   Run:    %OUT%\CompressPro.exe
echo ============================================
pause
