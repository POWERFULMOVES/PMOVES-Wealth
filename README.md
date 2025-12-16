# PMOVES-Wealth

[![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](LICENSE)
[![PMOVES.AI](https://img.shields.io/badge/PMOVES.AI-Integration-green.svg)](https://github.com/POWERFULMOVES/PMOVES.AI)

> Personal finance management and wealth tracking integration for PMOVES.AI

PMOVES-Wealth is a customized deployment of [Firefly III](https://github.com/firefly-iii/firefly-iii), a self-hosted personal finance manager, integrated into the PMOVES.AI multi-agent orchestration platform. It provides comprehensive financial tracking, budgeting, and wealth management capabilities with AI-powered insights.

## Overview

PMOVES-Wealth enables you to:
- Track income and expenses across multiple accounts
- Create budgets and monitor spending patterns
- Manage recurring transactions and subscriptions
- Generate detailed financial reports and visualizations
- Import data from banks and financial institutions
- Maintain complete privacy with self-hosted infrastructure

As part of the PMOVES.AI ecosystem, PMOVES-Wealth integrates with Agent Zero, Hi-RAG, and other services to provide intelligent financial insights and automated wealth tracking.

## Features

### Core Financial Management
- **Double-Entry Bookkeeping**: Accurate financial tracking with industry-standard accounting
- **Multi-Currency Support**: Track accounts in any currency with automatic conversion
- **Account Types**: Support for asset accounts, expense accounts, revenue accounts, cash accounts, and liabilities
- **Transaction Management**: Create, edit, and categorize transactions with rich metadata

### Planning & Budgeting
- **Budget Management**: Set monthly/quarterly/yearly budgets and track spending
- **Piggy Banks**: Save toward specific goals with dedicated tracking
- **Recurring Transactions**: Automate regular income and expenses
- **Financial Reports**: Comprehensive income/expense reports with charts and graphs

### Automation & Intelligence
- **Rule-Based Automation**: Automatically categorize and process transactions
- **Transaction Import**: Import from CSV, banks, and financial institutions
- **REST API**: Full-featured JSON API for integrations
- **Webhooks**: Event-driven notifications for financial events

### Security & Privacy
- **Self-Hosted**: Complete control over your financial data
- **2FA Authentication**: Enhanced security with two-factor authentication
- **OAuth2/Passport**: Secure API access with token-based authentication
- **Audit Logging**: Track system access and changes

## Quick Start

### Prerequisites
- Docker and Docker Compose
- Access to PMOVES.AI network (`pmoves-net`)
- MySQL/PostgreSQL database
- PHP 8.4+ (for local development)

### Docker Deployment (Recommended)

PMOVES-Wealth runs as part of the PMOVES.AI stack:

```bash
# From PMOVES.AI root directory
docker compose -f PMOVES-Wealth/docker-compose.pmoves-net.yml up -d
```

The service will be available at `http://localhost:8080` (or configured port).

### Standalone Deployment

```bash
# Clone the repository
git clone https://github.com/POWERFULMOVES/PMOVES-Wealth.git
cd PMOVES-Wealth

# Copy environment configuration
cp .env.example .env

# Configure your database and settings in .env
nano .env

# Start with Docker Compose
docker compose up -d
```

## Configuration

### Environment Variables

Key configuration options in `.env`:

#### Application Settings
```bash
APP_ENV=production                    # Environment: production, local, testing
APP_DEBUG=false                       # Debug mode (disable in production)
APP_KEY=                              # 32-character encryption key (generate with artisan)
APP_URL=http://localhost              # Public URL for your installation
SITE_OWNER=your.email@example.com     # Admin email address
```

#### Database Configuration
```bash
DB_CONNECTION=mysql                   # Database type: mysql, pgsql, sqlite
DB_HOST=db                            # Database hostname
DB_PORT=3306                          # Database port
DB_DATABASE=firefly                   # Database name
DB_USERNAME=firefly                   # Database user
DB_PASSWORD=secret_firefly_password   # Database password
```

#### Timezone & Localization
```bash
TZ=America/New_York                   # Your timezone
DEFAULT_LANGUAGE=en_US                # Default language
DEFAULT_LOCALE=equal                  # Number formatting locale
```

#### Authentication
```bash
AUTHENTICATION_GUARD=web              # Auth method: web, remote_user_guard
CUSTOM_LOGOUT_URL=                    # Custom logout redirect
```

#### Email Notifications
```bash
MAIL_MAILER=smtp                      # Mail driver: smtp, log, sendmail
MAIL_HOST=smtp.example.com            # SMTP hostname
MAIL_PORT=587                         # SMTP port
MAIL_FROM=firefly@example.com         # From address
MAIL_USERNAME=                        # SMTP username
MAIL_PASSWORD=                        # SMTP password
MAIL_ENCRYPTION=tls                   # Encryption: tls, ssl
```

#### Performance & Caching
```bash
CACHE_DRIVER=redis                    # Cache: file, redis, memcached
SESSION_DRIVER=redis                  # Sessions: file, redis, database
REDIS_HOST=127.0.0.1                  # Redis hostname
REDIS_PORT=6379                       # Redis port
REDIS_PASSWORD=                       # Redis password
```

#### Security & Privacy
```bash
TRUSTED_PROXIES=**                    # Trust reverse proxies
DISABLE_FRAME_HEADER=false            # X-Frame-Options header
DISABLE_CSP_HEADER=false              # Content Security Policy header
```

#### Optional Features
```bash
ENABLE_EXTERNAL_MAP=false             # Geolocation features
ENABLE_EXCHANGE_RATES=false           # Currency conversion
ENABLE_EXTERNAL_RATES=false           # Download exchange rates
ALLOW_WEBHOOKS=false                  # Enable webhook functionality
STATIC_CRON_TOKEN=                    # Token for cron jobs (32 chars)
```

### First-Time Setup

1. **Generate Application Key**:
   ```bash
   docker exec -it pmoves-wealth php artisan key:generate
   ```

2. **Run Database Migrations**:
   ```bash
   docker exec -it pmoves-wealth php artisan migrate --seed
   ```

3. **Create Admin User**: Visit the application URL and complete registration

4. **Configure OAuth Keys** (for API access):
   ```bash
   docker exec -it pmoves-wealth php artisan firefly-iii:laravel-passport-keys
   ```

## API Access

PMOVES-Wealth exposes a comprehensive REST API for integration with PMOVES.AI agents.

### Authentication

1. **Create Personal Access Token**:
   - Login to PMOVES-Wealth
   - Navigate to Profile → OAuth → Create New Token
   - Save the token securely

2. **API Request Example**:
   ```bash
   curl -X GET "http://localhost:8080/api/v1/accounts" \
     -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     -H "Accept: application/json"
   ```

### Key API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/accounts` | GET | List all accounts |
| `/api/v1/transactions` | GET | List transactions |
| `/api/v1/budgets` | GET | List budgets |
| `/api/v1/categories` | GET | List categories |
| `/api/v1/bills` | GET | List recurring bills |
| `/api/v1/piggy-banks` | GET | List savings goals |
| `/api/v1/data/export` | GET | Export all data |
| `/api/v1/autocomplete/*` | GET | Autocomplete endpoints |

Full API documentation: https://docs.firefly-iii.org/references/api/

## Integration with PMOVES.AI

### Agent Zero Integration

PMOVES-Wealth can be queried by Agent Zero for financial insights:

```python
# Example: Query account balance via Agent Zero
response = await agent_zero.mcp_call({
    "tool": "http_request",
    "params": {
        "url": "http://pmoves-wealth:8080/api/v1/accounts",
        "headers": {"Authorization": "Bearer TOKEN"}
    }
})
```

### NATS Event Integration

Financial events can be published to NATS for agent coordination:

```bash
# Example: Publish transaction event
nats pub "wealth.transaction.created.v1" '{
  "transaction_id": "123",
  "amount": 500.00,
  "category": "groceries",
  "timestamp": "2025-12-16T10:30:00Z"
}'
```

### Hi-RAG Integration

Financial data can be indexed into Hi-RAG for semantic search:

```bash
# Index financial report
curl -X POST http://localhost:8083/ingest \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Monthly financial report...",
    "metadata": {
      "source": "pmoves-wealth",
      "type": "financial_report",
      "date": "2025-12"
    }
  }'
```

### SupaSerch Research

Complex financial research queries can leverage SupaSerch:

```bash
# Research spending patterns
nats pub "supaserch.request.v1" '{
  "query": "Analyze my spending patterns for the last 6 months",
  "sources": ["pmoves-wealth"],
  "depth": "comprehensive"
}'
```

## Dependencies

### Runtime Dependencies
- **PHP**: 8.4 or higher
- **Database**: MySQL 8.0+, PostgreSQL 13+, or SQLite
- **Web Server**: Nginx (recommended) or Apache
- **PHP Extensions**: bcmath, curl, fileinfo, intl, json, mbstring, openssl, pdo, session, sodium, xml

### Optional Dependencies
- **Redis**: For caching and sessions (recommended for production)
- **Memcached**: Alternative caching backend
- **SMTP Server**: For email notifications

### Laravel Framework
Built on Laravel 12, leveraging:
- Laravel Passport for OAuth2
- Laravel Sanctum for API tokens
- Laravel Queue for background jobs
- Laravel Notifications for alerts

## Development

### Local Development Setup

```bash
# Install dependencies
composer install
npm install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate --seed

# Start development server
php artisan serve
```

### Testing

```bash
# Run all tests
composer coverage

# Run unit tests only
composer unit-test

# Run integration tests only
composer integration-test
```

### Code Quality

```bash
# PHPStan static analysis
vendor/bin/phpstan analyse

# PHP Code Sniffer
vendor/bin/phpcs

# Rector refactoring
vendor/bin/rector process
```

## Data Import

PMOVES-Wealth supports importing data from:
- **CSV Files**: Custom format or standard bank exports
- **Financial Institutions**: Via [Firefly III Data Importer](https://github.com/firefly-iii/data-importer)
- **Banks**: Using Spectre, Plaid, or other integrations
- **API**: Programmatic import via REST API

## Backup & Recovery

### Database Backup

```bash
# Backup database
docker exec pmoves-wealth-db mysqldump -u firefly -p firefly > backup.sql

# Restore database
docker exec -i pmoves-wealth-db mysql -u firefly -p firefly < backup.sql
```

### Full Data Export

```bash
# Export all data via API
curl -X GET "http://localhost:8080/api/v1/data/export" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -o firefly-export.zip
```

## Monitoring & Observability

PMOVES-Wealth integrates with PMOVES.AI monitoring stack:

- **Health Endpoint**: `GET /api/v1/ping` or `GET /health`
- **Prometheus Metrics**: Laravel metrics via custom exporters
- **Loki Logs**: Structured logging to centralized Loki
- **Grafana Dashboards**: Pre-configured financial dashboards

## Security Considerations

- **Keep Updated**: Regularly update to latest version for security patches
- **Strong Passwords**: Enforce strong password policies
- **2FA Required**: Enable two-factor authentication for all users
- **HTTPS Only**: Always use HTTPS in production
- **Database Security**: Use strong database passwords, restrict network access
- **Regular Backups**: Automate daily backups with encryption
- **Audit Logs**: Enable and monitor audit logging

## Troubleshooting

### Common Issues

**Issue**: Database connection errors
```bash
# Check database connectivity
docker exec pmoves-wealth php artisan db:show
```

**Issue**: Permission errors
```bash
# Fix storage permissions
docker exec pmoves-wealth chmod -R 775 storage bootstrap/cache
```

**Issue**: Cron jobs not running
```bash
# Verify cron configuration
docker exec pmoves-wealth php artisan schedule:list
```

**Issue**: API authentication fails
```bash
# Regenerate OAuth keys
docker exec pmoves-wealth php artisan firefly-iii:laravel-passport-keys
```

## Contributing

PMOVES-Wealth is based on Firefly III. For contributions:

1. **Upstream Contributions**: Submit to [firefly-iii/firefly-iii](https://github.com/firefly-iii/firefly-iii)
2. **PMOVES Integration**: Submit to [PMOVES-Wealth](https://github.com/POWERFULMOVES/PMOVES-Wealth)

Please follow the [Firefly III Contributing Guidelines](https://docs.firefly-iii.org/explanation/support/#contributing-code).

## Resources

### Documentation
- [Firefly III Official Docs](https://docs.firefly-iii.org/)
- [API Reference](https://docs.firefly-iii.org/references/api/)
- [PMOVES.AI Documentation](https://github.com/POWERFULMOVES/PMOVES.AI)

### Community
- [Firefly III GitHub Discussions](https://github.com/firefly-iii/firefly-iii/discussions)
- [Firefly III Gitter Chat](https://gitter.im/firefly-iii/firefly-iii)
- [Mastodon](https://fosstodon.org/@ff3)

### Related Projects
- [Firefly III Data Importer](https://github.com/firefly-iii/data-importer)
- [Firefly III Mobile App](https://docs.firefly-iii.org/references/firefly-iii/third-parties/apps/)
- [Third-Party Tools](https://docs.firefly-iii.org/references/firefly-iii/third-parties/apps/)

## License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).

PMOVES-Wealth is based on Firefly III by James Cole. See [THANKS.md](THANKS.md) for the full list of contributors to Firefly III.

## Acknowledgements

- **Firefly III**: Created and maintained by [James Cole](https://github.com/JC5)
- **PMOVES.AI**: Multi-agent orchestration platform by POWERFULMOVES
- **Laravel Framework**: The PHP framework for web artisans
- **Community Contributors**: All contributors listed in [THANKS.md](THANKS.md)

---

**PMOVES-Wealth**: Making personal finance management intelligent and integrated.

For support, issues, or questions about PMOVES.AI integration, please open an issue in the [PMOVES.AI repository](https://github.com/POWERFULMOVES/PMOVES.AI/issues).
