# ============================================
# Docker Buildx Bake — RASHA Super App
# Version: 1.0.0
# ============================================
#
# Architecture:
#   services/  → Backend microservices (PHP, Python, Node.js, Java, etc.)
#   websites/  → Frontend applications (Angular, React, Vue, etc.)
#
# Usage:
#   docker buildx bake              # build everything
#   docker buildx bake --no-cache   # full clean rebuild
#   docker buildx bake rasha-svc-core-laravel  # rebuild one service
#   docker buildx bake bases        # rebuild all base images

# ============================================
# Default group — builds all service images
# ============================================
group "default" {
  targets = [
    "rasha-svc-core-laravel",
    "rasha-svc-authorization-laravel",
    "rasha-svc-crm-laravel",
    "rasha-svc-dynamic-form-laravel",
    "rasha-svc-erp-laravel",
    "rasha-web-portal-angular",
    "rasha-web-crm-angular",
    "rasha-web-dynamic-form-angular",
    "rasha-web-erp-angular",
    "rasha-proxy",
    "rasha-database",
  ]
}

# Convenience group to rebuild all base images
group "bases" {
  targets = [
    "rasha-php-base",
    "rasha-node-base",
    "rasha-postgres-base",
    "rasha-python-base",
  ]
}

# ============================================
# Base Images
# ============================================
target "rasha-php-base" {
  context    = "."
  dockerfile = "dockerfiles/base/php.Dockerfile"
  tags       = ["rasha-php-base:latest"]
}

target "rasha-node-base" {
  context    = "."
  dockerfile = "dockerfiles/base/nodejs.Dockerfile"
  tags       = ["rasha-node-base:latest"]
}

target "rasha-postgres-base" {
  context    = "."
  dockerfile = "dockerfiles/base/postgres.Dockerfile"
  tags       = ["rasha-postgres-base:latest"]
}

target "rasha-python-base" {
  context    = "."
  dockerfile = "dockerfiles/base/python.Dockerfile"
  tags       = ["rasha-python-base:latest"]
}

# ============================================
# Backend Services
# ============================================

# Core Service — Auth, Users, Roles (shared by all apps)
target "rasha-svc-core-laravel" {
  context    = "."
  dockerfile = "services/svc-core-laravel/Dockerfile"
  tags       = ["rasha-svc-core-laravel:latest"]
  contexts   = {
    rasha-php-base = "target:rasha-php-base"
  }
}

# Authorization Service — Users, Roles, Permissions & Auth
target "rasha-svc-authorization-laravel" {
  context    = "."
  dockerfile = "services/svc-authorization-laravel/Dockerfile"
  tags       = ["rasha-svc-authorization-laravel:latest"]
  contexts   = {
    rasha-php-base = "target:rasha-php-base"
  }
}

# CRM Service
target "rasha-svc-crm-laravel" {
  context    = "."
  dockerfile = "services/svc-crm-laravel/Dockerfile"
  tags       = ["rasha-svc-crm-laravel:latest"]
  contexts   = {
    rasha-php-base = "target:rasha-php-base"
  }
}

# Dynamic Form Service
target "rasha-svc-dynamic-form-laravel" {
  context    = "."
  dockerfile = "services/svc-dynamic-form-laravel/Dockerfile"
  tags       = ["rasha-svc-dynamic-form-laravel:latest"]
  contexts   = {
    rasha-php-base = "target:rasha-php-base"
  }
}

# ERP Service
target "rasha-svc-erp-laravel" {
  context    = "."
  dockerfile = "services/svc-erp-laravel/Dockerfile"
  tags       = ["rasha-svc-erp-laravel:latest"]
  contexts   = {
    rasha-php-base = "target:rasha-php-base"
  }
}

# ============================================
# Frontend Websites
# ============================================

# Portal Website — Main Page
target "rasha-web-portal-angular" {
  context    = "."
  dockerfile = "websites/web-portal-angular/Dockerfile"
  tags       = ["rasha-web-portal-angular:latest"]
  contexts   = {
    rasha-node-base = "target:rasha-node-base"
  }
}

# CRM Website
target "rasha-web-crm-angular" {
  context    = "."
  dockerfile = "websites/web-crm-angular/Dockerfile"
  tags       = ["rasha-web-crm-angular:latest"]
  contexts   = {
    rasha-node-base = "target:rasha-node-base"
  }
}

# Dynamic Form Website
target "rasha-web-dynamic-form-angular" {
  context    = "."
  dockerfile = "websites/web-dynamic-form-angular/Dockerfile"
  tags       = ["rasha-web-dynamic-form-angular:latest"]
  contexts   = {
    rasha-node-base = "target:rasha-node-base"
  }
}

# ERP Website
target "rasha-web-erp-angular" {
  context    = "."
  dockerfile = "websites/web-erp-angular/Dockerfile"
  tags       = ["rasha-web-erp-angular:latest"]
  contexts   = {
    rasha-node-base = "target:rasha-node-base"
  }
}

# ============================================
# Reverse Proxy
# ============================================
target "rasha-proxy" {
  context    = "."
  dockerfile = "dockerfiles/proxy/nginx.Dockerfile"
  tags       = ["rasha-proxy:latest"]
}

# ============================================
# Database
# ============================================
target "rasha-database" {
  context    = "."
  dockerfile = "dockerfiles/base/postgres.Dockerfile"
  tags       = ["rasha-database:latest"]
}

# ============================================
# Future Services (uncomment when ready)
# ============================================
# Python example:
# target "rasha-svc-ai" {
#   context    = "."
#   dockerfile = "services/svc-ai-python/Dockerfile"
#   tags       = ["rasha-svc-ai:latest"]
#   contexts   = { rasha-python-base = "target:rasha-python-base" }
# }
#
# Node.js example:
# target "rasha-svc-notification" {
#   context    = "."
#   dockerfile = "services/svc-notification-nodejs/Dockerfile"
#   tags       = ["rasha-svc-notification:latest"]
#   contexts   = { rasha-node-base = "target:rasha-node-base" }
# }
#
# Java example:
# target "rasha-svc-reporting" {
#   context    = "."
#   dockerfile = "services/svc-reporting-java/Dockerfile"
#   tags       = ["rasha-svc-reporting:latest"]
# }
