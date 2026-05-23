@echo off
cd /d "%~dp0"
title Download 7z.dll

set "DLL=7z.dll"
set "EXE=7z.exe"

:: Already have them?
if exist "%DLL%" if exist "%EXE%" (
    echo [OK] 7z.dll and 7z.exe already present
    exit /b 0
)

echo ============================================
echo   Download 7z.dll/7z.exe (7-Zip Extra)
echo   Source: 7-zip.org (LGPL-2.1)
echo ============================================
echo.

:: Does the system have 7z?
set "HAS_7Z="
where 7z.exe >nul 2>&1 && set "HAS_7Z=1"
if exist "7z.exe" set "HAS_7Z=1"

if defined HAS_7Z (
    echo [1/3] Downloading 7z2409-extra.7z ...
    powershell -Command "& { Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z2409-extra.7z' -OutFile '7z2409-extra.7z' -UseBasicParsing }"
    if not exist "7z2409-extra.7z" (
        echo [ERROR] Download failed
        pause
        exit /b 1
    )

    echo [2/3] Extracting ...
    7z x "7z2409-extra.7z" -y >nul
    if errorlevel 1 (
        echo [ERROR] Extract failed
        pause
        exit /b 1
    )

    echo [3/3] Cleaning up ...
    del "7z2409-extra.7z" >nul 2>&1
    if exist "x64\7z.dll" (
        copy /y "x64\7z.dll" "7z.dll" >nul
        copy /y "x64\7z.exe" "7z.exe" >nul
        rmdir /s /q x86 >nul 2>&1
        rmdir /s /q x64 >nul 2>&1
    )
    echo [OK] Done! 7z.dll + 7z.exe ready
    goto :end
)

:: No 7z found - download self-extracting installer
echo [1/3] Downloading 7-Zip installer (self-extracting) ...
powershell -Command "& { Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z2409-x64.exe' -OutFile '7z2409-x64.exe' -UseBasicParsing }"
if not exist "7z2409-x64.exe" (
    echo [ERROR] Download failed.
    echo.
    echo Please manually download:
    echo   1. Go to https://7-zip.org/
    echo   2. Download 7z2409-x64.exe
    echo   3. Place it in the external folder
    echo   4. Re-run this script
    pause
    exit /b 1
)

echo [2/3] Extracting (silent self-extract) ...
set "TMP7Z=%TEMP%\7z-tmp-%RANDOM%"
mkdir "%TMP7Z%" >nul 2>&1
start /wait "" "7z2409-x64.exe" /S /D="%TMP7Z%" >nul 2>&1
ping 127.0.0.1 -n 3 >nul

if exist "%TMP7Z%\7z.dll" (
    echo [3/3] Copying to external\ ...
    copy /y "%TMP7Z%\7z.dll" "7z.dll" >nul
    copy /y "%TMP7Z%\7z.exe" "7z.exe" >nul
    rmdir /s /q "%TMP7Z%" >nul 2>&1
    del "7z2409-x64.exe" >nul 2>&1
    echo [OK] Done! 7z.dll + 7z.exe ready
) else (
    echo [WARN] Self-extract did not produce 7z.dll
    echo.
    echo Please manually get 7z.dll:
    echo   1. Download https://www.7-zip.org/a/7z2409-extra.7z
    echo   2. Extract it with any archiver
    echo   3. Copy x64\7z.dll here as 7z.dll
    echo   4. Copy x64\7z.exe here as 7z.exe
    echo.
    del "7z2409-x64.exe" >nul 2>&1
)

:end
echo.
pause
