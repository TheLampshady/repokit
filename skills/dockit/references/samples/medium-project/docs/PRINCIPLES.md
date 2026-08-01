# Principles

Decisions this project has made that an agent or a new contributor would not guess.

> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.

---

## Conventions

**Import from `app/core/` rather than the underlying library.** Database access goes through `get_db()`, auth through `get_current_user()`, caching through `cache`. Exceptions: `alembic/env.py` constructs its own engine.
<!-- dockit:check cmd="grep -rlE '^(from|import) (sqlalchemy|firebase_admin|redis)' app/ | grep -v 'app/core' | grep -v 'alembic' | wc -l" expect="0" last="2026-08-01" -->

<details><summary>Why</summary>

Each foundation owns connection pooling, token validation, and cache fallback. Code that
imports the library directly gets none of that and can't be swapped in tests.
Rejected: a lint rule banning the imports — it can't catch aliased or deferred imports.
</details>

**Business logic lives in `app/services/`; route handlers only translate HTTP.** A handler parses the request, calls one service function, and shapes the response.
<!-- dockit:conform cmd="grep -lE 'from app.services' app/api/routes/*.py | wc -l" total="grep -lE '@router\.' app/api/routes/*.py | wc -l" min="80%" last="2026-08-01" -->

[TODO: why?]

**Use `pydantic` models for request and response bodies, `SQLAlchemy` models for persistence.** The two stay separate even where the fields match.
<!-- dockit:check cmd="grep -rlE 'response_model=[A-Za-z]*Model' app/api/routes/ | wc -l" expect="0" last="2026-08-01" -->

<details><summary>Why</summary>

Serialising ORM objects directly leaked internal columns (`password_reset_token`,
`deleted_at`) into two public endpoints before this split.
Rejected: `orm_mode` on a single shared model — it defers the leak rather than preventing it.
</details>

**Every I/O function is `async`.** Database calls, cache reads, HTTP clients. Exceptions: `app/utils/slugify.py`, `app/utils/tokens.py` (pure functions).
<!-- dockit:conform cmd="grep -lE 'async def' app/services/*.py app/repositories/*.py | wc -l" total="grep -lE '(async )?def ' app/services/*.py app/repositories/*.py | wc -l" min="80%" last="2026-08-01" -->

[TODO: why?]

**Reach the database through a repository class, not a session query in a service.** One repository per model in `app/repositories/`.
<!-- dockit:conform cmd="grep -lE 'from app.repositories' app/services/*.py | wc -l" total="grep -lE '(async )?def ' app/services/*.py | wc -l" min="80%" last="2026-08-01" -->

<details><summary>Why</summary>

Lets service tests run without a database. Also kept the tenant filter in one place after
it was forgotten in two hand-written queries.
Rejected: query helpers on the model classes — nothing stops a caller bypassing them.
</details>

---

## Rules

**All API routes require authentication.** The only exempt route is `GET /health`.
<!-- dockit:check cmd="grep -LE 'Depends\(get_current_user\)' app/api/routes/*.py | grep -v 'health.py' | wc -l" expect="0" last="2026-08-01" -->

<details><summary>Why</summary>

An unauthenticated `/workspaces` listing shipped in March 2025 and exposed workspace names
across tenants for nine days.
Rejected: middleware-level auth — routes that legitimately need anonymous access become
invisible exceptions instead of explicit ones.
</details>

**No raw SQL outside `alembic/`.** Query through the ORM.
<!-- dockit:check cmd="grep -rlE 'execute\(text\(' app/ | wc -l" expect="0" last="2026-08-01" -->

<details><summary>Why</summary>

Two string-interpolated queries bypassed the tenant filter and returned rows belonging to
other workspaces.
Rejected: a query linter — it can't see interpolation built up across several statements.
</details>

---

## Extending the codebase

| Adding a... | Do this |
|-------------|---------|
| API endpoint | Add the route to `app/api/routes/<domain>.py`, include the router in `app/api/__init__.py`, add schemas to `app/schemas/<domain>.py` |
| Model | `make migration name=<slug>` → edit the generated revision → add the repository class in `app/repositories/` |
| Foundation | Create the module under `app/core/`, export its dependency function, then register it in [FOUNDATIONS.md](./FOUNDATIONS.md) |
| Background job | Add the task to `app/workers/tasks.py` and register it in the `CELERY_ROUTES` map |

---

## Architectural decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Auth provider | Firebase | [TODO: why?] |
| Realtime transport | Redis pub/sub for WebSocket fan-out | Instances are load-balanced, so in-process fan-out reaches only a fraction of connected clients |
| ORM | SQLAlchemy 2.0, async | [TODO: why?] |
| Migrations | Alembic, one revision per PR | [TODO: why?] |

---

## Related documentation

- [README.md](../README.md) — project overview and quick start
- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design and diagrams
- [FOUNDATIONS.md](./FOUNDATIONS.md) — the shared code these conventions apply to
- [CONTRIBUTING.md](./CONTRIBUTING.md) — development workflow, test commands, setup
