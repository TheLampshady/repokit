# Default Framework Module

Fallback when no specific framework is detected. Use this as a template for new framework modules.

## Analysis

### Detect Structure

1. **Project type**
   - Single service (one main entry point)
   - Multi-service (backend/, frontend/, services/*)
   - Monorepo (packages/*, apps/*)

2. **Language**
   - Python: pyproject.toml, requirements.txt, setup.py
   - JavaScript/TypeScript: package.json
   - Go: go.mod
   - Rust: Cargo.toml

3. **Entry points**
   - Python: main.py, app.py, manage.py
   - Node: index.js, main.js, src/index.ts
   - Go: main.go, cmd/*/main.go

### Detect Services

Look for service directories:
- `backend/`, `frontend/`, `api/`
- `services/*`, `apps/*`, `packages/*`
- `infra/`, `terraform/`, `k8s/`

### Extract Commands

| Source | Parse |
|--------|-------|
| `package.json` | `scripts` object |
| `pyproject.toml` | `[project.scripts]` or `[tool.poetry.scripts]` |
| `Makefile` | Target names |

Map to standard commands: install, run, test, build, lint, format, deploy

## Extra Docs

None for default. Core templates only:
- README.md
- docs/PRINCIPLES.md
- docs/ARCHITECTURE.md
- docs/ENVIRONMENTS.md
- docs/CLOUD.md
- docs/TROUBLESHOOTING.md
- docs/CONTRIBUTING.md

## Git Patterns

| Changed Files | Docs to Update |
|---------------|----------------|
| `package.json`, `pyproject.toml` | README.md (commands, deps) |
| `src/`, `lib/`, `app/` | ARCHITECTURE.md |
| `.env*`, `config/` | ENVIRONMENTS.md |
| `infra/`, `terraform/`, `.github/` | CLOUD.md, CONTRIBUTING.md |
| `Makefile`, `scripts/` | README.md (commands) |
| `.specify/memory/constitution.md` | PRINCIPLES.md |

## Questions

Only ask if cannot detect:

1. **Deployment target** (if no infra config found)
   - "Where is this deployed?" → Cloud Run, Vercel, AWS, self-hosted, etc.

2. **Non-negotiables** (for PRINCIPLES.md)
   - "Any non-negotiable principles?" → Security, performance, etc.

## Templates

Use `templates/core/` only.

## AI Context

If generating GEMINI.md:

```markdown
# [PROJECT_NAME]

[ONE_LINE_DESCRIPTION]

## Stack
- [LANGUAGE] [VERSION]
- [FRAMEWORK] (if any)
- [DATABASE] (if any)

## Commands

| Command | Action |
|---------|--------|
| `[INSTALL]` | Install deps |
| `[RUN]` | Start server |
| `[TEST]` | Run tests |

## Structure
[KEY_DIRECTORIES]

## Docs
@docs/ARCHITECTURE.md
@docs/PRINCIPLES.md
```

## Service READMEs

For each detected service, generate `[service]/README.md`:

```markdown
# [SERVICE_NAME]

[SERVICE_PURPOSE]

## Quick Start
\`\`\`bash
[SERVICE_COMMANDS]
\`\`\`

## Key Files

| File | Purpose |
|------|---------|
[KEY_FILES_TABLE]

## Related
- [../README.md](../README.md)
- [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
```
