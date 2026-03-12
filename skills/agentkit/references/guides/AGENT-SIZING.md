# Agent Sizing Guide

How to determine the right number and scope of agents for a project.

## Project Size Tiers

| Size | Source Files | Max Agents | Strategy |
|------|-------------|-----------|----------|
| Small | 1–20 | 1–2 | Single "project-expert" agent covering all custom patterns |
| Medium | 21–50 | 2–4 | One agent per major custom area |
| Large | 51+ | 3–7 | Specialized agents; may split by service in monorepos |

## Counting Source Files

Count files with these extensions, excluding generated/vendor directories:
- Python: `.py`
- JavaScript/TypeScript: `.js`, `.ts`, `.tsx`, `.jsx`
- Go: `.go`
- Rust: `.rs`
- Java/Kotlin: `.java`, `.kt`
- Ruby: `.rb`
- PHP: `.php`

Exclude: `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`, `__pycache__/`, `migrations/`, generated files.

## Grouping Rules

### Merge small clusters
If a custom code area has fewer than 3 files, merge it into the nearest related agent rather than creating a standalone agent.

### Never create single-file agents
Unless the file is highly complex (100+ lines of custom logic, multiple classes, or a critical base class that the entire project inherits from).

### Group by relationship, not by type
Prefer grouping by domain ("payment processing" agent covers payment models + payment middleware + payment serializers) over grouping by type ("all middleware" agent).

Exception: if the custom code IS the type — e.g., a project with 15 custom Wagtail blocks should get a "custom-blocks" agent, not split blocks across domain agents.

### Monorepo splitting
For monorepos with distinct services:
- If services share custom patterns → one shared agent
- If services have independent custom code → one agent per service (within the max)
- Mix is fine: shared "data-layer" agent + per-service "service-x-api" agent

## Scope Preferences

When the user chooses:
- **Broad agents** — aim for the lower end of the range. Combine related areas.
- **Focused agents** — aim for the higher end. Keep areas separate for precise triggering.
- **No preference** — default to broad for maintainability.

## When NOT to Create an Agent

- The custom code is boilerplate (inherits from framework base, adds nothing)
- The custom code is a single configuration override
- The custom code is legacy/unused (no imports, no recent commits)
- A native framework feature handles this (flag for user, suggest removal)
- An existing agent already covers this area
