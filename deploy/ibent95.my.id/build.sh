#!/bin/bash
# ============================================
# RASHA Super App — Build Script (Linux/Mac)
# Target: ibent95.my.id
# ============================================
#
# Builds all Angular websites and copies all services
# into domains/ structure matching ibent95.my.id hosting.
#
# Usage:
#   chmod +x deploy/ibent95.my.id/build.sh
#   ./deploy/ibent95.my.id/build.sh
#
# Output:
#   deploy/ibent95.my.id/
#   ├── domains/
#   │   ├── ibent95.my.id/public_html/              # Portal (Angular build)
#   │   ├── api.ibent95.my.id/public_html/          # Laravel APIs
#   │   │   ├── svc-core-laravel/                   # Full Laravel app
#   │   │   │   ├── public/index.php
#   │   │   │   ├── .htaccess
#   │   │   │   ├── app/, config/, routes/, vendor/, ...
#   │   │   ├── svc-crm-laravel/
#   │   │   ├── svc-dynamic-form-laravel/
#   │   │   └── svc-erp-laravel/
#   │   ├── crm.ibent95.my.id/public_html/          # CRM (Angular build)
#   │   ├── dynamic-form.ibent95.my.id/public_html/ # Dynamic Form (Angular build)
#   │   └── erp.ibent95.my.id/public_html/          # ERP (Angular build)
#   ├── deploy.env
#   └── configs/

set -e

# ============================================
# Configuration
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
DEPLOY_DIR="$SCRIPT_DIR"
WEBSITES_DIR="$PROJECT_ROOT/websites"
SERVICES_DIR="$PROJECT_ROOT/services"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  RASHA Super App — Build for ibent95.my.id${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# ============================================
# Check Prerequisites
# ============================================
echo -e "${YELLOW}[0/6] Checking prerequisites...${NC}"

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}  ✓ $1${NC}"
        return 0
    else
        echo -e "${RED}  ✗ $1 not found${NC}"
        return 1
    fi
}

PREREQS_OK=true
check_command node || PREREQS_OK=false
check_command npm || PREREQS_OK=false
check_command npx || PREREQS_OK=false
check_command composer || PREREQS_OK=false
check_command php || PREREQS_OK=false

if [ "$PREREQS_OK" = false ]; then
    echo -e "${RED}  Missing prerequisites. Please install the missing tools above.${NC}"
    exit 1
fi

if npx ng version &> /dev/null || ng version &> /dev/null; then
    echo -e "${GREEN}  ✓ Angular CLI${NC}"
else
    echo -e "${RED}  ✗ Angular CLI not found. Install: npm install -g @angular/cli${NC}"
    exit 1
fi

echo ""

# ============================================
# Clean previous build
# ============================================
echo -e "${YELLOW}[1/6] Cleaning previous build...${NC}"
rm -rf "$DEPLOY_DIR/domains" "$DEPLOY_DIR/deploy.env" "$DEPLOY_DIR/configs"
mkdir -p "$DEPLOY_DIR"
echo -e "${GREEN}  ✓ Clean${NC}"

# ============================================
# Create hosting domain directories
# ============================================
echo ""
echo -e "${YELLOW}[2/6] Creating hosting domain directories...${NC}"

DOMAINS_DIR="$DEPLOY_DIR/domains"
mkdir -p "$DOMAINS_DIR/ibent95.my.id/public_html"
mkdir -p "$DOMAINS_DIR/api.ibent95.my.id/public_html/svc-core-laravel"
mkdir -p "$DOMAINS_DIR/api.ibent95.my.id/public_html/svc-crm-laravel"
mkdir -p "$DOMAINS_DIR/api.ibent95.my.id/public_html/svc-dynamic-form-laravel"
mkdir -p "$DOMAINS_DIR/api.ibent95.my.id/public_html/svc-erp-laravel"
mkdir -p "$DOMAINS_DIR/crm.ibent95.my.id/public_html"
mkdir -p "$DOMAINS_DIR/dynamic-form.ibent95.my.id/public_html"
mkdir -p "$DOMAINS_DIR/erp.ibent95.my.id/public_html"
echo -e "${GREEN}  ✓ Directories created${NC}"

# ============================================
# Build Angular Websites (Frontend)
# ============================================
echo ""
echo -e "${YELLOW}[3/6] Building Angular websites...${NC}"

build_angular_app() {
    local app_dir="$1"
    local app_name="$2"
    local output_dir="$3"

    echo -e "${BLUE}  Building $app_name...${NC}"

    if [ ! -d "$app_dir" ] || [ ! -f "$app_dir/package.json" ]; then
        echo -e "${RED}    ⚠ $app_name not found, skipping${NC}"
        return
    fi

    if [ ! -d "$app_dir/node_modules" ]; then
        echo -e "${YELLOW}    Installing dependencies...${NC}"
        cd "$app_dir"
        npm install --legacy-peer-deps 2>/dev/null || npm install 2>/dev/null || {
            echo -e "${RED}    ✗ Failed to install deps, skipping${NC}"
            cd "$PROJECT_ROOT"
            return
        }
        cd "$PROJECT_ROOT"
    fi

    cd "$app_dir"
    npx ng build --configuration=production 2>/dev/null || {
        echo -e "${RED}    ✗ Build failed, skipping${NC}"
        cd "$PROJECT_ROOT"
        return
    }

    if [ -d "dist" ]; then
        cp -r dist/* "$output_dir/" 2>/dev/null || true
        echo -e "${GREEN}    ✓ $app_name built${NC}"
    fi

    cd "$PROJECT_ROOT"
}

# Portal → ibent95.my.id/public_html/
build_angular_app "$WEBSITES_DIR/web-portal-angular" "web-portal-angular" "$DOMAINS_DIR/ibent95.my.id/public_html"

# CRM → crm.ibent95.my.id/public_html/
build_angular_app "$WEBSITES_DIR/web-crm-angular" "web-crm-angular" "$DOMAINS_DIR/crm.ibent95.my.id/public_html"

# Dynamic Form → dynamic-form.ibent95.my.id/public_html/
build_angular_app "$WEBSITES_DIR/web-dynamic-form-angular" "web-dynamic-form-angular" "$DOMAINS_DIR/dynamic-form.ibent95.my.id/public_html"

# ERP → erp.ibent95.my.id/public_html/
build_angular_app "$WEBSITES_DIR/web-erp-angular" "web-erp-angular" "$DOMAINS_DIR/erp.ibent95.my.id/public_html"

# ============================================
# Copy Laravel Services (Backend)
# ============================================
echo ""
echo -e "${YELLOW}[4/6] Copying Laravel services...${NC}"

SERVICES=(svc-core-laravel svc-crm-laravel svc-dynamic-form-laravel svc-erp-laravel)

for svc in "${SERVICES[@]}"; do
    if [ -d "$SERVICES_DIR/$svc" ]; then
        echo -e "${BLUE}  Copying $svc...${NC}"

        SVC_TARGET="$DOMAINS_DIR/api.ibent95.my.id/public_html/$svc"
        mkdir -p "$SVC_TARGET"

        # Copy full Laravel app (public/, app/, config/, routes/, etc.)
        if command -v rsync &> /dev/null; then
            rsync -av --exclude='vendor/' --exclude='node_modules/' \
                --exclude='.git/' --exclude='storage/' \
                --exclude='bootstrap/cache/' --exclude='.env' \
                "$SERVICES_DIR/$svc/" "$SVC_TARGET/" 2>/dev/null || true
        else
            cp -r "$SERVICES_DIR/$svc/"* "$SVC_TARGET/" 2>/dev/null || true
            rm -rf "$SVC_TARGET/vendor" "$SVC_TARGET/node_modules" \
                "$SVC_TARGET/.git" 2>/dev/null || true
        fi

        # Create storage directories
        mkdir -p "$SVC_TARGET/storage/app/public"
        mkdir -p "$SVC_TARGET/storage/framework/cache/data"
        mkdir -p "$SVC_TARGET/storage/framework/sessions"
        mkdir -p "$SVC_TARGET/storage/framework/views"
        mkdir -p "$SVC_TARGET/storage/logs"
        mkdir -p "$SVC_TARGET/bootstrap/cache"

        # Generate per-service .htaccess (blocks access to sensitive files)
        cat > "$SVC_TARGET/.htaccess" << SVCEOF
RewriteEngine On

# Block access to sensitive Laravel directories
RewriteCond %{REQUEST_URI} ^/$svc/(app|config|routes|database|resources|bootstrap|vendor|storage|tests|node_modules)/ [OR]
RewriteCond %{REQUEST_URI} ^/$svc/\.(env|git|htaccess|editorconfig|gitattributes|gitignore)
RewriteCond %{REQUEST_URI} ^/$svc/(artisan|composer\.(json|lock)|package\.json|phpunit\.xml|README\.md|LICENSE)$
RewriteRule ^ - [F,L]
SVCEOF

        echo -e "${GREEN}  ✓ $svc copied${NC}"
    else
        echo -e "${RED}  ⚠ $svc not found, skipping${NC}"
    fi
done

# ============================================
# Generate .htaccess for API subdomain
# ============================================
echo ""
echo -e "${YELLOW}[5/6] Generating .htaccess files...${NC}"

# API subdomain root .htaccess
cat > "$DOMAINS_DIR/api.ibent95.my.id/public_html/.htaccess" << 'HTEOF'
RewriteEngine On

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# CORS: Dynamically set origin based on request
<IfModule mod_headers.c>
    SetEnvIf Origin "^https://(ibent95\.my\.id|crm\.ibent95\.my\.id|dynamic-form\.ibent95\.my\.id|erp\.ibent95\.my\.id)$" CORS_ORIGIN=$0
    Header set Access-Control-Allow-Origin "%{CORS_ORIGIN}e" env=CORS_ORIGIN
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
    Header set Access-Control-Allow-Credentials "true"
    Header merge Vary Origin
</IfModule>

# Handle OPTIONS preflight requests
RewriteCond %{REQUEST_METHOD} OPTIONS
RewriteRule ^(.*)$ $1 [R=204,L]

# Route to Laravel services (public/index.php is the entry point)
RewriteCond %{REQUEST_URI} ^/svc-core-laravel/
RewriteRule ^svc-core-laravel/(.*)$ /svc-core-laravel/public/index.php?/$1 [L,QSA]

RewriteCond %{REQUEST_URI} ^/svc-crm-laravel/
RewriteRule ^svc-crm-laravel/(.*)$ /svc-crm-laravel/public/index.php?/$1 [L,QSA]

RewriteCond %{REQUEST_URI} ^/svc-dynamic-form-laravel/
RewriteRule ^svc-dynamic-form-laravel/(.*)$ /svc-dynamic-form-laravel/public/index.php?/$1 [L,QSA]

RewriteCond %{REQUEST_URI} ^/svc-erp-laravel/
RewriteRule ^svc-erp-laravel/(.*)$ /svc-erp-laravel/public/index.php?/$1 [L,QSA]
HTEOF
echo -e "${GREEN}  ✓ API subdomain .htaccess${NC}"

# SPA .htaccess for Angular subdomains
SPA_HTACCESS='RewriteEngine On

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# SPA routing
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]

# CORS headers
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "https://api.ibent95.my.id"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization"
    Header set Access-Control-Allow-Credentials "true"
</IfModule>'

for spa_dir in "$DOMAINS_DIR/crm.ibent95.my.id/public_html" \
               "$DOMAINS_DIR/dynamic-form.ibent95.my.id/public_html" \
               "$DOMAINS_DIR/erp.ibent95.my.id/public_html"; do
    echo "$SPA_HTACCESS" > "$spa_dir/.htaccess"
done
echo -e "${GREEN}  ✓ SPA .htaccess for Angular subdomains${NC}"

# Portal .htaccess
cat > "$DOMAINS_DIR/ibent95.my.id/public_html/.htaccess" << 'HTEOF'
RewriteEngine On

# Force HTTPS
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Block sensitive files
<FilesMatch "(\.env|\.git|\.htaccess|composer\.(json|lock)|package\.json|README\.md)$">
    Require all denied
</FilesMatch>
HTEOF
echo -e "${GREEN}  ✓ Portal .htaccess${NC}"

# ============================================
# Generate deploy.env
# ============================================
echo ""
echo -e "${YELLOW}[6/6] Generating deploy.env...${NC}"

cat > "$DEPLOY_DIR/deploy.env" << 'ENVEOF'
# ============================================
# RASHA Super App — ibent95.my.id Environment Config
# ============================================
# Copy values to each Laravel service's .env file

APP_NAME=RASHA
APP_ENV=production
APP_DEBUG=false
APP_KEY=CHANGE_ME
APP_URL=https://ibent95.my.id
APP_API_URL=https://api.ibent95.my.id

# Database (MySQL/MariaDB)
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306

DB_DATABASE=ibentmyi_app_core
DB_USERNAME=app_core
DB_PASSWORD=CHANGE_ME

CRM_DB_DATABASE=ibentmyi_app_crm
CRM_DB_USERNAME=app_crm
CRM_DB_PASSWORD=CHANGE_ME

DYNAMIC_FORM_DB_DATABASE=ibentmyi_app_dynamic_form
DYNAMIC_FORM_DB_USERNAME=app_dynamic_form
DYNAMIC_FORM_DB_PASSWORD=CHANGE_ME

ERP_DB_DATABASE=ibentmyi_app_erp
ERP_DB_USERNAME=app_erp
ERP_DB_PASSWORD=CHANGE_ME

SANCTUM_STATEFUL_DOMAINS=ibent95.my.id,crm.ibent95.my.id,dynamic-form.ibent95.my.id,erp.ibent95.my.id
SESSION_DOMAIN=.ibent95.my.id
ENVEOF
echo -e "${GREEN}  ✓ deploy.env${NC}"

# ============================================
# Summary
# ============================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Build complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  ${BLUE}domains/${NC}  → Upload to hosting domains/ folder"
echo -e "  ${BLUE}deploy.env${NC} → Environment config"
echo ""
echo -e "  ${YELLOW}Hosting Structure:${NC}"
echo -e "    ibent95.my.id/public_html/                  → Portal (Angular)"
echo -e "    api.ibent95.my.id/public_html/svc-*/        → Laravel APIs"
echo -e "    crm.ibent95.my.id/public_html/              → CRM (Angular)"
echo -e "    dynamic-form.ibent95.my.id/public_html/     → Dynamic Form (Angular)"
echo -e "    erp.ibent95.my.id/public_html/              → ERP (Angular)"
echo ""
echo -e "  ${YELLOW}Next Steps:${NC}"
echo -e "    1. Upload domains/ to hosting"
echo -e "    2. Create MySQL databases in cPanel"
echo -e "    3. Copy deploy.env values to each service's .env"
echo -e "    4. Run composer install via SSH in each service"
echo -e "    5. Set permissions: chmod -R 775 storage bootstrap/cache"
echo ""
