# Medium Projects

Documentation structure for multi-service or feature-rich projects.

## When to Use Medium Structure

- Multi-service projects (API + frontend, backend + worker)
- Framework + database + multiple cloud services
- Projects with 20-50 source files
- CI/CD pipelines present
- Team collaboration expected

## Detection Logic

**Medium if ANY true:**
- Multi-service (FastAPI + React, API + Worker)
- Framework + database + auth/storage (multiple cloud services)
- Framework with many features (20+ routes, complex models)
- 20-50 source files
- CI/CD config present

### Detection Examples

```
FastAPI + PostgreSQL + Auth         → Medium (multiple cloud services)
FastAPI + React                     → Medium (multi-service)
Django (20 routes, ORM, admin)      → Medium (framework + many features)
```

---

## File Structure

README.md with docs/ folder containing detailed documentation. The README covers essentials; docs/ provides depth.

```
project/
├── README.md                    # Overview, Getting Started, Usage, TOC, links to docs
└── docs/
    ├── ARCHITECTURE.md          # System design, diagrams, data models, modules
    ├── ENVIRONMENTS.md          # Local setup, env vars, secrets, per-environment config
    ├── CLOUD.md                 # Cloud services, infrastructure, deployment
    ├── TROUBLESHOOTING.md       # Common issues by category
    ├── CONTRIBUTING.md          # PR process, code review, brief testing note
    └── PRINCIPLES.md            # Patterns, decisions, testing approach, AI-readable knowledge
```

---

## README Structure

The README contains all 9 categories but links to docs/ for details.

```markdown
# Project Name

> One-line description

Brief context paragraph (2-3 sentences).

## Table of Contents

### Quick Start
- [Overview](#overview)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
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
[Purpose, key features, tech stack table, audience]
[NO deep architecture - link to ARCHITECTURE.md]

---

## Getting Started
[Prerequisites, install, configure, run - numbered steps]
[Link to ENVIRONMENTS.md for detailed setup]

---

## Configuration
[Key env vars table - essentials only]
> See [ENVIRONMENTS.md](./docs/ENVIRONMENTS.md) for full configuration.

---

## Usage
[Commands table - common commands]
[Brief workflow description]

---

## Architecture
[Brief overview paragraph, simple diagram]
> See [ARCHITECTURE.md](./docs/ARCHITECTURE.md) for full system design.

---

## Testing
[Test command, brief description]
> See [PRINCIPLES.md](./docs/PRINCIPLES.md) for testing patterns.

---

## Deployment
[Deploy command]
> See [CLOUD.md](./docs/CLOUD.md) for infrastructure and deployment details.

---

## Troubleshooting
[Top 3-5 quick fixes table]
> See [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) for full guide.

---

## Contributing
[Brief bullets: standards, PR process]
> See [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for full workflow.
```

---

## Doc Purposes

| Doc | Category Coverage | Purpose |
|-----|-------------------|---------|
| **README.md** | All 9 (brief) | Quick start, essential commands, links to details |
| **ARCHITECTURE.md** | Architecture + API | System design, diagrams, modules, data models, **API endpoints** |
| **ENVIRONMENTS.md** | Configuration | Local setup, env vars, secrets, per-environment config |
| **CLOUD.md** | Deployment + Ops | Cloud services, infrastructure, deployment, **operations basics** |
| **TROUBLESHOOTING.md** | Troubleshooting | Issues by category (dev, build, deploy), debugging |
| **CONTRIBUTING.md** | Contributing | PR process, code review, commit format, brief testing note |
| **PRINCIPLES.md** | Testing + Patterns | Testing approach, service patterns, "use X not Y", AI knowledge |

**Note:** For medium projects, API documentation lives in ARCHITECTURE.md and basic operations (health checks, scaling) lives in CLOUD.md. These break out to separate files only for large projects.

---

## PRINCIPLES.md Content

PRINCIPLES.md is for **patterns and institutional knowledge** that both humans and AI tools need:

```markdown
# Principles

Project patterns, architectural decisions, and guidelines for consistent development.

---

## Service Patterns

### [Service Name] Access
[Explain wrapper services to use instead of raw imports]

```python
# YES - use the wrapper
from api.gcp_services.clients.gcp_services import db, bucket

# NO - bypasses configuration
from firebase_admin import firestore
```

**Why:** [Rationale - e.g., "Handles emulator vs production switching"]

---

## Testing Approach

### Test Organization
[How tests are structured - unit/, integration/, fixtures/]

### Testing Patterns
[Approaches to use - e.g., "Mock external services", "Use fixtures for DB state"]

### What to Test
[Guidelines - e.g., "All public functions", "Integration tests for API routes"]

---

## Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| [Decision] | [What we chose] | [Why] |

---

## Code Conventions

- [Convention 1 - e.g., "Type hints required"]
- [Convention 2 - e.g., "Async for all DB operations"]
- [Convention 3]
```

---

## CONTRIBUTING.md Content

For medium projects, CONTRIBUTING.md focuses on process with a brief testing note:

```markdown
# Contributing

## Development Setup
[Brief setup or link to ENVIRONMENTS.md]

## Workflow
1. Create feature branch
2. Make changes
3. Run tests: `make test`
4. Submit PR

## Code Review
[Review process, who approves]

## Commit Format
[Commit message format]

## Testing
Run tests before submitting:
```bash
[test command]
```
> See [PRINCIPLES.md](./PRINCIPLES.md) for testing patterns and approach.
```

---

## CLOUD.md Content

For medium projects, CLOUD.md includes deployment (not a separate doc):

```markdown
# Cloud Infrastructure

## Overview

| Attribute | Value |
|-----------|-------|
| Provider | [GCP/AWS/Azure] |
| Project | [Project ID] |
| Region | [Region] |

## Services Used

| Service | Purpose |
|---------|---------|
| [Service 1] | [Purpose] |
| [Service 2] | [Purpose] |

## Infrastructure Diagram
```mermaid
architecture-beta
    [diagram]
```

## Deployment

### How to Deploy
```bash
[deploy command]
```

### What Happens
1. [Step 1]
2. [Step 2]

### Rollback
```bash
[rollback command]
```

## Monitoring
[Where to view logs, metrics]
```

---

## Rules

1. **README has all 9 categories** - Brief coverage with links to docs/
2. **Two-section TOC required** - "Quick Start" + "Documentation"
3. **docs/ folder required** - Detailed documentation lives here
4. **PRINCIPLES.md for patterns** - Testing approach, service patterns, AI knowledge
5. **CLOUD.md includes deployment** - Infrastructure + deploy in one doc
6. **CONTRIBUTING.md is process-focused** - Brief testing note, links to PRINCIPLES.md
7. **Horizontal rules between sections** - Visual separation in README
8. **Link format**: `> See [DOC.md](./docs/DOC.md) for details.`

---

## Templates

- `templates/core/README-MEDIUM.template.md` - README template
- `templates/core/ARCHITECTURE.template.md` - Architecture doc
- `templates/core/ENVIRONMENTS.template.md` - Environment setup
- `templates/core/CLOUD.template.md` - Cloud infrastructure
- `templates/core/TROUBLESHOOTING.template.md` - Troubleshooting guide
- `templates/core/CONTRIBUTING-MEDIUM.template.md` - Contributing guide
- `templates/core/PRINCIPLES.template.md` - Principles doc

## Sample

See `samples/medium-project/` for a complete example.
