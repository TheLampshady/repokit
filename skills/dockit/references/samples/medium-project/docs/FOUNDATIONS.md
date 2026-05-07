# Foundations

Registry of shared, foundational code in the Task Manager API — the abstractions, services, and primitives that the rest of the codebase depends on. This document is the source of truth for `agentkit` (per-foundation subagents), `feedback-loop` (invariant validation), and `foundationtik` in tikkit (maintenance tickets).

A "foundation" here means: code with high fan-in across multiple features, intended to be reused, and expected to remain stable. Detection methodology in [dockit's FOUNDATIONS-DETECTION guide](../../skills/dockit/references/guides/FOUNDATIONS-DETECTION.md).

---

## Catalog

5 foundations detected across `app/`. Last sync: 2026-05-07.

| Name | Type | Path | Owner | Status | Health | Consumers | Last Reviewed |
|------|------|------|-------|--------|--------|-----------|---------------|
| `core.database` | service | `app/core/database.py` | platform | active | healthy | 28 (4 features) | 2026-04-12 |
| `core.auth` | abstraction | `app/core/auth.py` | platform | active | healthy | 24 (4 features) | 2026-04-12 |
| `core.cache` | service | `app/core/cache.py` | platform | active | healthy | 11 (3 features) | 2026-03-18 |
| `core.notifications` | service | `app/core/notifications.py` | platform | active | **hotspot** | 22 (3 features) | 2026-02-04 |
| `services.helpers` | primitive | `app/services/helpers.py` | _unowned_ | active | healthy | 19 (5 features) | _never_ |

> The `services.helpers` row is a **hidden foundation** — see Findings below.

---

## `core.database`

**Path:** `app/core/database.py`
**Type:** service
**Owner:** platform
**Status:** active
**Last reviewed:** 2026-04-12

### Purpose

Provides the async SQLAlchemy session factory and FastAPI dependency for all database access. Owns connection pooling, transaction lifecycle, and test-isolation behaviour.

### Public API

| Symbol | Purpose |
|--------|---------|
| `get_db()` | FastAPI dependency yielding an `AsyncSession`; commits on success, rolls back on exception |
| `engine` | Module-level engine, exported for migration scripts only |
| `Base` | Declarative base for ORM models |

```python
from app.core.database import get_db

async def list_tasks(db: AsyncSession = Depends(get_db)):
    return await db.execute(select(Task))
```

### Invariants

- **All database access goes through `get_db()`.** Direct use of `engine` outside of Alembic migrations is forbidden.
- **No raw SQL.** Use SQLAlchemy ORM expressions. Raw `text()` calls require platform-team review.
- **Sessions are request-scoped.** Never share a session across requests or background tasks; spawn a new one.

### Consumers

| Feature / Module | Usage |
|------------------|-------|
| `app/api/routes/` | All route handlers depend via `Depends(get_db)` |
| `app/services/` | Service layer accepts session as constructor arg |
| `app/repositories/` | Repository pattern wraps the session |
| `tests/` | Test fixtures override with transaction-rollback session |

### Dependencies

- `sqlalchemy` (async)
- `app.core.config` (for `DATABASE_URL`)

### Test coverage

`tests/integration/test_database.py` — covers session lifecycle, rollback, pool exhaustion. Coverage: ~85%.

### Refactor triggers

- Public API exceeds 5 symbols → split into `database/session.py` + `database/engine.py`.
- Consumers begin importing `engine` directly → tighten exports.
- Any consumer needs sync access → resist; route through async; document why if approved.

### Change checklist

- [ ] Update consumers in the same PR if `get_db` signature changes.
- [ ] Re-run integration tests against PostgreSQL 14, 15, 16.
- [ ] Update this row's `Last reviewed` date.
- [ ] Notify platform-team channel.

---

## `core.auth`

**Path:** `app/core/auth.py`
**Type:** abstraction
**Owner:** platform
**Status:** active
**Last reviewed:** 2026-04-12

### Purpose

Validates Firebase JWTs and exposes the current user as a FastAPI dependency. Single point of contact between the API and Firebase Auth — no other module talks to Firebase directly.

### Public API

| Symbol | Purpose |
|--------|---------|
| `get_current_user()` | FastAPI dependency; validates Bearer token, returns `User` |
| `require_role(role)` | Dependency factory for role-gated routes |

```python
from app.core.auth import get_current_user, require_role

@router.get("/tasks")
async def list_tasks(user: User = Depends(get_current_user)): ...

@router.delete("/workspaces/{id}")
async def delete_workspace(_: User = Depends(require_role("owner"))): ...
```

### Invariants

- **No protected route bypasses `get_current_user`.** Health check is the only exception.
- **Token validation always uses Firebase Admin SDK.** No manual JWT parsing.
- **`User` is read-only.** Mutations go through the user repository, not this module.

### Consumers

| Feature / Module | Usage |
|------------------|-------|
| `app/api/routes/` | Every protected route |
| `app/api/websockets/` | WS handshake uses the same dependency |

### Dependencies

- `firebase-admin`
- `app.core.config` (for service-account credentials)

### Test coverage

`tests/integration/test_auth.py` — token validation, role gates, expired-token handling. Coverage: ~90%.

### Refactor triggers

- More than 3 role-checking helpers accumulate → extract to `auth/roles.py`.
- Multiple identity providers added → extract `auth/providers/` directory.

### Change checklist

- [ ] Update consumers in the same PR if dependency return type changes.
- [ ] Test against expired and revoked tokens.
- [ ] Update this row's `Last reviewed` date.

---

## `core.cache`

**Path:** `app/core/cache.py`
**Type:** service
**Owner:** platform
**Status:** active
**Last reviewed:** 2026-03-18

### Purpose

Redis client wrapper providing typed get/set with serialization, TTL handling, and graceful fallback when Redis is unavailable.

### Public API

| Symbol | Purpose |
|--------|---------|
| `cache.get(key)` | Returns deserialized value or `None` |
| `cache.set(key, value, ttl=)` | Stores JSON-serialized value with TTL |
| `cache.delete(key)` | Removes key |
| `cache.invalidate(pattern)` | Pattern-based deletion (use sparingly — uses `SCAN`) |

### Invariants

- **All Redis access goes through `cache`.** No direct `redis.Redis()` instantiation.
- **Cache is best-effort.** Read paths must work when Redis is down; treat misses and errors identically.
- **TTL is required on every `set`.** No unbounded keys.

### Consumers

| Feature / Module | Usage |
|------------------|-------|
| `app/services/task.py` | Task list caching |
| `app/services/workspace.py` | Workspace member lookup caching |
| `app/api/websockets/` | Pub/sub for fan-out |

### Dependencies

- `redis` (async)
- `app.core.config`

### Test coverage

`tests/unit/test_cache.py` + `tests/integration/test_cache_failover.py`. Coverage: ~75%.

### Refactor triggers

- Pub/sub usage exceeds simple key/value usage → split `cache.py` and `pubsub.py`.
- Serialization needs grow beyond JSON (e.g. msgpack) → introduce a serializer abstraction.

### Change checklist

- [ ] Update consumers if signature changes.
- [ ] Run failover test (Redis killed mid-request).
- [ ] Update this row's `Last reviewed` date.

---

## `core.notifications`  ⚠️ hotspot

**Path:** `app/core/notifications.py`
**Type:** service
**Owner:** platform
**Status:** active
**Last reviewed:** 2026-02-04

### Purpose

WebSocket fan-out for real-time updates (task changes, comments, presence). Publishes to Redis pub/sub channels, fans out to connected clients.

### Public API

| Symbol | Purpose |
|--------|---------|
| `publish(channel, event)` | Send event to channel |
| `subscribe(channel)` | Async generator of events for a channel |
| `Hub` | Connection manager (currently exposed; should be internal) |

### Invariants

- **All real-time traffic goes through `publish` / `subscribe`.** No direct WebSocket sends from route handlers.
- **Events are JSON-serializable dicts with a `type` field.**

### Consumers

| Feature / Module | Usage |
|------------------|-------|
| `app/services/task.py` | Publishes on task state changes |
| `app/services/workspace.py` | Publishes on member changes |
| `app/api/websockets/` | Subscribes per-connection |

### Dependencies

- `app.core.cache` (for Redis pub/sub)
- `fastapi.WebSocket`

### Test coverage

`tests/unit/test_notifications.py` — coverage thin (~50%); pub/sub tested only via mocked Redis.

### Refactor triggers — fired

- **`change_count_12m = 14` (top quartile).** This module is being actively redesigned. Expect a `foundation-wrong-abstraction` ticket from foundationtik.
- **`Hub` leaks connection objects to consumers.** Encapsulate or split.
- **Public API has 3 symbols with growing parameter counts.** See [Sandi Metz on the wrong abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction).

### Change checklist

- [ ] Coordinate with consumers — high churn means high blast radius.
- [ ] Update integration tests for any pub/sub semantics change.
- [ ] Update this row's `Last reviewed` date.

---

## `services.helpers`  ⚠️ hidden foundation

**Path:** `app/services/helpers.py`
**Type:** primitive
**Owner:** _unowned — needs assignment_
**Status:** active
**Last reviewed:** never

### Purpose

A catch-all utility module that accumulated over the last year: date formatting, slug generation, retry decorators, currency math. Not originally designed as a foundation — but its fan-in (19 importers across 5 features) makes it one in practice.

### Public API

| Symbol | Purpose |
|--------|---------|
| `format_due_date(dt)` | Human-readable date strings |
| `slugify(text)` | URL-safe slug |
| `retry_with_backoff(fn, max=3)` | Decorator for transient failures |
| `to_cents(amount)` | Money math |
| `from_cents(cents)` | Money math |
| _(several others — see Refactor triggers)_ |

### Invariants

_No invariants documented yet. Adding these is the priority for this foundation._

Suggested invariants pending review:
- Functions must be pure (no I/O, no global state).
- Each function must have unit tests.

### Consumers

| Feature / Module | Usage |
|------------------|-------|
| `app/api/routes/tasks.py` | `format_due_date`, `slugify` |
| `app/api/routes/workspaces.py` | `slugify` |
| `app/services/billing.py` | `to_cents`, `from_cents` |
| `app/services/notifications.py` | `format_due_date` |
| `app/api/websockets/` | `retry_with_backoff` |

### Dependencies

- Standard library only.

### Test coverage

Partial — `tests/unit/test_helpers.py` covers `slugify` and money math. `format_due_date` and `retry_with_backoff` are untested.

### Refactor triggers — fired

- **Module exceeds 11 public functions across unrelated concerns.** Split by responsibility:
  - `app/core/dates.py` — date formatting
  - `app/core/text.py` — slugify, truncation
  - `app/core/retry.py` — retry decorators
  - `app/core/money.py` — currency math
- **Lives outside `app/core/`.** After splitting, move to `app/core/`.
- **No owner.** Assign to platform team or distribute pieces to feature teams.

### Change checklist

- [ ] Assign an owner before any further additions.
- [ ] Add unit tests for `format_due_date` and `retry_with_backoff` before splitting.
- [ ] Coordinate the split — every consumer's imports change.

---

## Findings

Surfaced by the most recent dockit foundation scan. These are flags for the maintainer.

### Hotspots

Active foundations whose churn places them in the top quartile — likely the wrong abstraction or under active redesign. foundationtik (tikkit) will write refactor tickets.

| Foundation | Changes (12mo) | Note |
|------------|----------------|------|
| `core.notifications` | 14 | Hub class leaks connections; param-count growth on `publish` suggests wrong abstraction |

### Hidden foundations

Files acting as foundations (high fan-in across features) but not living in a conventional foundation directory. Consider relocating after splitting.

| Path | Fan-in | Distinct features | Suggested location |
|------|--------|-------------------|--------------------|
| `app/services/helpers.py` | 19 | 5 | Split into `app/core/dates.py`, `app/core/text.py`, `app/core/retry.py`, `app/core/money.py` |

### Pretenders

Files in `core/`/`shared/`/`lib/` with low fan-in. Consider inlining back into a feature folder, or deleting.

| Path | Fan-in | Note |
|------|--------|------|
| `app/core/legacy_session.py` | 1 | Pre-Firebase session helper. Last imported by a deprecated migration script. Delete candidate. |

---

## Maintenance

### Review schedule

Foundations are reviewed on a rolling cadence. A foundation's `Last reviewed` date should be no more than **90 days** old.

| Trigger | Action |
|---------|--------|
| `Last reviewed` > 90 days | foundationtik writes a `foundation-stale-review` ticket |
| Health flips to `hotspot` | foundationtik writes a `foundation-wrong-abstraction` or `foundation-bloat` ticket |
| New hidden foundation detected | dockit `sync` adds a row, flags for review |
| Consumer count drops below threshold | foundationtik writes a `foundation-deprecation-candidate` ticket |

Currently triggered:
- `core.notifications` — hotspot, will get a refactor ticket on next foundationtik run.
- `services.helpers` — hidden foundation, needs an owner.
- `core.cache` — `Last reviewed = 2026-03-18`, approaching the 90-day threshold (currently 50 days old).

### Re-running detection

```bash
/repokit:dockit sync
```

Refreshes the catalog from current code state. Existing manual edits to invariants, refactor triggers, and change checklists are preserved — dockit only updates the table, consumers, dependencies, and findings.

---

## Related documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design context
- [PRINCIPLES.md](./PRINCIPLES.md) — patterns and conventions that foundations implement
- [CONTRIBUTING.md](./CONTRIBUTING.md) — workflow for changes that touch foundations
