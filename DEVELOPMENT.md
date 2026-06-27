# RASHA Super App — Development Guide

## Directory Structure

```
services/           → Backend microservices (PHP, Python, Node.js, Java, etc.)
  svc-core-laravel/   → Core auth, users, roles (shared by all)
  svc-authorization-laravel/ → Authorization — Users, Roles, Permissions & Auth
  svc-crm-laravel/    → CRM backend
  svc-dynamic-form-laravel/ → Dynamic Form backend
  svc-erp-laravel/    → ERP backend

websites/           → Frontend applications (Angular, React, Vue, etc.)
  web-portal-angular/ → Main portal
  web-crm-angular/    → CRM frontend
  web-dynamic-form-angular/ → Dynamic Form frontend
  web-erp-angular/    → ERP frontend

configs/            → Nginx, PHP, PostgreSQL, Redis, Angular configs
  proxy/             → Nginx reverse proxy config (subdomain routing)
  php/               → PHP-FPM, Nginx, Supervisor configs
  angular/           → Angular website Nginx config
  postgresql/        → PostgreSQL configs
  redis/             → Redis config

dockerfiles/        → Base Docker images
  base/              → php.Dockerfile, nodejs.Dockerfile, postgres.Dockerfile, python.Dockerfile
  proxy/             → nginx.Dockerfile (reverse proxy)
```

## Services & Websites

### Backend Services (Laravel)

| Service | Docker Name | Host Port | Container Port | Health Check |
|---------|-------------|-----------|----------------|-------------|
| Core (Auth/Users/Roles) | `rasha-svc-core-laravel` | `8400` | `8400` | `http://localhost:8400/up` |
| Authorization (Users/Roles/Permissions) | `rasha-svc-authorization-laravel` | `8401` | `8401` | `http://localhost:8401/up` |
| CRM | `rasha-svc-crm-laravel` | `8402` | `8402` | `http://localhost:8402/up` |
| Dynamic Form | `rasha-svc-dynamic-form-laravel` | `8403` | `8403` | `http://localhost:8403/up` |
| ERP | `rasha-svc-erp-laravel` | `8404` | `8404` | `http://localhost:8404/up` |

### Frontend Websites (Angular)

| Website | Docker Name | Host Port | Container Port | Health Check |
|---------|-------------|-----------|----------------|-------------|
| Portal (Main) | `rasha-web-portal-angular` | `4400` | `80` | `http://localhost:4400/health` |
| CRM | `rasha-web-crm-angular` | `4401` | `80` | `http://localhost:4401/health` |
| Dynamic Form | `rasha-web-dynamic-form-angular` | `4402` | `80` | `http://localhost:4402/health` |
| ERP | `rasha-web-erp-angular` | `4403` | `80` | `http://localhost:4403/health` |

### Reverse Proxy (Subdomain Routing)

| Subdomain | Routes To | Host Port |
|-----------|-----------|----------|
| `http://rasha.local` | Portal (`:4400`) | `80` |
| `http://crm.rasha.local` | CRM (`:4401`) | `80` |
| `http://dynamic-form.rasha.local` | Dynamic Form (`:4402`) | `80` |
| `http://erp.rasha.local` | ERP (`:4403`) | `80` |
| `http://api.rasha.local/public/api/` | Core API (`:8400`) | `80` |

> **Note:** Add to `/etc/hosts` for subdomain routing:
> ```
> 127.0.0.1 rasha.local crm.rasha.local dynamic-form.rasha.local erp.rasha.local api.rasha.local
> ```

### Infrastructure

| Service | Docker Name | Host Port | Container Port |
|---------|-------------|-----------|----------------|
| PostgreSQL | `rasha-database` | `5432` | `5432` |
| Redis | `rasha-redis` | `6379` | `6379` |
| Memcached | `rasha-memcached` | `11211` | `11211` |

### Database Per Service

Each Laravel service has its **own database**:

| Service | Database Name | DB User |
|---------|---------------|---------|
| Core | `rasha_core_db` | `rasha_user` |
| Authorization | `rasha_core_db` | `rasha_user` |
| CRM | `rasha_crm_db` | `rasha_crm_user` |
| Dynamic Form | `rasha_dynamic_form_db` | `rasha_dynamic_form_user` |
| ERP | `rasha_erp_db` | `rasha_erp_user` |

> **Note:** Core and Authorization share the same database (`rasha_core_db`).

Databases are auto-created by `configs/postgresql/init-databases.sql` on first start.

---

## Quick Start

### Build & Start Everything

```bash
# Linux/Mac
./startup.sh

# Windows
startup.bat
```

This will: pre-build base images → build all service images → start all containers.

### Build & Start Options

| Flag | Description |
|------|-------------|
| (none) | Pre-build bases → build all → start |
| `--clean` | Stop containers → pre-build → rebuild → start |
| `--no-cache` | Full clean rebuild (no Docker layer cache) |
| `--bases-only` | Rebuild only base images |
| `--skip-bases` | Skip pre-building bases (faster if unchanged) |

---

## Building Specific Services

You don't need to rebuild everything when only one service changes. Use `docker buildx bake` with a specific target.

### Build a Specific Backend Service

```bash
# Build only the core service
docker buildx bake rasha-svc-core-laravel

# Build only the authorization service
docker buildx bake rasha-svc-authorization-laravel

# Build only the CRM service
docker buildx bake rasha-svc-crm-laravel

# Build only the ERP service
docker buildx bake rasha-svc-erp-laravel

# Build only the Dynamic Form service
docker buildx bake rasha-svc-dynamic-form-laravel
```

### Build a Specific Frontend Website

```bash
# Build only the portal
docker buildx bake rasha-web-portal-angular

# Build only the CRM frontend
docker buildx bake rasha-web-crm-angular

# Build only the ERP frontend
docker buildx bake rasha-web-erp-angular

# Build only the Dynamic Form frontend
docker buildx bake rasha-web-dynamic-form-angular
```

### Build Multiple Specific Targets

```bash
# Build core service + portal together
docker buildx bake rasha-svc-core-laravel rasha-web-portal-angular
```

### Build Without Cache (Clean Build)

```bash
docker buildx bake --no-cache rasha-svc-core-laravel
```

### Build Base Images Only

```bash
# Rebuild all base images
docker buildx bake bases

# Rebuild a specific base image
docker buildx bake rasha-php-base
docker buildx bake rasha-node-base
```

### Start/Restart a Specific Service

```bash
# Start (or recreate) only specific containers
docker compose up -d rasha-svc-core-laravel rasha-web-portal-angular

# Restart a running service
docker compose restart rasha-svc-crm-laravel

# Stop a specific service
docker compose stop rasha-svc-erp-laravel
```

### View Logs for a Specific Service

```bash
# Tail logs for a specific service
docker compose logs -f rasha-svc-core-laravel
docker compose logs -f rasha-web-portal-angular
```

---

## Database Migrations

Each Laravel service manages its **own database**. Migrations run per-service — there is no single "migrate all" command.

### Run Migrations for a Specific Service

```bash
# Core service migrations
docker exec rasha-svc-core-laravel php artisan migrate

# Authorization service migrations
docker exec rasha-svc-authorization-laravel php artisan migrate

# CRM service migrations
docker exec rasha-svc-crm-laravel php artisan migrate

# ERP service migrations
docker exec rasha-svc-erp-laravel php artisan migrate

# Dynamic Form service migrations
docker exec rasha-svc-dynamic-form-laravel php artisan migrate
```

### Run Migrations with Fresh Database (Drop & Re-run)

```bash
# Core — drop all tables, re-run migrations, seed
docker exec rasha-svc-core-laravel php artisan migrate:fresh --seed --force

# CRM
docker exec rasha-svc-crm-laravel php artisan migrate:fresh --seed --force

# ERP
docker exec rasha-svc-erp-laravel php artisan migrate:fresh --seed --force

# Dynamic Form
docker exec rasha-svc-dynamic-form-laravel php artisan migrate:fresh --seed --force
```

### Run a Specific Migration File

```bash
# Run a single migration by name
docker exec rasha-svc-core-laravel php artisan migrate --path=database/migrations/2024_01_01_000000_create_users_table.php
```

### Rollback Migrations

```bash
# Rollback the last batch of migrations
docker exec rasha-svc-core-laravel php artisan migrate:rollback

# Rollback all migrations
docker exec rasha-svc-core-laravel php artisan migrate:reset

# Rollback and re-run from scratch
docker exec rasha-svc-core-laravel php artisan migrate:fresh --force
```

### Check Migration Status

```bash
docker exec rasha-svc-core-laravel php artisan migrate:status
```

### Seeders

```bash
# Run all seeders
docker exec rasha-svc-core-laravel php artisan db:seed

# Run a specific seeder
docker exec rasha-svc-core-laravel php artisan db:seed --class=RoleSeeder
```

### Common Laravel Artisan Commands

```bash
# Clear all caches
docker exec rasha-svc-core-laravel php artisan cache:clear
docker exec rasha-svc-core-laravel php artisan config:clear
docker exec rasha-svc-core-laravel php artisan route:clear
docker exec rasha-svc-core-laravel php artisan view:clear

# Rebuild caches
docker exec rasha-svc-core-laravel php artisan config:cache
docker exec rasha-svc-core-laravel php artisan route:cache

# List all routes
docker exec rasha-svc-core-laravel php artisan route:list

# Create a new migration
docker exec rasha-svc-core-laravel php artisan make:migration create_example_table

# Create a new model + migration
docker exec rasha-svc-core-laravel php artisan make:model Example -m
```

---

## Common Development Workflows

### Rebuild & Restart One Service (Fast Iteration)

```bash
# 1. Build only the service you changed
docker buildx bake rasha-svc-core-laravel

# 2. Restart only that container
docker compose up -d rasha-svc-core-laravel

# 3. Check logs
docker compose logs -f rasha-svc-core-laravel
```

### Rebuild Frontend After Code Change

```bash
# 1. Build only the website you changed
docker buildx bake rasha-web-portal-angular

# 2. Restart only that container
docker compose up -d rasha-web-portal-angular
```

### Add a New Migration & Run It

> **Note:** Since `artisan make:migration` runs inside the container, the migration file lands in the container's `/var/www/html/database/migrations/`. However, `database/migrations/` is **not** mounted as a volume, so the file won't persist to the host. The recommended approach is to create the migration file manually on the host, then run `artisan migrate` from the container.

```bash
# 1. Create the migration file manually on the host
#    e.g. services/svc-crm-laravel/database/migrations/2024_01_01_000000_add_status_to_contacts_table.php

# 2. Run the migration from the container
docker exec rasha-svc-crm-laravel php artisan migrate
```

### Full Reset (Nuclear Option)

```bash
# Option A: Reset data only (fast, no rebuild)
docker compose down -v
docker compose up -d

# Then run migrations
docker exec rasha-svc-core-laravel php artisan migrate --force
docker exec rasha-svc-authorization-laravel php artisan migrate --force
docker exec rasha-svc-crm-laravel php artisan migrate --force
docker exec rasha-svc-erp-laravel php artisan migrate --force
docker exec rasha-svc-dynamic-form-laravel php artisan migrate --force
```

```bash
# Option B: Full reset with rebuild (slower, rebuilds all images)
docker compose down -v
docker compose up -d --build

# Then run migrations
docker exec rasha-svc-core-laravel php artisan migrate --force
docker exec rasha-svc-authorization-laravel php artisan migrate --force
docker exec rasha-svc-crm-laravel php artisan migrate --force
docker exec rasha-svc-erp-laravel php artisan migrate --force
docker exec rasha-svc-dynamic-form-laravel php artisan migrate --force
```

---

## Adding a New Service (Backend)

1. Create `services/svc-{name}-{lang}/`
2. Add a `Dockerfile` that either:
   - Extends a RASHA base image: `FROM rasha-php-base AS build`
   - Or uses any base image
3. Add to `docker-compose.yml` with its own port and DB config
4. Add to `docker-bake.hcl` with base image dependency

## Adding a New Website (Frontend)

1. Create `websites/web-{name}-{framework}/`
2. Add a `Dockerfile` that either:
   - Extends `FROM rasha-node-base AS production`
   - Or uses any base image
3. Add to `docker-compose.yml` with its own port
4. Add to `docker-bake.hcl` with base image dependency

---

## Environment Variables

Copy `.env.example` to `.env` and adjust values:
```bash
cp .env.example .env
```

Each service and website has its own database and port configuration. See `.env.example` for all available options.

---

## Local Development & Access

There are two ways to access the services in your browser after running `docker compose up -d`:

### Option 1: Direct Access (localhost:ports)

| Service | URL |
|---------|-----|
| Portal | http://localhost:4400 |
| CRM | http://localhost:4401 |
| Dynamic Form | http://localhost:4402 |
| ERP | http://localhost:4403 |
| Core API | http://localhost:8400/up |
| Authorization API | http://localhost:8401/up |
| CRM API | http://localhost:8402/up |
| DynForm API | http://localhost:8403/up |
| ERP API | http://localhost:8404/up |

### Option 2: Via Reverse Proxy (subdomains)

First, add to your hosts file:

| OS | File Location |
|----|---------------|
| Windows | `C:\Windows\System32\drivers\etc\hosts` |
| macOS/Linux | `/etc/hosts` |

Add these lines:
```
127.0.0.1 rasha.local crm.rasha.local dynamic-form.rasha.local erp.rasha.local api.rasha.local
```

Then access via subdomains:

| Subdomain | Routes To |
|-----------|-----------|
| http://rasha.local | Portal |
| http://crm.rasha.local | CRM |
| http://dynamic-form.rasha.local | Dynamic Form |
| http://erp.rasha.local | ERP |
| http://api.rasha.local/public/api/ | Core API |

---

## Certificate Setup (HTTPS)

### 1. Generate certificates (one-time)

```bash
./scripts/generate-ssl-certs.sh
```

This creates three files in the `certs/` directory: `rasha.crt`, `rasha.key`, and `rasha-ca.crt`.

### 2. Install the CA certificate

**Windows:**
Double-click `certs/rasha-ca.crt` → Install Certificate → Local Machine → Place in "Trusted Root Certification Authorities"

**macOS:**
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/rasha-ca.crt
```

**Linux:**
```bash
sudo cp certs/rasha-ca.crt /usr/local/share/ca-certificates/rasha-ca.crt
sudo update-ca-certificates
```

### 3. Access via HTTPS

- https://rasha.local — Portal
- https://crm.rasha.local — CRM
- https://dynamic-form.rasha.local — Dynamic Form
- https://erp.rasha.local — ERP
- https://api.rasha.local — API

The proxy nginx config already has SSL configured (port 443) and HTTP→HTTPS redirect enabled. Both port 80 and 443 are exposed, so HTTP still works as a fallback until you install the CA cert.
