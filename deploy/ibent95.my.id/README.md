# RASHA — Deployment: ibent95.my.id

This folder contains the deployment configuration for **ibent95.my.id** hosting.

## Quick Start

### Linux/Mac

```bash
chmod +x deploy/ibent95.my.id/build.sh
./deploy/ibent95.my.id/build.sh
```

### Windows

```cmd
deploy\ibent95.my.id\build.bat
```

## Output Structure

The build script outputs directly to `deploy/ibent95.my.id/`
matching your hosting's domain structure:

```txt
deploy/ibent95.my.id/
└── domains/
    ├── ibent95.my.id/public_html/              # Portal (main page)
    │   ├── index.html
    │   └── .htaccess
    │
    ├── api.ibent95.my.id/public_html/          # Laravel APIs
    │   ├── .htaccess
    │   ├── svc-core-laravel/public/                        # Core service (auth)
    │   ├── svc-crm-laravel/public/                         # CRM service
    │   ├── svc-dynamic-form-laravel/public/                # Dynamic Form service
    │   └── svc-erp-laravel/public/                         # ERP service
    │
    ├── crm.ibent95.my.id/public_html/          # CRM Angular app
    │   ├── index.html
    │   └── .htaccess
    │
    ├── dynamic-form.ibent95.my.id/public_html/ # Dynamic Form Angular app
    │   ├── index.html
    │   └── .htaccess
    │
    └── erp.ibent95.my.id/public_html/          # ERP Angular app
        ├── index.html
        └── .htaccess
├── deploy.env                                  # Environment config
└── configs/README.md                           # Hosting setup guide
```

## Domain & Subdomain Mapping

|          Subdomain           | Document Root  | Technology |   Purpose     |
|------------------------------|----------------|------------|---------------|
| `ibent95.my.id`              | `public_html/` | Angular    | Portal        |
|                              |                |            | (main page)   |
| `api.ibent95.my.id`          | `public_html/` | Laravel    | Backend APIs  |
| `crm.ibent95.my.id`          | `public_html/` | Angular    | CRM website   |
| `dynamic-form.ibent95.my.id` | `public_html/` | Angular    | Dynamic Form  |
|                              |                |            | website       |
| `erp.ibent95.my.id`          | `public_html/` | Angular    | ERP website   |

## API URL Structure

|                          URL                           |       Service       |
|--------------------------------------------------------|---------------------|
| `https://api.ibent95.my.id/svc-core-laravel/*`         | Core API            |
|                                                        | (auth, users, roles)|
| `https://api.ibent95.my.id/svc-crm-laravel/*`          | CRM API             |
| `https://api.ibent95.my.id/svc-dynamic-form-laravel/*` | Dynamic Form API    |
| `https://api.ibent95.my.id/svc-erp-laravel/*`          | ERP API             |

## Database Configuration (MySQL/MariaDB)

|          Database           |        User        |  Access  |
|-----------------------------|--------------------|----------|
| `ibentmyi_app_core`         | `app_core`         | DML only |
| `ibentmyi_app_crm`          | `app_crm`          | DML only |
| `ibentmyi_app_dynamic_form` | `app_dynamic_form` | DML only |
| `ibentmyi_app_erp`          | `app_erp`          | DML only |

## Deployment Steps

1. **Build locally**: Run `./deploy/ibent95.my.id/build.sh`
2. **Upload**: Use cPanel File Manager or FTP to upload `domains/` to hosting
3. **Database**: Create MySQL databases in cPanel → MySQL Databases
4. **SSH**: Run `composer install` in each service directory
5. **Permissions**: `chmod -R 775 storage bootstrap/cache`
6. **Configure**: Update each Laravel service's `.env` with database credentials

## Environment Variables

Edit `deploy.env` and copy values to each service's `.env`:

| Variable        |    Description    |            Example             |
|-----------------|-------------------|--------------------------------|
| `DB_CONNECTION` | Database driver   | `mysql`                        |
| `DB_HOST`       | Database host     | `localhost`                    |
| `DB_PORT`       | Database port     | `3306`                         |
| `DB_DATABASE`   | Database name     | `ibentmyi_app_core`            |
| `DB_USERNAME`   | Database user     | `app_core`                     |
| `DB_PASSWORD`   | Database password | `CHANGE_ME`                    |
| `APP_KEY`       | Laravel key       | Run `php artisan key:generate` |
| `APP_URL`       | Main URL          | `https://ibent95.my.id`        |
| `APP_API_URL`   | API URL           | `https://api.ibent95.my.id`    |

## CORS Configuration

The `.htaccess` files include CORS headers to allow cross-origin requests
between subdomains:

- Portal → API subdomain
- CRM/Dynamic Form/ERP → API subdomain
