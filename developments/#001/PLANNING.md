> ⚠️ **Note:** This is a reference document adapted from my-erp. File paths reference the original project structure. Adapt paths for RASHA microservices architecture (svc-core-laravel, svc-dynform-laravel, web-rasha-superapp-angular) when implementing.
# RASHA System Project Planning

## Project #001 - Development Planning Document

**Last Updated:** `2025-01-15`
**Project Name:** RASHA System
**Status:** ✅ Completed
**Version:** 1.0.0

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Project Goals](#project-goals)
3. [System Architecture](#system-architecture)
4. [Technology Stack](#technology-stack)
5. [Development Modules](#development-modules)
6. [Database Design](#database-design)
7. [API Design](#api-design)
8. [Frontend Architecture](#frontend-architecture)
9. [Infrastructure & Deployment](#infrastructure--deployment)
10. [Security Considerations](#security-considerations)
11. [Testing Strategy](#testing-strategy)

---

## Executive Summary

This document outlines the complete plan for developing a production-ready RASHA (Enterprise Resource Planning) system. The system manages products, inventory, warehouses, customers, and sales orders with full CRUD operations, real-time inventory tracking, and multi-warehouse support.

### Key Objectives

- ✅ Build a production-ready Laravel backend with RESTful API (PHP 8.4)
- ✅ Create a responsive Angular 20+ frontend with modern UI/UX
- ✅ Implement Docker-based deployment with Ubuntu LTS base images
- ✅ Nginx reverse proxy with PHP-FPM for optimal performance
- ✅ PostgreSQL 16 database with proper indexing
- ✅ Supervisor process management for queue workers

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│               Frontend Nginx (Angular SPA + API Proxy)       │
└─────────────────────────┬────────────────────────────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌───────▼─────────────┐          ┌─────────▼──────────┐
│  Laravel Backend    │          │   Angular Frontend  │
│  (PHP 8.4 FPM)      │          │   (Ubuntu + Nginx)  │
│                     │          │                      │
│  - REST API         │          │  - SPA Application   │
│  - Business Logic   │          │  - Lazy Loading      │
│  - Sanctum Auth     │          │  - Reactive Forms    │
│  - Supervisor Workers│         │  - SSR Ready         │
└───────┬─────────────┘          └─────────┬────────────┘
        │                                   │
        └─────────────────┬─────────────────┘
                          │
                ┌─────────▼──────────┐
                │   PostgreSQL 16    │
                │  (Ubuntu + PG)     │
                └────────────────────┘
```

### Container Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        Docker Compose                         │
├──────────────┬──────────────┬────────────────┬───────────────┤
│  rasha-laravel │ rasha-angular │  rasha-database  │
│  (Nginx:8000)│ (Nginx:80)   │ (PostgreSQL)   │                │
│  Port 8000   │ Port 80      │ Port 5432      │ Port 80       │
└──────────────┴──────────────┴────────────────┴───────────────┘
```

---

## Technology Stack

### Backend Technologies
| Technology | Version | Purpose |
|-----------|---------|---------|
| PHP | 8.4 | Backend scripting language |
| Laravel | 11.x | Web framework |
| PostgreSQL | 15 | Database |
| Composer | 2.x | Dependency management |
| Sanctum | Latest | API authentication |

### Frontend Technologies
| Technology | Version | Purpose |
|-----------|---------|---------|
| Angular | 19.x | Frontend framework |
| TypeScript | 5.x | Type-safe JavaScript |
| SCSS | Latest | CSS preprocessor |
| RxJS | 7.x | Reactive programming |

### Infrastructure
| Technology | Version | Purpose |
|-----------|---------|---------|
| Ubuntu | 24.04 LTS | Base OS for all containers |
| Docker | 24.x | Containerization |
| Nginx | 1.26+ | Web server & reverse proxy |
| Supervisor | 4.x | Process management |
| PHP-FPM | 8.4 | PHP FastCGI Process Manager |

---

## Development Modules

### Module 1: Products (RASHA-PRD-001)
**Features:**
- Full CRUD operations
- SKU validation (unique)
- Stock quantity tracking
- Search & pagination

### Module 2: Warehouses (RASHA-WH-002)
**Features:**
- Full CRUD operations
- Multi-location support
- Capacity tracking

### Module 3: Inventory Transactions (RASHA-INV-003)
**Features:**
- Stock IN/OUT/ADJUSTMENT transactions
- Audit trail with created_by user
- Transaction history with pagination

### Module 4: Customers (RASHA-CUST-004)
**Features:**
- Full CRUD operations
- Contact management (phone, address, city, country)
- Email validation & uniqueness

### Module 5: Sales Orders (RASHA-SAL-005)
**Features:**
- Multi-item order support
- Order status tracking (pending → confirmed → shipped → delivered → cancelled)
- Auto order number generation
- Line item total calculations
- Customer & product relationship management

---

## Database Design

### Entity Relationship Diagram

```
┌──────────┐     ┌────────────────────┐     ┌───────────┐
│  Users   │     │ InventoryTransactions│    │ Warehouses │
├──────────┤     ├────────────────────┤     ├───────────┤
│ id (PK)  │◄────│ created_by (FK)    │     │ id (PK)   │
│ name     │     │ product_id (FK)    │◄────│ name      │
│ email    │     │ warehouse_id (FK)  │     │ location  │
│ password │     │ transaction_type   │     │ capacity  │
└──────────┘     │ quantity           │     └───────────┘
                  │ notes              │
┌──────────┐     └────────────────────┘     ┌───────────┐
│ Products │                                 │ Customers │
├──────────┤     ┌────────────────────┐     ├───────────┤
│ id (PK)  │◄────│ SalesOrderItems    │     │ id (PK)   │
│ name     │     ├────────────────────┤     │ name      │
│ sku (UQ) │     │ id (PK)            │     │ email (UQ)│
│ price    │     │ sales_order_id (FK)│     │ phone     │
│ stock    │     │ product_id (FK)    │     │ address   │
└──────────┘     │ quantity           │     │ city      │
                  │ unit_price         │     │ country   │
┌──────────┐     │ total_price        │     └───────────┘
│SalesOrders│    └────────┬───────────┘          │
├──────────┤             │                      │
│ id (PK)  │◄────────────┘                      │
│ order_no │◄───────────────────────────────────│
│ cust (FK)│                                    │
│ status   │                                    │
│ total    │                                    │
└──────────┘                                    │
```

---

## API Design

### Standard Response Format

**Success:**
```json
{
    "success": true,
    "data": {},
    "message": "Operation successful"
}
```

**Error:**
```json
{
    "success": false,
    "message": "Error message",
    "data": {}
}
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/products | List products (paginated) |
| POST | /api/products | Create product |
| GET | /api/products/{id} | Get product |
| PUT | /api/products/{id} | Update product |
| DELETE | /api/products/{id} | Delete product |
| GET | /api/warehouses | List warehouses |
| POST | /api/warehouses | Create warehouse |
| GET | /api/warehouses/{id} | Get warehouse |
| PUT | /api/warehouses/{id} | Update warehouse |
| DELETE | /api/warehouses/{id} | Delete warehouse |
| GET | /api/inventory-transactions | List transactions |
| POST | /api/inventory-transactions | Create transaction |
| GET | /api/inventory-transactions/{id} | Get transaction |
| PUT | /api/inventory-transactions/{id} | Update transaction |
| DELETE | /api/inventory-transactions/{id} | Delete transaction |
| GET | /api/customers | List customers |
| POST | /api/customers | Create customer |
| GET | /api/customers/{id} | Get customer |
| PUT | /api/customers/{id} | Update customer |
| DELETE | /api/customers/{id} | Delete customer |
| GET | /api/sales-orders | List sales orders |
| POST | /api/sales-orders | Create sales order |
| GET | /api/sales-orders/{id} | Get sales order |
| PUT | /api/sales-orders/{id} | Update sales order |
| DELETE | /api/sales-orders/{id} | Delete sales order |

---

## Frontend Architecture

### Component Tree
```
AppComponent
├── NavigationComponent (sidebar with menu items)
├── DashboardComponent (dashboard cards + stats)
├── ProductsModule
│   ├── ProductListComponent (table with CRUD)
│   └── ProductFormComponent (reactive form)
├── WarehousesModule
│   ├── WarehouseListComponent
│   └── WarehouseFormComponent
├── InventoryModule
│   ├── InventoryListComponent
│   └── InventoryFormComponent (with product/warehouse dropdowns)
├── CustomersModule
│   ├── CustomerListComponent
│   └── CustomerFormComponent
└── SalesModule
    ├── SalesOrderListComponent (with status badges)
    └── SalesOrderFormComponent (multi-item FormArray)
```

### State Management
- Angular Services with RxJS Observables
- Zoneless Change Detection for performance
- Lazy-loaded feature modules

---

## Infrastructure & Deployment

### Docker Images
1. **Base PHP Image** (ubuntu:24.04 + PHP 8.4 FPM + Nginx + Supervisor)
2. **Base Node Image** (ubuntu:24.04 + Node.js + Nginx)
3. **Base PostgreSQL Image** (ubuntu:24.04 + PostgreSQL 16)

### Service Dockerfiles
1. **Backend (rasha-laravel):** Uses Base PHP Image + Laravel app
2. **Frontend (rasha-angular):** Uses Base Node Image + Angular build + Nginx
3. **Database (rasha-database):** Uses Base PostgreSQL Image


### Production Optimizations
- OPcache enabled for PHP
- PHP-FPM with pm = dynamic
- Nginx with gzip, caching headers
- Supervisor for queue workers
- PostgreSQL with optimized config
- Volume mounts for persistent data

---

## Security Considerations

### Implemented
- ✅ Laravel Sanctum API authentication
- ✅ Input validation on all endpoints
- ✅ SQL injection prevention via Eloquent ORM
- ✅ XSS protection via Angular sanitization
- ✅ CORS configuration
- ✅ Environment-based configuration

### Best Practices
- Follow OWASP Top 10 recommendations
- Use parameterized queries (Laravel ORM)
- Sanitize all user inputs
- Regular dependency updates

---

## Testing Strategy

### Backend Testing
- **Unit Tests:** Model relationships, accessors, mutators
- **Feature Tests:** API endpoints, CRUD operations, validation
- **Test Framework:** Pest PHP

### Frontend Testing
- **Unit Tests:** Component rendering, service methods
- **Integration:** Component interactions with services
- **Test Framework:** Jasmine/Karma

---

## Implementation Status

| Module | Backend | Frontend | Docker | Status |
|--------|---------|----------|--------|--------|
| Products | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Done |
| Warehouses | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Done |
| Inventory | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Done |
| Customers | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Done |
| Sales Orders | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Done |
| Infrastructure | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Done |

---

*Document Version: 1.0.0 | Last Updated: 2025-01-15*
