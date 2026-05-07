# Agentkit Sync Guide

How `agentkit sync` reconciles existing project agents with the current state of `FOUNDATIONS.md` and the codebase.

Sync is a three-way compare: **agent files** vs. **FOUNDATIONS.md** vs. **the code**. Where they disagree, sync surfaces the disagreement and asks the user.

---

## Inputs

Before running, sync gathers:

| Input | Source | What's needed |
|-------|--------|---------------|
| Existing agents | `.claude/agents/`, `.gemini/agents/`, `.github/agents/` | All `*.md` and `*.agent.md` files |
| Current foundations | `docs/FOUNDATIONS.md` (catalog table + entries) | Names, paths, status, invariants, last-reviewed dates |
| Per-foundation sub-docs | `docs/architecture/foundations/*.md` (if present) | Deeper context for large projects |
| Code state | Source files referenced by foundations | To detect path renames, public API drift |

If `FOUNDATIONS.md` is missing, sync stops and recommends running `/dockit init` — there's nothing to reconcile against.

---

## Drift Categories

Sync classifies findings by **comparing content** between the agent body and FOUNDATIONS.md. No timestamps involved — the question is always "do these match right now?"

### 1. Orphaned agents

The agent claims ownership of a foundation that no longer appears in `FOUNDATIONS.md` (removed, renamed, or demoted to pretender).

**Detection:** parse the agent's `Owned Foundations` section; check each named foundation against the current catalog.

**Default action:** prompt the user — `[u]pdate to remove the orphan`, `[d]elete agent if it's the only foundation it owned`, `[s]kip`.

### 2. Missing agents

A foundation exists in `FOUNDATIONS.md` but no agent claims ownership.

**Detection:** for each catalog row, check whether any existing agent's `Owned Foundations` section names it.

**Default action:** propose creating a new agent OR folding the foundation into an existing related agent (per AGENT-SIZING grouping rules). Ask the user.

### 3. Path drift

The foundation's path in the catalog changed (e.g., `core/notifications.py` → `core/notifications/dispatcher.py`), but the agent's `Working Directories` table still points at the old location.

**Detection:** compare each owned foundation's path in the catalog vs. the path(s) in the agent's Working Directories.

**Default action:** auto-update the path. Re-grep PRINCIPLES.md / ARCHITECTURE.md for the old path; surface hits.

### 4. Invariant drift

The catalog's invariants for a foundation differ from what's embedded in the agent's hot memory.

**Detection:** parse the bullet list under each foundation's `### Invariants` heading in FOUNDATIONS.md and the matching `### <FoundationName>` block in the agent body. A drift is any of:
- Invariant present in FOUNDATIONS.md, missing from agent
- Invariant present in agent, missing from FOUNDATIONS.md
- Wording differs in a way that changes meaning (use loose normalization — case + whitespace + punctuation — to avoid noise)

**Default action:** show the diff. Ask the user `[u]pdate agent to match catalog`, `[r]econsider the catalog`, `[s]kip`. Don't auto-rewrite — invariants are load-bearing.

### 5. Status drift

The foundation's `Status` (active / deprecated / sunset) or `Health` (healthy / hotspot / unknown) changed in FOUNDATIONS.md but the agent's `Owned Foundations` table still shows the old value.

**Detection:** compare each owned foundation's status/health in the catalog vs. the agent's Owned Foundations table.

**Default action:** auto-update the table. Run cross-doc check if status flipped to `deprecated` or `sunset`.

### 6. Stale review (informational)

`FOUNDATIONS.md` itself records a `Last reviewed` date for each foundation — set deliberately by the team or by a foundation-owner agent during a real invariant validation. This is **dockit's** field, not agentkit's. Sync surfaces it as a recommendation, not as an action item.

**Detection:** read `Last reviewed: YYYY-MM-DD` from each owned foundation's catalog row; compare against today.

**Default action:** flag in the report only. Recommend (don't auto-trigger): *"FOUNDATIONS.md says `core.auth` was last reviewed 142 days ago. Invoke the owning agent for a review pass, or `tikkit:foundationtik` will write a `foundation-stale-review` ticket on its next pass."*

---

## Sync Output Format

After scanning, sync prints a structured report. Don't auto-apply changes — present findings, prompt per-finding.

```
─────────────────────────────────────────────────────
agentkit sync — drift report
─────────────────────────────────────────────────────

Project: <project-name>  |  Platforms: <list>  |  Agents: <count>

Orphaned agents:
  - .claude/agents/legacy-cache.md
    Claims ownership of `core.cache.legacy` (removed from FOUNDATIONS.md)
    Action? [u]pdate · [d]elete · [s]kip

Missing agents:
  - core.notifications  (new in FOUNDATIONS.md)
    Recommend: fold into existing `messaging` agent (same domain)
    Action? [c]reate · [f]old · [s]kip

Path drift:
  - .claude/agents/auth.md
    Foundation `core.auth` moved: core/auth.py → core/auth/middleware.py
    Cross-doc hits: PRINCIPLES.md:47, ARCHITECTURE.md:91
    Action? [u]pdate

Invariant drift:
  - .claude/agents/data-layer.md  →  core.database
    Catalog: "All writes go through the unit-of-work pattern"
    Agent:   "All writes use the repository pattern"
    Action? [u]pdate agent · [r]econsider catalog · [s]kip

Status drift:
  - .claude/agents/messaging.md
    `core.notifications` flipped: healthy → hotspot
    Action? [u]pdate

Stale review (informational — dockit's Last reviewed dates):
  - core.notifications  (FOUNDATIONS.md: last reviewed 142 days ago)
  - core.auth           (FOUNDATIONS.md: last reviewed 95 days ago)
  Recommend: invoke owning agents for review, or wait for foundationtik

─────────────────────────────────────────────────────
```

---

## Per-Finding Actions

### Update an agent

When the user accepts an update:

1. Read the current agent file
2. Apply the specific change (path, invariant, owned-foundation list, status)
3. Re-grep cross-docs if the change affects PRINCIPLES.md / ARCHITECTURE.md
4. Do not modify FOUNDATIONS.md's `Last reviewed` field — sync didn't review, it just reconciled. That field flips only during an explicit invariant-validation pass by the owning agent.

### Delete an agent

Only when the agent's only remaining ownership was orphaned. Confirm explicitly — *"Delete .claude/agents/legacy-cache.md? It owns no remaining foundations."*

### Create / fold for a missing agent

- **Create** — generate a new agent following the standard Phase 4 template (foundation-agent.template.md). Cap at 5 total agents per AGENT-SIZING rules.
- **Fold** — add the new foundation to an existing agent's `Owned Foundations` section. Update the body's hot-memory section to reference the new foundation. Add a Working Directory row.

If folding would push an agent over the size budget (≥10,000 chars or >5 owned foundations), prompt the user — splitting may be cleaner than folding.

### Reconcile invariant drift

Two valid resolutions:

1. **Agent is wrong** — the catalog has the truth; update the agent body.
2. **Catalog is wrong** — the team changed the invariant in code without updating FOUNDATIONS.md. Recommend running `/dockit sync` first, then re-running `/agentkit sync`.

The agent should never claim an invariant the catalog doesn't endorse.

---

## Multi-Platform Considerations

When a project has agents on multiple platforms (Claude + Gemini, etc.), the same drift may appear in each platform's copy of an agent. Apply changes to **all platforms** in one pass — never let Claude and Gemini agents drift apart.

If only one platform has the agent (e.g., Claude has `auth.md` but Gemini doesn't), flag it as a **coverage gap** rather than drift. Ask: *"`auth` agent exists for Claude only. Generate Gemini and Copilot copies?"*

---

## Status Mode (Read-Only)

`agentkit status` runs the same drift scan but **never offers actions** — it just reports.

```
─────────────────────────────────────────────────────
agentkit status
─────────────────────────────────────────────────────

Project: <project-name>
Foundations: 6  |  Agents: 4  |  Coverage: 100%

Agents:
  ✓ auth         owns: core.auth, core.permissions      in sync
  ✓ data-layer   owns: core.database, core.cache         in sync
  ⚠ messaging    owns: core.notifications, core.events   invariant drift
  ⚠ admin        owns: (none — orphaned)                  orphaned

Drift summary:
  - 1 orphaned agent
  - 0 missing agents
  - 1 invariant drift
  - 2 informational: dockit's Last reviewed > 90 days (core.notifications, core.auth)

Run `/agentkit sync` to address drift.
─────────────────────────────────────────────────────
```

---

## How Sync Identifies Agentkit-Generated Agents

Each generated agent has a marker comment near the top of the body:

```html
<!-- agentkit-managed -->
```

No date — just a marker. Hand-authored agents (no marker) are off-limits to sync; agentkit warns about them but never replaces them without explicit user approval.

Drift is detected by **content comparison** between the agent body and FOUNDATIONS.md, not by timestamp comparison. If the user wants to know when an agent file was last touched, `git log -1 .claude/agents/<name>.md` is authoritative — agentkit doesn't duplicate that.

---

## What Sync Does NOT Do

- **Does not run dockit's foundation detection** — never re-scores fan-in/cross-feature/stability. That's dockit's job. If sync sees the catalog is stale, it tells the user to run `/dockit sync`.
- **Does not silently rewrite invariants** — always prompts.
- **Does not delete agents without confirmation** — even orphans require explicit user approval.
- **Does not modify foundation source code** — only agent files and (with permission) doc files.
- **Does not create FOUNDATIONS.md** — that's dockit's `init`.
