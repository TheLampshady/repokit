# Architecture

## Overview

[ARCHITECTURE_OVERVIEW]

## System Diagram

```
[SYSTEM_DIAGRAM_ASCII]
```

[IF_WAGTAIL]
## Wagtail Architecture

### Page Tree Structure

```
[PAGE_TREE_ASCII]
```

### App Organization

| App | Purpose | Key Models |
|-----|---------|------------|
[APPS_TABLE]

[REPEAT_FOR_EACH_APP]
### [APP_NAME]

**Purpose**: [APP_PURPOSE]

**Models**:

| Model | Type | Description |
|-------|------|-------------|
[APP_MODELS_TABLE]

**Key Files**:

| File | Purpose |
|------|---------|
| `models.py` | Page models, fields |
[IF_HAS_BLOCKS]
| `blocks.py` | Custom blocks |
[ENDIF]
[IF_HAS_WAGTAIL_HOOKS]
| `wagtail_hooks.py` | Admin customizations |
[ENDIF]

**See**: [[APP_NAME]/GEMINI.md](../[APP_NAME]/GEMINI.md)

[END_REPEAT]

### Block Architecture

Blocks are organized hierarchically:

```
core/blocks/
├── base.py          # Base block classes
├── content.py       # Text, rich text, headings
├── media.py         # Images, videos, embeds
├── layout.py        # Columns, sections, cards
└── __init__.py      # Public exports
```

See [docs/BLOCKS.md](./BLOCKS.md) for full block reference.

[IF_HEADLESS]
### API Architecture

Headless setup using Wagtail API v2:

| Endpoint | Purpose | Serializer |
|----------|---------|------------|
[API_ENDPOINTS_TABLE]

**Base URL**: `/api/v2/`

**Authentication**: [API_AUTH_METHOD]
[ENDIF]

[IF_HAS_SEARCH]
### Search Architecture

**Backend**: [SEARCH_BACKEND]

**Indexed Models**:
[SEARCH_INDEXED_MODELS]
[ENDIF]

[ENDIF]

## Services

[IF_MULTI_SERVICE]
| Service | Purpose | Port | Tech | Location |
|---------|---------|------|------|----------|
[SERVICES_TABLE]

[REPEAT_FOR_EACH_SERVICE]
### [SERVICE_NAME]

**Purpose**: [SERVICE_PURPOSE]

**Tech Stack**: [SERVICE_TECH]

**Dependencies**: [SERVICE_DEPENDENCIES]

**Key Files**:

| File | Purpose |
|------|---------|
[SERVICE_KEY_FILES_TABLE]

**See**: [[SERVICE_NAME]/README.md](../[SERVICE_NAME]/README.md)
[END_REPEAT]
[ENDIF]

[IF_SINGLE_SERVICE]
### Application Structure

| Directory | Purpose |
|-----------|---------|
[DIRECTORY_TABLE]
[ENDIF]

## Data Flow

```
[DATA_FLOW_DIAGRAM]
```

## Key Packages/Modules

| Package | Purpose | Location |
|---------|---------|----------|
[PACKAGES_TABLE]

[REPEAT_FOR_KEY_PACKAGES]
### [PACKAGE_NAME]

**Purpose**: [PACKAGE_PURPOSE]

**Public API**:
```[LANGUAGE]
[PUBLIC_API_EXAMPLE]
```

**Usage**:
```[LANGUAGE]
[USAGE_EXAMPLE]
```
[END_REPEAT]

## Database

[IF_HAS_DATABASE]
**Type**: [DATABASE_TYPE]

**ORM/Client**: [DATABASE_CLIENT]

### Schema Overview

| Table/Collection | Purpose | Key Fields |
|------------------|---------|------------|
[TABLES_TABLE]

[IF_WAGTAIL]
### Wagtail Core Tables

| Table | Purpose |
|-------|---------|
| `wagtailcore_page` | Base page tree (MPTT) |
| `wagtailcore_pagerevision` | Page version history |
| `wagtailcore_site` | Site configuration |
| `wagtailimages_image` | Image library |
| `wagtaildocs_document` | Document library |
[ENDIF]

### Relationships

```
[RELATIONSHIP_DIAGRAM]
```
[ENDIF]

[IF_NO_DATABASE]
This project does not use a database.
[ENDIF]

[IF_HAS_API]
## API

[API_CONTEXT]
<!-- Brief intro: "REST API for client applications. All endpoints require authentication unless noted." -->

### Base URL

| Environment | URL |
|-------------|-----|
| Local | `http://localhost:[PORT]` |
| Staging | `[STAGING_URL]` |
| Production | `[PRODUCTION_URL]` |

### Authentication

[API_AUTH_DESCRIPTION]
<!-- How auth works: Bearer tokens, API keys, etc. -->

```bash
# Example authenticated request
curl -H "Authorization: Bearer $TOKEN" [API_URL]/endpoint
```

### Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
[API_ENDPOINTS_TABLE]

[IF_MEDIUM_PROJECT]
### Error Codes

| Code | Meaning | Common Cause |
|------|---------|--------------|
| 400 | Bad Request | Invalid input or missing required fields |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | Valid token but insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Internal error - check logs |

### Rate Limits

[RATE_LIMITS_DESCRIPTION]
[ENDIF]

[IF_LARGE_PROJECT]
> See [architecture/API.md](./architecture/API.md) for full API reference.
[ENDIF]
[ENDIF]

## External Integrations

| Integration | Purpose | Auth Method | Docs |
|-------------|---------|-------------|------|
[INTEGRATIONS_TABLE]

## Design Decisions

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
[DESIGN_DECISIONS_TABLE]

## Related Documentation

- [README.md](../README.md) - Project overview
[IF_WAGTAIL]
- [MODELS.md](./MODELS.md) - Page models reference
- [BLOCKS.md](./BLOCKS.md) - Block library reference
[ENDIF]
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Environment configuration
- [CLOUD.md](./CLOUD.md) - Deployment architecture
