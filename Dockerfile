# PMOVES-Wealth (Firefly III) - Hardened Architecture Dockerfile
# Extends upstream Firefly III with PMOVES branded defaults

ARG FIREFLY_UPSTREAM_IMAGE=fireflyiii/core
ARG FIREFLY_UPSTREAM_TAG=latest

FROM ${FIREFLY_UPSTREAM_IMAGE}:${FIREFLY_UPSTREAM_TAG}

# PMOVES branded labels
LABEL maintainer="PMOVES.AI <ops@cataclysmstudios.com>"
LABEL description="PMOVES-enhanced Firefly III personal finance manager"
LABEL org.pmoves.version="1.0.0-hardened"
LABEL org.pmoves.mode="standalone-docked"

# Set working directory
WORKDIR /var/www/html

# PMOVES branded default user (firefly:firefly)
# Upstream Firefly III runs as firefly user - PMOVES.AI preserves this
USER firefly

# Health check (follows redirect to /login)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fLs http://localhost:8080/ || exit 1

# Expose web UI
EXPOSE 8080

# Default entrypoint uses upstream
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
