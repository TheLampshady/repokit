# Environments

## Overview

| Environment | URL | Purpose | Access |
|-------------|-----|---------|--------|
[ENVIRONMENTS_TABLE]

## Local Development

### Prerequisites

[PREREQUISITES_LIST]

### Setup

```bash
[LOCAL_SETUP_COMMANDS]
```

### Environment Variables

Create `.env.local` from template:
```bash
cp .env.example .env.local
```

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
[LOCAL_ENV_VARS_TABLE]

### Local Services

[IF_HAS_LOCAL_SERVICES]
| Service | How to Run | Port | Notes |
|---------|------------|------|-------|
[LOCAL_SERVICES_TABLE]
[ENDIF]

### Local URLs

| Service | URL |
|---------|-----|
[LOCAL_URLS_TABLE]

## Staging

**URL**: [STAGING_URL]

**Deployment**: [STAGING_DEPLOY_METHOD]

### Environment Variables

| Variable | Source | Notes |
|----------|--------|-------|
[STAGING_ENV_VARS_TABLE]

### Access

[STAGING_ACCESS_INSTRUCTIONS]

## Production

**URL**: [PROD_URL]

**Deployment**: [PROD_DEPLOY_METHOD]

### Environment Variables

| Variable | Source | Notes |
|----------|--------|-------|
[PROD_ENV_VARS_TABLE]

### Access

[PROD_ACCESS_INSTRUCTIONS]

## Secrets Management

**Method**: [SECRETS_METHOD]

| Secret | Location | Rotation Policy |
|--------|----------|-----------------|
[SECRETS_TABLE]

### Adding New Secrets

[ADD_SECRETS_INSTRUCTIONS]

## Environment Parity

| Feature | Local | Staging | Prod |
|---------|-------|---------|------|
[PARITY_TABLE]

## Switching Environments

```bash
# Local
[LOCAL_SWITCH_CMD]

# Staging
[STAGING_SWITCH_CMD]

# Production
[PROD_SWITCH_CMD]
```

## Related Documentation

- [README.md](../README.md) - Project overview
- [CLOUD.md](./CLOUD.md) - Infrastructure details
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Environment issues
