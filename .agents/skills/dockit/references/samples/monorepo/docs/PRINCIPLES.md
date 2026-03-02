# Principles

Project patterns, architectural decisions, and guidelines for consistent development. This document serves both human developers and AI tools.

---

## Service Patterns

### Database Access

Always use the shared database client from `@ecom/utils`:

```typescript
// ✅ YES - use the shared client
import { db } from '@ecom/utils/db'
const users = await db.user.findMany()

// ❌ NO - bypasses connection pooling and config
import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()
```

**Why:** The shared client handles connection pooling, logging, and environment-specific configuration.

### API Responses

Always use the response helpers for consistent formatting:

```typescript
// ✅ YES - consistent response format
import { success, error } from '@ecom/utils/response'
return success(data)
return error('Not found', 404)

// ❌ NO - inconsistent formats
res.json({ data })
res.status(404).send({ error: 'Not found' })
```

**Why:** Consistent response format makes client-side error handling predictable.

### Environment Variables

Access env vars through the config module:

```typescript
// ✅ YES - typed and validated
import { config } from '@ecom/utils/config'
const dbUrl = config.DATABASE_URL

// ❌ NO - untyped, may be undefined
const dbUrl = process.env.DATABASE_URL
```

**Why:** Config validates at startup and provides TypeScript types.

### Shared Types

Import types from `@ecom/types`, never duplicate:

```typescript
// ✅ YES - single source of truth
import { Product, Order } from '@ecom/types'

// ❌ NO - will drift out of sync
interface Product {
  id: string
  name: string
}
```

**Why:** Shared types ensure frontend and backend stay in sync.

---

## Testing Approach

### Test Organization

```
service/
├── src/
│   └── orders/
│       ├── orders.service.ts
│       └── orders.service.test.ts   # Co-located unit tests
└── tests/
    ├── integration/                  # API tests
    │   └── orders.test.ts
    └── fixtures/                     # Shared test data
        └── orders.ts
```

### Testing Patterns

| Pattern | When to Use |
|---------|-------------|
| Unit tests | Pure functions, business logic |
| Integration tests | API endpoints, database operations |
| E2E tests | Critical user flows (checkout, auth) |

### What to Test

| Component | Test | Don't Test |
|-----------|------|------------|
| Services | Business logic, edge cases | Framework internals |
| API routes | Request/response, auth, validation | Third-party libraries |
| React components | User interactions, state | Implementation details |

### Running Tests

```bash
# All tests
pnpm test

# Single service
pnpm --filter backend test

# Watch mode
pnpm --filter frontend test:watch

# Coverage
pnpm test --coverage
```

### Test Requirements

- All new features require tests
- Critical paths require E2E tests
- Coverage must not decrease

---

## Tech Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Monorepo | pnpm workspaces | Shared code, atomic changes |
| Frontend | React + TypeScript | Team expertise, type safety |
| Backend | Node.js + Express | JavaScript ecosystem consistency |
| ML Service | Python + FastAPI | ML library ecosystem |
| Database | PostgreSQL | ACID, JSON support, familiarity |
| Cache | Redis | Performance, pub/sub for events |
| Cloud | GCP | Existing relationship, Cloud Run |
| IaC | Terraform | Team expertise, state management |

---

## Conventions

### Naming

| Element | Convention | Example |
|---------|------------|---------|
| React components | PascalCase | `ProductCard.tsx` |
| TypeScript files | camelCase | `productService.ts` |
| Python files | snake_case | `product_recommender.py` |
| API routes | kebab-case | `/api/v1/product-categories` |
| Database tables | snake_case | `order_items` |
| Environment vars | UPPER_SNAKE | `DATABASE_URL` |

### File Organization

- Feature-based folder structure in frontend
- Route-based organization in backend
- Shared types in `packages/types`
- Shared UI in `packages/ui`

### API Design

- RESTful for CRUD operations
- Version prefix: `/api/v1/`
- Pagination via `?page=&limit=`
- Consistent error response format

---

## Non-Negotiables

> These rules are mandatory. Violations should block PRs.

### Security

- [ ] No secrets in code or version control
- [ ] All user input validated (Zod on backend, React Hook Form on frontend)
- [ ] Authentication required on all non-public endpoints
- [ ] HTTPS only in all environments

### Code Quality

- [ ] ESLint must pass
- [ ] TypeScript strict mode enabled
- [ ] No `any` types without justification
- [ ] Prettier formatting enforced

### Testing

- [ ] All new features require tests
- [ ] Tests must pass before merge
- [ ] E2E tests for critical user flows

### Documentation

- [ ] API endpoints documented in OpenAPI
- [ ] Breaking changes require migration guide

---

## Preferences

Recommended but not enforced:

- Use React Query for server state
- Prefer server components where possible
- Keep components under 200 lines
- Use conventional commits

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development workflow
