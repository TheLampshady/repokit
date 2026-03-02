# Small Projects

Documentation structure for small, single-purpose projects.

## When to Use Small Structure

- Personal projects, utilities, scripts
- Single-purpose libraries or tools
- Proof of concepts or prototypes
- Single service with ≤20 source files
- No database or simple single-table DB
- No team collaboration files (CODEOWNERS, PR templates)

## Detection Logic

**Small if ALL true:**
- Single service (FastAPI alone, React alone, CLI tool)
- ≤20 source files (exclude tests, configs, generated)
- No database OR simple single-table DB
- No team collaboration files (CODEOWNERS, PR templates)

### Detection Examples

```
FastAPI (5 routes, no DB)           → Small
React (10 components, no backend)   → Small
CLI tool (15 files)                 → Small
```

---

## File Structure

Single README.md containing all 9 categories. No docs/ folder, no separate files.

```
project/
└── README.md     # Everything in one file
```

---

## README Structure

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

### Reference
- [Architecture](#architecture)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Overview
[Project purpose, key features, tech stack, audience - NO sub-sections]

---

## Getting Started
[Prerequisites, install, configure, run - as a simple numbered list or sequential commands]

---

## Configuration
[Environment variables table, config files - single table, no sub-sections]

---

## Usage
[Common commands table - single table with Command | Description]

---

## Architecture
[Brief structure description, single diagram if needed, key files table]

---

## Testing
[How to run tests, brief explanation - single code block + 1-2 sentences]

---

## Deployment
[Deploy command, brief explanation - single code block + 1-2 sentences]

---

## Troubleshooting
[Quick reference table: Symptom | Fix - no sub-sections]

---

## Contributing
[Brief standards, PR process - 3-5 bullet points max]
```

---

## Rules

1. **All 9 categories as H2 sections** - No skipping categories
2. **No sub-sections (H3)** - Keep flat structure
3. **One table per section max** - Consolidate information
4. **No separate docs/ folder** - Everything in README.md
5. **Horizontal rules between sections** - Visual separation
6. **Brief explanatory lead-ins** - 1-2 sentences per section
7. **Total length target: 150-300 lines** - Concise but complete
8. **Two-section TOC** - "Quick Start" + "Reference"

---

## Category Guidelines

| Category | What to Include | What to Skip |
|----------|-----------------|--------------|
| Overview | Purpose, 3-5 features, tech stack list, audience | Detailed architecture, history |
| Getting Started | Prerequisites list, install command, config command, run command | Multiple environment setups |
| Configuration | Single env vars table (Variable, Description, Required) | Per-environment breakdowns |
| Usage | Commands table (Command, Description) | Detailed workflows, CLI reference |
| Architecture | Structure table (Folder, Purpose), one diagram | Module deep-dives, design decisions |
| Testing | Test command, one sentence on approach | Coverage setup, CI integration |
| Deployment | Deploy command, target environment | Multi-environment, rollback procedures |
| Troubleshooting | Quick fixes table (Symptom, Fix) | Detailed debugging guides |
| Contributing | Code standards bullets, PR process | Detailed style guides, governance |

---

## Template

Use `templates/core/README-SMALL.template.md` for generation.

## Sample

See `samples/small-project/README.md` for a complete example.
