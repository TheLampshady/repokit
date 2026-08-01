# Principles

Decisions this project has made that an agent or a new contributor would not guess.

> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.

---

## Conventions

**Import `db` from `@ecom/utils/db`.** Don't construct a `PrismaClient`. Exceptions: `packages/utils/src/db.ts`, `scripts/seed.ts`.
<!-- dockit:check cmd="grep -rlE 'new PrismaClient' apps/ packages/ | grep -v 'packages/utils/src/db.ts' | wc -l" expect="0" last="2026-08-01" -->

<details><summary>Why</summary>

Each `new PrismaClient()` opens its own pool. Four of them in the same Cloud Run instance
exhausted Postgres connections under normal load.
Rejected: a max-clients env cap — it turns the failure into a slow one rather than removing it.
</details>

**Return API responses through `success()` / `error()` from `@ecom/utils/response`.** Not bare `res.json()`.
<!-- dockit:conform cmd="grep -lE 'from .@ecom/utils/response' apps/backend/src/routes/*.ts | wc -l" total="grep -lE 'router\.(get|post|put|delete)' apps/backend/src/routes/*.ts | wc -l" min="80%" last="2026-08-01" -->

[TODO: why?]

**Read environment variables through `config` from `@ecom/utils/config`.** Not `process.env`. Exceptions: `packages/utils/src/config.ts`, `*.config.ts` build files.
<!-- dockit:check cmd="grep -rlE 'process\.env\.' apps/ packages/ | grep -v '*.config.ts' | grep -v 'packages/utils/src/config.ts' | wc -l" expect="0" last="2026-08-01" -->

<details><summary>Why</summary>

`config` validates the whole environment at startup, so a missing variable fails the
container immediately instead of throwing on the first request that needs it.
Rejected: runtime `??` defaults — they mask a misconfigured deploy as working.
</details>

**Import shared domain types from `@ecom/types`.** Don't redeclare them locally.
<!-- dockit:check cmd="grep -rlE 'interface (Product|Order|User|Cart)\b' apps/ | grep -v 'packages/types' | wc -l" expect="0" last="2026-08-01" -->

[TODO: why?]

**API routes are kebab-case under a `/api/v1/` prefix.** Pagination is `?page=&limit=`.
<!-- dockit:conform cmd="grep -rhoE '/api/v1/[a-z0-9-]+' apps/backend/src | wc -l" total="grep -rhoE 'router\.(get|post|put|delete)' apps/backend/src | wc -l" min="80%" last="2026-08-01" -->

[TODO: why?]

**Server state goes through React Query.** Don't fetch in `useEffect`.
<!-- dockit:check cmd="grep -rlE 'useEffect\(\(\) => \{[^}]*fetch\(' apps/frontend/src | wc -l" expect="0" last="2026-08-01" -->

[TODO: why?]

---

## Rules

**Every non-public endpoint requires authentication.** Public routes are listed explicitly in `apps/backend/src/middleware/public-routes.ts`.
<!-- dockit:check cmd="grep -LE 'requireAuth|isPublicRoute' apps/backend/src/routes/*.ts | wc -l" expect="0" last="2026-08-01" -->

<details><summary>Why</summary>

An unauthenticated `/api/v1/orders` shipped in the 2025 Black Friday release and exposed
order history across accounts.
Rejected: auth-by-default middleware — public routes then become invisible omissions
instead of an explicit list someone reviews.
</details>

**Validate every request body with a Zod schema before it reaches a service.**
<!-- dockit:conform cmd="grep -lE 'z\.object' apps/backend/src/routes/*.ts | wc -l" total="grep -lE 'router\.(get|post|put|delete)' apps/backend/src/routes/*.ts | wc -l" min="80%" last="2026-08-01" -->

[TODO: why?]

**Breaking API changes ship with a migration guide in `docs/migrations/`.**

[TODO: why?]

---

## Extending the codebase

| Adding a... | Do this |
|-------------|---------|
| Package | `pnpm create @ecom/<name>` → add to `pnpm-workspace.yaml` → add the path alias to the root `tsconfig.json` |
| Backend route | Add `apps/backend/src/routes/<name>.ts`, register it in `routes/index.ts`, add the Zod schema alongside |
| Shared type | Add to `packages/types/src/<domain>.ts` and export from the package index — never redeclare in a consumer |
| Frontend page | Add under `apps/frontend/src/app/<route>/page.tsx`; server component unless it needs browser state |
| ML endpoint | Add to `services/ml/app/routers/`, register in `main.py`, update the OpenAPI spec |

---

## Tech decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Monorepo tooling | pnpm workspaces | [TODO: why?] |
| Backend runtime | Node.js + Express | [TODO: why?] |
| ML service | Python + FastAPI, separate deploy | The recommender depends on libraries with no JS equivalent, and its memory profile would force the whole API to a larger instance class |
| Database | PostgreSQL | [TODO: why?] |
| Cache and events | Redis | [TODO: why?] |
| Cloud | GCP Cloud Run | [TODO: why?] |
| IaC | Terraform | [TODO: why?] |

---

## Related documentation

- [README.md](../README.md) — project overview
- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design
- [CONTRIBUTING.md](./CONTRIBUTING.md) — development workflow, test commands, setup
