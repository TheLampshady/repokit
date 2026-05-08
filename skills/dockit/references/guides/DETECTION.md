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
