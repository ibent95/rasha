# ============================================
# Base PostgreSQL Image - Ubuntu 24.04 LTS
# PostgreSQL 16
# RASHA Super App - Modular Microservices
# ============================================
FROM postgres:16 AS postgres-base

LABEL maintainer="RASHA Super App Team"
LABEL description="PostgreSQL 16 for RASHA Super App microservices"

ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive

# Use the standard postgres entrypoint
# Each service creates its own database via POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD env vars
