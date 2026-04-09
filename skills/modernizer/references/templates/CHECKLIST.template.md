# AI Readiness Checklist

> Generated: [DATE]
> Project: [PROJECT_NAME]
> Primary Language: [PRIMARY_LANGUAGE]
> Secondary Languages: [SECONDARY_LANGUAGES or "None"]

## Overall Score: [OVERALL_SCORE]/10

| Category | Score | Status |
|----------|-------|--------|
| Documentation | [DOC_SCORE]/10 | [DOC_STATUS] |
| Package Management | [PKG_SCORE]/10 | [PKG_STATUS] |
| Testing | [TEST_SCORE]/10 | [TEST_STATUS] |
| Code Quality | [QUALITY_SCORE]/10 | [QUALITY_STATUS] |
| Code Patterns | [PATTERNS_SCORE]/10 | [PATTERNS_STATUS] |

## Quick Summary

[2-3_SENTENCE_SUMMARY]

## Available Executors

| Executor | Type | Can Help With |
|----------|------|---------------|
[EXECUTOR_TABLE]

## Task Overview

| ID | Task | Priority | Executor | Status |
|----|------|----------|----------|--------|
[TASK_TABLE]

---

## Detailed Checklist

### Documentation
- [ ] README.md comprehensive
- [ ] AI instruction file exists (CLAUDE.md, etc.)
- [ ] Architecture documented
- [ ] Setup instructions clear
- [ ] API documentation (if applicable)

### Package Management
- [ ] Modern package manager (uv for Python, pnpm for JS)
- [ ] Lock file present
- [ ] Dependencies pinned appropriately
- [ ] Dev dependencies separated
- [ ] No legacy tooling (requirements.txt only, etc.)

### Testing
- [ ] Test directory exists
- [ ] pytest configured (Python)
- [ ] Network isolation enabled (pytest-socket)
- [ ] Async support configured (if needed)
- [ ] Coverage configured
- [ ] Test markers defined (slow, integration)

### Code Quality
- [ ] Pre-commit hooks installed
- [ ] Linter configured (ruff)
- [ ] Formatter configured (ruff)
- [ ] Type checker configured (ty or mypy)
- [ ] Commit template configured

### Code Patterns
- [ ] Type hints on all functions
- [ ] Consistent naming conventions
- [ ] Docstrings on public APIs
- [ ] Reasonable file sizes (<500 lines)

---

## Next Steps

1. Review task files in `specs/tickets/`
2. Prioritize based on project needs
3. Run recommended executors or implement manually
4. Re-run `/modernizer` to verify improvements

## speckit Integration

[IF_SPECKIT_AVAILABLE]
Tasks can be converted to speckit tickets. Run:
```
/speckit.taskstoissues specs/tickets/
```
[ENDIF]

[IF_NO_SPECKIT]
speckit not detected. Tasks are standalone markdown files.
[ENDIF]
