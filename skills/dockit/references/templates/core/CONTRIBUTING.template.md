# Contributing

## Development Workflow

```
[WORKFLOW_DIAGRAM]
```

## Quick Start

```bash
# 1. Clone and setup
[CLONE_SETUP_COMMANDS]

# 2. Create branch
git checkout -b [BRANCH_PREFIX]/your-feature

# 3. Make changes and test
[TEST_COMMANDS]

# 4. Commit and push
git add .
git commit -m "[COMMIT_PREFIX]: your message"
git push -u origin HEAD

# 5. Create PR
[PR_COMMAND]
```

## Branch Naming

**Format**: `[BRANCH_FORMAT]`

| Prefix | Use For |
|--------|---------|
[BRANCH_PREFIXES_TABLE]

**Examples**:
```
[BRANCH_EXAMPLES]
```

## Commit Messages

**Format**: `[COMMIT_FORMAT]`

| Prefix | Use For |
|--------|---------|
[COMMIT_PREFIXES_TABLE]

**Examples**:
```
[COMMIT_EXAMPLES]
```

## Code Review

### Before Submitting

- [ ] Tests pass locally: `[TEST_CMD]`
- [ ] Linting passes: `[LINT_CMD]`
- [ ] Code is formatted: `[FORMAT_CMD]`
- [ ] Documentation updated (if applicable)
- [ ] No console.logs or debug code
[ADDITIONAL_PR_CHECKS]

### Review Process

[REVIEW_PROCESS_DESCRIPTION]

### Review Checklist

Reviewers will check:
- [ ] Code follows project conventions
- [ ] Tests cover new functionality
- [ ] No security vulnerabilities introduced
- [ ] Performance impact considered
- [ ] Breaking changes documented

## By Role

### Frontend Developers

**Key Directories**:
```
[FRONTEND_DIRS]
```

**Commands**:
```bash
# Run frontend only
[FRONTEND_RUN_CMD]

# Run frontend tests
[FRONTEND_TEST_CMD]

# Build frontend
[FRONTEND_BUILD_CMD]
```

**Guidelines**:
[FRONTEND_GUIDELINES]

---

### Backend Developers

**Key Directories**:
```
[BACKEND_DIRS]
```

**Commands**:
```bash
# Run backend only
[BACKEND_RUN_CMD]

# Run backend tests
[BACKEND_TEST_CMD]

# Run migrations
[BACKEND_MIGRATE_CMD]
```

**Guidelines**:
[BACKEND_GUIDELINES]

---

### DevOps / SRE

**Key Directories**:
```
[DEVOPS_DIRS]
```

**Commands**:
```bash
# Deploy to staging
[DEPLOY_STAGING_CMD]

# Check infrastructure
[INFRA_STATUS_CMD]

# View logs
[LOGS_CMD]
```

**Guidelines**:
[DEVOPS_GUIDELINES]

---

### QA Engineers

**Key Directories**:
```
[QA_DIRS]
```

**Commands**:
```bash
# Run all tests
[ALL_TESTS_CMD]

# Run E2E tests
[E2E_TESTS_CMD]

# Generate coverage
[COVERAGE_CMD]
```

**Guidelines**:
[QA_GUIDELINES]

## Style Guides

| Language | Guide | Enforced By |
|----------|-------|-------------|
[STYLE_GUIDES_TABLE]

## Release Process

[RELEASE_PROCESS_DESCRIPTION]

### Creating a Release

```bash
[RELEASE_COMMANDS]
```

## Questions & Support

| Need | Contact |
|------|---------|
| Code questions | [CODE_SUPPORT] |
| Process questions | [PROCESS_SUPPORT] |
| Urgent issues | [URGENT_SUPPORT] |

## Related Documentation

- [README.md](../README.md) - Project overview
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues
- [PRINCIPLES.md](../PRINCIPLES.md) - Project conventions
