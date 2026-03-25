# dockit Documentation Tree

How dockit structures project documentation — the logical hierarchy, what each layer contains, and how it scales.

---

## The Idea

Documentation follows a **funnel pattern**: start broad (what is this?), narrow into principles (how do we work?), then branch into specifics (architecture, environments, operations). Each layer builds on the one above it.

```
README.md                          ← Entry point: what, why, get started
  |
  +-- PRINCIPLES.md                ← Foundation: how we work, patterns, conventions
  |     |
  |     +-- ARCHITECTURE.md        ← Structure: system design, components, data flow
  |     |     |
  |     |     +-- architecture/    ← Breakouts: API, data models, services
  |     |
  |     +-- ENVIRONMENTS.md        ← Setup: prerequisites, config, local dev
  |     |     |
  |     |     +-- environments/    ← Breakouts: staging, production
  |     |
  |     +-- CLOUD.md               ← Operations: infra, deployment, monitoring
  |           |
  |           +-- cloud/           ← Breakouts: runbook, deployment, infra
  |
  +-- CONTRIBUTING.md              ← Workflow: PR process, releases
  |     |
  |     +-- contributing/          ← Breakouts: workflow, releases
  |
  +-- TROUBLESHOOTING.md           ← Reference: symptom -> fix
```

**Reading order for humans:** README -> PRINCIPLES -> ARCHITECTURE -> (the rest based on need)

**Reading order for AI agents:** PRINCIPLES first (institutional knowledge), then ARCHITECTURE (system context), then README (quick reference)

---

## Scaling Tiers

dockit auto-detects project size and generates only the docs that tier needs. Smaller projects get fewer files with content consolidated; larger projects get dedicated files and sub-doc breakouts.

### Small (≤20 source files)

Single-purpose projects, utilities, scripts, prototypes.

```
project/
├── README.md               # Everything lives here for small projects
└── docs/
    ├── ARCHITECTURE.md      # System design + decisions
    └── ENVIRONMENTS.md      # Setup + configuration
```

**3 docs total.** README carries the bulk — philosophy, quick start, usage, troubleshooting, and contributing guidance all in one file.

### Medium (20-50 source files)

Multi-service projects, framework + database + auth, CI/CD present.

```
project/
├── README.md                # Hub — quick start + links to docs/
└── docs/
    ├── ARCHITECTURE.md      # System design, components, data flow
    ├── ENVIRONMENTS.md      # Setup, env vars, local config
    ├── PRINCIPLES.md        # Coding patterns, testing, conventions
    ├── CLOUD.md             # Infrastructure, deployment, monitoring
    └── TROUBLESHOOTING.md   # Common issues by category
```

**6 docs total.** README becomes a hub with links. Each concern gets its own file. Content that was inline in README migrates to the right doc.

### Large (>50 source files)

Monorepos, multiple teams, complex CI/CD, multiple databases.

```
project/
├── README.md                     # Hub — links to everything
└── docs/
    ├── ARCHITECTURE.md           # System overview
    ├── architecture/
    │   ├── API.md                # Full API reference (if >10 endpoints)
    │   ├── DATA-MODELS.md        # Schema + relationships (if multiple DBs)
    │   └── SERVICES.md           # Service catalog (if >2 services)
    │
    ├── ENVIRONMENTS.md           # Setup overview
    ├── environments/
    │   ├── LOCAL.md              # Local dev specifics
    │   ├── STAGING.md            # Staging config
    │   └── PRODUCTION.md         # Production config
    │
    ├── PRINCIPLES.md             # Patterns overview
    ├── principles/
    │   ├── CONVENTIONS.md        # Naming, file structure
    │   └── TESTING.md            # Test strategy (if >100 tests)
    │
    ├── CLOUD.md                  # Infrastructure overview
    ├── cloud/
    │   ├── DEPLOYMENT.md         # CI/CD details (if >3 workflows)
    │   ├── INFRASTRUCTURE.md     # IaC details (if Terraform/Pulumi)
    │   ├── MONITORING.md         # Alerts + dashboards (if alert configs)
    │   └── RUNBOOK.md            # Operations playbook (if production)
    │
    ├── CONTRIBUTING.md           # Workflow overview
    ├── contributing/
    │   ├── WORKFLOW.md           # Branching + PR process
    │   └── RELEASES.md          # Release process (if large team)
    │
    └── TROUBLESHOOTING.md        # Common issues
```

**7+ docs with sub-doc breakouts.** Parent docs (ARCHITECTURE.md, CLOUD.md, etc.) serve as overviews linking to their sub-docs. Sub-docs are only created when specific complexity triggers fire — no empty placeholders.

---

## Complexity Triggers

Sub-docs are created on demand, not by default. Each trigger maps to a detection rule:

| Trigger | Detection | Creates |
|---------|-----------|---------|
| Complex API | >10 endpoints | `architecture/API.md` |
| Multiple databases | >1 DB connection | `architecture/DATA-MODELS.md` |
| Multiple services | >2 service dirs | `architecture/SERVICES.md` |
| Multiple environments | >2 env configs | `environments/<ENV>.md` |
| Complex CI/CD | >3 workflow files | `cloud/DEPLOYMENT.md` |
| IaC present | Terraform/Pulumi detected | `cloud/INFRASTRUCTURE.md` |
| Monitoring setup | Alert configs exist | `cloud/MONITORING.md` |
| Production ops | Production + SLAs | `cloud/RUNBOOK.md` |
| Extensive tests | >100 tests | `principles/TESTING.md` |
| Large team | Multiple CODEOWNERS | `contributing/RELEASES.md` |
| Many procedures | >5 multi-step tasks | `how-to/INDEX.md` |

---

## Content Routing

Where different types of content land at each tier:

| Content | Small | Medium | Large |
|---------|-------|--------|-------|
| System architecture | README | ARCHITECTURE.md | ARCHITECTURE.md (overview) |
| API reference | README | ARCHITECTURE.md | architecture/API.md |
| Data models | README | ARCHITECTURE.md | architecture/DATA-MODELS.md |
| Setup / config | README | ENVIRONMENTS.md | ENVIRONMENTS.md + environments/ |
| Coding standards | README | PRINCIPLES.md | PRINCIPLES.md + principles/ |
| Testing approach | README | PRINCIPLES.md | principles/TESTING.md |
| Infrastructure | README | CLOUD.md | CLOUD.md + cloud/ |
| Deployment | README | CLOUD.md | cloud/DEPLOYMENT.md |
| Operations | README | CLOUD.md | cloud/RUNBOOK.md |
| PR workflow | README | CONTRIBUTING.md* | CONTRIBUTING.md + contributing/ |
| Common issues | README | TROUBLESHOOTING.md | TROUBLESHOOTING.md |

*\*CONTRIBUTING.md is inline in README for medium projects, dedicated file for large.*

---

## Document Purposes

Quick reference for what belongs in each doc:

| Document | Purpose | Key Sections |
|----------|---------|-------------|
| **README.md** | Get running in 3 steps | Philosophy, Quick Start, Usage, TOC |
| **PRINCIPLES.md** | How we write code here | Code style, naming, patterns (YES/NO examples), testing |
| **ARCHITECTURE.md** | How the system is designed | Overview, diagram, components, data flow, decisions |
| **ENVIRONMENTS.md** | How to set up locally | Prerequisites, setup steps, env vars, database, team-specific config |
| **CLOUD.md** | How we deploy and operate | Provider, infra diagram, services, deployment, monitoring |
| **CONTRIBUTING.md** | How to contribute | Workflow, code guidelines, testing, release process |
| **TROUBLESHOOTING.md** | How to fix common issues | Symptom-fix table, categorized issues, debug commands |

---

## Monorepo Layout

Monorepos use shared docs at root + per-service READMEs:

```
monorepo/
├── README.md                      # Hub — links to all services + shared docs
├── docs/
│   ├── PRINCIPLES.md              # Shared across all services
│   ├── CONTRIBUTING.md            # Unified workflow
│   ├── ARCHITECTURE.md            # System-wide overview
│   └── ...
└── services/
    ├── api/
    │   └── README.md              # Service-specific (links back to shared docs)
    ├── worker/
    │   └── README.md
    └── frontend/
        └── README.md
```

Shared docs (PRINCIPLES, CONTRIBUTING, ARCHITECTURE) live at root. Service READMEs cover service-specific setup, endpoints, and context — linking back to root docs for shared conventions.

---

## Related

- [DOC-MAP.md](../skills/dockit/references/DOC-MAP.md) — full implementation reference
- [SIZE-SMALL.md](../skills/dockit/references/guides/SIZE-SMALL.md) — small tier detection logic
- [SIZE-MEDIUM.md](../skills/dockit/references/guides/SIZE-MEDIUM.md) — medium tier detection logic
- [SIZE-LARGE.md](../skills/dockit/references/guides/SIZE-LARGE.md) — large tier detection logic
