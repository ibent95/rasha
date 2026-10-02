# RASHA Super App

> **Manoratha** (Dream) + **Akasha** (Universe) = "The Universe of Dreams"

A **modular, language-agnostic super app** where each business domain
has its own backend service and frontend website.

---

## Architecture

```txt
RASHA/
├── services/                          # Backend microservices
│   ├── svc-core-laravel/              # Core: Auth, Users, Roles (shared)
│   ├── svc-crm-laravel/               # CRM backend
│   ├── svc-dynamic-form-laravel/       # Dynamic Form backend
│   └── svc-erp-laravel/               # ERP backend
├── websites/                          # Frontend applications
│   ├── web-portal-angular/            # Main portal (first website)
│   ├── web-crm-angular/               # CRM frontend
│   ├── web-dynamic-form-angular/       # Dynamic Form frontend
│   └── web-erp-angular/               # ERP frontend
├── configs/                           # Server configurations
├── dockerfiles/                       # Base Docker images
├── assets/                            # Brand assets
└── developments/                      # Development docs
```

Each service can be built with **any programming language**
  (PHP, Python, Java, Node.js, etc.).
Each website can be built with **any framework**
  (Angular, React, Vue, Svelte, etc.).

---

## Quick Start

```bash
# Build & start everything
docker buildx bake && docker compose up -d

# Or use the convenience script
./startup.sh
```

|       Service        | Port |      Description       |
|----------------------|------|------------------------|
| Portal               | 4200 | Main Website           |
| CRM Web              | 4201 | CRM Frontend           |
| Dynamic Form Web     | 4202 | Form Builder           |
| ERP Web              | 4203 | ERP Frontend           |
| Core Service         | 8000 | Auth, Users, Roles API |
| CRM Service          | 8001 | CRM Backend            |
| Dynamic Form Service | 8002 | Form Builder API       |
| ERP Service          | 8003 | ERP Backend            |
| PostgreSQL           | 5432 | Database               |
| Redis                | 6379 | Cache                  |

---

## Tech Stack

|   Layer   |      Technology      |
|-----------|----------------------|
| Frontend  | Angular 20           |
| Backend   | Laravel 13 + Sanctum |
| Database  | PostgreSQL 16        |
| Cache     | Redis 7              |
| Container | Docker + Buildx Bake |
| Base OS   | Ubuntu 24.04 LTS     |

---

## Brand

|   Color    |     Name      |   HEX   |
|------------|---------------|---------|
| Foundation | Obsidian      | #10100F |
| Primary    | Ember Red     | #C83E36 |
| Secondary  | Burnt Orange  | #D66A2C |
| Ecosystem  | Forest        | #3F6B4F |
| Light      | Warm Ivory    | #F1EDE3 |
| Neutral    | Stone         | #918C82 |

Slogan: **RASHA: Ruang Impian dalam Satu Genggaman**

---

## Adding a New Service

1. Create `services/svc-{name}-{lang}/` with your backend
2. Add a `Dockerfile` (extend `rasha-php-base` or use any base)
3. Add to `docker-compose.yml` and `docker-bake.hcl`
4. Register in Portal website navigation

## Adding a New Website

1. Create `websites/web-{name}-{framework}/` with your frontend
2. Add a `Dockerfile` (extend `rasha-node-base` or use any base)
3. Add to `docker-compose.yml` and `docker-bake.hcl`
4. Connect to its backend service via API proxy

---

## License

Built with love using Angular, Laravel, Docker, and the RASHA vision.
