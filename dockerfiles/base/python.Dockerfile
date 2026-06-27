# ============================================
# Hardened Base Python Image - Ubuntu 24.04 LTS
# Python 3.12 + pip + virtualenv + Nginx
# RASHA Super App - Modular Microservices
# ============================================
FROM ubuntu:24.04 AS python-base

LABEL maintainer="RASHA Super App Team"
LABEL description="Hardened Python 3.12 image with Nginx on Ubuntu 24.04 LTS"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	unzip \
	nginx \
	tzdata \
	libpq-dev \
	libssl-dev \
	libffi-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN apt-get update && apt-get install -y --no-install-recommends \
	python3.12 \
	python3.12-dev \
	python3.12-venv \
	python3-pip \
	&& rm -rf /var/lib/apt/lists/*

# Make python3.12 the default
RUN update-alternatives --install /usr/bin/python  python  /usr/bin/python3.12 1 && \
	update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

RUN pip install --no-cache-dir --break-system-packages \
	gunicorn \
	uvicorn \
	virtualenv

RUN apt-get purge -y --auto-remove python3.12-dev && \
	rm -rf /var/lib/apt/lists/*

# Security hardening
RUN find /usr -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

# Create appuser
RUN if ! id -u appuser >/dev/null 2>&1; then \
        useradd -r -s /usr/sbin/nologin appuser; \
    fi

RUN mkdir -p \
	/var/www/app \
	/var/log/nginx \
	/etc/nginx/sites-enabled && \
	chown -R appuser:appuser /var/www/app /var/log/nginx

WORKDIR /var/www/app

EXPOSE 80 443 8000

USER appuser

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
