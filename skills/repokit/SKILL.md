---
name: repokit
description: 'Hub for the context-in-sync toolkit. Check repo health, sync docs and project agents after changes, resolve the doc decisions that need a human, or bootstrap the docs+agents loop on a new project. Use when asked to: see repo status, check repo health, sync after changes, refresh docs and agents, check for drift, run maintenance, bootstrap repokit, what needs attention, list repokit tools, check whether agents can find the project docs, answer open doc decisions, fill in missing rationale, or promote a convention to a rule. Modes: status, sync, init.'
user-invocable: true
---

# repokit

Hub for repokit's context-in-sync architecture: dockit keeps docs aligned with the code; agentkit consumes that synced context to build project-level agents that own the foundations.

**Modes:** `status` | `sync` | `init` | _(bare — tool menu)_

> **Core principle:** repokit orchestrates, never duplicates. Each mode delegates to dockit and agentkit rather than reimplementing their logic.

> **Sibling plugin:** ticket creation lives in [tikkit](https://github.com/TheLampshady/tikkit) (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`). Repokit reads `.backlog/backlog.md` for its dashboard but never writes to it.

---

## Auto-Detection

When invoked bare (`/repokit` with no mode), detect what the user likely needs:

| Condition | Suggest |
|-----------|---------|
| No `docs/` or `README.md` | → `init` |
| `.backlog/backlog.md` has open items | → `status` (show what needs attention) |
| Git changes since last doc sync | → `sync` |
| User asks "what can repokit do" | → show tool menu |
| Otherwise | → show tool menu with live status summary |

Always show the tool menu as a fallback, but lead with a recommendation when the project state suggests a specific mode.

---

## Tool Menu (bare invocation or when guiding)

When showing the menu, enhance it with live status if `.backlog/` or `docs/` exist.

### Gather Status Counts

```bash
# Open backlog items
grep -c '^\- \[ \]' .backlog/backlog.md 2>/dev/null || echo "0"

# Pending tickets
ls .backlog/tickets/*.md 2>/dev/null | wc -l

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

**Consumer (puts context to work):**
| Tool | Invoke | Purpose |
|------|--------|---------|
| `agentkit` | `/repokit:agentkit` | Generate project agents that own foundations and understand custom code |

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
**Purpose:** Dashboard of repo health. Quick, no prompts.

Read-only by default. The one exception is the open-decisions walk (check 7): if the user opts in, `status` writes their answers back into the docs. Nothing is written unless they accept.

### What to check

Run these checks and present a unified dashboard:

#### 1. Backlog & Tickets (skip entirely if `.backlog/` is absent)

```bash
# Read backlog
cat .backlog/backlog.md 2>/dev/null

# Count by tag
grep -o '\[.*\]' .backlog/backlog.md 2>/dev/null | sort | uniq -c

# Count open vs completed
grep -c '^\- \[ \]' .backlog/backlog.md 2>/dev/null  # open
grep -c '^\- \[x\]' .backlog/backlog.md 2>/dev/null  # done

# Pending ticket files
ls .backlog/tickets/*.md 2>/dev/null
```

This row is **read-only and conditional** — repokit writes no tickets. If `.backlog/backlog.md` doesn't exist, omit the Backlog and Tickets rows entirely rather than showing zeros, and mention tikkit once in Suggested Next Steps. Report whatever tags are present without assuming a fixed set; tikkit contributes `[tik]`, `[figtik]`, `[stitchtik]`, `[modernizer]`.

#### 2. Documentation Freshness

For human-readable context in the dashboard, capture timestamps:

```bash
# Last doc change
git log -1 --format="%cr (%h)" -- docs/ README.md 2>/dev/null

# Last code change
git log -1 --format="%cr (%h)" -- src/ lib/ app/ *.py *.ts *.js *.go *.rs 2>/dev/null
```

For the actual drift verdict, delegate to **`dockit check`** — that's its purpose-built read-only drift detection. Don't reinvent it inline with a "commits since" proxy; that tells you something happened, not what's wrong.

Map the result into the dashboard:

| `dockit check` exit | Dashboard row |
|---------------------|---------------|
| 0 (current) | 🟢 Fresh |
| 1 (stale) | 🟡 Stale — run `/repokit sync` |

For a deeper inspection (broken refs, silently-passing predicates, code documented nowhere), point the user at `/repokit:dockit sync --deep` — a whole-repo pass, slower and more thorough than `check`. They can also just ask for a "deep scan" or "full scan".

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

# When was agentkit last run? (proxy: last agent-dir change)
git log -1 --format="%cr" -- .claude/agents/ .agents/agents/ .github/agents/ 2>/dev/null || echo "never"
```

#### 5. Agent-to-Doc Drift

If agentkit has been initialized on this project, the agents reference foundation names, file paths, and component names from the docs. When dockit changes any of those (foundation demoted, file moved, component renamed), the agents become stale — and unlike doc drift, this is invisible until someone reads a wrong agent.

Check whether agentkit agents exist:

```bash
ls .claude/agents/*.md .agents/agents/*.md .agents/agents/*/agent.md .github/agents/*.md 2>/dev/null
```

If any exist, delegate to **`agentkit status`** for the actual drift check — it knows the exact shape of agentkit's outputs and how they reference FOUNDATIONS.md. Don't re-implement the comparison here; that violates "orchestrate, never duplicate."

Map the result into the dashboard:

| `agentkit status` finding | Dashboard row |
|---------------------------|---------------|
| All agents in sync | 🟢 In sync |
| Drift detected | 🟡 Drifted — run `/repokit sync` (or `/agentkit sync` directly) |
| No agents found | Skip the row, or note "Not adopted" |

#### 6. Context Handoff

Synced docs only pay off if agents *find* them. The project's context file (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.github/copilot-instructions.md`) is the one artifact loaded on every turn without anyone asking for it — so it's the handoff point between "docs exist" and "docs get used." If it never names `docs/FOUNDATIONS.md`, agents re-derive the architecture from scratch on every task and the foundation registry sits unread.

This is repokit's decision-phase concern: route agents to context that already exists rather than building another retrieval layer.

```bash
# Is there a foundation registry to point at?
ls docs/FOUNDATIONS.md 2>/dev/null

# Which context files are auto-loaded in this project?
ls CLAUDE.md GEMINI.md AGENTS.md .github/copilot-instructions.md 2>/dev/null

# Do any of them reference it?
grep -l "FOUNDATIONS.md" CLAUDE.md GEMINI.md AGENTS.md .github/copilot-instructions.md 2>/dev/null
```

| State | Dashboard row |
|-------|---------------|
| No `docs/FOUNDATIONS.md` | Skip the row — nothing to point at yet |
| Referenced by at least one context file | 🟢 Wired — `<file>` references `docs/FOUNDATIONS.md` |
| Context file exists, no reference | 🟡 Not wired — `<file>` doesn't reference `docs/FOUNDATIONS.md` |
| `FOUNDATIONS.md` exists, no context file at all | 🔴 No context file — nothing is auto-loaded |

`status` is read-only: **report the gap, don't fix it.** When the row isn't 🟢, add this to Suggested Next Steps:

> Run `/repokit init` to wire `docs/FOUNDATIONS.md` into `<context file>` — or add the line yourself.

If several context files exist (a project targeting Claude *and* Antigravity), check each and name the ones missing the reference. One 🟢 file doesn't cover the others — each platform loads only its own.

#### 7. Open Decisions

dockit deliberately leaves work for humans rather than inventing answers: it never writes rationale, never promotes a Convention to a Rule, and never deletes a rule whose evidence decayed. That work accumulates in the docs as open markers. Without somewhere to process it, the `[TODO: why?]` slots become permanent and the docs read as half-finished forever.

```bash
# Missing rationale
grep -rn '\[TODO: why?\]' docs/ 2>/dev/null | wc -l

# Unanswered intent questions
grep -rn '\[TODO:.*boundary\|\[TODO:.*gap' docs/ 2>/dev/null | wc -l

# Mined rules carrying stored predicates
grep -rc 'dockit:check\|dockit:conform' docs/PRINCIPLES.md docs/FOUNDATIONS.md 2>/dev/null

# SDD artifacts present (compare-only — repokit and dockit never write these)
ls .specify/memory/constitution.md openspec/project.md conductor/workflow.md 2>/dev/null
```

For the actual predicate results and decay flags, take them from the last `dockit sync` report rather than re-running the analysis here — same "orchestrate, never duplicate" rule that applies to `dockit check`.

| State | Dashboard row |
|-------|---------------|
| No mined rules in `docs/` | Skip the row |
| Open items exist | 🟡 N need your input |
| Everything answered | 🟢 Nothing pending |

**The walk is opt-in.** `status` stays read-only: report the count, then offer. Only if the user accepts do you walk the queue one item at a time and write their answers back. Never start walking unprompted, and never guess an answer to move things along — a fabricated reason is the one output worse than a blank one.

When walking, present one item at a time with enough context to answer without opening files:

```
1 of 4 — Why is missing
   "Query through the SQLAlchemy ORM." Rule since March, no reason recorded.
   One sentence and I'll write it in. (skip / stop anytime)

2 of 4 — Convention drafted
   "API handlers return Result[T]" — 11/13 conform.
   Exceptions: legacy_export.py, health.py
   → keep as Convention · promote to Rule · drop it

3 of 4 — Boundary question
   SearchClient handles reads; 4 features write directly.
   → deliberate boundary, or a gap?

4 of 4 — Rule decayed
   "All API routes require authentication" — predicate now fails.
   New non-conformers: webhooks.py, health_v2.py
   → doc wrong, or code drifting?
```

Write answers back into the docs as given: a reason fills the `<details><summary>Why</summary>` block, a promotion moves the line from Conventions to Rules, a drop removes it. Answers are the user's words — don't embellish them into prose.

### Output Format

```
## Repo Health Dashboard

| Area | Status | Details |
|------|--------|---------|
| Backlog | 🟡 3 open | tags: 2 `[tik]`, 1 `[modernizer]` |
| Tickets | 📋 2 pending | .backlog/tickets/ |
| Docs | 🟡 Stale | `dockit check` reports drift; last updated 2 days ago |
| Agents | 🟡 Drifted | 2 of 5 agents reference renamed foundations |
| Context handoff | 🟡 Not wired | CLAUDE.md doesn't reference docs/FOUNDATIONS.md |
| Open decisions | 🟡 4 need you | 2 missing rationale, 1 promotion candidate, 1 decayed rule |
| Pre-commit | 🟢 Installed | .pre-commit-config.yaml present |
| Linting | 🟢 Configured | ruff |
| Type checking | 🔴 Missing | No mypy/pyright config found |
| CI | 🟢 Present | 2 workflows |

### Open Backlog Items
- [ ] Migrate auth to the shared client [tik] → tickets/migrate-auth-client.md
- [ ] Add type checking [modernizer] → tickets/type-checking.md

### Suggested Next Steps
1. Run `/repokit sync` — refreshes docs and reconciles drifted agents in one pass
2. Run `/repokit init` to wire docs/FOUNDATIONS.md into CLAUDE.md — or add the line yourself
3. Address the open backlog items in order

4 open decisions are waiting — want to walk through them now? (~2 min)
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

#### Step 2: Sync the foundation (dockit)

If code has changed since the last doc update, invoke `dockit sync`. This updates stale doc sections without prompting or restructuring.

Tell the user: "Running dockit sync to update documentation..."

Follow the dockit skill's `sync` mode — it handles git diff detection, section updates, and diagram regeneration.

#### Step 3: Sync the consumers (agentkit)

dockit may have just changed foundation names, file paths, or component names that the project's agents reference. Without refreshing the agents, they end up pointing at stale facts — which defeats the whole "context in sync" point.

Check whether agentkit has been initialized on this project:

```bash
ls .claude/agents/*.md .agents/agents/*.md .agents/agents/*/agent.md .github/agents/*.md 2>/dev/null
```

If any agent files exist, invoke `agentkit sync`. It reconciles each agent against the now-current docs, surfaces drift, and lets the user pick what to update — it doesn't auto-overwrite.

Tell the user: "Running agentkit sync to update project agents against the new docs..."

If no agentkit agents exist, skip this step — agentkit hasn't been adopted on this project yet.

#### Step 4: Summary

Report what changed across both halves:

```
## Sync Complete

| Action | Result |
|--------|--------|
| Docs | Updated ARCHITECTURE.md (new service added) |
| Diagrams | Regenerated component diagram |
| Agents | 2 agents reconciled against renamed foundations |

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
ls .backlog/backlog.md .backlog/tickets/ 2>/dev/null

# AI instruction files — and whether they already route to the foundation registry
ls CLAUDE.md GEMINI.md AGENTS.md .github/copilot-instructions.md 2>/dev/null
grep -l "FOUNDATIONS.md" CLAUDE.md GEMINI.md AGENTS.md .github/copilot-instructions.md 2>/dev/null

# Project type
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
```

#### Step 2: Recommend a setup plan

Repokit's architecture is **foundation + consumer**: dockit produces synced context; agentkit puts it to work. Init proposes them in that order — the foundation must exist before agentkit adds value, because agentkit reads FOUNDATIONS.md as its source of truth.

Based on what's missing, propose a phased plan:

```
## Repokit Setup Plan

Based on your project, here's what I recommend:

### Foundation: Synced Context (dockit) — required
[x] README.md exists
[ ] Architecture docs → run `/repokit:dockit init`
[ ] Environment docs

This is the foundation everything else builds on. Run dockit first.

### Consumer: Project AI Agents (agentkit)
[ ] Project-specific AI agents → run `/repokit:agentkit`
    Reads FOUNDATIONS.md and analyzes custom code to generate SME agents
    that own each foundation and stay in sync with it.

### Context handoff — one line, big payoff
[ ] CLAUDE.md doesn't reference docs/FOUNDATIONS.md
    Your context file is loaded on every turn; the foundation registry isn't.
    Without the pointer, agents re-derive the architecture each time.
    I'll add a two-line section — say the word.

### Optional: Install tikkit for ticket creation
For text/Figma/Stitch designs and code-quality audits as tickets,
install the [tikkit](https://github.com/TheLampshady/tikkit) sibling plugin.

Run the foundation now, or pick a different starting point?
```

#### Step 3: Execute chosen phases

For each phase the user approves:

- **Foundation (dockit):** Invoke `dockit init` — handles all doc generation with its own question/plan/confirm flow. This must complete before agentkit can use the docs as context.
- **agentkit:** Invoke `agentkit` — analyzes custom code and generates project-level agents using the docs from the foundation
- **Context handoff:** wire the context file to the foundation registry — see below. Run this **after** dockit, so the file you're pointing at actually exists.

Let each skill handle its own interaction (questions, confirmations). Repokit just sequences them and provides transitions.

##### Wiring the context handoff

Only act if `docs/FOUNDATIONS.md` exists — never add a pointer to a file that isn't there.

**Ask before writing.** Context files are hand-maintained and often carry team conventions; an unrequested edit is an intrusion. Show the exact text and name the target file, then wait.

**Append, never overwrite.** Add a section at the end of the file — or immediately after an existing architecture/overview section if there's an obvious home. Touch nothing else.

The text to add, verbatim except for the path:

```markdown
## Foundations

Shared, foundational code is catalogued in [docs/FOUNDATIONS.md](docs/FOUNDATIONS.md),
with the invariants each foundation guarantees. Read it before changing anything under
those paths.
```

Handle each case:

| Situation | Action |
|-----------|--------|
| One context file, no reference | Ask, then append to it |
| Several context files (Claude + Antigravity + Copilot) | Each platform loads only its own — ask once, then append to every one that's missing the reference |
| Already references `FOUNDATIONS.md` | Nothing to do; say so and move on |
| No context file at all | Offer to create the smallest useful one for the detected platform, containing this section and nothing else. Don't generate project context you haven't verified — that's dockit's job |
| `docs/FOUNDATIONS.md` doesn't exist | Skip silently. Revisit after dockit runs |

If the user declines, don't re-ask later in the same run. Note it in the summary as skipped so `status` can surface it again next time.

#### Step 4: Summary

```
## Setup Complete

### Foundation
- docs/README.md, docs/ARCHITECTURE.md, docs/ENVIRONMENTS.md (via dockit)

### Consumer ready to use
- /agentkit — generated [N] project-level agents (if run)

### Context handoff
- CLAUDE.md now points at docs/FOUNDATIONS.md — agents find the foundation without being told
  (or: "skipped — run `/repokit init` again, or add the pointer yourself")

### What's next
- Review generated docs and fill [TODO] markers
- Run `/repokit status` anytime to check progress
- Run `/repokit sync` after code changes — keeps the foundation current
- For ticket creation, install [tikkit](https://github.com/TheLampshady/tikkit)
```

---

## Cross-Cutting Concerns

### Backlog is Read-Only

Repokit never writes to `.backlog/`. When a mode surfaces work that deserves a ticket, say so and point at tikkit — don't create the file. Ticket deduplication is tikkit's concern, handled internally by its ticket-writing skills.

### Missing Infrastructure

If a mode needs something that doesn't exist:
- `status` with no `docs/` or `README.md`: suggest `init`
- `status` with no `.backlog/`: omit the backlog rows, mention tikkit once
- `status` with no `docs/FOUNDATIONS.md`: omit the context-handoff row — there's nothing to point at
- `status` with no mined rules in `docs/`: omit the open-decisions row rather than showing zero
- `sync` with no docs: suggest `init`

### Editing Context Files

`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, and `.github/copilot-instructions.md` are hand-maintained and carry team conventions. Repokit touches them in exactly one place — wiring the `docs/FOUNDATIONS.md` pointer during `init` — and only after asking, only by appending. Never rewrite or reformat one, and never edit it during `status` (read-only) or `sync`.

### Agent Availability

Not all environments have subagent support. Agentkit generates project-level agents for Claude, Antigravity, and Copilot; where subagents aren't available, its generated agents still work as loadable context files that a human or agent can read directly.
