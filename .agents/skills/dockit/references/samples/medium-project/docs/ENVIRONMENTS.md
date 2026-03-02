# Environments

Local setup, environment variables, and per-environment configuration.

---

## Overview

| Environment | URL | Purpose |
|-------------|-----|---------|
| Local | http://localhost:8000 | Development |
| Staging | https://api-staging.example.com | Pre-production testing |
| Production | https://api.example.com | Live service |

---

## Local Development

### Prerequisites

- Python 3.12+
- Docker and Docker Compose
- Firebase project with Auth enabled
- Make

### Setup

```bash
# 1. Clone and install
git clone <repo>
cd task-manager
make setup

# 2. Start databases
make db-start

# 3. Configure environment
cp .env.example .env
# Edit .env with your values

# 4. Run migrations
make migrate

# 5. Start server
make run
```

### Local Services

| Service | Command | Port |
|---------|---------|------|
| API | `make run` | 8000 |
| PostgreSQL | `make db-start` | 5432 |
| Redis | `make db-start` | 6379 |

### Local URLs

| Service | URL |
|---------|-----|
| API | http://localhost:8000 |
| API Docs | http://localhost:8000/docs |
| WebSocket | ws://localhost:8000/ws |

---

## Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection | `postgresql+asyncpg://user:pass@localhost:5432/tasks` |
| `REDIS_URL` | Redis connection | `redis://localhost:6379/0` |
| `FIREBASE_PROJECT_ID` | Firebase project | `my-project-id` |
| `JWT_SECRET` | Token signing key | `your-secret-key` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUG` | Enable debug mode | `false` |
| `LOG_LEVEL` | Logging verbosity | `INFO` |
| `CORS_ORIGINS` | Allowed origins | `*` |
| `MAX_CONNECTIONS` | DB pool size | `10` |

---

## Secrets Management

### Local

Secrets are stored in `.env` file (git-ignored).

### Staging/Production

Secrets are stored in Google Secret Manager and injected at runtime.

| Secret | Location |
|--------|----------|
| `DATABASE_URL` | Secret Manager |
| `JWT_SECRET` | Secret Manager |
| `FIREBASE_SA_KEY` | Secret Manager |

---

## Per-Environment Config

| Setting | Local | Staging | Production |
|---------|-------|---------|------------|
| Debug | true | false | false |
| Log Level | DEBUG | INFO | WARNING |
| DB Pool | 5 | 10 | 20 |
| CORS | * | staging domains | production domains |

---

## Database Setup

### Local (Docker)

```bash
make db-start    # Start PostgreSQL and Redis
make db-stop     # Stop containers
make db-reset    # Reset database (destroys data)
```

### Migrations

```bash
make migrate           # Run pending migrations
make migrate-create    # Create new migration
make migrate-rollback  # Rollback last migration
```

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [CLOUD.md](./CLOUD.md) - Infrastructure and deployment
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Environment issues
