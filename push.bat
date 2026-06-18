@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  OD Console - one-click publish to GitHub Pages
REM  Run this from the folder that contains OD_Simulator.html
REM ============================================================
cd /d "%~dp0"
title OD Console - GitHub Publisher
echo.
echo ===  OD CONSOLE  -  GitHub Pages publisher  ===
echo.

REM --- 1. checks ---------------------------------------------------------
where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git is not installed or not on PATH.
  echo         Install it from https://git-scm.com/download/win  then re-run.
  pause & exit /b 1
)
if not exist "OD_Simulator.html" (
  echo [ERROR] OD_Simulator.html not found in this folder.
  pause & exit /b 1
)

REM --- 2. repo URL ------------------------------------------------------
set "REPO=%~1"
if "%REPO%"=="" (
  echo Create an EMPTY repo on GitHub first, then paste its URL below.
  echo   e.g.  https://github.com/yourname/od-console.git
  set /p REPO=Repository URL:
)
if "%REPO%"=="" ( echo [ERROR] No repository URL given. & pause & exit /b 1 )

REM --- 3. build the page Pages will serve -------------------------------
echo.
echo [1/5] Copying OD_Simulator.html  ->  index.html
copy /y "OD_Simulator.html" "index.html" >nul

REM --- 4. git init / commit --------------------------------------------
if not exist ".git" (
  echo [2/5] Initialising git repository
  git init >nul
) else (
  echo [2/5] Existing git repository found
)
echo [3/5] Staging and committing
git add index.html OD_Simulator.html README.md push.bat >nul 2>nul
git commit -m "Publish OD Console simulator" >nul 2>nul
git branch -M main

REM --- 5. remote + push ------------------------------------------------
echo [4/5] Setting remote origin
git remote remove origin >nul 2>nul
git remote add origin "%REPO%"
echo [5/5] Pushing to GitHub (you may be asked to sign in)
git push -u origin main
if errorlevel 1 (
  echo.
  echo [WARN] Push failed. Common fixes:
  echo        - make sure the GitHub repo exists and is EMPTY
  echo        - sign in when prompted ^(or set up a Personal Access Token^)
  echo        - if the repo already has commits:  git pull --rebase origin main  then re-run
  pause & exit /b 1
)

REM --- done ------------------------------------------------------------
for /f "tokens=4,5 delims=/." %%a in ("%REPO%") do set "USER=%%a" & set "NAME=%%b"
echo.
echo ====================================================================
echo  DONE.  Now enable GitHub Pages:
echo    1. Open your repo on GitHub  -^>  Settings  -^>  Pages
echo    2. Source: "Deploy from a branch"
echo    3. Branch: main   Folder: / (root)   -^>  Save
echo.
echo  Your shareable link will be:
echo    https://!USER!.github.io/!NAME!/
echo ====================================================================
echo.
pause
endlocal
