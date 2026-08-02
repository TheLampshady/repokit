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
| .specify/memory/constitution.md, openspec/project.md, conductor/workflow.md | PRINCIPLES.md — compare and report only, never merge |

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
- Removes doc sections for code that no longer exists, and reports each removal in chat
- Regenerates diagrams if architecture changed
- Runs without prompts, except for prose-heavy deletions

**Run sync by hand, never from a hook or CI job.** Sync deletes, and its only safeguard is the change report it prints at the end — which requires a human reading it. Automated, that report goes nowhere and content disappears unattended. Hooks and CI run `check` only.

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

## Why There Is No Auto-Sync

Automating `sync` in CI or a hook is deliberately not offered.

Sync removes doc sections when the code behind them is gone. The safeguard is the change report it prints at the end — every move, removal, and untouched section named individually, closing with an offer to amend. That safeguard is a human reading it.

Run it from a bot and the report is written to a log nobody opens. Content gets deleted, the commit says `docs: auto-sync`, and the first person to notice is whoever needed the missing section.

Automate `check` instead. It's read-only, it fails the build when docs go stale, and a developer then runs `sync` locally where the report reaches someone who can act on it.
