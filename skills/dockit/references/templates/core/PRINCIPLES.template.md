# Principles

Project patterns, architectural decisions, and guidelines for consistent development. This document serves both human developers and AI tools.

---

## Service Patterns

[SERVICE_PATTERNS_CONTEXT]
<!-- Explain the service abstraction approach for this project -->

[REPEAT_FOR_EACH_SERVICE_PATTERN]
### [PATTERN_NAME]

[PATTERN_DESCRIPTION]

```[LANGUAGE]
# YES - [correct approach]
[CORRECT_EXAMPLE]

# NO - [incorrect approach]
[INCORRECT_EXAMPLE]
```

**Why:** [RATIONALE]

[END_REPEAT]

---

## Testing Approach

[TESTING_CONTEXT]
<!-- Explain the testing philosophy for this project -->

### Test Organization

[TEST_ORGANIZATION_DESCRIPTION]

```
[TEST_DIRECTORY_STRUCTURE]
```

### Testing Patterns

[TESTING_PATTERNS_LIST]
<!-- Patterns: mocking external services, fixtures, factories, etc. -->

### What to Test

| Type | Coverage | Example |
|------|----------|---------|
[TESTING_COVERAGE_TABLE]

### Running Tests

```bash
[TEST_COMMAND]
```

[IF_HAS_TEST_MARKERS]
| Marker | Purpose |
|--------|---------|
[TEST_MARKERS_TABLE]
[ENDIF]

---

## Architectural Decisions

[DECISIONS_CONTEXT]
<!-- Brief intro to why these decisions matter -->

| Decision | Choice | Rationale |
|----------|--------|-----------|
[DECISIONS_TABLE]

[IF_HAS_MAJOR_DECISIONS]
[REPEAT_FOR_MAJOR_DECISIONS]
### [DECISION_NAME]

**Context:** [DECISION_CONTEXT]

**Decision:** [WHAT_WE_CHOSE]

**Rationale:** [WHY_WE_CHOSE_IT]

[END_REPEAT]
[ENDIF]

---

## Code Conventions

[CONVENTIONS_CONTEXT]
<!-- Brief intro to coding standards -->

### General

- [CONVENTION_1]
- [CONVENTION_2]
- [CONVENTION_3]

[IF_HAS_LANGUAGE_CONVENTIONS]
### [LANGUAGE]-Specific

- [LANGUAGE_CONVENTION_1]
- [LANGUAGE_CONVENTION_2]
[ENDIF]

[IF_HAS_DOCSTRING_FORMAT]
### Documentation Format

```[LANGUAGE]
[DOCSTRING_EXAMPLE]
```
[ENDIF]

---

## Non-Negotiables

> These rules are mandatory. Violations should block PRs.

- [ ] [NON_NEGOTIABLE_1]
- [ ] [NON_NEGOTIABLE_2]
- [ ] [NON_NEGOTIABLE_3]

---

## Related Documentation

- [README.md](../README.md) - Project overview and quick start
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design and diagrams
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development workflow
