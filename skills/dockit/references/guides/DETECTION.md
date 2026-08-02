# Detection

Discovery logic for project name, description, and environment variables. Used by Phase 1 of the dockit execution flow.

For foundation detection (a separate, heavier scoring pass), see [FOUNDATIONS-DETECTION.md](./FOUNDATIONS-DETECTION.md).

---

## Project Name & Description

**Don't ask the user for project name or description.** Both are nearly always already declared in a manifest file (`package.json`, `pyproject.toml`, etc.) or visible in the existing README. Asking the user to retype something the project already says about itself is the kind of friction that makes documentation tools feel bureaucratic.

Auto-detect from these sources, in priority order:

| Source | Name Field | Description Field |
|--------|------------|-------------------|
| `package.json` | `name` | `description` |
| `pyproject.toml` | `[project] name` | `[project] description` |
| `Cargo.toml` | `[package] name` | `[package] description` |
| `setup.py` | `name=` | `description=` |
| Existing `README.md` | First `# heading` | First paragraph after heading |
| Directory name | Folder name | (skip) |

If description is not found in any source, infer from file structure or detected framework. If still unclear, leave as `[TODO: Add project description]` — don't fabricate.

---

## Environment Variables

**Don't assume env var names from framework conventions.** A Django project might use `DJANGO_DB_HOST` instead of `DATABASE_URL`; a Node project might use `MONGO_URI`. If the docs claim the project reads `DATABASE_URL` and the code reads `DB_HOST`, every dev who follows the docs gets a confusing error — the docs become *worse than no docs*. Discover what the project actually uses.

Check these sources in order, accumulating every variable found:

| Source | What to look for |
|--------|------------------|
| `.env.example`, `.env.sample`, `.env.template`, `.env.dist` | All `KEY=` definitions |
| `Makefile` | `$(VAR)`, `export VAR`, `env VAR=` references |
| `docker-compose.yml`, `docker-compose.*.yml` | `environment:` and `env_file:` sections |
| `.github/workflows/*.yml`, `*.gitlab-ci.yml` | `env:` blocks |
| `settings.py`, `config.py`, `env.py`, `*settings*.py` | `os.environ.get(`, `os.getenv(`, `env(` calls |
| `manage.py`, `wsgi.py`, `asgi.py` | `os.environ.setdefault(` |
| Existing docs (`README.md`, `docs/ENVIRONMENTS.md`) | Already-documented vars |

Collect the actual variable names. If nothing in the project mentions `DATABASE_URL`, do not document `DATABASE_URL`. If the project uses `DB_HOST`, `DB_NAME`, `DB_USER`, document those.

### Fallback

Only fall back to framework defaults (e.g., `DATABASE_URL`, `SECRET_KEY`) if **no env var sources exist at all** in the project, and mark each one with `[TODO: verify var name]` so the user knows it's a guess.

---

## Structural Integrity

Whether the project's *existing* docs work as a structure. This decides whether `init` leads with additive or with restructure (SKILL.md Phase 1 step 9b → Phase 3), and it is a different question from whether docs exist at all.

Dockit's doc structure is a research position, not a neutral container, so it applies by default. A project earns deference by demonstrating a working structure of its own — not by having files.

Signals, in rough order of weight:

| Signal | Integrity present | Integrity absent |
|--------|-------------------|------------------|
| Distribution | Content split across discrete topical files | One dump — a single README carrying everything |
| Headings | Consistent enough to navigate | Ad hoc, duplicated, or absent |
| Internal links | Resolve | Broken, or no cross-linking at all |
| Duplication | Each topic has one home | The same content restated in several files |
| README role | Delegates to other docs | Carries setup, architecture, deploy, and troubleshooting itself |

**Judge what exists, never what's missing.** A repo documented in one well-organised README is missing most template files and is thoroughly documented; scoring absent files would mark it barren and shred it. Conversely a 3000-line unnavigable README is documentation and is exactly the case dockit exists to fix. Failing to match dockit's templates is not evidence of poor structure — plenty of teams have a good shape that isn't this one.

**Ties go to restructure.** See SKILL.md Phase 3 for why the costs are asymmetric.

### Relationship to generation posture (step 9)

Two adjacent questions with different outputs — don't collapse them:

| Question | Step | Drives |
|----------|------|--------|
| Do docs exist at all? | 9 — documented / doc-barren | Whether the overview ban applies |
| Do the docs that exist work? | 9b — integrity present / absent | Whether `init` leads with additive or restructure |

A 3000-line README is `documented` **and** `integrity absent`: the overview ban applies (they don't need generated orientation prose) and restructure leads (the shape isn't serving them). That combination is coherent, not a conflict.
