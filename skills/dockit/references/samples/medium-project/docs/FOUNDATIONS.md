# Foundations

Registry of shared, foundational code in the Task Manager API — the abstractions, services, and primitives that the rest of the codebase depends on. This document is the source of truth for `agentkit` (per-foundation subagents) and `foundationtik` in tikkit (maintenance tickets).

A "foundation" here means: code with high fan-in across multiple features, intended to be reused, and expected to remain stable. Regenerate this file with `/repokit:dockit sync`.

> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.

---

## Catalog

6 foundations across `app/` — 5 in use, 1 intended.

| Name | Type | Path | Owner | Status | Health | Consumers |
|------|------|------|-------|--------|--------|-----------|
| `core.database` | service | `app/core/database.py` | platform | active | healthy | 28 (4 features) |
| `core.auth` | abstraction | `app/core/auth.py` | platform | active | healthy | 24 (4 features) |
| `core.cache` | service | `app/core/cache.py` | platform | active | healthy | 11 (3 features) |
| `core.notifications` | service | `app/core/notifications.py` | platform | active | **hotspot** | 22 (3 features) |
| `services.helpers` | primitive | `app/services/helpers.py` | _unowned_ | active | healthy | 19 (5 features) |
| `core.settings` | service | `app/core/settings.py` | platform | **intended** | healthy | none yet |

> The `services.helpers` row is a **hidden foundation** — see Findings below.
>
> `core.settings` is **intended**: it's the sanctioned path for configuration and nothing routes through it yet. Zero consumers is what that status means, not a problem to fix — the 15 direct `os.environ` reads still in `app/` are what it exists to replace.

---

## `core.database`

**Path:** `app/core/database.py`
**Type:** service
**Owner:** platform
**Status:** active

### Use when

- Reading or writing anything persisted
- Adding a repository, a migration, or a test that touches the database
- Deciding how a service gets its session

### Invariants

**Reach the database through `get_db()`.** Importing `engine` from `app.core.database` skips commit-on-success and rollback-on-exception, which left transactions open under load — depend on `get_db()` instead. `engine` is exported for Alembic only. Exceptions: `alembic/env.py`.
<!-- dockit:tier="rule" -->

<details><summary>Why</summary>

`get_db()` owns commit-on-success and rollback-on-exception. Code holding the engine
directly gets neither, and two early handlers left transactions open under load.
Rejected: a session context manager per call site — same guarantees, but every caller has
to remember to use it.
</details>

**Sessions are request-scoped.** A `Depends(get_db)` in `app/workers/` binds a worker to a request lifecycle that has already ended — open a session inside the task with `async with session_scope()`. Background tasks own theirs; a session never crosses a request boundary.
<!-- dockit:tier="convention" -->

[TODO: why?]

**Query through the ORM.** An `execute(text(` call bypasses the tenant filter and can return other workspaces' rows — express the query with ORM constructs. `text()` requires platform-team review. Exceptions: `alembic/versions/`.
<!-- dockit:tier="rule" -->

<details><summary>Why</summary>

Two string-interpolated queries bypassed the tenant filter and returned rows belonging to
other workspaces.
Rejected: a query linter — it can't see interpolation built up across several statements.
</details>

### Canonical usage

```python
# from app/api/routes/tasks.py:41
@router.get("/tasks")
async def list_tasks(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[TaskRead]:
    return await TaskRepository(db).list_for_workspace(user.workspace_id)
```

### Extend by

New repository → add `app/repositories/<model>.py` subclassing `BaseRepository`, then take it as a constructor arg in the service. New table → `make migration name=<slug>`, edit the generated revision under `alembic/versions/`.

<!-- Derived from the last 4 additions (task, comment, workspace, invite repositories) —
     every one touched exactly these files. -->

### Doesn't cover

Read replicas and connection routing. `get_db()` returns the primary unconditionally; the two reporting endpoints in `app/api/routes/reports.py` construct their own read-only session.

[TODO: intentional boundary, or a gap?]

---

#### Reference

**Consumers**

| Feature / Module | Usage |
|------------------|-------|
| `app/api/routes/` | All route handlers depend via `Depends(get_db)` |
| `app/services/` | Service layer accepts session as constructor arg |
| `app/repositories/` | Repository pattern wraps the session |
| `tests/` | Test fixtures override with transaction-rollback session |

**Dependencies**

- `sqlalchemy` (async)
- `app.core.config` (for `DATABASE_URL`)

**Test coverage**

`tests/integration/test_database.py` — session lifecycle, rollback, pool exhaustion. Coverage: ~85%.

**Refactor triggers**

- Public API exceeds 5 symbols → split into `database/session.py` + `database/engine.py`.
- Consumers begin importing `engine` directly → tighten exports.
- Any consumer needs sync access → resist; route through async; document why if approved.

**Change checklist**

- [ ] Update consumers in the same PR if `get_db` signature changes.
- [ ] Re-run integration tests against PostgreSQL 14, 15, 16.
- [ ] Notify platform-team channel.

---

## `core.auth`

**Path:** `app/core/auth.py`
**Type:** abstraction
**Owner:** platform
**Status:** active

### Use when

- Adding or changing any route, WebSocket handshake, or background job that acts on behalf of a user
- Gating something by role
- Anything touching identity, tokens, or Firebase

### Invariants

**Every route declares `Depends(get_current_user)`.** A route file without it is unauthenticated — add the dependency to the router or the individual route. Exceptions: `GET /health`.
<!-- dockit:tier="rule" -->

<details><summary>Why</summary>

An unauthenticated `/workspaces` listing shipped in March 2025 and exposed workspace names
across tenants for nine days.
Rejected: middleware-level auth — routes that legitimately need anonymous access become
invisible exceptions instead of explicit ones.
</details>

**Validate tokens through the Firebase Admin SDK.** A `jwt.decode` call or a base64 split on the token skips signature and revocation checks — call `verify_id_token()` via `app/core/auth.py`.
<!-- dockit:tier="rule" -->

[TODO: why?]

**Treat `User` as read-only.** Assigning to an attribute (`user.email = ...`) in a route or service mutates an object the session may flush unexpectedly — call the matching `UserRepository` method instead.
<!-- dockit:tier="convention" -->

[TODO: why?]

### Canonical usage

```python
# from app/api/routes/workspaces.py:88
@router.delete("/workspaces/{workspace_id}")
async def delete_workspace(
    workspace_id: UUID,
    _: User = Depends(require_role("owner")),
    db: AsyncSession = Depends(get_db),
) -> None:
    await WorkspaceService(db).delete(workspace_id)
```

### Extend by

New role → add it to the `Role` enum in `app/core/auth.py`, then gate routes with `require_role("<name>")`. New identity provider → not currently supported; see Doesn't cover.

### Doesn't cover

Service-to-service auth. The two internal endpoints in `app/api/routes/internal.py` check a shared secret header instead of going through this module.

[TODO: intentional boundary, or a gap?]

---

#### Reference

**Consumers**

| Feature / Module | Usage |
|------------------|-------|
| `app/api/routes/` | Every protected route |
| `app/api/websockets/` | WS handshake uses the same dependency |

**Dependencies**

- `firebase-admin`
- `app.core.config` (for service-account credentials)

**Test coverage**

`tests/integration/test_auth.py` — token validation, role gates, expired-token handling. Coverage: ~90%.

**Refactor triggers**

- More than 3 role-checking helpers accumulate → extract to `auth/roles.py`.
- Multiple identity providers added → extract `auth/providers/` directory.

**Change checklist**

- [ ] Update consumers in the same PR if dependency return type changes.
- [ ] Test against expired and revoked tokens.

---

## `core.cache`

**Path:** `app/core/cache.py`
**Type:** service
**Owner:** platform
**Status:** active

### Use when

- Caching anything, or invalidating a cached value
- Publishing to or subscribing from Redis
- Deciding whether a read path can tolerate a cache miss

### Invariants

**Go through `cache`.** A `redis.Redis(` construction or a bare `from redis import` outside `app/core/cache.py` opens its own connection and loses the down-Redis fallback — import `cache` and use it.
<!-- dockit:tier="rule" -->

[TODO: why?]

**Read paths work when Redis is down.** A `cache.get` whose result is used without an `except RedisError` or an `or <fallback>` turns a cache outage into an API outage — fall through to the database on both a miss and an error. Treat the two identically.
<!-- dockit:tier="rule" -->

<details><summary>Why</summary>

A Redis restart during the 2025-11 deploy took the whole API down for four minutes —
every list endpoint raised instead of falling through to the database.
Rejected: a circuit breaker — it adds a failure mode of its own for a cache that's already
optional by design.
</details>

**Every `set` passes a `ttl`.** A `cache.set(` without `ttl=` writes a key nothing will ever evict — pass an explicit `ttl`, even a long one.
<!-- dockit:tier="convention" -->

[TODO: why?]

### Canonical usage

```python
# from app/services/task.py:112
cached = await cache.get(f"tasks:{workspace_id}")
if cached is not None:
    return cached

tasks = await TaskRepository(self.db).list_for_workspace(workspace_id)
await cache.set(f"tasks:{workspace_id}", tasks, ttl=300)
return tasks
```

### Extend by

New cached read → follow the get-miss-set shape above and add the key prefix to the `CACHE_PREFIXES` table in `app/core/cache.py` so invalidation can find it.

### Doesn't cover

Write-through and read-through caching — every call site does its own get/set by hand. Also no cache stampede protection; three services hit the same key on expiry.

[TODO: intentional boundary, or a gap?]

---

#### Reference

**Consumers**

| Feature / Module | Usage |
|------------------|-------|
| `app/services/task.py` | Task list caching |
| `app/services/workspace.py` | Workspace member lookup caching |
| `app/api/websockets/` | Pub/sub for fan-out |

**Dependencies**

- `redis` (async)
- `app.core.config`

**Test coverage**

`tests/unit/test_cache.py` + `tests/integration/test_cache_failover.py`. Coverage: ~75%.

**Refactor triggers**

- Pub/sub usage exceeds simple key/value usage → split `cache.py` and `pubsub.py`.
- Serialization needs grow beyond JSON (e.g. msgpack) → introduce a serializer abstraction.

**Change checklist**

- [ ] Update consumers if signature changes.
- [ ] Run failover test (Redis killed mid-request).

---

## `core.notifications`  ⚠️ hotspot

**Path:** `app/core/notifications.py`
**Type:** service
**Owner:** platform
**Status:** active

### Use when

- Sending anything to a connected client in real time
- Adding a new event type or WebSocket channel
- Debugging why a client didn't receive an update

### Invariants

**Publish through `publish()`.** A `websocket.send_json` / `send_text` call in a route handler reaches only the one connected socket, skipping fan-out across instances — call `publish()` instead.
<!-- dockit:tier="rule" -->

[TODO: why?]

**Events are JSON-serialisable dicts carrying a `type` field.** A `publish()` payload without `type` can't be dispatched by the client, and an ORM object or `datetime` in it fails to serialise — send a plain dict with `type` set.
<!-- dockit:tier="convention" -->

[TODO: why?]

### Canonical usage

```python
# from app/services/task.py:64
await publish(
    f"workspace:{task.workspace_id}",
    {"type": "task.updated", "task_id": str(task.id), "status": task.status},
)
```

### Extend by

New event type → publish it with a dotted `type` string from the owning service, then add a case to the client-side handler. There is no registry; the set of event types is discoverable only by grepping `publish(`.

<!-- Flagged: no scaffold or registry exists for this. Reported to the user, not written as a rule. -->

### Doesn't cover

Delivery guarantees. Events are fire-and-forget — a client that reconnects mid-publish misses them, and nothing replays. Presence is also handled separately in `app/api/websockets/presence.py` rather than through this module.

[TODO: intentional boundary, or a gap?]

---

#### Reference

**Consumers**

| Feature / Module | Usage |
|------------------|-------|
| `app/services/task.py` | Publishes on task state changes |
| `app/services/workspace.py` | Publishes on member changes |
| `app/api/websockets/` | Subscribes per-connection |

**Dependencies**

- `app.core.cache` (for Redis pub/sub)
- `fastapi.WebSocket`

**Test coverage**

`tests/unit/test_notifications.py` — coverage thin (~50%); pub/sub tested only via mocked Redis.

**Refactor triggers — fired**

- **`change_count_12m = 14` (top quartile).** This module is being actively redesigned. Expect a `foundation-wrong-abstraction` ticket from foundationtik.
- **`Hub` leaks connection objects to consumers.** Encapsulate or split.
- **Public API has 3 symbols with growing parameter counts.** See [Sandi Metz on the wrong abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction).

**Change checklist**

- [ ] Coordinate with consumers — high churn means high blast radius.
- [ ] Update integration tests for any pub/sub semantics change.

---

## `services.helpers`  ⚠️ hidden foundation

**Path:** `app/services/helpers.py`
**Type:** primitive
**Owner:** _unowned — needs assignment_
**Status:** active

### Use when

- Formatting a due date, slugifying text, converting currency, or retrying a transient failure
- Before writing any of the above from scratch — one of the 11 functions here probably does it

### Invariants

_None recorded. This foundation accumulated rather than being designed, so nothing has been asserted about it yet — the priority for its first review._

Candidates observed in the code, unconfirmed:

**Functions are pure — no I/O, no global state.** 11/11 when observed. An `open(`, `requests.`, or `await` in here makes a helper untestable without a fixture and pulls a dependency into every caller.
<!-- dockit:tier="convention" -->

[TODO: intentional rule, or just how it happens to be?]

### Canonical usage

```python
# from app/api/routes/tasks.py:77
from app.services.helpers import format_due_date, slugify

slug = slugify(payload.title)
due = format_due_date(task.due_at)
```

### Extend by

No sanctioned path — functions are appended to the module directly. That's the reason it's flagged as a hidden foundation; see the split proposed under Refactor triggers.

### Doesn't cover

[TODO: nothing recorded — needs an owner before this can be answered]

---

#### Reference

**Consumers**

| Feature / Module | Usage |
|------------------|-------|
| `app/api/routes/tasks.py` | `format_due_date`, `slugify` |
| `app/api/routes/workspaces.py` | `slugify` |
| `app/services/billing.py` | `to_cents`, `from_cents` |
| `app/services/notifications.py` | `format_due_date` |
| `app/api/websockets/` | `retry_with_backoff` |

**Dependencies**

- Standard library only.

**Test coverage**

Partial — `tests/unit/test_helpers.py` covers `slugify` and money math. `format_due_date` and `retry_with_backoff` are untested.

**Refactor triggers — fired**

- **Module exceeds 11 public functions across unrelated concerns.** Split by responsibility:
  - `app/core/dates.py` — date formatting
  - `app/core/text.py` — slugify, truncation
  - `app/core/retry.py` — retry decorators
  - `app/core/money.py` — currency math
- **Lives outside `app/core/`.** After splitting, move to `app/core/`.
- **No owner.** Assign to platform team or distribute pieces to feature teams.

**Change checklist**

- [ ] Assign an owner before any further additions.
- [ ] Add unit tests for `format_due_date` and `retry_with_backoff` before splitting.
- [ ] Coordinate the split — every consumer's imports change.

---

## `core.settings`

**Path:** `app/core/settings.py`
**Type:** service
**Owner:** platform
**Status:** intended

> **Sanctioned path, no precedent yet.** Nothing routes through `Settings` so far. You may be writing the first call site — follow the contract below rather than copying the surrounding `os.environ` reads, which are what this exists to replace.

### Use when

- Reading any configuration value, secret, or feature flag
- Adding a new environment variable
- Deciding how a module gets an environment-dependent value

### Invariants

**All config comes from the `Settings` object** (`app/core/settings.py`). Direct `os.environ` / `os.getenv` reads skip type coercion and startup validation, so a missing variable surfaces as an `AttributeError` on the first request that needs it rather than a failure at boot — add a field to `Settings` and read it from there.
<!-- dockit:tier="convention" -->

<details><summary>Why</summary>

A mistyped `REDIS_TIMEOUT` shipped as the string `"5"` and silently disabled the cache
timeout for a week — `int` coercion at load time makes that a startup failure instead.
Rejected: a `python-dotenv` + module-level constants pattern — no validation, and no
single place to see what the service actually reads.
</details>

**`Settings` is instantiated once, at import, and injected.** Constructing a second `Settings()` inside a function re-reads the environment and drops the validation cache — import the module-level `settings` instance instead.
<!-- dockit:tier="convention" -->

[TODO: why?]

### Canonical usage

_None yet — no consumers. The intended shape:_

```python
# app/core/settings.py defines:
#   class Settings(BaseSettings): redis_timeout: int = 5
from app.core.settings import settings

timeout = settings.redis_timeout
```

### Extend by

New config value → add a typed field to `Settings` with a default, document it in `ENVIRONMENTS.md`, then read `settings.<field>` at the call site. No `os.environ` at any point.

### Doesn't cover

Runtime-mutable configuration. `Settings` is validated once at import, so feature flags that flip without a restart need a different mechanism.

[TODO: intentional boundary, or a gap?]

---

#### Reference

**Consumers**

_None yet._ Intended consumers are the 15 modules under `app/api/`, `app/services/`, and `app/workers/` that currently read `os.environ` directly — those are the call sites this replaces.

**Dependencies**

- `pydantic-settings`

**Test coverage**

_None yet._ [TODO: add a test asserting a missing required variable fails at import]

**Refactor triggers**

- **Exceeds ~30 fields.** Split into nested settings models by domain (`settings.db`, `settings.cache`).
- **Any consumer constructs its own `Settings()`.** Tighten to a module-level singleton export.

**Change checklist**

- [ ] Migrate the 15 direct `os.environ` readers in the same PR or a tracked follow-up.
- [ ] Every new field documented in `ENVIRONMENTS.md`.

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

### Review triggers

Reviews are triggered by **events, not by the calendar.** Nothing here fires because time passed, and no date is stamped into this file — for "how long since anyone touched this", ask git: `git log -1 --format=%cr -- app/core/cache.py`.

| Trigger | Action |
|---------|--------|
| Health flips to `hotspot` | foundationtik writes a `foundation-wrong-abstraction` or `foundation-bloat` ticket |
| New hidden foundation detected | dockit `sync` adds a row, flags for review |
| Consumer count drops to zero **and the module is gone** | foundationtik writes a `foundation-deprecation-candidate` ticket |
| The code an invariant governs is deleted | dockit `sync` removes the invariant and names it in the run report |
| Someone works on the foundation | Validate the invariants while you're in there |

Currently triggered:
- `core.notifications` — hotspot, will get a refactor ticket on next foundationtik run.
- `services.helpers` — hidden foundation, needs an owner.
- 8 open decisions across these entries — run `/repokit status` to walk them.

### Re-running detection

```bash
/repokit:dockit sync
```

Refreshes the catalog from current code state. Manual edits to invariants, refactor triggers, and change checklists are preserved.

**Invariants are not re-measured.** Each one was measured once, when it was written; after that it's a directive about what future work should do. Fewer files following it isn't counted and isn't reported — a directive being bypassed is a reason to keep it, not to cut it. The only removal trigger is the code it governs disappearing. For enforcement on every commit, use a linter: ArchUnit, import-linter, and dependency-cruiser run where enforcement actually works.

---

## Related documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design context
- [PRINCIPLES.md](./PRINCIPLES.md) — codebase-wide conventions and rules
- [CONTRIBUTING.md](./CONTRIBUTING.md) — workflow for changes that touch foundations
