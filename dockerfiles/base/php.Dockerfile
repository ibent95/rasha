# ============================================
# Hardened Base PHP Image - Ubuntu 24.04 LTS
# PHP 8.4 FPM + Nginx + Supervisor + Composer
# RASHA Super App - Modular Microservices
# ============================================
FROM ubuntu:24.04 AS php-base

LABEL maintainer="RASHA Super App Team"
LABEL description="Hardened PHP 8.4 FPM image with Nginx and Supervisor on Ubuntu 24.04 LTS"

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	unzip \
	supervisor \
	nginx \
	tzdata \
	libzip-dev \
	libpng-dev \
	libjpeg-dev \
	libfreetype6-dev \
	libonig-dev \
	libxml2-dev \
	libpq-dev \
	libicu-dev \
	libssl-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install PHP 8.4 from Ondrej PPA
RUN apt-get update && apt-get install -y software-properties-common && \
	add-apt-repository ppa:ondrej/php -y && \
	apt-get update && apt-get install -y --no-install-recommends \
	php8.4-fpm \
	php8.4-cli \
	php8.4-common \
	php8.4-mbstring \
	php8.4-xml \
	php8.4-zip \
	php8.4-pgsql \
	php8.4-mysql \
	php8.4-curl \
	php8.4-gd \
	php8.4-intl \
	php8.4-bcmath \
	php8.4-redis \
	php8.4-opcache \
	php8.4-memcached \
	php8.4-rdkafka \
	php8.4-ldap \
	&& rm -rf /var/lib/apt/lists/*

# Install PHP dev tools & PECL extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
	php8.4-dev \
	php-pear \
	build-essential \
	&& pecl channel-update pecl.php.net \
	&& pecl install apfd \
	&& echo 'extension=apfd.so' > /etc/php/8.4/mods-available/apfd.ini \
	&& phpenmod apfd \
	&& apt-get purge -y --auto-remove \
	php8.4-dev \
	php-pear \
	build-essential \
	&& rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PHP-FPM configuration
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.4/cli/php.ini && \
	sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.4/fpm/php.ini

# Security hardening: Remove setuid/setgid binaries
RUN find /usr -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

# Create www-data user
RUN if ! id -u www-data >/dev/null 2>&1; then \
		useradd -r -s /usr/sbin/nologin www-data; \
	fi

# Create directories
RUN mkdir -p /var/www/html && \
	mkdir -p /var/log/supervisor && \
	mkdir -p /var/run/supervisor && \
	mkdir -p /var/log/php && \
	mkdir -p /run/php && \
	mkdir -p /var/log/nginx && \
	chown -R www-data:www-data /var/www/html /var/log/php /run/php

WORKDIR /var/www/html

EXPOSE 80 443 8400

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
