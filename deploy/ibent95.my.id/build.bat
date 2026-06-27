@echo off
REM ============================================
REM RASHA Super App — Build Script (Windows)
REM Target: ibent95.my.id
REM ============================================
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..\\..\\
if "%PROJECT_ROOT:~-1%"=="\" set PROJECT_ROOT=%PROJECT_ROOT:~0,-1%

set DEPLOY_DIR=%SCRIPT_DIR%
set WEBSITES_DIR=%PROJECT_ROOT%\\websites
set SERVICES_DIR=%PROJECT_ROOT%\\services

echo ============================================
echo   RASHA — Build for ibent95.my.id
echo ============================================
echo.

REM Check Prerequisites
echo [0/6] Checking prerequisites...
where node >nul 2>&1 || (echo   X Node.js not found & exit /b 1)
where npm >nul 2>&1 || (echo   X npm not found & exit /b 1)
where npx >nul 2>&1 || (echo   X npx not found & exit /b 1)
where composer >nul 2>&1 || (echo   X Composer not found & exit /b 1)
where php >nul 2>&1 || (echo   X PHP not found & exit /b 1)
echo   + All prerequisites found
echo.

REM Clean previous build
echo [1/6] Cleaning previous build...
if exist "%DEPLOY_DIR%\\domains" rmdir /s /q "%DEPLOY_DIR%\\domains"
if exist "%DEPLOY_DIR%\\deploy.env" del "%DEPLOY_DIR%\\deploy.env"
if exist "%DEPLOY_DIR%\\configs" rmdir /s /q "%DEPLOY_DIR%\\configs"
echo   + Clean

REM Create hosting domain directories
echo.
echo [2/6] Creating hosting domain directories...
mkdir "%DEPLOY_DIR%\\domains\\ibent95.my.id\\public_html" 2>nul
mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel" 2>nul
mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel" 2>nul
mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel" 2>nul
mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel" 2>nul
mkdir "%DEPLOY_DIR%\\domains\\crm.ibent95.my.id\\public_html" 2>nul
mkdir "%DEPLOY_DIR%\\domains\\dynamic-form.ibent95.my.id\\public_html" 2>nul
mkdir "%DEPLOY_DIR%\\domains\\erp.ibent95.my.id\\public_html" 2>nul
echo   + Directories created

REM Build Angular Websites
echo.
echo [3/6] Building Angular websites...

REM Portal
if exist "%WEBSITES_DIR%\\web-portal-angular\\package.json" (
    if not exist "%WEBSITES_DIR%\\web-portal-angular\\node_modules" (
        cd "%WEBSITES_DIR%\\web-portal-angular" & call npm install --legacy-peer-deps & cd "%PROJECT_ROOT%"
    )
    cd "%WEBSITES_DIR%\\web-portal-angular" & call npx ng build --configuration=production & cd "%PROJECT_ROOT%"
    if exist "%WEBSITES_DIR%\\web-portal-angular\\dist" (
        xcopy /s /e /y /q "%WEBSITES_DIR%\\web-portal-angular\\dist\\*.*" "%DEPLOY_DIR%\\domains\\ibent95.my.id\\public_html\\" >nul
        echo   + web-portal-angular built
    )
)

REM CRM
if exist "%WEBSITES_DIR%\\web-crm-angular\\package.json" (
    if not exist "%WEBSITES_DIR%\\web-crm-angular\\node_modules" (
        cd "%WEBSITES_DIR%\\web-crm-angular" & call npm install --legacy-peer-deps & cd "%PROJECT_ROOT%"
    )
    cd "%WEBSITES_DIR%\\web-crm-angular" & call npx ng build --configuration=production & cd "%PROJECT_ROOT%"
    if exist "%WEBSITES_DIR%\\web-crm-angular\\dist" (
        xcopy /s /e /y /q "%WEBSITES_DIR%\\web-crm-angular\\dist\\*.*" "%DEPLOY_DIR%\\domains\\crm.ibent95.my.id\\public_html\\" >nul
        echo   + web-crm-angular built
    )
)

REM Dynamic Form
if exist "%WEBSITES_DIR%\\web-dynamic-form-angular\\package.json" (
    if not exist "%WEBSITES_DIR%\\web-dynamic-form-angular\\node_modules" (
        cd "%WEBSITES_DIR%\\web-dynamic-form-angular" & call npm install --legacy-peer-deps & cd "%PROJECT_ROOT%"
    )
    cd "%WEBSITES_DIR%\\web-dynamic-form-angular" & call npx ng build --configuration=production & cd "%PROJECT_ROOT%"
    if exist "%WEBSITES_DIR%\\web-dynamic-form-angular\\dist" (
        xcopy /s /e /y /q "%WEBSITES_DIR%\\web-dynamic-form-angular\\dist\\*.*" "%DEPLOY_DIR%\\domains\\dynamic-form.ibent95.my.id\\public_html\\" >nul
        echo   + web-dynamic-form-angular built
    )
)

REM ERP
if exist "%WEBSITES_DIR%\\web-erp-angular\\package.json" (
    if not exist "%WEBSITES_DIR%\\web-erp-angular\\node_modules" (
        cd "%WEBSITES_DIR%\\web-erp-angular" & call npm install --legacy-peer-deps & cd "%PROJECT_ROOT%"
    )
    cd "%WEBSITES_DIR%\\web-erp-angular" & call npx ng build --configuration=production & cd "%PROJECT_ROOT%"
    if exist "%WEBSITES_DIR%\\web-erp-angular\\dist" (
        xcopy /s /e /y /q "%WEBSITES_DIR%\\web-erp-angular\\dist\\*.*" "%DEPLOY_DIR%\\domains\\erp.ibent95.my.id\\public_html\\" >nul
        echo   + web-erp-angular built
    )
)
echo.

REM Copy Laravel Services
echo [4/6] Copying Laravel services...

REM svc-core-laravel
if exist "%SERVICES_DIR%\\svc-core-laravel" (
    xcopy /s /e /y /q "%SERVICES_DIR%\\svc-core-laravel\\*.*" "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\" >nul 2>&1
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\vendor" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\vendor"
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\node_modules" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\node_modules"
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\storage\\app\\public" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\storage\\framework\\cache\\data" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\storage\\framework\\sessions" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\storage\\framework\\views" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\storage\\logs" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-core-laravel\\bootstrap\\cache" 2>nul
    echo   + svc-core-laravel copied
)

REM svc-crm-laravel
if exist "%SERVICES_DIR%\\svc-crm-laravel" (
    xcopy /s /e /y /q "%SERVICES_DIR%\\svc-crm-laravel\\*.*" "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\" >nul 2>&1
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\vendor" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\vendor"
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\node_modules" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\node_modules"
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\storage\\app\\public" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\storage\\framework\\cache\\data" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\storage\\framework\\sessions" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\storage\\framework\\views" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\storage\\logs" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-crm-laravel\\bootstrap\\cache" 2>nul
    echo   + svc-crm-laravel copied
)

REM svc-dynamic-form-laravel
if exist "%SERVICES_DIR%\\svc-dynamic-form-laravel" (
    xcopy /s /e /y /q "%SERVICES_DIR%\\svc-dynamic-form-laravel\\*.*" "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\" >nul 2>&1
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\vendor" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\vendor"
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\node_modules" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\node_modules"
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\storage\\app\\public" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\storage\\framework\\cache\\data" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\storage\\framework\\sessions" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\storage\\framework\\views" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\storage\\logs" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-dynamic-form-laravel\\bootstrap\\cache" 2>nul
    echo   + svc-dynamic-form-laravel copied
)

REM svc-erp-laravel
if exist "%SERVICES_DIR%\\svc-erp-laravel" (
    xcopy /s /e /y /q "%SERVICES_DIR%\\svc-erp-laravel\\*.*" "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\" >nul 2>&1
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\vendor" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\vendor"
    if exist "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\node_modules" rmdir /s /q "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\node_modules"
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\storage\\app\\public" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\storage\\framework\\cache\\data" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\storage\\framework\\sessions" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\storage\\framework\\views" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\storage\\logs" 2>nul
    mkdir "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\svc-erp-laravel\\bootstrap\\cache" 2>nul
    echo   + svc-erp-laravel copied
)
echo.

REM Generate .htaccess
echo [5/6] Generating .htaccess files...

REM API subdomain root .htaccess
echo RewriteEngine On > "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteCond %%%%{HTTPS} off >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteRule ^(.*)$ https://%%{HTTP_HOST}%%{REQUEST_URI} [L,R=301] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteCond %%{REQUEST_METHOD} OPTIONS >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteRule ^(.*)$ $1 [R=204,L] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteRule ^svc-core-laravel/(.*)$ /svc-core-laravel/public/index.php?/$1 [L,QSA] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteRule ^svc-crm-laravel/(.*)$ /svc-crm-laravel/public/index.php?/$1 [L,QSA] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteRule ^svc-dynamic-form-laravel/(.*)$ /svc-dynamic-form-laravel/public/index.php?/$1 [L,QSA] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo RewriteRule ^svc-erp-laravel/(.*)$ /svc-erp-laravel/public/index.php?/$1 [L,QSA] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\.htaccess"
echo   + API .htaccess created

REM Per-service .htaccess
for %%s in (svc-core-laravel svc-crm-laravel svc-dynamic-form-laravel svc-erp-laravel) do (
    echo RewriteEngine On > "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\%%s\\.htaccess"
    echo RewriteCond %%{REQUEST_URI} ^/%%s/(app^|config^|routes^|database^|resources^|bootstrap^|vendor^|storage^|tests^|node_modules^)/ [OR] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\%%s\\.htaccess"
    echo RewriteCond %%{REQUEST_URI} ^/%%s/\\.(env^|git^|htaccess^|editorconfig^|gitattributes^|gitignore^) >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\%%s\\.htaccess"
    echo RewriteRule ^ - [F,L] >> "%DEPLOY_DIR%\\domains\\api.ibent95.my.id\\public_html\\%%s\\.htaccess"
    echo   + %%s/.htaccess created
)

REM SPA .htaccess for Angular subdomains
for %%d in (crm dynamic-form erp) do (
    echo RewriteEngine On > "%DEPLOY_DIR%\\domains\\%%d.ibent95.my.id\\public_html\\.htaccess"
    echo RewriteCond %%%%{HTTPS} off >> "%DEPLOY_DIR%\\domains\\%%d.ibent95.my.id\\public_html\\.htaccess"
    echo RewriteRule ^(.*)$ https://%%{HTTP_HOST}%%{REQUEST_URI} [L,R=301] >> "%DEPLOY_DIR%\\domains\\%%d.ibent95.my.id\\public_html\\.htaccess"
    echo RewriteCond %%{REQUEST_FILENAME} !-f >> "%DEPLOY_DIR%\\domains\\%%d.ibent95.my.id\\public_html\\.htaccess"
    echo RewriteCond %%{REQUEST_FILENAME} !-d >> "%DEPLOY_DIR%\\domains\\%%d.ibent95.my.id\\public_html\\.htaccess"
    echo RewriteRule . /index.html [L] >> "%DEPLOY_DIR%\\domains\\%%d.ibent95.my.id\\public_html\\.htaccess"
    echo   + %%d/.htaccess created
)

REM Portal .htaccess
echo RewriteEngine On > "%DEPLOY_DIR%\\domains\\ibent95.my.id\\public_html\\.htaccess"
echo RewriteCond %%%%{HTTPS} off >> "%DEPLOY_DIR%\\domains\\ibent95.my.id\\public_html\\.htaccess"
echo RewriteRule ^(.*)$ https://%%{HTTP_HOST}%%{REQUEST_URI} [L,R=301] >> "%DEPLOY_DIR%\\domains\\ibent95.my.id\\public_html\\.htaccess"
echo   + Portal .htaccess created

echo.

REM Generate deploy.env
echo [6/6] Generating deploy.env...
echo APP_NAME=RASHA > "%DEPLOY_DIR%\\deploy.env"
echo APP_ENV=production >> "%DEPLOY_DIR%\\deploy.env"
echo APP_DEBUG=false >> "%DEPLOY_DIR%\\deploy.env"
echo APP_KEY=CHANGE_ME >> "%DEPLOY_DIR%\\deploy.env"
echo APP_URL=https://ibent95.my.id >> "%DEPLOY_DIR%\\deploy.env"
echo APP_API_URL=https://api.ibent95.my.id >> "%DEPLOY_DIR%\\deploy.env"
echo DB_CONNECTION=mysql >> "%DEPLOY_DIR%\\deploy.env"
echo DB_HOST=localhost >> "%DEPLOY_DIR%\\deploy.env"
echo DB_PORT=3306 >> "%DEPLOY_DIR%\\deploy.env"
echo DB_DATABASE=ibentmyi_app_core >> "%DEPLOY_DIR%\\deploy.env"
echo DB_USERNAME=app_core >> "%DEPLOY_DIR%\\deploy.env"
echo DB_PASSWORD=CHANGE_ME >> "%DEPLOY_DIR%\\deploy.env"
echo CRM_DB_DATABASE=ibentmyi_app_crm >> "%DEPLOY_DIR%\\deploy.env"
echo CRM_DB_USERNAME=app_crm >> "%DEPLOY_DIR%\\deploy.env"
echo CRM_DB_PASSWORD=CHANGE_ME >> "%DEPLOY_DIR%\\deploy.env"
echo DYNAMIC_FORM_DB_DATABASE=ibentmyi_app_dynamic_form >> "%DEPLOY_DIR%\\deploy.env"
echo DYNAMIC_FORM_DB_USERNAME=app_dynamic_form >> "%DEPLOY_DIR%\\deploy.env"
echo DYNAMIC_FORM_DB_PASSWORD=CHANGE_ME >> "%DEPLOY_DIR%\\deploy.env"
echo ERP_DB_DATABASE=ibentmyi_app_erp >> "%DEPLOY_DIR%\\deploy.env"
echo ERP_DB_USERNAME=app_erp >> "%DEPLOY_DIR%\\deploy.env"
echo ERP_DB_PASSWORD=CHANGE_ME >> "%DEPLOY_DIR%\\deploy.env"
echo SANCTUM_STATEFUL_DOMAINS=ibent95.my.id,crm.ibent95.my.id,dynamic-form.ibent95.my.id,erp.ibent95.my.id >> "%DEPLOY_DIR%\\deploy.env"
echo SESSION_DOMAIN=.ibent95.my.id >> "%DEPLOY_DIR%\\deploy.env"
echo   + deploy.env created

echo.
echo ============================================
echo   Build complete!
echo ============================================
echo.
echo   domains/  Upload to hosting domains/ folder
echo   deploy.env  Environment config
echo.

endlocal
