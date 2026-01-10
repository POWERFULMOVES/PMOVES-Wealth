# PMOVES-Wealth (Firefly III) Makefile - Hardened Architecture
# Dual-mode operation: standalone or docked to PMOVES.AI

SHELL := /bin/bash
.SHELLFLAGS := -ec

# Docker compose command
COMPOSE ?= $(shell docker compose version >/dev/null 2>&1 && echo "docker compose" || echo "docker-compose")

# Image names
DOCKERHUB_IMAGE := powerfulmoves/pmoves-wealth
GHCR_IMAGE := ghcr.io/powerfulmoves/pmoves-wealth
VERSION ?= pmoves-latest

# Build platforms
PLATFORMS := linux/amd64,linux/arm64

.PHONY: help up up-postgres down restart logs build push status clean install check test db-migrate

help:
	@echo "PMOVES-Wealth (Firefly III) Commands"
	@echo "===================================="
	@echo "  make up           - Start Firefly III with SQLite"
	@echo "  make up-postgres  - Start Firefly III with PostgreSQL"
	@echo "  make down         - Stop Firefly III"
	@echo "  make restart      - Restart Firefly III"
	@echo "  make logs         - View logs"
	@echo "  make status       - Check service status"
	@echo "  make build        - Build Docker image"
	@echo "  make push         - Build and push multi-arch image"
	@echo "  make clean        - Remove containers and volumes"
	@echo "  make install      - Setup environment"
	@echo "  make check        - Verify configuration"
	@echo "  make db-migrate   - Run database migrations"

# Check environment
check:
	@echo "Checking environment..."
	@docker --version > /dev/null 2>&1 || { echo "✗ Docker not found"; exit 1; }
	@$(COMPOSE) version > /dev/null 2>&1 || { echo "✗ Docker Compose not found"; exit 1; }
	@test -f .env || { echo "✗ .env file not found. Run 'make install'"; exit 1; }
	@echo "✓ Environment OK"

# Install/setup
install: check
	@echo "Setting up PMOVES-Wealth..."
	@test -f .env || cp .env.example .env
	@test -f .env.local || cp .env.local.example .env.local
	@echo "✓ Configuration files created"
	@$(MAKE) -s generate-key
	@echo "✓ Setup complete. Edit .env and .env.local files to configure."

# Generate APP_KEY
generate-key:
	@if grep -q "CHANGE_ME" .env.local 2>/dev/null; then \
		KEY=$$(openssl rand -base32 32 | cut -c1-32); \
		sed -i "s/APP_KEY=.*/APP_KEY=$$KEY/" .env.local; \
		echo "✓ Generated APP_KEY in .env.local"; \
	fi

# Start service (SQLite)
up: check
	@echo "Starting PMOVES-Wealth (Firefly III) with SQLite..."
	@$(COMPOSE) up -d
	@echo "✓ Firefly III started"
	@echo "  Web UI: http://localhost:8080"
	@echo "  Default credentials: See .env.local"

# Start service (PostgreSQL)
up-postgres: check
	@echo "Starting PMOVES-Wealth (Firefly III) with PostgreSQL..."
	@$(COMPOSE) --profile postgres up -d
	@echo "✓ Firefly III started with PostgreSQL"
	@echo "  Web UI: http://localhost:8080"

# Stop service
down:
	@echo "Stopping PMOVES-Wealth..."
	@$(COMPOSE) --profile postgres down
	@echo "✓ Firefly III stopped"

# Restart service
restart: down
	@$(MAKE) -s $(shell test -n "$$POSTGRES_PASSWORD" && echo "up-postgres" || echo "up")

# View logs
logs:
	@$(COMPOSE) logs -f app

# Check status
status:
	@echo "PMOVES-Wealth Status:"
	@$(COMPOSE) ps

# Build image
build:
	@echo "Building PMOVES-Wealth image..."
	@docker build \
		--build-arg FIREFLY_UPSTREAM_IMAGE=${FIREFLY_UPSTREAM_IMAGE:-fireflyiii/core} \
		--build-arg FIREFLY_UPSTREAM_TAG=${FIREFLY_UPSTREAM_TAG:-latest} \
		-t $(DOCKERHUB_IMAGE):$(VERSION) \
		-t $(GHCR_IMAGE):$(VERSION) \
		.
	@echo "✓ Build complete"
	@echo "  Images tagged:"
	@echo "    - $(DOCKERHUB_IMAGE):$(VERSION)"
	@echo "    - $(GHCR_IMAGE):$(VERSION)"

# Build and push multi-arch
push: buildx-prepare
	@echo "Building and pushing multi-arch image..."
	@docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg FIREFLY_UPSTREAM_IMAGE=${FIREFLY_UPSTREAM_IMAGE:-fireflyiii/core} \
		--build-arg FIREFLY_UPSTREAM_TAG=${FIREFLY_UPSTREAM_TAG:-latest} \
		--progress=plain \
		-t $(DOCKERHUB_IMAGE):$(VERSION) \
		-t $(GHCR_IMAGE):$(VERSION) \
		--push \
		.
	@echo "✓ Multi-arch push complete"

# Buildx helpers
buildx-prepare:
	@docker buildx inspect multi-platform-builder >/dev/null 2>&1 || \
		docker buildx create --use --name multi-platform-builder --driver docker-container
	@docker buildx use multi-platform-builder

# Clean up
clean:
	@echo "Cleaning up PMOVES-Wealth..."
	@$(COMPOSE) --profile postgres down -v
	@docker volume rm ${VOLUME_PREFIX:-firefly}_upload ${VOLUME_PREFIX:-firefly}_export ${VOLUME_PREFIX:-firefly}_db 2>/dev/null || true
	@echo "✓ Cleanup complete"

# Database migrations
db-migrate:
	@echo "Running database migrations..."
	@$(COMPOSE) exec app php artisan migrate --force
	@echo "✓ Migrations complete"

# Health check
test:
	@echo "Testing PMOVES-Wealth..."
	@curl -fSs http://localhost:8080/health > /dev/null && echo "✓ Health check passed" || echo "✗ Health check failed"
