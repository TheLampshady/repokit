# Architecture

System design overview for the E-Commerce Platform.

## Table of Contents

### In This Document
- [Overview](#overview)
- [System Diagram](#system-diagram)
- [Key Components](#key-components)

### Detailed Documentation
- [Services](./architecture/SERVICES.md) - Service-by-service breakdown
- [Data Models](./architecture/DATA-MODELS.md) - Database schemas and ERDs

---

## Overview

Three-service architecture: React frontend, Node.js API, and Python ML service. Services communicate via REST, share a PostgreSQL database, and use Redis for caching and pub/sub.

| Attribute | Value |
|-----------|-------|
| Architecture Style | Microservices (3 services) |
| Communication | REST + Redis pub/sub |
| Database | PostgreSQL (shared) |
| Cache | Redis |

---

## System Diagram

```mermaid
flowchart TD
    subgraph Clients
        Web[Web Browser]
        Mobile[Mobile App]
    end

    subgraph Frontend
        React[React SPA<br/>:3000]
    end

    subgraph Backend
        API[Node.js API<br/>:4000]
    end

    subgraph ML
        Recs[Python Recommendations<br/>:5000]
    end

    subgraph Data
        DB[(PostgreSQL)]
        Cache[(Redis)]
    end

    Web --> React
    Mobile --> API
    React --> API
    API --> Recs
    API --> DB
    API --> Cache
    Recs --> DB
    Recs --> Cache
```

---

## Key Components

| Component | Purpose | Port | Details |
|-----------|---------|------|---------|
| Frontend | React SPA, product browsing, checkout | 3000 | [Services →](./architecture/SERVICES.md#frontend) |
| Backend | REST API, auth, orders, inventory | 4000 | [Services →](./architecture/SERVICES.md#backend) |
| Recommendations | ML predictions, similar products | 5000 | [Services →](./architecture/SERVICES.md#recommendations) |
| PostgreSQL | Primary data store | 5432 | [Data Models →](./architecture/DATA-MODELS.md) |
| Redis | Cache, session, pub/sub | 6379 | - |

---

## Service Communication

```mermaid
sequenceDiagram
    participant F as Frontend
    participant B as Backend API
    participant R as Recommendations
    participant DB as PostgreSQL
    participant C as Redis

    F->>B: GET /products
    B->>C: Check cache
    C-->>B: Cache miss
    B->>DB: Query products
    DB-->>B: Products
    B->>R: GET /recommendations/{user}
    R->>DB: Query user history
    DB-->>R: History
    R-->>B: Recommendations
    B->>C: Cache result
    B-->>F: Products + Recommendations
```

---

## Shared Packages

| Package | Purpose | Used By |
|---------|---------|---------|
| `@ecom/types` | TypeScript types | Frontend, Backend |
| `@ecom/ui` | React components | Frontend |
| `@ecom/utils` | Utility functions | All services |

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [PRINCIPLES.md](./PRINCIPLES.md) - Patterns and conventions
- [CLOUD.md](./CLOUD.md) - Infrastructure and deployment
