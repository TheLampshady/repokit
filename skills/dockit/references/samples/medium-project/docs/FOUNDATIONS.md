# Foundations

Registry of shared, foundational code in the Task Manager API — the abstractions, services, and primitives that the rest of the codebase depends on. This document is the source of truth for `agentkit` (per-foundation subagents) and `foundationtik` in tikkit (maintenance tickets).

A "foundation" here means: code with high fan-in across multiple features, intended to be reused, and expected to remain stable. Regenerate this file with `/repokit:dockit sync`.

> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.

---

## Catalog

5 foundations detected across `app/`. Last sync: 2026-08-01.

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

### Use when

- Reading or writing anything persisted
- Adding a repository, a migration, or a test that touches the database
- Deciding how a service gets its session

### Invariants

**Reach the database through `get_db()`.** `engine` is exported for Alembic only. Exceptions: `alembic/env.py`.
<!-- dockit:check cmd="grep -rlE 'from app.core.database import engine' app/ | grep -v 'alembic' | wc -l" expect="0" tier="rule" last="2026-08-01" -->

<details><summary>Why</summary>

`get_db()` owns commit-on-success and rollback-on-exception. Code holding the engine
directly gets neither, and two early handlers left transactions open under load.
Rejected: a session context manager per call site — same guarantees, but every caller has
to remember to use it.
</details>

**Sessions are request-scoped.** Background tasks open their own; never pass one across a request boundary.
<!-- dockit:check cmd="grep -lE 'Depends\(get_db\)' app/workers/*.py | wc -l" expect="0" tier="convention" last="2026-08-01" -->

[TODO: why?]

**Query through the ORM.** `text()` requires platform-team review. Exceptions: `alembic/versions/`.
<!-- dockit:check cmd="grep -rlE 'execute\(text\(' app/ | wc -l" expect="0" tier="rule" last="2026-08-01" -->

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
- [ ] Update this row's `Last reviewed` date.
- [ ] Notify platform-team channel.

---

## `core.auth`

**Path:** `app/core/auth.py`
**Type:** abstraction
**Owner:** platform
**Status:** active
**Last reviewed:** 2026-04-12

### Use when

- Adding or changing any route, WebSocket handshake, or background job that acts on behalf of a user
- Gating something by role
- Anything touching identity, tokens, or Firebase

### Invariants

**Every route declares `Depends(get_current_user)`.** Exceptions: `GET /health`.
<!-- dockit:check cmd="grep -LE 'Depends\(get_current_user\)' app/api/routes/*.py | grep -v 'health.py' | wc -l" expect="0" tier="rule" last="2026-08-01" -->

<details><summary>Why</summary>

An unauthenticated `/workspaces` listing shipped in March 2025 and exposed workspace names
across tenants for nine days.
Rejected: middleware-level auth — routes that legitimately need anonymous access become
invisible exceptions instead of explicit ones.
</details>

**Validate tokens through the Firebase Admin SDK.** No hand-rolled JWT parsing.
<!-- dockit:check cmd="grep -rlE 'jwt.decode|base64.*\.split\(.\..\)' app/ | wc -l" expect="0" tier="rule" last="2026-08-01" -->

[TODO: why?]

**Treat `User` as read-only.** Mutations go through `UserRepository`.
<!-- dockit:check cmd="grep -rlE 'user\.[a-z_]+ = ' app/api/ app/services/ | wc -l" expect="0" tier="convention" last="2026-08-01" -->

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
- [ ] Update this row's `Last reviewed` date.

---

## `core.cache`

**Path:** `app/core/cache.py`
**Type:** service
**Owner:** platform
**Status:** active
**Last reviewed:** 2026-03-18

### Use when

- Caching anything, or invalidating a cached value
- Publishing to or subscribing from Redis
- Deciding whether a read path can tolerate a cache miss

### Invariants

**Go through `cache`.** No direct `redis.Redis()` construction.
<!-- dockit:check cmd="grep -rlE 'redis\.Redis\(|from redis import' app/ | grep -v 'app/core/cache.py' | wc -l" expect="0" tier="rule" last="2026-08-01" -->

[TODO: why?]

**Read paths work when Redis is down.** Treat misses and errors identically.
<!-- dockit:conform cmd="grep -rlE 'except.*RedisError|cache\.get.*or ' app/services/*.py | wc -l" total="grep -lE 'cache\.get' app/services/*.py | wc -l" min="80%" tier="rule" last="2026-08-01" -->

<details><summary>Why</summary>

A Redis restart during the 2025-11 deploy took the whole API down for four minutes —
every list endpoint raised instead of falling through to the database.
Rejected: a circuit breaker — it adds a failure mode of its own for a cache that's already
optional by design.
</details>

**Every `set` passes a `ttl`.** No unbounded keys.
<!-- dockit:check cmd="grep -rE 'cache\.set\(' app/ | grep -v 'ttl=' | wc -l" expect="0" tier="convention" last="2026-08-01" -->

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
- [ ] Update this row's `Last reviewed` date.

---

## `core.notifications`  ⚠️ hotspot

**Path:** `app/core/notifications.py`
**Type:** service
**Owner:** platform
**Status:** active
**Last reviewed:** 2026-02-04

### Use when

- Sending anything to a connected client in real time
- Adding a new event type or WebSocket channel
- Debugging why a client didn't receive an update

### Invariants

**Publish through `publish()`.** No direct WebSocket sends from route handlers.
<!-- dockit:check cmd="grep -rlE 'websocket\.send_(json|text)' app/api/routes/ | wc -l" expect="0" tier="rule" last="2026-08-01" -->

[TODO: why?]

**Events are JSON-serialisable dicts carrying a `type` field.**
<!-- dockit:conform cmd="grep -lE 'publish\(.{0,40}type' app/services/*.py | wc -l" total="grep -cE 'publish\(' app/services/*.py | wc -l" min="80%" tier="convention" last="2026-08-01" -->

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
- [ ] Update this row's `Last reviewed` date.

---

## `services.helpers`  ⚠️ hidden foundation

**Path:** `app/services/helpers.py`
**Type:** primitive
**Owner:** _unowned — needs assignment_
**Status:** active
**Last reviewed:** never

### Use when

- Formatting a due date, slugifying text, converting currency, or retrying a transient failure
- Before writing any of the above from scratch — one of the 11 functions here probably does it

### Invariants

_None recorded. This foundation accumulated rather than being designed, so nothing has been asserted about it yet — the priority for its first review._

Candidates observed in the code, unconfirmed:

**Functions are pure — no I/O, no global state.** Currently 11/11.
<!-- dockit:conform cmd="grep -LE 'open\(|requests\.|await ' app/services/helpers.py | wc -l" total="1" min="80%" tier="convention" last="2026-08-01" -->

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
| Invariant predicate fails | dockit `sync` flags it; `/repokit status` asks whether the doc is wrong or the code is drifting |

Currently triggered:
- `core.notifications` — hotspot, will get a refactor ticket on next foundationtik run.
- `services.helpers` — hidden foundation, needs an owner.
- `core.cache` — `Last reviewed = 2026-03-18`, past the 90-day threshold.
- 8 open decisions across these entries — run `/repokit status` to walk them.

### Re-running detection

```bash
/repokit:dockit sync
```

Refreshes the catalog from current code state, and re-runs every stored predicate. Manual edits to invariants, refactor triggers, and change checklists are preserved.

**Nothing here is auto-removed on a failed predicate.** A decayed count means either the invariant is wrong or the code is drifting away from a correct invariant, and the evidence doesn't distinguish those. Sync flags; a human decides.

---

## Related documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design context
- [PRINCIPLES.md](./PRINCIPLES.md) — codebase-wide conventions and rules
- [CONTRIBUTING.md](./CONTRIBUTING.md) — workflow for changes that touch foundations
