# syntax=docker/dockerfile:1
# ============================================
# Service: Authorization (Laravel) — Users, Roles, Permissions & Auth
# RASHA Super App
# ============================================
FROM rasha-php-base AS build

LABEL maintainer="RASHA Super App Team"
LABEL description="Authorization service — Users, Roles, Permissions & Auth"

# ── PHP & Nginx configs ──
COPY configs/php/php.ini /etc/php/8.4/fpm/php.ini
COPY configs/php/www.conf /etc/php/8.4/fpm/pool.d/www.conf
COPY configs/php/nginx.conf /etc/nginx/sites-enabled/default.conf
RUN sed -i 's/listen \[::\]:8400/listen [::]:8401/g; s/listen 8400/listen 8401/g' /etc/nginx/sites-enabled/default.conf
COPY configs/php/supervisord.conf /etc/supervisor/supervisord.conf
COPY configs/php/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir -p /etc/supervisor/supervisord-services

# ── Optional supervisor service configs ──
COPY configs/php/queue.conf /etc/supervisor/supervisord-services/queue.conf
COPY configs/php/schedule.conf /etc/supervisor/supervisord-services/schedule.conf

# ── Application code ──
WORKDIR /var/www/html
COPY services/svc-authorization-laravel/composer.json services/svc-authorization-laravel/composer.lock ./

RUN mkdir -p /root/.composer/cache
RUN --mount=type=cache,target=/root/.composer/cache composer install \
    --no-dev \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader \
    --no-progress

COPY services/svc-authorization-laravel/ .

# ── Clear stale bootstrap cache (dev packages like laravel/pail won't exist in prod) ──
# ── Publish spatie/laravel-permission migrations into database/migrations/ ──
RUN cp vendor/spatie/laravel-permission/database/migrations/create_permission_tables.php.stub \
        database/migrations/$(date +%%Y_%%m_%%d_%%H%M%%S)_create_permission_tables.php && \
    rm -f /var/www/html/bootstrap/cache/packages.php /var/www/html/bootstrap/cache/services.php && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 8401

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8401/up || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
