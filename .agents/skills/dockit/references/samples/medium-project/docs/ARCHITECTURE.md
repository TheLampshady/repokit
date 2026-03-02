# Architecture

System design, data models, and technical decisions for the Task Manager API.

---

## Overview

FastAPI backend with PostgreSQL for persistence, Redis for caching and real-time features, and Firebase for authentication. Designed for horizontal scaling with stateless API instances.

## System Diagram

```mermaid
flowchart TD
    subgraph Clients
        Web[Web App]
        Mobile[Mobile App]
    end

    subgraph API[FastAPI Backend]
        Routes[Route Handlers]
        Services[Service Layer]
        Repos[Repositories]
        WS[WebSocket Hub]
    end

    subgraph External
        Auth[Firebase Auth]
    end

    subgraph Data
        DB[(PostgreSQL)]
        Cache[(Redis)]
    end

    Web --> Routes
    Mobile --> Routes
    Web --> WS
    Mobile --> WS
    Routes --> Auth
    Routes --> Services
    Services --> Repos
    Repos --> DB
    Services --> Cache
    WS --> Cache
```

---

## Application Structure

| Directory | Purpose |
|-----------|---------|
| `app/` | Application root |
| `app/api/` | Route handlers, organized by resource |
| `app/api/routes/` | Individual route modules (tasks, workspaces, users) |
| `app/core/` | Configuration, database, auth, cache |
| `app/models/` | SQLAlchemy ORM models |
| `app/schemas/` | Pydantic request/response models |
| `app/services/` | Business logic layer |
| `app/repositories/` | Data access layer |
| `tests/` | Test suite |

---

## Data Model

```mermaid
erDiagram
    User ||--o{ WorkspaceMember : "belongs to"
    Workspace ||--o{ WorkspaceMember : "has"
    Workspace ||--o{ Task : "contains"
    User ||--o{ Task : "assigned to"
    Task ||--o{ Comment : "has"
    User ||--o{ Comment : "writes"

    User {
        uuid id PK
        string email
        string name
        timestamp created_at
    }

    Workspace {
        uuid id PK
        string name
        uuid owner_id FK
        timestamp created_at
    }

    WorkspaceMember {
        uuid id PK
        uuid workspace_id FK
        uuid user_id FK
        enum role
    }

    Task {
        uuid id PK
        uuid workspace_id FK
        uuid assignee_id FK
        string title
        text description
        enum status
        date due_date
        timestamp created_at
    }

    Comment {
        uuid id PK
        uuid task_id FK
        uuid author_id FK
        text content
        timestamp created_at
    }
```

---

## Key Modules

### Core (`app/core/`)

| Module | Purpose |
|--------|---------|
| `config.py` | Settings from environment variables |
| `database.py` | Async SQLAlchemy session factory |
| `auth.py` | Firebase token validation, user dependency |
| `cache.py` | Redis client wrapper |

### Services (`app/services/`)

| Service | Responsibility |
|---------|----------------|
| `TaskService` | Task CRUD, assignment, status transitions |
| `WorkspaceService` | Workspace management, member invites |
| `NotificationService` | Real-time updates via WebSocket |

---

## Request Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant R as Route Handler
    participant A as Auth Middleware
    participant S as Service
    participant Repo as Repository
    participant DB as PostgreSQL

    C->>R: POST /tasks
    R->>A: Validate token
    A->>A: Verify Firebase JWT
    A-->>R: User object
    R->>S: create_task(data, user)
    S->>S: Validate permissions
    S->>Repo: save(task)
    Repo->>DB: INSERT
    DB-->>Repo: Task row
    Repo-->>S: Task model
    S-->>R: Task
    R-->>C: 201 Created
```

---

## API

REST API for task management. All endpoints require authentication via Firebase JWT unless noted.

### Base URLs

| Environment | URL |
|-------------|-----|
| Local | `http://localhost:8000` |
| Staging | `https://api-staging.taskmanager.dev` |
| Production | `https://api.taskmanager.dev` |

### Authentication

All requests require a Bearer token from Firebase Auth:

```bash
curl -H "Authorization: Bearer $TOKEN" https://api.taskmanager.dev/tasks
```

### Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/tasks` | List tasks in workspace | Required |
| POST | `/tasks` | Create new task | Required |
| GET | `/tasks/{id}` | Get task details | Required |
| PATCH | `/tasks/{id}` | Update task | Required |
| DELETE | `/tasks/{id}` | Delete task | Required |
| GET | `/workspaces` | List user's workspaces | Required |
| POST | `/workspaces` | Create workspace | Required |
| POST | `/workspaces/{id}/invite` | Invite member | Required (Owner) |
| GET | `/users/me` | Current user profile | Required |
| GET | `/health` | Health check | None |

### Error Codes

| Code | Meaning | Common Cause |
|------|---------|--------------|
| 400 | Bad Request | Invalid input or missing required fields |
| 401 | Unauthorized | Missing or expired token |
| 403 | Forbidden | Not a workspace member or insufficient role |
| 404 | Not Found | Task or workspace doesn't exist |
| 409 | Conflict | Duplicate workspace name |
| 500 | Server Error | Internal error—check logs |

### Rate Limits

- 100 requests/minute per user
- 1000 requests/minute per workspace
- Headers: `X-RateLimit-Remaining`, `X-RateLimit-Reset`

---

## External Integrations

| Integration | Purpose | Auth Method |
|-------------|---------|-------------|
| Firebase Auth | User authentication | Service account |
| PostgreSQL | Data persistence | Connection string |
| Redis | Caching, pub/sub | Connection string |

---

## ⚠️ Limitations

**What this API doesn't do:**

- **Bulk operations** — Each task must be created/updated individually
- **Webhooks** — No outbound event notifications (planned for v2)
- **File attachments** — Tasks are text-only
- **Offline sync** — Clients must handle their own offline state

---

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Layered architecture | Routes → Services → Repos | Separation of concerns, testability |
| Async SQLAlchemy | SQLAlchemy 2.0 async | Non-blocking database operations |
| UUID primary keys | UUIDs over integers | No sequential enumeration, distributed generation |
| Soft deletes | `deleted_at` column | Audit trail, recovery |

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [PRINCIPLES.md](./PRINCIPLES.md) - Patterns and conventions
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Configuration
