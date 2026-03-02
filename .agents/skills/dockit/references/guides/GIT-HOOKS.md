# Git Hooks Integration

How dockit integrates with git for automatic documentation sync checking.

## Overview

Dockit provides a `check` mode designed for CI/pre-commit hooks that validates documentation freshness without making changes.

---

## Check Mode

**Purpose:** Detect documentation drift without making changes.

**Behavior:**
- Read-only - never modifies files
- No prompts - runs silently
- Returns exit codes for CI integration

### Exit Codes

| Code | Meaning | CI Action |
|------|---------|-----------|
| `0` | Documentation is current | Pass |
| `1` | Documentation is stale | Fail |

---

## Git Diff Detection

Dockit detects which files have changed since the last documentation update:

```bash
LAST_SYNC=$(git log -1 --format=%H -- docs/ README.md)
CHANGED=$(git diff --name-only $LAST_SYNC HEAD)
```

### Change Mapping

| Changed Files | Stale Documentation |
|---------------|---------------------|
| package.json, pyproject.toml | README.md |
| src/, lib/, app/ | ARCHITECTURE.md + diagrams |
| .env*, config/ | ENVIRONMENTS.md |
| infra/, .github/ | CLOUD.md |
| .specify/memory/constitution.md | PRINCIPLES.md |

---

## Pre-Commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: dockit-check
        name: Check documentation freshness
        entry: claude /dockit check
        language: system
        pass_filenames: false
        always_run: true
```

Or manually in `.git/hooks/pre-commit`:

```bash
#!/bin/bash
claude /dockit check
if [ $? -ne 0 ]; then
    echo "Documentation is stale. Run 'claude /dockit sync' to update."
    exit 1
fi
```

---

## CI Integration

### GitHub Actions

```yaml
name: Documentation Check

on: [push, pull_request]

jobs:
  docs-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check documentation freshness
        run: |
          # Install claude CLI
          npm install -g @anthropic-ai/claude-code

          # Run dockit check
          claude /dockit check
```

### GitLab CI

```yaml
docs-check:
  stage: validate
  script:
    - npm install -g @anthropic-ai/claude-code
    - claude /dockit check
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
```

---

## Check Mode Output

When documentation is **current**:

```
─────────────────────────────────────────
✓ dockit check
─────────────────────────────────────────

Documentation is current.
Last sync: 2024-01-15 (commit abc123)

─────────────────────────────────────────
```

When documentation is **stale**:

```
─────────────────────────────────────────
✗ dockit check
─────────────────────────────────────────

Documentation is stale.

Changed since last sync:
  • src/api/routes.py
  • src/models/user.py

Affected documentation:
  ○ docs/ARCHITECTURE.md (data models changed)
  ○ docs/ARCHITECTURE.md (routes changed)

Run 'claude /dockit sync' to update.

─────────────────────────────────────────
```

Exit code: `1`

---

## Sync After Check Fails

When check fails, run sync to update documentation:

```bash
claude /dockit sync
```

Sync mode:
- Adds or updates stale sections
- Never removes content
- Regenerates diagrams if architecture changed
- Runs without prompts

---

## CI Workflow Recommendation

1. **PR checks:** Run `check` mode to validate
2. **On failure:** Developer runs `sync` locally
3. **Commit:** Updated docs included in PR
4. **Merge:** Documentation stays current

```
PR opened → dockit check → Pass? → Merge
                 ↓
              Fail
                 ↓
         Run dockit sync
                 ↓
           Commit docs
                 ↓
              Re-push
```

---

## Auto-Sync Option

For teams that prefer automatic updates, configure CI to run sync on the main branch:

```yaml
# Only on main branch pushes
on:
  push:
    branches: [main]

jobs:
  docs-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Sync documentation
        run: claude /dockit sync

      - name: Commit if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add docs/ README.md
          git diff --staged --quiet || git commit -m "docs: auto-sync documentation"
          git push
```

**Warning:** Auto-sync can create noise in commit history. Manual sync is recommended for most teams.
