# Large Projects

Documentation structure for complex projects, monorepos, and multi-team codebases.

## When to Use Large Structure

- >50 source files
- Monorepo structure
- Multiple teams (CODEOWNERS with multiple owners)
- Complex CI/CD (multiple environments, pipelines)
- Multiple databases or extensive integrations

## Detection Logic

**Large if ANY true:**
- Monorepo structure
- Multiple teams (CODEOWNERS with multiple owners)
- >50 source files
- Multiple deployment environments with complex pipelines
- Multiple databases or services

### Detection Examples

```
Monorepo (3 services)               → Large
Multiple teams, CODEOWNERS          → Large
60+ source files                    → Large
```

---

## File Structure

Docs can break out into **sub-folders** when sections become too complex. Each parent doc becomes an overview with links to detailed sub-docs.

```
project/
├── README.md                        # Overview + TOC with two sections
└── docs/
    ├── ARCHITECTURE.md              # Overview + links to architecture/
    ├── architecture/                # Created when triggers fire
    │   ├── DATA-MODELS.md           # If multiple DBs or complex schema
    │   ├── SERVICES.md              # If multiple services
    │   ├── API.md                   # If API with >10 endpoints
    │   └── INTEGRATIONS.md          # If >5 external integrations
    │
    ├── ENVIRONMENTS.md              # Overview + links to environments/
    ├── environments/                # Created when multiple envs
    │   ├── LOCAL.md
    │   ├── STAGING.md
    │   └── PRODUCTION.md
    │
    ├── CLOUD.md                     # Overview + links to cloud/
    ├── cloud/                       # Created when triggers fire
    │   ├── INFRASTRUCTURE.md        # IaC details
    │   ├── DEPLOYMENT.md            # CI/CD pipelines (separate for large!)
    │   ├── MONITORING.md            # Logging, alerts, dashboards
    │   └── RUNBOOK.md               # Incident response, scaling, maintenance
    │
    ├── TROUBLESHOOTING.md           # Overview + links to troubleshooting/
    ├── troubleshooting/             # Created when complex
    │   ├── DEVELOPMENT.md
    │   └── PRODUCTION.md
    │
    ├── CONTRIBUTING.md              # Overview + links to contributing/
    ├── contributing/                # Created when team is large
    │   ├── WORKFLOW.md
    │   └── RELEASES.md
    │
    ├── PRINCIPLES.md                # Overview + links to principles/
    ├── principles/                  # Created when triggers fire
    │   ├── PATTERNS.md              # Service patterns
    │   ├── TESTING.md               # Now its own doc for large!
    │   └── CONVENTIONS.md           # Code style details
    │
    ├── how-to/                      # Created when many procedures needed
    │   ├── INDEX.md                 # List of all how-to guides
    │   └── [procedure].md           # Individual procedure guides
    │
    └── [framework-specific]/        # Wagtail, Django, React, etc.
```

---

## Complexity Triggers

Dockit **automatically** creates sub-docs when these triggers are detected:

| Trigger | Detection | Creates |
|---------|-----------|---------|
| Multiple databases | >1 DB connection, multiple ORMs | `architecture/DATA-MODELS.md` |
| Multiple services | >2 service directories | `architecture/SERVICES.md` |
| Complex API | >10 endpoints, multiple auth methods | `architecture/API.md` |
| Many integrations | >5 external API clients | `architecture/INTEGRATIONS.md` |
| Multiple environments | >2 env configs, terraform workspaces | `environments/[ENV].md` |
| Complex CI/CD | >3 workflow files, multiple stages | `cloud/DEPLOYMENT.md` |
| Monitoring setup | Alert configs, dashboard definitions | `cloud/MONITORING.md` |
| Production deployment | Production env with SLAs | `cloud/RUNBOOK.md` |
| Security config | IAM policies, network rules | `cloud/SECURITY.md` |
| Large team | CODEOWNERS, >5 contributors | `contributing/RELEASES.md` |
| Extensive tests | >100 tests, multiple test types | `principles/TESTING.md` |
| IaC present | Terraform, Pulumi, CloudFormation | `cloud/INFRASTRUCTURE.md` |
| Many procedures | >5 multi-step operational tasks | `how-to/INDEX.md` |

**Partial breakout**: Only create the specific sub-doc that's needed. Don't create empty files.

---

## TOC Structure

README and parent docs use a **two-section TOC**:

```markdown
# Project Name

> Description

## Table of Contents

### Quick Start
- [Overview](#overview)
- [Getting Started](#getting-started)
- [Usage](#usage)

### Documentation
- [Architecture](./docs/ARCHITECTURE.md) - System design and data models
- [Environments](./docs/ENVIRONMENTS.md) - Setup and configuration
- [Cloud](./docs/CLOUD.md) - Infrastructure and deployment
- [Troubleshooting](./docs/TROUBLESHOOTING.md) - Common issues
- [Contributing](./docs/CONTRIBUTING.md) - Development workflow
- [Principles](./docs/PRINCIPLES.md) - Patterns and conventions

---

## Overview
...
```

---

## Parent Doc Structure

When a doc has sub-docs, it becomes an overview:

```markdown
# Architecture

System design overview with links to detailed documentation.

## Table of Contents

### In This Document
- [Overview](#overview)
- [System Diagram](#system-diagram)
- [Key Components](#key-components)

### Detailed Documentation
- [Data Models](./architecture/DATA-MODELS.md) - Database schemas, ERDs
- [Services](./architecture/SERVICES.md) - Service-by-service breakdown
- [Integrations](./architecture/INTEGRATIONS.md) - External APIs and webhooks

---

## Overview

[Brief architecture overview - executive summary level]

---

## System Diagram

[High-level diagram - details in sub-docs]

```mermaid
flowchart TD
    ...
```

---

## Key Components

| Component | Purpose | Details |
|-----------|---------|---------|
| API | REST backend | [Services →](./architecture/SERVICES.md) |
| Database | PostgreSQL + Redis | [Data Models →](./architecture/DATA-MODELS.md) |
| Integrations | Stripe, SendGrid | [Integrations →](./architecture/INTEGRATIONS.md) |
```

---

## Framework-Specific Docs

| Framework | Additional Docs |
|-----------|-----------------|
| **Wagtail** | `wagtail/PAGES.md`, `wagtail/BLOCKS.md`, `wagtail/ADMIN.md` |
| **Django** | `django/APPS.md`, `django/ADMIN.md` |
| **React** | `react/COMPONENTS.md`, `react/STATE.md` |
| **Kubernetes** | `k8s/README.md`, `k8s/HELM.md` |
| **Terraform** | `infra/README.md`, `infra/MODULES.md` |

---

## Monorepo Structure

For monorepos, each service has its own README linking to **shared docs**:

```
monorepo/
├── README.md                    # Root overview, links to services and shared docs
├── docs/                        # SHARED docs (PRINCIPLES, CONTRIBUTING, etc.)
│   ├── PRINCIPLES.md            # Shared across all services
│   ├── CONTRIBUTING.md          # Shared workflow
│   ├── ARCHITECTURE.md          # System-wide architecture
│   └── ...
├── services/
│   ├── api/
│   │   ├── README.md            # API-specific (links to ../../docs/)
│   │   └── docs/                # API-specific docs if complex
│   │       └── ROUTES.md
│   └── worker/
│       ├── README.md            # Worker-specific
│       └── docs/
└── packages/
    └── common/
        └── README.md            # Package docs
```

Service README links to shared docs:

```markdown
# API Service

> REST API for the platform.

## Documentation

- [Shared Principles](../../docs/PRINCIPLES.md)
- [Shared Contributing](../../docs/CONTRIBUTING.md)
- [System Architecture](../../docs/ARCHITECTURE.md)

## Service-Specific

- [API Routes](./docs/ROUTES.md)
```

---

## Migration Detection

On `sync` or `migrate`, dockit detects project growth and prompts:

```
─────────────────────────────────────────
dockit detected project growth
─────────────────────────────────────────

Your project appears to have grown:
  • 65 source files (was ~40)
  • Complex CI/CD detected (3 workflows)
  • Multiple environments (local, staging, prod)
  • >100 tests detected

Recommend upgrading to large project structure:
  + docs/cloud/DEPLOYMENT.md (extracted from CLOUD.md)
  + docs/environments/STAGING.md (extracted from ENVIRONMENTS.md)
  + docs/environments/PRODUCTION.md (extracted from ENVIRONMENTS.md)
  + docs/principles/TESTING.md (extracted from PRINCIPLES.md)

Proceed with restructure? [Y/n]
─────────────────────────────────────────
```

---

## Rules

1. **Partial breakout** - Only create sub-docs when specific triggers fire
2. **Two-section TOC** - "In This Document" + "Detailed Documentation"
3. **Parent docs become overviews** - Brief content + links to sub-docs
4. **Sub-docs are self-contained** - Can be read independently
5. **Framework docs in named folders** - `wagtail/`, `react/`, `k8s/`
6. **Monorepo shares docs** - Services link to root docs/
7. **Migration prompts** - Detect growth on sync/migrate
8. **TESTING.md becomes separate** - Extracted from PRINCIPLES.md for large projects

---

## Templates

- `templates/core/README-LARGE.template.md` - README template
- `templates/core/ARCHITECTURE-LARGE.template.md` - Parent architecture doc
- `templates/core/architecture/DATA-MODELS.template.md` - Data models sub-doc
- `templates/core/architecture/API.template.md` - API reference sub-doc
- `templates/core/cloud/DEPLOYMENT.template.md` - Deployment sub-doc
- `templates/core/cloud/RUNBOOK.template.md` - Operations runbook
- `templates/core/principles/TESTING.template.md` - Testing sub-doc

## Sample

See `samples/monorepo/` for a complete example.
