# Documentation Structure Map

Complete reference for dockit documentation structure, topics, and scaling.

> **Core Principle:** Structure can change, but information must NEVER be destroyed. Team-specific content (VMs, corporate auth, security configs) is preserved and migrated to appropriate docs.

---

## Quick Reference

| Question | Answer |
|----------|--------|
| "What docs do I need?" | See [Size Tiers](#size-tiers) |
| "What goes in each doc?" | See [Document Purposes](#document-purposes) |
| "Where does X content go?" | See [Content Routing](#content-routing) |
| "What about sub-docs?" | See [Large Project Sub-docs](#large-project-sub-docs) |

---

## Size Tiers

| Size | Docs Generated |
|------|----------------|
| **Small** (≤20 files) | README, ARCHITECTURE, ENVIRONMENTS |
| **Medium** (20-50 files) | + PRINCIPLES, TROUBLESHOOTING, CLOUD |
| **Large** (>50 files) | + CONTRIBUTING, sub-docs |

For detection logic, see: [SIZE-SMALL.md](guides/SIZE-SMALL.md) | [SIZE-MEDIUM.md](guides/SIZE-MEDIUM.md) | [SIZE-LARGE.md](guides/SIZE-LARGE.md)

---

## Document Purposes

### README.md

**Purpose:** Quick start - get users running in 3 steps

#### Small Projects (all content in README)

| Section | Content |
|---------|---------|
| Title + badges | Project name, status |
| Philosophy | Why decisions were made |
| Quick Start | Install → Configure → Run |
| Usage | Common commands, examples |
| Architecture | Brief system overview |
| Troubleshooting | Common issues (inline) |
| Contributing | How to contribute (inline) |

#### Medium/Large Projects (hub + links)

| Section | Content |
|---------|---------|
| Title + badges | Project name, status |
| Philosophy | Why decisions were made |
| Quick Start | Install → Configure → Run |
| Usage | Common commands, examples |
| Documentation (TOC) | Links to docs/ files |

**NOT in README (medium/large):** Troubleshooting, Contributing, Architecture details - these go in dedicated docs, linked from TOC only

---

### ARCHITECTURE.md (All sizes)

**Purpose:** System design and technical decisions

| Section | Content |
|---------|---------|
| Overview | High-level description |
| Diagram | Mermaid flowchart of components |
| Components | Table of services/modules |
| Data Flow | How data moves through system |
| API | Endpoints, auth, errors (medium+) |
| Decisions | Key technical choices and rationale |

**Large projects:** API section breaks out to `architecture/API.md`

---

### ENVIRONMENTS.md (All sizes)

**Purpose:** Setup and configuration

| Section | Content |
|---------|---------|
| Prerequisites | Required tools + versions |
| Setup | Step-by-step local setup |
| Environment Variables | Table with descriptions |
| Database | Setup, migrations, seeding |
| Services | External service setup |
| Corporate/Team Setup | VPN, SSO, VMs, internal services (if applicable) |

**Team-specific content belongs here:** VM instructions, corporate auth (SSO/VPN), internal service URLs, security configurations. Preserve existing content - many teams have specific ways to skin a cat.

---

### PRINCIPLES.md (Medium+)

**Purpose:** Coding conventions and patterns

| Section | Content |
|---------|---------|
| Code Style | Linting, formatting rules |
| Naming | Conventions for files, functions, etc. |
| Patterns | YES/NO code examples |
| Testing | Test organization, coverage expectations |
| Architecture | Design principles |

---

### CLOUD.md (Medium+)

**Purpose:** Infrastructure and deployment

| Section | Content |
|---------|---------|
| Overview | Provider, region, IaC tool |
| Architecture | Infrastructure diagram |
| Services | Table of cloud services used |
| Deployment | How to deploy, rollback |
| Monitoring | Logs, metrics, alerts |
| Operations | Health checks, scaling, incidents |

**Large projects:** Operations breaks out to `cloud/RUNBOOK.md`

---

### TROUBLESHOOTING.md (Medium+)

**Purpose:** Problem solving reference

| Section | Content |
|---------|---------|
| Quick Reference | Symptom → Fix table |
| By Category | Grouped issues (setup, runtime, deploy) |
| Debug Commands | Useful diagnostic commands |
| Getting Help | Where to ask questions |

---

### CONTRIBUTING.md (Large only)

**Purpose:** Development workflow for teams

| Section | Content |
|---------|---------|
| Getting Started | Setup for contributors |
| Workflow | Branch → Code → PR process |
| Code Guidelines | Standards, review checklist |
| Testing | How to write/run tests |
| Release | Version, deploy process |

---

## Large Project Sub-docs

When complexity triggers are met, break out to sub-docs.

### Complexity Triggers

| Trigger | Creates |
|---------|---------|
| >10 API endpoints | `architecture/API.md` |
| Production deployment + on-call | `cloud/RUNBOOK.md` |
| >5 multi-step procedures | `docs/HOW-TO.md` |

### architecture/API.md

Full API reference for large projects.

| Section | Content |
|---------|---------|
| Overview | API purpose, base URL |
| Authentication | Auth methods, examples |
| Endpoints | Grouped by resource |
| Error Handling | Error codes, responses |
| Rate Limits | Limits, headers |
| Versioning | Version strategy |
| Examples | Full request/response examples |

### cloud/RUNBOOK.md

Operations playbook for large projects.

| Section | Content |
|---------|---------|
| Service Overview | What's running, dependencies |
| Health Checks | Endpoints, expected responses |
| Incident Response | Severity levels, escalation |
| Common Issues | Symptoms, causes, fixes |
| Scaling | Manual/auto scaling procedures |
| Maintenance | Scheduled tasks, windows |
| Contacts | On-call, escalation paths |

---

## Content Routing

Where different content types belong (medium/large projects). Small projects keep all content in README.

| Content Type | Destination | README keeps |
|--------------|-------------|--------------|
| System setup, prerequisites | ENVIRONMENTS.md | Link in TOC |
| Architecture, data flow | ARCHITECTURE.md | Link in TOC |
| API endpoints, auth | ARCHITECTURE.md (or API.md) | Link in TOC |
| Coding standards | PRINCIPLES.md | Link in TOC |
| Deployment, CI/CD | CLOUD.md | Link in TOC |
| Common issues | TROUBLESHOOTING.md | Link in TOC |
| PR process, workflow | CONTRIBUTING.md | Link in TOC |
| Operations, incidents | CLOUD.md (or RUNBOOK.md) | Link in TOC |

---

## Framework Additions

Frameworks add specialized docs.

| Framework | Additional Docs |
|-----------|-----------------|
| Wagtail | MODELS.md, BLOCKS.md |
| Django | MODELS.md |
| FastAPI | (API in ARCHITECTURE.md) |
| React | COMPONENTS.md |

---

## File Structure Examples

### Small Project
```
project/
├── README.md
└── docs/
    ├── ARCHITECTURE.md
    └── ENVIRONMENTS.md
```

### Medium Project
```
project/
├── README.md
└── docs/
    ├── ARCHITECTURE.md
    ├── ENVIRONMENTS.md
    ├── PRINCIPLES.md
    ├── CLOUD.md
    └── TROUBLESHOOTING.md
```

### Large Project
```
project/
├── README.md
└── docs/
    ├── ARCHITECTURE.md
    ├── ENVIRONMENTS.md
    ├── PRINCIPLES.md
    ├── CLOUD.md
    ├── TROUBLESHOOTING.md
    ├── CONTRIBUTING.md
    ├── architecture/
    │   ├── API.md
    │   ├── DATA-MODELS.md
    │   └── SERVICES.md
    └── cloud/
        └── RUNBOOK.md
```

### Monorepo
```
monorepo/
├── README.md              # Hub - links to all
└── docs/
    ├── ARCHITECTURE.md    # System-wide
    ├── CONTRIBUTING.md    # Shared workflow
    ├── architecture/
    │   ├── SERVICES.md    # Service catalog
    │   └── DATA-MODELS.md # Shared schemas
    └── services/
        ├── api/
        │   └── README.md  # Service-specific
        └── worker/
            └── README.md
```

---

## Related References

- [`guides/SIZE-SMALL.md`](guides/SIZE-SMALL.md) - Small project details
- [`guides/SIZE-MEDIUM.md`](guides/SIZE-MEDIUM.md) - Medium project details
- [`guides/SIZE-LARGE.md`](guides/SIZE-LARGE.md) - Large project details
- [`templates/`](templates/) - Document templates
- [`samples/`](samples/) - Example implementations
