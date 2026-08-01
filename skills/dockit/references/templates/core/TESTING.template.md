# Testing

Comprehensive testing guide including organization, patterns, and CI integration.

## Table of Contents

- [Overview](#overview)
- [Test Organization](#test-organization)
- [Running Tests](#running-tests)
- [Testing Patterns](#testing-patterns)
- [Fixtures and Factories](#fixtures-and-factories)
- [Mocking](#mocking)
- [Coverage](#coverage)
- [CI Integration](#ci-integration)

---

## Overview

[TESTING_OVERVIEW]
<!-- Testing philosophy and approach for this project -->

| Attribute | Value |
|-----------|-------|
| Test Framework | [TEST_FRAMEWORK] |
| Coverage Target | [COVERAGE_TARGET] |
| CI Integration | [CI_INTEGRATION] |

---

## Test Organization

[TEST_ORG_CONTEXT]
<!-- How tests are structured -->

```
tests/
├── conftest.py              # Shared fixtures
├── unit/                    # Pure function tests
│   ├── test_services.py
│   └── test_utils.py
├── integration/             # Database/API tests
│   ├── test_api.py
│   └── test_models.py
├── e2e/                     # End-to-end tests
│   └── test_workflows.py
└── fixtures/                # Test data
    ├── factories.py
    └── data/
```

### Test Types

| Type | Location | Purpose | Speed |
|------|----------|---------|-------|
| Unit | `tests/unit/` | Pure logic, no I/O | Fast |
| Integration | `tests/integration/` | DB, APIs, services | Medium |
| E2E | `tests/e2e/` | Full workflows | Slow |

---

## Running Tests

### All Tests

```bash
[TEST_ALL_CMD]
```

### By Type

```bash
# Unit tests only
[TEST_UNIT_CMD]

# Integration tests only
[TEST_INTEGRATION_CMD]

# E2E tests only
[TEST_E2E_CMD]
```

### Specific Tests

```bash
# Single test file
[TEST_FILE_CMD]

# Single test function
[TEST_FUNCTION_CMD]

# Tests matching pattern
[TEST_PATTERN_CMD]
```

### Test Markers

| Marker | Purpose | Usage |
|--------|---------|-------|
[TEST_MARKERS_TABLE]

---

## Testing Patterns

[PATTERNS_CONTEXT]
<!-- Core testing patterns used in this project -->

### Arrange-Act-Assert

```[LANGUAGE]
[AAA_EXAMPLE]
```

### Given-When-Then (BDD)

```[LANGUAGE]
[GWT_EXAMPLE]
```

### What to Test

| Component | What to Test | What NOT to Test |
|-----------|--------------|------------------|
[WHAT_TO_TEST_TABLE]

---

## Fixtures and Factories

[FIXTURES_CONTEXT]

### Using Fixtures

```[LANGUAGE]
[FIXTURE_USAGE_EXAMPLE]
```

### Creating Factories

```[LANGUAGE]
[FACTORY_EXAMPLE]
```

### Shared Fixtures

| Fixture | Purpose | Scope |
|---------|---------|-------|
[FIXTURES_TABLE]

---

## Mocking

[MOCKING_CONTEXT]
<!-- When and how to mock -->

### Mock External Services

```[LANGUAGE]
[MOCK_EXTERNAL_EXAMPLE]
```

### Mock Database

```[LANGUAGE]
[MOCK_DB_EXAMPLE]
```

### What to Mock

| Always Mock | Never Mock |
|-------------|------------|
[MOCK_GUIDELINES_TABLE]

---

## Coverage

[COVERAGE_CONTEXT]

### Running Coverage

```bash
[COVERAGE_CMD]
```

### Coverage Requirements

| Metric | Minimum | Target |
|--------|---------|--------|
| Line coverage | [MIN_LINE] | [TARGET_LINE] |
| Branch coverage | [MIN_BRANCH] | [TARGET_BRANCH] |

### Excluding from Coverage

```[LANGUAGE]
[COVERAGE_EXCLUDE_EXAMPLE]
```

---

## CI Integration

[CI_CONTEXT]

### CI Pipeline Tests

```yaml
[CI_TEST_CONFIG]
```

### Test Parallelization

[PARALLELIZATION_CONTEXT]

### Flaky Test Handling

[FLAKY_TEST_CONTEXT]

---

## Debugging Tests

### Verbose Output

```bash
[VERBOSE_TEST_CMD]
```

### Debugging with PDB

```[LANGUAGE]
[PDB_EXAMPLE]
```

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
[TEST_ISSUES_TABLE]

---

## Related Documentation

- [Principles Overview](../PRINCIPLES.md)
- [Patterns](./PATTERNS.md)
- [Contributing](../CONTRIBUTING.md)
