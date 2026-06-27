@echo off
:: ============================================
:: RASHA Super App — Build & Start (Windows)
::
:: Usage:
::   startup.bat                  :: pre-build bases, then build all & start
::   startup.bat --clean          :: stop, remove containers, rebuild, start fresh
::   startup.bat --no-cache       :: full clean rebuild, then start
::   startup.bat --bases-only     :: rebuild base images only (no start)
::   startup.bat --skip-bases     :: skip pre-building base images (use cached)
:: ============================================
setlocal enabledelayedexpansion

set NO_CACHE=
set BASES_ONLY=false
set CLEAN=false
set SKIP_BASES=false

:parse_args
if "%1"=="" goto :args_done
if /i "%1"=="--clean"      set CLEAN=true
if /i "%1"=="--no-cache"   set NO_CACHE=--no-cache
if /i "%1"=="--bases-only" set BASES_ONLY=true
if /i "%1"=="--skip-bases" set SKIP_BASES=true
shift
goto :parse_args
:args_done

:: ── Step 0: Pre-build base images ──
if "%BASES_ONLY%"=="true" (
    echo ^>^> [bases] Rebuilding base images...
    docker buildx bake bases %NO_CACHE%
    if errorlevel 1 (
        echo ^>^> ERROR: Base image build failed.
        exit /b 1
    )
    echo ^>^> Base images rebuilt. Run 'startup.bat' to start containers.
    exit /b 0
)

if "%SKIP_BASES%"=="false" (
    echo ^>^> [0/3] Pre-building base images (cached if unchanged^)...
    docker buildx bake bases %NO_CACHE%
    if errorlevel 1 (
        echo ^>^> ERROR: Base image build failed.
        exit /b 1
    )
    echo.
)

:: ── Clean restart if requested ──
if "%CLEAN%"=="true" (
    echo ^>^> [1/3] Safe clean restart — stopping and removing containers...
    docker compose stop
    docker compose rm -f
)

:: ── Build all images ──
echo ^>^> [2/3] Building all service images...
docker buildx bake %NO_CACHE%
if errorlevel 1 (
    echo ^>^> ERROR: Build failed.
    exit /b 1
)

:: ── Start containers ──
echo ^>^> [3/3] Starting containers...
docker compose up -d
if errorlevel 1 (
    echo ^>^> ERROR: Failed to start containers.
    exit /b 1
)

echo.
echo ^>^> Done. Running services:
docker compose ps

endlocal
