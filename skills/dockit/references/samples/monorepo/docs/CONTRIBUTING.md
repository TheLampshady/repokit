# Contributing

Development workflow and contribution guidelines for the E-Commerce Platform.

---

## Getting Started

1. Clone the repo and install dependencies:
   ```bash
   git clone https://github.com/org/ecom-platform.git
   cd ecom-platform
   pnpm install
   ```

2. Start local development:
   ```bash
   docker-compose up -d postgres redis
   pnpm dev
   ```

3. Verify everything works:
   ```bash
   pnpm test
   ```

> See [ENVIRONMENTS.md](./ENVIRONMENTS.md) for detailed setup.

---

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feat/your-feature
# or
git checkout -b fix/your-bugfix
```

### 2. Make Changes

- Write code following [PRINCIPLES.md](./PRINCIPLES.md)
- Add tests for new functionality
- Update docs if needed

### 3. Run Checks

```bash
pnpm lint        # ESLint + Prettier
pnpm typecheck   # TypeScript
pnpm test        # All tests
```

### 4. Commit

Use conventional commits:

```bash
git commit -m "feat(backend): add order cancellation endpoint"
git commit -m "fix(frontend): resolve cart total calculation"
git commit -m "docs: update API authentication guide"
```

| Prefix | Use For |
|--------|---------|
| `feat` | New features |
| `fix` | Bug fixes |
| `docs` | Documentation |
| `refactor` | Code changes that don't add features or fix bugs |
| `test` | Adding or fixing tests |
| `chore` | Maintenance tasks |

### 5. Push and Create PR

```bash
git push -u origin feat/your-feature
```

Then create a PR on GitHub.

---

## Pull Request Process

### PR Requirements

- [ ] Tests pass (`pnpm test`)
- [ ] Lint passes (`pnpm lint`)
- [ ] Types check (`pnpm typecheck`)
- [ ] Docs updated (if API changed)
- [ ] Conventional commit messages

### Review Process

1. **Auto-checks** — CI runs tests, lint, typecheck
2. **Code review** — Requires 1 approval from service owner
3. **Merge** — Squash and merge to `main`

### Service Owners

| Service | Owner | Backup |
|---------|-------|--------|
| Frontend | @frontend-lead | @senior-dev |
| Backend | @backend-lead | @senior-dev |
| Recommendations | @ml-lead | @backend-lead |
| Infrastructure | @devops-lead | @backend-lead |

---

## Working with Services

### Running a Single Service

```bash
pnpm --filter frontend dev
pnpm --filter backend dev
pnpm --filter recommendations dev
```

### Running Tests for a Service

```bash
pnpm --filter frontend test
pnpm --filter backend test
```

### Adding Dependencies

```bash
# To a specific service
pnpm --filter backend add express

# To a shared package
pnpm --filter @ecom/utils add lodash

# Dev dependency
pnpm --filter frontend add -D vitest
```

---

## Testing

Run tests before submitting:

```bash
pnpm test
```

| Flag | Description |
|------|-------------|
| `--filter frontend` | Frontend tests only |
| `--filter backend` | Backend tests only |
| `--coverage` | Generate coverage report |

> See [PRINCIPLES.md](./PRINCIPLES.md) for testing patterns and requirements.

---

## Release Process

Releases are automated via tags:

```bash
# Create a release
git tag v1.2.3
git push origin v1.2.3
```

This triggers:
1. Build all services
2. Run full test suite
3. Deploy to production
4. Create GitHub release

---

## Getting Help

- **Questions** — Ask in #ecom-platform Slack
- **Bugs** — Create a GitHub issue
- **Security** — Email security@company.com (don't create public issues)

---

## Related Documentation

- [PRINCIPLES.md](./PRINCIPLES.md) - Coding standards and patterns
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Local setup
