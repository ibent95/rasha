# syntax=docker/dockerfile:1
# ============================================
# Service: ERP (Laravel) — Enterprise Resource Planning
# RASHA Super App
# ============================================
FROM rasha-php-base AS build

LABEL maintainer="RASHA Super App Team"
LABEL description="ERP service — Enterprise Resource Planning"

# ── PHP & Nginx configs ──
COPY configs/php/php.ini /etc/php/8.4/fpm/php.ini
COPY configs/php/www.conf /etc/php/8.4/fpm/pool.d/www.conf
COPY configs/php/nginx.conf /etc/nginx/sites-enabled/default.conf
RUN sed -i 's/listen \[::\]:8400/listen [::]:8404/g; s/listen 8400/listen 8404/g' /etc/nginx/sites-enabled/default.conf
COPY configs/php/supervisord.conf /etc/supervisor/supervisord.conf
COPY configs/php/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir -p /etc/supervisor/supervisord-services

COPY configs/php/queue.conf /etc/supervisor/supervisord-services/queue.conf
COPY configs/php/schedule.conf /etc/supervisor/supervisord-services/schedule.conf

# ── Application code ──
WORKDIR /var/www/html
COPY services/svc-erp-laravel/composer.json services/svc-erp-laravel/composer.lock ./

RUN mkdir -p /root/.composer/cache
RUN --mount=type=cache,target=/root/.composer/cache composer install \
    --no-dev \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader \
    --no-progress

COPY services/svc-erp-laravel/ .

# ── Clear stale bootstrap cache (dev packages like laravel/pail won't exist in prod) ──
RUN rm -f /var/www/html/bootstrap/cache/packages.php /var/www/html/bootstrap/cache/services.php && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
# NOTE: config/route/view caching is handled at runtime by entrypoint.sh

EXPOSE 8404

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8404/up || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
