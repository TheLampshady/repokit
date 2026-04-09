---
name: repokit
description: 'Codebase maintenance hub — check repo health, sync docs and tickets after changes, run deep audits, or bootstrap a new project. Use when asked to: see repo status, check repo health, sync after changes, audit the codebase, run maintenance, bootstrap repokit, what needs attention, show open tickets, or list repokit tools. Modes: status, sync, audit, init.'
user-invocable: true
---

# repokit

Codebase maintenance hub. Orchestrates repokit's skills and agents into coherent workflows.

**Modes:** `status` | `sync` | `audit` | `init` | _(bare — tool menu)_

> **Core principle:** repokit orchestrates, never duplicates. Each mode delegates to existing skills and agents rather than reimplementing their logic.

---

## Auto-Detection

When invoked bare (`/repokit` with no mode), detect what the user likely needs:

| Condition | Suggest |
|-----------|---------|
| No `docs/` or `README.md` and no `specs/` | → `init` |
| `specs/backlog.md` has open items | → `status` (show what needs attention) |
| Git changes since last doc sync | → `sync` |
| User asks "what can repokit do" | → show tool menu |
| Otherwise | → show tool menu with live status summary |

Always show the tool menu as a fallback, but lead with a recommendation when the project state suggests a specific mode.

---

## Tool Menu (bare invocation or when guiding)

When showing the menu, enhance it with live status if `specs/` or `docs/` exist.

### Gather Status Counts

```bash
# Open backlog items
grep -c '^\- \[ \]' specs/backlog.md 2>/dev/null || echo "0"

# Pending tickets
ls specs/tickets/*.md 2>/dev/null | wc -l

# Doc staleness (commits since last doc touch)
git rev-list --count $(git log -1 --format=%H -- docs/ README.md 2>/dev/null || echo HEAD)..HEAD 2>/dev/null || echo "?"
```

### Menu Format

```
## repokit — Codebase Maintenance Toolkit

| Tool | Type | When to Use |
|------|------|-------------|
| `/repokit status` | Mode | Dashboard — see repo health, open tickets, doc freshness |
| `/repokit sync` | Mode | After code changes — refresh docs, clean up tickets |
| `/repokit audit` | Mode | Deep review — full codebase analysis with findings report |
| `/repokit init` | Mode | First-time setup — bootstrap docs, quality checks, tickets |
| `/repokit:dockit` | Skill | Generate or sync project documentation |
| `/repokit:modernizer` | Skill | Audit tooling and generate modernization tickets |
| `/repokit:onboard` | Skill | Onboard a new team member |
| `/repokit:agentkit` | Skill | Generate project-level AI agents |
| `sanity-checker` | Agent | Lint, format, typecheck, test (auto-triggers after code changes) |
| `auditor` | Agent | Find outdated code and stale practices (auto-triggers for reviews) |

[If status counts available:]
📋 **Open items:** [N] in backlog | [M] pending tickets
📄 **Docs:** [X] commits since last update
```

---

## Mode: `status`

**Trigger:** `/repokit status`
**Purpose:** Read-only dashboard of repo health. Quick, no prompts, no changes.

### What to check

Run these checks and present a unified dashboard:

#### 1. Backlog & Tickets

```bash
# Read backlog
cat specs/backlog.md 2>/dev/null

# Count by tag
grep -o '\[.*\]' specs/backlog.md 2>/dev/null | sort | uniq -c

# Count open vs completed
grep -c '^\- \[ \]' specs/backlog.md 2>/dev/null  # open
grep -c '^\- \[x\]' specs/backlog.md 2>/dev/null  # done

# Pending ticket files
ls specs/tickets/*.md 2>/dev/null
```

#### 2. Documentation Freshness

```bash
# Last doc change
git log -1 --format="%cr (%h)" -- docs/ README.md 2>/dev/null

# Last code change
git log -1 --format="%cr (%h)" -- src/ lib/ app/ *.py *.ts *.js *.go *.rs 2>/dev/null

# Files changed since last doc sync
LAST_DOC=$(git log -1 --format=%H -- docs/ README.md 2>/dev/null)
git diff --stat "$LAST_DOC"..HEAD -- src/ lib/ app/ 2>/dev/null | tail -1
```

#### 3. Code Quality Infrastructure

```bash
# Pre-commit hooks installed?
ls .git/hooks/pre-commit 2>/dev/null && echo "installed" || echo "not installed"

# Pre-commit config exists?
ls .pre-commit-config.yaml .config/.pre-commit-config.yaml 2>/dev/null

# Linter config?
ls .ruff.toml ruff.toml eslint.config.js .eslintrc* biome.json 2>/dev/null

# Type checking?
ls tsconfig.json mypy.ini .mypy.ini 2>/dev/null
grep -l "mypy\|pyright" pyproject.toml 2>/dev/null

# CI pipeline?
ls .github/workflows/*.yml 2>/dev/null
```

#### 4. Last Tool Runs

```bash
# When was modernizer last run? (proxy: last specs/ change)
git log -1 --format="%cr" -- specs/ 2>/dev/null || echo "never"

# When was dockit last run? (proxy: last docs/ change with dockit patterns)
git log -1 --format="%cr" -- docs/ 2>/dev/null || echo "never"
```

### Output Format

```
## Repo Health Dashboard

| Area | Status | Details |
|------|--------|---------|
| Backlog | 🟡 3 open | 1 modernizer, 1 auditor, 1 manual |
| Tickets | 📋 2 pending | specs/tickets/ |
| Docs | 🟢 Fresh | Last updated 2 days ago (14 code commits since) |
| Pre-commit | 🟢 Installed | .pre-commit-config.yaml present |
| Linting | 🟢 Configured | ruff |
| Type checking | 🔴 Missing | No mypy/pyright config found |
| CI | 🟢 Present | 2 workflows |
| Last audit | 🟡 3 weeks ago | Consider running `/repokit audit` |

### Open Backlog Items
- [ ] Add type checking `[modernizer]` → tickets/004-type-checking.md
- [ ] Update ARCHITECTURE.md `[dockit]` → tickets/007-arch-docs.md
- [ ] Fix flaky auth test `[manual]`

### Suggested Next Steps
1. Run `/repokit sync` — docs are 14 commits behind
2. Address P1 ticket: 004-type-checking.md
```

Use 🟢 for healthy, 🟡 for needs attention, 🔴 for missing/broken. Adapt the checks to whatever project structure exists — not all projects will have all of these.

---

## Mode: `sync`

**Trigger:** `/repokit sync`
**Purpose:** Post-change refresh. Bring docs and tickets up to date after code changes.

This mode is non-destructive and requires minimal interaction. It runs the lightweight maintenance tasks that should happen after any significant code change.

### Execution Flow

#### Step 1: Assess what changed

```bash
# What changed since last doc sync?
LAST_DOC=$(git log -1 --format=%H -- docs/ README.md 2>/dev/null)
git diff --name-only "$LAST_DOC"..HEAD 2>/dev/null | head -30

# What changed since last spec update?
LAST_SPEC=$(git log -1 --format=%H -- specs/ 2>/dev/null)
git diff --name-only "$LAST_SPEC"..HEAD 2>/dev/null | head -30
```

#### Step 2: Sync docs (delegate to dockit)

If code has changed since the last doc update, invoke `dockit sync`. This updates stale doc sections without prompting or restructuring.

Tell the user: "Running dockit sync to update documentation..."

Follow the dockit skill's `sync` mode — it handles git diff detection, section updates, and diagram regeneration.

#### Step 3: Refresh tickets (delegate to modernizer)

If `specs/tickets/` exists, invoke `modernizer status`. This:
- Checks if pending tickets have been resolved by recent code changes
- Cleans up completed tickets
- Updates `specs/CHECKLIST.md`

Tell the user: "Running modernizer status to refresh tickets..."

Follow the modernizer skill's `status` mode logic.

#### Step 4: Summary

Report what changed:

```
## Sync Complete

| Action | Result |
|--------|--------|
| Docs | Updated ARCHITECTURE.md (new service added) |
| Tickets | 2 completed and cleaned up, 3 remaining |
| Diagrams | Regenerated component diagram |

No further action needed.
```

If nothing needs syncing, say so: "Everything is up to date — no sync needed."

---

## Mode: `audit`

**Trigger:** `/repokit audit`
**Purpose:** Deep review of the entire codebase. Combines documentation audit, code quality analysis, and practice review into a single comprehensive report.

This is the "big review" mode — it takes longer and may prompt for preferences. Use for periodic health checks, onboarding review, or after major refactors.

### Execution Flow

#### Step 1: Scope

Ask the user what they want to audit (or run everything):

```
What would you like to audit?
1. **Everything** — full docs + code + tooling review
2. **Docs only** — documentation accuracy and freshness
3. **Code quality only** — tooling, testing, linting, patterns
4. **Tooling only** — dependency versions, outdated practices
```

Default to "everything" if the user doesn't specify.

#### Step 2: Run audits (delegate to specialized tools)

Based on scope, orchestrate the appropriate tools:

**Documentation audit:**
- Invoke `dockit audit` — verifies doc claims against codebase (file paths, commands, configs)
- Invoke `dockit check` — detects drift between docs and code

**Code quality & tooling audit:**
- Invoke `modernizer analyze` — full codebase analysis with scoring and ticket generation
- This internally handles: package management, testing, linting, code patterns, doc health

**Practice & staleness audit:**
- Trigger the `auditor` agent — reviews for outdated code, stale practices, deprecated patterns, automation gaps
- The auditor uses context7 and web search to verify against current best practices

Run these in parallel where possible. The auditor agent runs in its own context window, so it can work alongside modernizer.

#### Step 3: Aggregate findings

Combine outputs from all tools into a unified report. Don't just concatenate — synthesize:

```
## Audit Report

### Overall Health: 7/10

| Area | Score | Tool | Key Finding |
|------|-------|------|-------------|
| Documentation | 8/10 | dockit | 2 stale sections, 1 broken file reference |
| Package Management | 9/10 | modernizer | Modern tooling, lockfile present |
| Testing | 5/10 | modernizer | 60% coverage, no integration tests |
| Code Quality | 7/10 | modernizer | Linter configured, no type checking |
| Practices | 6/10 | auditor | 3 deprecated patterns found |

### Critical Findings (act now)
[From auditor 🔴 Critical tier + modernizer P1 items]

### Recommended Improvements
[From auditor 🟡 Recommended tier + modernizer P2 items]

### Informational
[From auditor 🔵 FYI tier + modernizer P3 items]

### Tickets Created
[List any new tickets written to specs/tickets/ by modernizer]

### Next Steps
1. [Most impactful action]
2. [Second priority]
3. Run `/repokit sync` after addressing findings
```

Deduplicate findings across tools — if both modernizer and auditor flag the same issue, merge them into one finding with both sources cited.

---

## Mode: `init`

**Trigger:** `/repokit init`
**Purpose:** Bootstrap repokit for a new project. Walks through first-time setup of docs, quality infrastructure, and maintenance workflows.

This is different from `audit` — init is about setting things up, not reviewing what exists. Use when adopting repokit on a project for the first time.

### Execution Flow

#### Step 1: Discovery

Assess what already exists:

```bash
# Documentation
ls README.md docs/ 2>/dev/null

# Quality infrastructure
ls .pre-commit-config.yaml Makefile 2>/dev/null
ls .ruff.toml eslint.config.js biome.json 2>/dev/null

# Existing repokit artifacts
ls specs/backlog.md specs/tickets/ 2>/dev/null

# AI instruction files
ls CLAUDE.md GEMINI.md .github/copilot-instructions.md 2>/dev/null

# Project type
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
```

#### Step 2: Recommend a setup plan

Based on what's missing, propose a phased plan:

```
## Repokit Setup Plan

Based on your project, here's what I recommend:

### Phase 1: Documentation (dockit)
[x] README.md exists
[ ] Architecture docs → run `/repokit:dockit init`
[ ] Environment docs

### Phase 2: Code Quality (modernizer)
[ ] Linter setup
[ ] Pre-commit hooks
[x] Tests exist
[ ] Type checking → run `/repokit:modernizer`

### Phase 3: Maintenance Workflow
[ ] specs/ directory for tickets
[ ] Backlog tracking

Run all phases now, or pick one to start with?
```

#### Step 3: Execute chosen phases

For each phase the user approves:

- **Phase 1:** Invoke `dockit init` — handles all doc generation with its own question/plan/confirm flow
- **Phase 2:** Invoke `modernizer analyze` — audits tooling and generates tickets for improvements
- **Phase 3:** Create `specs/` directory and `specs/backlog.md` if they don't exist. Any tickets from Phase 2 will already be there.

Let each skill handle its own interaction (questions, confirmations). Repokit just sequences them and provides transitions.

#### Step 4: Summary

```
## Setup Complete

### What was created
- docs/README.md, docs/ARCHITECTURE.md, docs/ENVIRONMENTS.md (via dockit)
- specs/backlog.md with 4 items (via modernizer)
- specs/tickets/001-*.md through 004-*.md

### What's next
- Review generated docs and fill [TODO] markers
- Address P1 tickets first: 001-testing-setup.md
- Run `/repokit status` anytime to check progress
- Run `/repokit sync` after making changes
```

---

## Cross-Cutting Concerns

### Ticket Deduplication

Before any mode creates or delegates ticket creation, check `specs/backlog.md` for existing items. Pass this context to modernizer so it doesn't create duplicates.

### Missing Infrastructure

If a mode needs something that doesn't exist:
- `status` with no `specs/`: suggest `init` or `audit`
- `sync` with no docs: suggest `init`
- `audit` on a fresh project: suggest `init` instead

### Agent Availability

Not all environments have subagent support. If the auditor agent can't be spawned:
- In `audit` mode: skip the practice review section, note it in the report
- Suggest the user run the auditor separately if needed
