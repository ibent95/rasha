# syntax=docker/dockerfile:1
# ============================================
# Website: CRM (Angular 22 SSR)
# RASHA Super App — CRM Frontend
# ============================================

# ── Stage 1: Build ──
FROM rasha-node-base AS build

WORKDIR /app

COPY websites/web-crm-angular/package.json websites/web-crm-angular/package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --prefer-offline --no-audit

COPY websites/web-crm-angular/ .
RUN npx ng build --configuration=staging

# ── Stage 2: Production ──
FROM rasha-node-base AS production

LABEL maintainer="RASHA Super App Team"
LABEL description="CRM website — Customer Relationship frontend (Angular 22 SSR)"

# ── Nginx config ──
RUN rm -f /etc/nginx/sites-enabled/default
COPY configs/angular/nginx.conf /etc/nginx/sites-enabled/default.conf

# ── SSR server ──
WORKDIR /var/www/html

# Install only production dependencies (no devDependencies = smaller image)
COPY websites/web-crm-angular/package.json websites/web-crm-angular/package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev --prefer-offline --no-audit

# Copy only the build output (dist is ~10-50MB vs node_modules ~500MB+)
COPY --from=build /app/dist/web-crm-angular/server/ ./server/
COPY --from=build /app/dist/web-crm-angular/browser/ ./browser/

# ── PM2 ecosystem for SSR ──
RUN echo 'module.exports = {' > ecosystem.config.cjs && \
    echo '  apps: [{' >> ecosystem.config.cjs && \
    echo '    name: "crm-ssr",' >> ecosystem.config.cjs && \
    echo '    script: "./server/server.mjs",' >> ecosystem.config.cjs && \
    echo '    env: { PORT: 4000, NODE_ENV: "production" }' >> ecosystem.config.cjs && \
    echo '  }]' >> ecosystem.config.cjs && \
    echo '};' >> ecosystem.config.cjs

RUN chown -R node:node /var/www/html

EXPOSE 80 4000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

CMD ["sh", "-c", "pm2 start ecosystem.config.cjs && nginx -g 'daemon off;'"]
