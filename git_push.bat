@echo off
cd /d "%~dp0"
title Push CompressPro to GitHub

set PATH=C:\Program Files\Git\cmd;%PATH%

echo ============================================
echo   Upload CompressPro to GitHub
echo ============================================
echo.
echo [IMPORTANT] First create an EMPTY repo on GitHub:
echo   1. Open https://github.com/new
echo   2. Repository name: CompressPro
echo   3. Do NOT check any boxes
echo   4. Click "Create repository"
echo.
echo After that, come back and run this script.
echo.
pause
echo.

:: 1. Verify build
echo [1/8] Verify build...
call build.bat
if errorlevel 1 (
    echo [ERROR] Build failed, please fix first
    pause
    exit /b 1
)
echo [OK] Build passed
echo.

:: 2. Init git
if exist ".git" (
    echo [2/8] Git already initialized
) else (
    echo [2/8] Initializing git...
    git init
)

:: 3. Configure user
echo [3/8] Setting Git user...
git config user.email "jiangflow@foxmail.com"
git config user.name "helloword4381"

:: 4. Add files
echo [4/8] Adding files...
git add .

:: 5. Commit
echo [5/8] Committing...
git commit -m "v1.0 CompressPro - open source archive tool based on 7-Zip"

:: 6. Branch
echo [6/8] Setting branch to main...
git branch -M main

:: 7. Remote
echo [7/8] Setting remote origin...
git remote add origin https://github.com/helloword4381/CompressPro.git 2>nul
echo        Remote: https://github.com/helloword4381/CompressPro.git

:: 8. Push
echo [8/8] Pushing to GitHub...
echo.
echo A login window will pop up. Sign in with your browser.
echo.
pause

git push -u origin main

if errorlevel 1 (
    echo.
    echo [ERROR] Push failed.
    echo.
    echo Make sure:
    echo   1. You created the repo on GitHub first
    echo   2. The repo is empty (no README/.gitignore)
    echo   3. You have write access
    echo.
) else (
    echo.
    echo ============================================
    echo  [SUCCESS] Upload complete!
    echo
    echo   GitHub:  https://github.com/helloword4381/CompressPro
    echo   Actions: https://github.com/helloword4381/CompressPro/actions
    echo
    echo   To trigger CI build:
    echo     1. Go to Actions tab
    echo     2. Click "Build CompressPro"
    echo     3. Click "Run workflow" -> "Run"
    echo ============================================
)

echo.
pause
