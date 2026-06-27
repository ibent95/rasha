# ============================================
# RASHA Reverse Proxy — Nginx
# Routes subdomains to Angular websites
# ============================================
FROM nginx:alpine

LABEL maintainer="RASHA Super App Team"
LABEL description="Nginx reverse proxy — subdomain routing to Angular websites"

# Install curl for healthchecks (not included in Alpine by default)
RUN apk add --no-cache curl

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy proxy config
COPY configs/proxy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
