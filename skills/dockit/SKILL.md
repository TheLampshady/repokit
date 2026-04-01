---
name: dockit
description: 'Generate, update, and maintain project documentation. Use when asked to: create/write/add docs, generate/make README, setup documentation, document this project, check doc freshness, explain doc structure, sync docs with code, verify docs against code, audit docs for accuracy, or cross-reference docs with codebase. Modes: init, sync, check, audit, migrate, diagrams. Auto-detects frameworks and scales by project size.'
user-invocable: true
---

# dockit

Generate and maintain project documentation for humans and AI agents.

**Modes:** `init` | `sync` | `check` | `audit` | `migrate` | `diagrams`

**Frameworks:** Wagtail (dedicated module), others use `_default.md` (auto-detected)

**Generates:** README, ARCHITECTURE, PRINCIPLES, ENVIRONMENTS, CLOUD, TROUBLESHOOTING, CONTRIBUTING

**Scales:** Small (3 docs) → Medium (6 docs) → Large (7+ with sub-docs)

> For full structure details, ask "explain dockit structure" or see [`references/DOC-MAP.md`](references/DOC-MAP.md)

---

## Core Principle: Never Destroy Content

**Structure can be rewritten. Information must NEVER be destroyed.**

When restructuring docs:
- **MIGRATE** team-specific content (VMs, corporate auth, security configs) to appropriate docs
- **KEEP** all specifics even if they seem sensitive - most repos have restricted access
- **WARN** users about potentially sensitive content, but don't remove it
- **PRESERVE** the team's way of doing things (ENVIRONMENTS.md can have many approaches)

If existing README has:
- VM setup instructions → Move to ENVIRONMENTS.md
- Corporate SSO/VPN auth → Move to ENVIRONMENTS.md
- Security configurations → Move to ENVIRONMENTS.md or CLOUD.md
- Team-specific workflows → Move to CONTRIBUTING.md or PRINCIPLES.md

**Always create `docs/MIGRATION-NOTES.md`** showing where content moved.

---

## Usage

```
/dockit
```

Auto-detects what to do based on project state.

### Auto-Detection

| Condition | Action |
|-----------|--------|
| No docs/ or README.md | → init |
| CI environment | → check |
| Git changes since docs | → sync |
| Docs exist, wrong structure | → suggest migrate |
| User asks to verify/audit/cross-reference docs | → audit |
| Docs current | → "Up to date" |

### Explicit Modes

| Mode | Action | Prompts? | Destructive? |
|------|--------|----------|--------------|
| `init` | Full doc generation | Yes | Can restructure |
| `sync` | Update stale sections | No | Never - adds only |
| `check` | CI mode - exit codes only | No | Read-only |
| `audit` | Verify doc claims against code | No | Read-only |
| `migrate` | Restructure legacy docs | Yes | Can restructure |
| `diagrams` | Generate mermaid diagrams only | No | Updates diagrams only |

**Safe modes** (no prompts, non-destructive): `sync`, `check`, `audit`, `diagrams`
**Interactive modes** (prompts, can restructure): `init`, `migrate`

---

## Execution Flow

### Phase 1: Analyze

1. Auto-detect mode from project state
2. Detect framework (see `frameworks/_index.md`)
3. Detect project size (see Project Scaling)
4. **Detect project name and description** (see below)
5. Check for custom templates (`.dockit/templates/`)
6. Load framework module or `_default.md`
7. Extract commands from package.json, Makefile, pyproject.toml
8. **Discover environment variables** (see below)
9. Check for constitution at `.specify/memory/constitution.md`

#### Environment Variable Discovery

**NEVER assume env var names from framework conventions.** Always discover what the project actually uses.

Check these sources in order, accumulating all vars found:

| Source | What to look for |
|--------|-----------------|
| `.env.example`, `.env.sample`, `.env.template`, `.env.dist` | All `KEY=` definitions |
| `Makefile` | `$(VAR)`, `export VAR`, `env VAR=` references |
| `docker-compose.yml`, `docker-compose.*.yml` | `environment:` and `env_file:` sections |
| `.github/workflows/*.yml`, `*.gitlab-ci.yml` | `env:` blocks |
| `settings.py`, `config.py`, `env.py`, `*settings*.py` | `os.environ.get(`, `os.getenv(`, `env(` calls |
| `manage.py`, `wsgi.py`, `asgi.py` | `os.environ.setdefault(` |
| Existing docs (`README.md`, `docs/ENVIRONMENTS.md`) | Already-documented vars |

Collect the actual variable names used. If no sources mention `DATABASE_URL` — do not use `DATABASE_URL`. If the project uses `DB_HOST`, `DB_NAME`, `DB_USER` — document those instead.

Only fall back to framework defaults (e.g., `DATABASE_URL`, `SECRET_KEY`) if **no env var sources exist at all** in the project, and mark them as `[TODO: verify var name]`.

#### Project Name & Description Detection

**NEVER ask for project name or description.** Auto-detect from these sources (in priority order):

| Source | Name Field | Description Field |
|--------|------------|-------------------|
| `package.json` | `name` | `description` |
| `pyproject.toml` | `[project] name` | `[project] description` |
| `Cargo.toml` | `[package] name` | `[package] description` |
| `setup.py` | `name=` | `description=` |
| Existing `README.md` | First `# heading` | First paragraph after heading |
| Directory name | Folder name | (skip) |

If description not found, infer from: file structure, framework detected, or leave as `[TODO: Add project description]`.

### Phase 2: Questions

Ask clarifying questions BEFORE showing plan (max 3-5). Only ask what can't be auto-detected. Skip if confident.

**NEVER ask for:** Project name, project description, framework (auto-detected), project size (auto-detected).

### Phase 3: Plan & Confirm

Show plan and offer options:
- **Option 1**: Full restructure per dockit templates
- **Option 2**: Preserve existing doc structure, only add missing sections/files
- **Option 3**: Exit without changes

### Phase 4: Execute

| Mode | Behavior |
|------|----------|
| **init** | Questions → Plan → Confirm → Generate all docs from templates |
| **sync** | Git diff → Update stale sections → Regenerate diagrams if needed |
| **check** | Detect drift → Exit 0 (current) or Exit 1 (stale) |
| **audit** | Extract references from docs → Verify against codebase → Report broken refs. See [AUDIT.md](./references/guides/AUDIT.md) |
| **migrate** | Questions → Plan → Confirm → Merge into existing files |
| **diagrams** | Generate/update mermaid diagrams only |

### Phase 5: Generate

Core docs scaled by project size. See Project Scaling below.

### Phase 6: Validate & Report

1. Cross-link all docs
2. Validate markdown syntax
3. List remaining `[TODO:]` markers
4. Show completion report with next steps

---

## Project Scaling

Detect project size and adjust documentation accordingly.

| Size | Docs | Guide |
|------|------|-------|
| **Small** (≤20 files, single service) | README + 2 docs | [SIZE-SMALL.md](./references/guides/SIZE-SMALL.md) |
| **Medium** (20-50 files, framework + DB) | README + 5 docs | [SIZE-MEDIUM.md](./references/guides/SIZE-MEDIUM.md) |
| **Large** (>50 files, monorepo, teams) | README + 7+ docs + sub-docs | [SIZE-LARGE.md](./references/guides/SIZE-LARGE.md) |

See guides for detection logic and document structure details.

---

## Detailed Guides

| Guide | Purpose |
|-------|---------|
| [SIZE-SMALL.md](./references/guides/SIZE-SMALL.md) | Small project documentation structure |
| [SIZE-MEDIUM.md](./references/guides/SIZE-MEDIUM.md) | Medium project documentation structure |
| [SIZE-LARGE.md](./references/guides/SIZE-LARGE.md) | Large project documentation structure |
| [WRITING-GUIDE.md](./references/guides/WRITING-GUIDE.md) | How to write explanatory documentation |
| [DIAGRAMS.md](./references/guides/DIAGRAMS.md) | Mermaid diagram standards |
| [AUDIT.md](./references/guides/AUDIT.md) | Doc accuracy verification against codebase |
| [GIT-HOOKS.md](./references/guides/GIT-HOOKS.md) | CI/pre-commit integration |

---

## Custom Templates

Projects can override default templates.

### Location

```
.dockit/
└── templates/
    ├── README.md           # Override core README
    ├── ARCHITECTURE.md     # Override core ARCHITECTURE
    └── wagtail/            # Override framework templates
        └── MODELS.md
```

### Priority

1. `.dockit/templates/[file]` (project custom)
2. `templates/[framework]/[file]` (framework specific)
3. `templates/core/[file]` (default)

---

## Git Integration

See [GIT-HOOKS.md](./references/guides/GIT-HOOKS.md) for full CI/pre-commit integration.

### Change Detection

```bash
LAST_SYNC=$(git log -1 --format=%H -- docs/ README.md)
CHANGED=$(git diff --name-only $LAST_SYNC HEAD)
```

| Changed Files | Update |
|---------------|--------|
| package.json, pyproject.toml | README.md |
| src/, lib/, app/ | ARCHITECTURE.md + diagrams |
| .env*, config/ | ENVIRONMENTS.md |
| infra/, .github/ | CLOUD.md |
| .specify/memory/constitution.md | PRINCIPLES.md |

---

## Templates

| Location | Purpose |
|----------|---------|
| `.dockit/templates/` | Project overrides (highest priority) |
| `references/templates/[framework]/` | Framework-specific |
| `references/templates/core/` | Default fallback |

---

## Constitution Sync

| Scenario | Behavior |
|----------|----------|
| Constitution exists, no PRINCIPLES.md | Generate FROM constitution |
| Both exist | Sync - constitution wins |
| Only PRINCIPLES.md | Keep as-is |
| Neither | Generate from codebase |

---

## Sensitive Content Handling

**If content already exists in repo docs: PRESERVE IT.** Most repos have restricted access.

### Existing Content

If migrating docs that contain:
- Internal URLs, VPN/SSO instructions, corporate auth
- VM setup, infrastructure specifics
- Team-specific security configurations

**Action:** Move to appropriate doc (ENVIRONMENTS.md, CLOUD.md), warn user, but DO NOT delete.

### New Content

When generating new docs, warn user before including:
- Hardcoded secrets, API keys, credentials
- Production IP addresses or connection strings
- Personal information

**Action:** Add `[TODO: verify this should be documented]` marker and continue.

---

## Placeholders

| Token | Meaning |
|-------|---------|
| `[NAME]` | Required field |
| `[IF_X]...[ENDIF]` | Conditional section |
| `[REPEAT_FOR_X]...[END_REPEAT]` | Repeated section |
| `[TODO: desc]` | Needs manual input |

---

## Adding Frameworks

1. Add detection rule to `frameworks/_index.md`
2. Create `frameworks/[name].md` module
3. Create `templates/[name]/` folder
4. Add sample to `samples/[name]-project/`

Use `frameworks/_default.md` as template.

---

## Next Steps Output

After completion, recommend actionable next steps:

```
Next steps:
  1. Review generated docs for accuracy
  2. Fill in [TODO] markers
  3. Run setup commands:

     [FRAMEWORK_INIT_COMMANDS]
```

### Framework-specific commands

| Framework | Commands |
|-----------|----------|
| Django/Wagtail | `python manage.py migrate`, `createsuperuser`, `collectstatic` |
| Node | `npm install`, `npm run dev` |
| Python (general) | `pip install -e ".[dev]"`, `pytest` |

---

## Self-Explanation

When user asks about doc structure, topics, sizes, or "what docs do I need": read and present [`references/DOC-MAP.md`](references/DOC-MAP.md)
