# Agentkit Sync Guide

How `agentkit sync` reconciles existing project agents with the current state of `FOUNDATIONS.md` and the codebase.

Sync is a three-way compare: **agent files** vs. **FOUNDATIONS.md** vs. **the code**. Where they disagree, sync surfaces the disagreement and asks the user.

---

## Inputs

Before running, sync gathers:

| Input | Source | What's needed |
|-------|--------|---------------|
| Existing agents | `.claude/agents/`, `.agents/agents/`, `.github/agents/` | All `*.md` and `*.agent.md` files |
| Current foundations | `docs/FOUNDATIONS.md` (catalog table + entries) | Names, paths, status, invariants |
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

**Detection:** parse each foundation's `### Invariants` section in FOUNDATIONS.md and the matching `### <FoundationName>` block in the agent body.

An invariant in FOUNDATIONS.md is a **bold statement line** — including any named anti-pattern and repair that follows it — optionally followed by a `<!-- dockit:tier=... -->` comment and a `<details><summary>Why</summary>` block. In the agent, the same invariant appears as a bullet prefixed with its tier: `- **[Rule]** <text>`. Compare the statement text **and its anti-pattern clause**; ignore the `dockit:tier` comment and the `Why` blocks (not extracted). An agent whose invariant has lost the anti-pattern clause has drifted — that clause is the operational half.

A drift is any of:
- Invariant present in FOUNDATIONS.md, missing from agent
- Invariant present in agent, missing from FOUNDATIONS.md
- Wording differs in a way that changes meaning (use loose normalization — case + whitespace + punctuation — to avoid noise)
- **Tier differs** — the agent says `[Rule]` where the catalog says `tier="convention"`, or vice versa

Tier drift matters as much as text drift and is easier to miss: an agent enforcing a Convention as a Rule blocks work the team considers legitimate, and one treating a Rule as a Convention lets a real defect through. Always report it explicitly rather than folding it into a wording diff.

**Default action:** show the diff. Ask the user `[u]pdate agent to match catalog`, `[r]econsider the catalog`, `[s]kip`. Don't auto-rewrite — invariants are load-bearing.

> Sync never *promotes* an invariant. If the catalog and agent disagree on tier, the catalog wins on update — but moving something from Convention to Rule in the catalog itself is a human decision, collected by `/repokit status`.

### 5. Status drift

The foundation's `Status` (active / intended / deprecated / sunset) or `Health` (healthy / hotspot / unknown) changed in FOUNDATIONS.md but the agent's `Owned Foundations` table still shows the old value.

**Detection:** compare each owned foundation's status/health in the catalog vs. the agent's Owned Foundations table.

**Default action:** auto-update the table. Run cross-doc check if status flipped to `deprecated` or `sunset`.

**`intended → active` needs more than a table edit.** The foundation now has real consumers, which changes what the agent should carry:

- **Rescope `Working Directories`.** They were sourced from where consumers were *meant* to go; now use the catalog's actual `Consumers` column, keeping any intended-destination directory that's still empty.
- **Replace the no-precedent block with a canonical call site.** Real usage exists, so the agent should pattern-match against it instead of being told none exists.

Ask before applying — the scope change is the substantive part, not the status word.

> **Never report foundation age.** Not from a date field (there isn't one — see [FOUNDATION-MAINTENANCE.md](./FOUNDATION-MAINTENANCE.md#never-stamp-a-date-into-foundationsmd)) and not derived from git either. *"Nobody has touched `core.auth` in 142 days"* is trivial to compute and is a calendar nag whichever source it comes from. Review is triggered by someone working on the foundation. Derive an age only if the user explicitly asks for one.

### 6. Scope drift — Trigger Coverage Gaps

Categories 1–5 all compare the agent against the catalog. This one compares the **agent set against the code**, and it catches the failure the others structurally cannot: `FOUNDATIONS.md` is entirely correct, every agent matches it, and a whole directory still triggers nothing.

That gap is invisible from inside the agent set. Nothing errors. Work in the uncovered directory routes to a generic assistant, which writes plausible code that ignores conventions no one told it about. It shows up in the field as *"we refactored one module into a package and the agent kept editing the old file"* and *"nobody noticed `presenters/` was never in any agent's scope."*

Detecting absence is the point. Run this pass on every sync.

#### Building the covered set

1. For each agent, collect its `Working Directories` paths, any file globs in its frontmatter description, and paths named in `Owned Foundations`.
2. Normalize to directories. A path covers itself and everything beneath it.
3. Union across **all** agents on all platforms — coverage is a property of the agent set, not of one agent.

#### Finding what's outside it

Use dockit's standard exclusions (`tests/`, `node_modules/`, `vendor/`, `dist/`, generated code, vendored code). Then flag three things:

**a. Uncovered active directories.** A directory containing source files, none of whose ancestors are in the covered set:

```bash
find src -type d -not -path "*/node_modules/*" -not -path "*/tests/*" \
  | while read d; do
      n=$(find "$d" -maxdepth 1 -type f \( -name "*.py" -o -name "*.ts" \) | wc -l)
      [ "$n" -ge 1 ] && echo "$n $d"
    done | sort -rn
```

Threshold by project size — flag at **≥ 10 files** on small/medium projects, **≥ 20** on large ones. Below that, list under a single "also uncovered (small)" line rather than as findings.

**b. Uncovered inheritance roots.** A type with **≥ 5 subclasses** in-repo whose defining file sits outside the covered set, or sits inside it but is named nowhere in any agent's hot memory.

Count occurrences, not files — one file can define several subclasses of the same base, and each is a separate consumer of its contract:

| Language | Recipe |
|----------|--------|
| Python | `grep -rhoE "class\s+\w+\([^)]*\b<Type>\b" src/ \| wc -l` |
| JS / TS | `grep -rhoE "class\s+\w+\s+extends\s+<Type>\b" src/ \| wc -l` |
| Java / Kotlin | `grep -rhoE "(extends\|implements\|:)\s+<Type>\b" --include="*.java" --include="*.kt" . \| wc -l` |
| Go (embedding) | `grep -rhoE "^\s+\*?<Type>\s*$" --include="*.go" . \| wc -l` |
| Rust | `grep -rhoE "impl\s+(<[^>]*>\s+)?<Type>\s+for\b" --include="*.rs" src/ \| wc -l` |

Inlined deliberately: skills load independently, so agentkit can't rely on reading a guide that ships inside dockit. If these fall out of step with dockit's Signal 1b, dockit's copy is authoritative — but a wrong subclass count here costs a mis-prioritized finding, not a bad catalog row.

An inheritance root inside a covered directory but absent from hot memory is still a finding. The agent will be *invoked*; it just won't know the base class exists, which is the hallucination case.

**c. Module-split drift.** A catalog path or Working Directory row that names a single file which no longer exists, where a *package of the same stem* does:

```bash
# agent says: service/api/utils/discovery_utils.py
[ ! -f service/api/utils/discovery_utils.py ] && ls service/api/utils/
```

This is the refactor that most reliably orphans an agent's scope while everything still looks superficially fine. Treat it as scope drift rather than path drift (category 3): the fix is usually "cover the package," not "repoint at one replacement file."

#### A gap is a question, not a defect

Plenty of directories *should* be uncovered — thin CRUD, config, glue, generated output, anything an AI gets right from framework knowledge alone. That's the Core Test in `AGENT-SIZING.md`, and it still governs. Report the gap, state what's in the directory, and let the user decide.

**Default action:** per gap, offer `[f]old into <nearest agent>`, `[c]reate a new agent`, `[s]kip`.

Before proposing a fold, run the **layer test** in [`AGENT-SIZING.md`](./AGENT-SIZING.md) § "Closing a coverage gap without inflating an agent." Folding four architectural layers into one agent to make a coverage report go green trades a blindspot for an agent that triggers on everything and knows each layer shallowly. Sync must not recommend that silently.

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

Trigger coverage gaps:
  - src/presenters/  (14 files, no agent covers it)
    Nearest agent: `component-expert` (owns src/components/)
    ⚠ Different layer — folding adds a 2nd layer to that agent. Recommend: new agent.
    Action? [c]reate · [f]old anyway · [s]kip

  - src/dao/base.py  →  BaseDao, 12 subclasses, named in no agent's hot memory
    Nearest agent: `data-layer` (already covers src/dao/)
    Recommend: add to hot memory — scope is fine, the invariant is missing.
    Action? [u]pdate · [s]kip

  - service/api/utils/discovery_utils.py  →  file gone, package exists
    `schema-agent` still scoped to the single file; utils/ now has 3 modules
    Recommend: rescope to service/api/utils/
    Action? [u]pdate · [s]kip

  Also uncovered (small, listed not flagged): src/glue/ (3), src/typing/ (2)

─────────────────────────────────────────────────────
```

---

## Per-Finding Actions

### Update an agent

When the user accepts an update:

1. Read the current agent file
2. Apply the specific change (path, invariant, owned-foundation list, status)
3. Re-grep cross-docs if the change affects PRINCIPLES.md / ARCHITECTURE.md
4. Don't record that a review happened — sync didn't review, it reconciled. `FOUNDATIONS.md` carries no date field for this, and the distinction matters: reconciling an agent against a catalog row is not the same as reading the code and confirming the invariants hold.

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

When a project has agents on multiple platforms (Claude + Antigravity, etc.), the same drift may appear in each platform's copy of an agent. Apply changes to **all platforms** in one pass — never let Claude and Antigravity agents drift apart.

If only one platform has the agent (e.g., Claude has `auth.md` but Antigravity doesn't), flag it as a **platform gap** rather than drift. Ask: *"`auth` agent exists for Claude only. Generate Antigravity and Copilot copies?"*

(Distinct from a **trigger coverage gap**, category 6 — that's code no agent covers on *any* platform. A platform gap is the same agent missing a copy.)

---

## Status Mode (Read-Only)

`agentkit status` runs the same drift scan but **never offers actions** — it just reports.

```
─────────────────────────────────────────────────────
agentkit status
─────────────────────────────────────────────────────

Project: <project-name>
Foundations: 6/6 owned  |  Agents: 4  |  Source dirs covered: 11/14

Agents:
  ✓ auth         owns: core.auth, core.permissions      in sync
  ✓ data-layer   owns: core.database, core.cache         in sync
  ⚠ messaging    owns: core.notifications, core.events   invariant drift
  ⚠ admin        owns: (none — orphaned)                  orphaned

Drift summary:
  - 1 orphaned agent
  - 0 missing agents
  - 1 invariant drift
  - 3 trigger coverage gaps (src/presenters/, BaseDao, schema utils split)

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

- **Does not run dockit's foundation detection** — never re-scores fan-in, cross-feature spread, or stability, and never writes a `FOUNDATIONS.md` row. That's dockit's job. If sync sees the catalog is stale, it tells the user to run `/dockit sync`.

  The category-7 scan is deliberately on the near side of that line. It may **count** — files per directory, subclasses per type — because counting is what "is this covered?" requires. It may not **score** or **rank**, and when a coverage gap looks like an uncatalogued foundation, the recommendation is `/dockit sync`, not a row written by agentkit. Two scanners that both decide what a foundation is will drift; one that counts and one that scores will not.
- **Does not silently rewrite invariants** — always prompts.
- **Does not delete agents without confirmation** — even orphans require explicit user approval.
- **Does not modify foundation source code** — only agent files and (with permission) doc files.
- **Does not create FOUNDATIONS.md** — that's dockit's `init`.
