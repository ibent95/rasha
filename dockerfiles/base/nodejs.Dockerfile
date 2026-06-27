# syntax=docker/dockerfile:1
# ============================================
# Hardened Base Node.js Image - Ubuntu 24.04 LTS
# Node.js 20 LTS + Nginx + PM2
# RASHA Super App - Modular Microservices
# ============================================
FROM ubuntu:24.04 AS node-base

LABEL maintainer="RASHA Super App Team"
LABEL description="Hardened Node.js 20 LTS image with Nginx on Ubuntu 24.04 LTS"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    nginx \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    node --version && npm --version

# Install PM2 globally
RUN --mount=type=cache,target=/root/.npm npm install -g pm2@latest && \
    pm2 --version

# Security hardening
RUN find /usr -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

# Create node user
RUN if ! id -u node >/dev/null 2>&1; then \
        useradd -r -s /usr/sbin/nologin node; \
    fi

RUN mkdir -p /var/www/html && \
    mkdir -p /var/log/nginx && \
    mkdir -p /etc/nginx/sites-enabled && \
    chown -R node:node /var/www/html /var/log/nginx

WORKDIR /var/www/html

EXPOSE 80 443 3000

CMD ["nginx", "-g", "daemon off;"]
