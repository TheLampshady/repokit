# Principles

Decisions this project has made that an agent or a new contributor would not guess.

> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.

---

## Conventions

**Import from `app/core/` rather than the underlying library.** Database access goes through `get_db()`, auth through `get_current_user()`, caching through `cache`. A direct `import sqlalchemy` / `firebase_admin` / `redis` outside `app/core/` gets no connection pooling, token validation, or cache fallback, and can't be swapped in tests — route it through the matching foundation. Exceptions: `alembic/env.py` constructs its own engine.

<details><summary>Why</summary>

Each foundation owns connection pooling, token validation, and cache fallback. Code that
imports the library directly gets none of that and can't be swapped in tests.
Rejected: a lint rule banning the imports — it can't catch aliased or deferred imports.
</details>

**Business logic lives in `app/services/`; route handlers only translate HTTP.** A handler parses the request, calls one service function, and shapes the response. A `@router.` file with no `from app.services` import is holding logic that can't be reused or tested without HTTP — extract it into a service function.

[TODO: why?]

**Use `pydantic` schemas for request and response bodies, `SQLAlchemy` models for persistence.** The two stay separate even where the fields match. A `response_model=` pointing at a SQLAlchemy model serialises internal columns (`password_reset_token`, `deleted_at`) to the client — declare a pydantic schema in `app/schemas/` and return that.

<details><summary>Why</summary>

Serialising ORM objects directly leaked internal columns (`password_reset_token`,
`deleted_at`) into two public endpoints before this split.
Rejected: `orm_mode` on a single shared model — it defers the leak rather than preventing it.
</details>

**Every I/O function is `async`.** Database calls, cache reads, HTTP clients. A plain `def` doing I/O in a service or repository blocks the event loop for every other request — make it `async def` and `await` the call. Exceptions: `app/utils/slugify.py`, `app/utils/tokens.py` (pure functions).

[TODO: why?]

**Reach the database through a repository class.** One repository per model in `app/repositories/`. A `session.query(` or `select(` inside a service skips the tenant filter and forces a real database for tests — call the matching repository method, or add one.

<details><summary>Why</summary>

Lets service tests run without a database. Also kept the tenant filter in one place after
it was forgotten in two hand-written queries.
Rejected: query helpers on the model classes — nothing stops a caller bypassing them.
</details>

---

## Rules

**All API routes require authentication.** A route without `Depends(get_current_user)` is unauthenticated — add the dependency. The only exempt route is `GET /health`.

<details><summary>Why</summary>

An unauthenticated `/workspaces` listing shipped in March 2025 and exposed workspace names
across tenants for nine days.
Rejected: middleware-level auth — routes that legitimately need anonymous access become
invisible exceptions instead of explicit ones.
</details>

**Query through the SQLAlchemy ORM.** An `execute(text(` call bypasses the tenant filter and can return other workspaces' rows — express the query with ORM constructs instead. Raw SQL belongs only in `alembic/` migrations.

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
