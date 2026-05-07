---
name: repokit
description: 'Hub for the context-in-sync toolkit. Check repo health, sync docs after changes, or bootstrap the foundation+consumers loop on a new project. Use when asked to: see repo status, check repo health, sync after changes, run maintenance, bootstrap repokit, what needs attention, or list repokit tools. Modes: status, sync, init.'
user-invocable: true
---

# repokit

Hub for repokit's context-in-sync architecture: dockit keeps docs aligned with the code; onboard, agentkit, and feedback-loop consume that synced context.

**Modes:** `status` | `sync` | `init` | _(bare — tool menu)_

> **Core principle:** repokit orchestrates, never duplicates. Each mode delegates to dockit and the three consumers rather than reimplementing their logic.

> **Sibling plugin:** ticket creation lives in [tikkit](https://github.com/TheLampshady/tikkit) (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`). Both plugins write to the same `specs/backlog.md` if installed together.

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
## repokit — Keep your project's context in sync, then put it to work

**Foundation (synced context):**
| Tool | Invoke | Purpose |
|------|--------|---------|
| `dockit` | `/repokit:dockit` | Scan codebase and generate/sync living docs |

**Consumers (put context to work):**
| Tool | Invoke | Purpose |
|------|--------|---------|
| `onboard` | `/repokit:onboard` | Personalized ramp-up plans for new team members |
| `agentkit` | `/repokit:agentkit` | Generate AI agents that understand custom code |
| `feedback-loop` | (agent — auto-triggered) | Validate completed work at feature/plan checkpoints |

**Hub modes:**
| Mode | Invoke | Purpose |
|------|--------|---------|
| `status` | `/repokit status` | Dashboard — repo health, open tickets, doc freshness |
| `sync` | `/repokit sync` | After code changes — refresh docs |
| `init` | `/repokit init` | First-time setup — bootstrap the loop |

### Sibling plugin: tikkit
Install [tikkit](https://github.com/TheLampshady/tikkit) for ticket creation: `/tik`, `/figtik`, `/stitchtik`, `/modernizer`.

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

Tags from repokit: `[feedback-loop]`. Tags from tikkit (if installed): `[tik]`, `[figtik]`, `[stitchtik]`, `[modernizer]`.

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
# When was dockit last run? (proxy: last docs/ change)
git log -1 --format="%cr" -- docs/ 2>/dev/null || echo "never"
```

### Output Format

```
## Repo Health Dashboard

| Area | Status | Details |
|------|--------|---------|
| Backlog | 🟡 3 open | 1 feedback-loop, 2 tikkit tags |
| Tickets | 📋 2 pending | specs/tickets/ |
| Docs | 🟢 Fresh | Last updated 2 days ago (14 code commits since) |
| Pre-commit | 🟢 Installed | .pre-commit-config.yaml present |
| Linting | 🟢 Configured | ruff |
| Type checking | 🔴 Missing | No mypy/pyright config found |
| CI | 🟢 Present | 2 workflows |

### Open Backlog Items
- [ ] Fix flaky auth test [feedback-loop] → tickets/flaky-auth-test.md
- [ ] Add type checking [modernizer] → tickets/type-checking.md  ← from tikkit

### Suggested Next Steps
1. Run `/repokit sync` — docs are 14 commits behind
2. Address the open backlog items in order
```

Use 🟢 for healthy, 🟡 for needs attention, 🔴 for missing/broken. Adapt the checks to whatever project structure exists — not all projects will have all of these.

---

## Mode: `sync`

**Trigger:** `/repokit sync`
**Purpose:** Post-change refresh. Bring docs up to date after code changes.

This mode is non-destructive and requires minimal interaction. It runs the lightweight maintenance tasks that should happen after any significant code change.

### Execution Flow

#### Step 1: Assess what changed

```bash
# What changed since last doc sync?
LAST_DOC=$(git log -1 --format=%H -- docs/ README.md 2>/dev/null)
git diff --name-only "$LAST_DOC"..HEAD 2>/dev/null | head -30
```

#### Step 2: Sync docs (delegate to dockit)

If code has changed since the last doc update, invoke `dockit sync`. This updates stale doc sections without prompting or restructuring.

Tell the user: "Running dockit sync to update documentation..."

Follow the dockit skill's `sync` mode — it handles git diff detection, section updates, and diagram regeneration.

#### Step 3: Summary

Report what changed:

```
## Sync Complete

| Action | Result |
|--------|--------|
| Docs | Updated ARCHITECTURE.md (new service added) |
| Diagrams | Regenerated component diagram |

No further action needed.
```

If nothing needs syncing, say so: "Everything is up to date — no sync needed."

> **Note:** Ticket maintenance (refreshing modernizer/tik/figtik/stitchtik tickets) lives in tikkit. If tikkit is installed, the user can run `/modernizer status` separately.

---

## Mode: `init`

**Trigger:** `/repokit init`
**Purpose:** Bootstrap repokit for a new project. Walks through first-time setup of docs and maintenance workflows.

Use when adopting repokit on a project for the first time.

### Execution Flow

#### Step 1: Discovery

Assess what already exists:

```bash
# Documentation
ls README.md docs/ 2>/dev/null

# Quality infrastructure
ls .pre-commit-config.yaml Makefile 2>/dev/null
ls .ruff.toml eslint.config.js biome.json 2>/dev/null

# Existing repokit/tikkit artifacts
ls specs/backlog.md specs/tickets/ 2>/dev/null

# AI instruction files
ls CLAUDE.md GEMINI.md .github/copilot-instructions.md 2>/dev/null

# Project type
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
```

#### Step 2: Recommend a setup plan

Repokit's architecture is **foundation + consumers**: dockit produces synced context; onboard, agentkit, and feedback-loop put it to work. Init proposes them in that order — the foundation must exist before the consumers add value.

Based on what's missing, propose a phased plan:

```
## Repokit Setup Plan

Based on your project, here's what I recommend:

### Foundation: Synced Context (dockit) — required
[x] README.md exists
[ ] Architecture docs → run `/repokit:dockit init`
[ ] Environment docs

This is the foundation everything else builds on. Run dockit first.

### Consumers (pick the ones you want):

#### Onboarding (onboard)
[ ] Personalized ramp-up plans for new devs — run `/repokit:onboard` anytime
    No setup required. Uses the docs from Phase 1.

#### Project AI Agents (agentkit)
[ ] Project-specific AI agents → run `/repokit:agentkit`
    Reads your docs and analyzes custom code to generate SME agents.

#### Validation at Completion (feedback-loop)
[x] Auto-triggers when features/plan sections complete
    No setup required. Already shipped as an agent.

### Optional: Install tikkit for ticket creation
For text/Figma/Stitch designs and code-quality audits as tickets,
install the [tikkit](https://github.com/TheLampshady/tikkit) sibling plugin.

Run the foundation now, or pick a different starting point?
```

#### Step 3: Execute chosen phases

For each phase the user approves:

- **Foundation (dockit):** Invoke `dockit init` — handles all doc generation with its own question/plan/confirm flow. This must complete before agentkit can use the docs as context.
- **agentkit:** Invoke `agentkit` — analyzes custom code and generates project-level agents using the docs from the foundation
- **onboard:** No init action — it runs on demand when a new dev joins
- **feedback-loop:** No init action — it auto-triggers at completion checkpoints

Let each skill handle its own interaction (questions, confirmations). Repokit just sequences them and provides transitions.

#### Step 4: Summary

```
## Setup Complete

### Foundation
- docs/README.md, docs/ARCHITECTURE.md, docs/ENVIRONMENTS.md (via dockit)

### Consumers ready to use
- /onboard — when a new team member joins
- /agentkit — generated [N] project-level agents (if run)
- feedback-loop — auto-triggers when you finish a feature

### What's next
- Review generated docs and fill [TODO] markers
- Run `/repokit status` anytime to check progress
- Run `/repokit sync` after code changes — keeps the foundation current
- For ticket creation, install [tikkit](https://github.com/TheLampshady/tikkit)
```

---

## Cross-Cutting Concerns

### Ticket Deduplication

Before suggesting any ticket creation, check `specs/backlog.md` for existing items. Tikkit (if installed) does this internally for its own ticket-writing skills.

### Missing Infrastructure

If a mode needs something that doesn't exist:
- `status` with no `specs/`: suggest `init`
- `sync` with no docs: suggest `init`

### Agent Availability

Not all environments have subagent support. The `feedback-loop` agent auto-triggers at completion checkpoints when supported. If subagents aren't available, suggest the user run quality checks manually at the end of features.
