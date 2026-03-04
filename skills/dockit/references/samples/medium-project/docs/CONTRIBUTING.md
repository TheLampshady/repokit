# Contributing

Guidelines for contributing to the Task Manager API.

---

## Development Setup

```bash
git clone <repo>
cd task-manager
make setup
make db-start
cp .env.example .env
make migrate
make run
```

> See [ENVIRONMENTS.md](./ENVIRONMENTS.md) for detailed environment configuration.

---

## Workflow

1. Create a feature branch from `main`
2. Make your changes
3. Run tests: `make test`
4. Run linting: `make lint`
5. Commit with proper format
6. Submit a pull request

---

## Branch Naming

**Format:** `type/description`

| Prefix | Use For |
|--------|---------|
| `feat/` | New features |
| `fix/` | Bug fixes |
| `refactor/` | Code refactoring |
| `docs/` | Documentation |
| `test/` | Test additions |

**Examples:**
```
feat/workspace-invites
fix/task-due-date-validation
refactor/service-layer
```

---

## Commit Messages

**Format:** `type: description`

| Prefix | Use For |
|--------|---------|
| `feat:` | New features |
| `fix:` | Bug fixes |
| `refactor:` | Code refactoring |
| `docs:` | Documentation |
| `test:` | Test changes |
| `chore:` | Maintenance |

**Examples:**
```
feat: add workspace invite functionality
fix: validate due date is in future
refactor: extract task service from routes
```

---

## Pull Request Process

### Before Submitting

- [ ] Tests pass: `make test`
- [ ] Linting passes: `make lint`
- [ ] No debug code or print statements
- [ ] Documentation updated if needed
- [ ] Migrations included if schema changed

### PR Description

Include:
- What changed and why
- How to test
- Screenshots for UI changes
- Migration notes if applicable

### Review

- PRs require 1 approval
- CI must pass
- Reviewer will check: code quality, tests, security

---

## Testing

Run tests before submitting any changes:

```bash
make test           # All tests
make test-unit      # Unit tests only
make test-cov       # With coverage report
```

> See [PRINCIPLES.md](./PRINCIPLES.md) for testing patterns and approach.

---

## Code Style

- Run `make lint` before committing
- Run `make format` to auto-fix formatting
- Follow patterns in [PRINCIPLES.md](./PRINCIPLES.md)

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [PRINCIPLES.md](./PRINCIPLES.md) - Patterns and conventions
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
