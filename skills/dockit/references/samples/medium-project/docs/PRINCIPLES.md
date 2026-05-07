# Principles

Project patterns, architectural decisions, and guidelines for consistent development. This document serves both human developers and AI tools.

---

## Service Patterns

**Rule: use the project's foundations instead of importing libraries directly.** Foundations exist for cross-cutting concerns (database access, authentication, caching, real-time fan-out) so consumers get consistent lifecycle, configuration, and test behaviour.

```python
# YES — go through the foundation
from app.core.database import get_db
from app.core.auth import get_current_user

async def list_tasks(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
): ...

# NO — bypass it
from sqlalchemy import create_engine
import firebase_admin
```

**Why:** Foundations encapsulate the patterns this project depends on (connection pooling, token validation, cache fallback). Bypassing them creates parallel implementations that drift apart over time and break testability.

**The catalog of foundations — with each one's public API, invariants, and refactor triggers — lives in [FOUNDATIONS.md](./FOUNDATIONS.md).** That document is the source of truth for what to import, what contract to honour, and when to refactor. This section states the rule; FOUNDATIONS.md owns the list.

---

## Testing Approach

Tests are organized by type and use fixtures for database state.

### Test Organization

```
tests/
├── conftest.py          # Shared fixtures
├── unit/                # Pure function tests (no DB/network)
│   └── test_services.py
├── integration/         # Database and API tests
│   ├── test_api.py
│   └── test_models.py
└── fixtures/            # Test data factories
    └── factories.py
```

### Testing Patterns

- **Unit tests**: Mock all external dependencies, test business logic
- **Integration tests**: Use test database with transaction rollback
- **API tests**: Use `TestClient`, test full request/response cycle
- **Fixtures**: Use factory functions, not static data

### What to Test

| Type | Coverage | Example |
|------|----------|---------|
| Service functions | All public methods | `test_create_task_assigns_to_user` |
| API routes | Happy path + error cases | `test_get_tasks_requires_auth` |
| Models | Validation, relationships | `test_task_requires_title` |
| Auth | Token validation, permissions | `test_admin_can_delete_workspace` |

### Running Tests

```bash
make test                    # All tests
make test-unit               # Unit tests only
make test-integration        # Integration tests only
pytest -k "test_name"        # Specific test
```

| Marker | Purpose |
|--------|---------|
| `@pytest.mark.slow` | Long-running tests, skipped by default |
| `@pytest.mark.integration` | Requires database |

---

## Architectural Decisions

Key decisions that shape the codebase.

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Async everywhere | Required | Better concurrency for I/O-bound API |
| SQLAlchemy 2.0 | Async ORM | Type safety, async support |
| Firebase Auth | External auth | No password management, easy mobile integration |
| Redis for WebSockets | Pub/sub | Scalable real-time across instances |

### Repository Pattern

**Context:** Need to abstract database operations from business logic.

**Decision:** Use repository classes for each model, inject via dependencies.

**Rationale:** Enables testing business logic without database, consistent query patterns.

### Service Layer

**Context:** API routes were getting complex with business logic.

**Decision:** Extract business logic to service classes, routes only handle HTTP.

**Rationale:** Testable business logic, reusable across routes and WebSockets.

---

## Code Conventions

Standards for consistent, maintainable code.

### General

- Type hints required for all function parameters and returns
- Async functions for all I/O operations
- Dependency injection via FastAPI `Depends()`
- No business logic in route handlers

### Python-Specific

- Use `pydantic` for all request/response models
- Use `SQLAlchemy` models for database, `pydantic` for API
- Prefer `asyncio.gather()` for concurrent operations

### Documentation Format

```python
async def create_task(
    title: str,
    workspace_id: UUID,
    assignee_id: UUID | None = None,
) -> Task:
    """
    Create a new task in a workspace.

    :param title: Task title (required, non-empty)
    :param workspace_id: Workspace to create task in
    :param assignee_id: Optional user to assign task to
    :return: Created task with generated ID
    :raises WorkspaceNotFoundError: If workspace doesn't exist
    :raises PermissionDeniedError: If user can't create tasks in workspace
    """
```

---

## Non-Negotiables

> These rules are mandatory. Violations should block PRs. Per-foundation invariants (e.g. "`Hub` is internal," "all DB access goes through `get_db()`") live in the foundation entries in [FOUNDATIONS.md](./FOUNDATIONS.md). The list below is for project-wide rules that span foundations.

- [ ] All database operations must be async
- [ ] All API routes must require authentication (except health check)
- [ ] No secrets in code - use environment variables
- [ ] Tests must pass before merge
- [ ] No raw SQL - use SQLAlchemy ORM

---

## Related Documentation

- [README.md](../README.md) - Project overview and quick start
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design and diagrams
- [FOUNDATIONS.md](./FOUNDATIONS.md) - Catalog of shared/foundational code (the *what* behind the patterns above)
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development workflow
