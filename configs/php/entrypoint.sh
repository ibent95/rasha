#!/bin/bash
# ============================================
# Entrypoint — RASHA Laravel Container
# ============================================
set -e

# Pre-create log files
touch /var/log/nginx/backend-access.log /var/log/nginx/backend-error.log /var/log/php/fpm-error.log 2>/dev/null || true
su -s /bin/sh www-data -c "touch /var/www/html/storage/logs/laravel.log" 2>/dev/null || true

# Supervisor: Append optional service configs
echo "[INIT] Checking optional services..."

if [ "${ENABLE_QUEUE}" = "true" ] || [ "${QUEUE_ENABLE}" = "true" ]; then
    echo "[INIT] ENABLE_QUEUE=true — appending queue worker config"
    echo "" >> /etc/supervisor/supervisord.conf
    cat /etc/supervisor/supervisord-services/queue.conf >> /etc/supervisor/supervisord.conf
    ENABLE_SCHEDULE=true
fi

if [ "${ENABLE_SCHEDULE}" = "true" ]; then
    echo "[INIT] ENABLE_SCHEDULE=true — appending schedule runner config"
    echo "" >> /etc/supervisor/supervisord.conf
    cat /etc/supervisor/supervisord-services/schedule.conf >> /etc/supervisor/supervisord.conf
fi

# Redis
if [ "${REDIS_ENABLE}" = "true" ]; then
    echo "[INIT] REDIS_ENABLE=true — setting Redis as cache/session driver"
    export REDIS_HOST=rasha-redis
    export REDIS_PASSWORD=${REDIS_PASSWORD:-rasha_redis_2024}
fi

# Memcached
if [ "${MEMCACHED_ENABLE}" = "true" ]; then
    echo "[INIT] MEMCACHED_ENABLE=true — setting Memcached as cache driver"
    export MEMCACHED_HOST=rasha-memcached
    export MEMCACHED_PORT=11211
fi

# Laravel config cache
if [ -f /var/www/html/artisan ] && [ -n "${APP_KEY:-}" ]; then
    php /var/www/html/artisan config:cache 2>/dev/null || true
    php /var/www/html/artisan route:cache 2>/dev/null || true
    php /var/www/html/artisan view:cache 2>/dev/null || true
fi

echo "[INIT] Enabled supervisor services:"
grep "^\[program:" /etc/supervisor/supervisord.conf | sed 's/\[program:/- /' | sed 's/\]//'

# Ensure supervisor socket directory exists (may be tmpfs at runtime)
mkdir -p /var/run/supervisor

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
