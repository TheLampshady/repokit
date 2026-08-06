---
name: agentkit
description: 'Generate, sync, and maintain project-level AI subagents tailored to your codebase. Reads dockit FOUNDATIONS.md as the source of truth and analyzes custom code patterns, then creates agents that own foundations, understand custom extensions, and keep their own docs in sync. Modes: init, sync, status. Use when asked to: create agents for this project, generate AI helpers, set up subagents, sync project agents, check agent drift, update agents after foundation changes, help AI understand my custom code, create coding assistants, generate project agents. Supports Claude, Antigravity, and Copilot.'
user-invocable: true
argument-hint: "[init|sync|status] [claude|antigravity|copilot|all]"
---

# agentkit

Generate and maintain project-level AI subagents that understand your team's foundations, custom code, and conventions — and keep them in sync as the codebase evolves.

**Modes:** `init` | `sync` | `status`

## Philosophy

- **Foundations first** — `docs/FOUNDATIONS.md` (from dockit) is the source of truth. Each foundation gets an owner agent that can both teach AI assistants the rules and update the doc when the code shifts.
- **Combined agents** — One agent covers a foundation plus the custom code that extends it. Fewer, broader agents avoid triggering conflicts.
- **Dynamic discovery** — No hardcoded framework lists. Detects what's in your project, researches what's native vs custom, builds agents around the delta.
- **Plans first, generates second** — Always presents a plan for user review. Asks questions when something could be native instead of custom.
- **Sync, don't redo** — Existing agents are reconciled against current state, not regenerated. Drift is surfaced; the user picks what to update.
- **Cross-platform** — Generates and syncs agents for Claude, Antigravity, and Copilot from the same analysis.

---

## Modes

| Mode | When to use | Behavior |
|------|------------|----------|
| (default, no args) | Any time | Auto-detects: no agents → init; agents + drift → sync; otherwise → status |
| `init` | Fresh project, or starting over | Discover, plan, generate, then stop (Phases 1–6) |
| `sync` | Code or FOUNDATIONS.md changed since agents were generated | Reconcile existing agents against current state. See `references/guides/SYNC.md`. |
| `status` | Read-only inventory | What agents exist, what they own, what's drifted from FOUNDATIONS.md |

### Auto-detection rules

| Project state | Default mode |
|--------------|--------------|
| No agents in `.claude/agents/`, `.agents/agents/`, `.github/agents/` | → `init` (with FOUNDATIONS.md guard, below) |
| Agents exist + content drift detected (invariants/paths in agent body don't match FOUNDATIONS.md) | → `sync` |
| Agents exist + content matches | → `status` |

---

## FOUNDATIONS.md Guard

Before doing anything else, detect the project's state from observable signals — no markers, no metadata files. Two checks:

1. **Source file count** — run the same scan step 1.3 uses (see [DISCOVERY.md](references/guides/DISCOVERY.md)) (count `*.py`, `*.ts`, `*.go`, etc. excluding the standard exclusions). This tells you whether the project is small, medium, or large.
2. **Documentation state** — does `docs/FOUNDATIONS.md` exist? Does `docs/` have other files? Does `README.md` reference docs?

### State table

| Source files | FOUNDATIONS.md | Other docs | State | Action |
|--------------|----------------|------------|-------|--------|
| any | exists | any | **1: foundations available** | Continue to Phase 1 |
| > 20 | missing | yes (ARCHITECTURE.md, PRINCIPLES.md, etc.) | **2: dockit ran but pre-foundations** | Recommend `/dockit sync` |
| > 20 | missing | no | **3: no docs at all** | Recommend `/dockit init` |
| ≤ 20 | missing | any | **4: small project** | Confirm with user, then custom-code-only flow |

The size check is the same one step 1.3 already runs — we just do it once up front so the guard can branch on it.

### How to respond per state

**State 1** → continue to Phase 1.

**State 2 (medium/large project, no foundations layer)** → recommend **sync**:

> Your project already has documentation in `docs/`, but `docs/FOUNDATIONS.md` is missing. That's the foundations registry agentkit needs — it lists which code is load-bearing across features, with invariants and consumers.
>
> Recommended: `/dockit sync` — it adds FOUNDATIONS.md to your existing doc set without restructuring anything else. Then re-run `/agentkit`.
>
> (Avoid `/dockit init` here — that's for fresh projects and may restructure your existing docs.)

**State 3 (medium/large project, no docs)** → recommend **init**:

> No documentation found in this project. agentkit relies on `docs/FOUNDATIONS.md` (and benefits from `docs/ARCHITECTURE.md`) to generate agents that understand the codebase.
>
> Recommended: `/dockit init` — first-time setup, generates the full doc set including FOUNDATIONS.md. Then re-run `/agentkit`.

**State 4 (small project, ≤20 source files)** → ask, then proceed without foundations:

> This project has [N] source files — small enough that a foundations registry is overkill. Dockit's small-project mode skips FOUNDATIONS.md by design.
>
> Want me to generate a single project-expert agent covering all custom patterns? (No foundations, no per-foundation maintenance — just an SME agent for what's in the codebase.)

If the user confirms, run the custom-code-only flow: step 1.4 in [DISCOVERY.md](references/guides/DISCOVERY.md) (custom-code scan) and step 3.2 in [ANALYSIS.md](references/guides/ANALYSIS.md) (custom-code assessment). No Owned Foundations sections, no Maintenance sections. Use `agent.template.md`, not `foundation-agent.template.md`.

### Wait, don't fill the gap

In states 2 and 3, **stop and wait** for the user to run dockit. Do not:
- Ask the user open-ended questions about the project's direction or future features (that's not agentkit's job — see "Scope Boundary" below)
- Try to infer foundations on the fly by reading the codebase yourself (dockit's scoring methodology is not something agentkit reproduces)
- Generate agents anyway with weaker context

---

## Scope Boundary

**Agentkit reads what exists; it does not propose what could be.**

Out of scope:
- Suggesting new features the team might want
- Proposing architectural improvements or refactors
- Recommending framework upgrades (read the version, work with what's there)
- Asking the user about future direction or where they'd like to take the project

Why: agents are generated to support the team's **current** codebase. Speculation about future directions belongs in the team's planning process, not in the agent-generation conversation. Asking the user "where do you want to take this" wastes their time and produces agents that drift from reality.

If the user asks agentkit a future-direction question (e.g., "what features should we add?"), redirect: *"That's one for your team's planning process. Agentkit's job is to set up agents for what's in the codebase today — want me to proceed with that?"*

---

## Phase 1: Discovery

All automatic. Do not ask the user for anything detectable — every input here is observable from the repo, and asking for it wastes the user's time and invites answers that contradict the code.

| Step | Produces |
|------|----------|
| 1.0 Read `FOUNDATIONS.md` | The lead input: catalog rows, per-foundation agent payload |
| 1.1 Detect dependencies and versions | Framework and version, from the manifest |
| 1.2 Research framework capabilities | What's native, so custom code can be told apart from it |
| 1.3 Scan project structure | Source file count — sets the size tier the whole run scales to |
| 1.4 Find custom and extended code | The delta between what the framework gives you and what the team built |
| 1.5 Detect and review existing agents | Whether this is an init or a reconcile |

**Read [`references/guides/DISCOVERY.md`](references/guides/DISCOVERY.md) before running this phase** — it holds the per-step detection recipes, the language-specific scans, and the exclusion rules. The table above is the contract between phases; the guide is how each step is actually performed.

---

## Phase 2: User Preferences

Ask only what cannot be detected. **Maximum 3 questions.**

### Question 1: Target Platforms

Skip if `$ARGUMENTS` specifies a platform (e.g., `/agentkit claude`).

> Which platforms should I generate agents for?
> - Claude
> - Antigravity
> - Copilot
> - All (recommended)

### Question 2: Foundations to Skip

Only ask if FOUNDATIONS.md has 4+ foundations and the user wants to scope down.

> FOUNDATIONS.md lists [N] foundations: [list with paths].
> Any you'd like to skip (e.g., owned by a different team, planned for sunset)?

### Question 3: Custom Code Folding

Only ask if custom-code areas were found that don't clearly belong to a foundation.

> I found custom code in these areas that aren't directly tied to a FOUNDATIONS.md row:
> [list areas with file counts and nearest foundation by domain].
>
> Fold each into the nearest foundation agent, or create a separate domain-expert agent? (For most cases, folding keeps agent count low and triggering reliable.)

---

## Phase 3: Analysis

Turn discovery output into a proposed agent set. Two assessments run, then grouping.

| Step | Produces |
|------|----------|
| 3.1 Foundation assessment | One candidate owner per `FOUNDATIONS.md` row (skipped when there's no registry) |
| 3.2 Custom-code assessment | Candidates for the custom patterns discovery found, native alternatives ruled out |
| 3.3 Grouping into agents | The merge/split decision — fewer, broader agents by default |

**Read [`references/guides/ANALYSIS.md`](references/guides/ANALYSIS.md) before running this phase** — it holds the assessment format, native-alternative detection, and the grouping rules. Grouping also depends on [`AGENT-SIZING.md`](references/guides/AGENT-SIZING.md), which owns the change-coupling principle, the split triggers, and the per-agent budgets.

The output of this phase is the plan the user reviews in Phase 4. Nothing is written until they accept it.

---

## Phase 4: Plan and User Review

Present the analysis as a plan. **Do not generate any files yet.**

**Read [`references/guides/REPORTING.md`](references/guides/REPORTING.md) before presenting** — it owns the four-field agent block, the full plan format, the review block for hand-authored agents, and the rule that reports state decisions rather than ask questions. Sync's **New** section uses the same agent block, so the shape is learned once.

The plan covers, in this order: the agent blocks, the routability check, per-agent budgets, custom code folded in, assumptions the reader may want to correct, anything left uncovered on purpose, and a closing line saying what will be written and how to reshape it.

Two rules that decide what belongs in it:

- **A foundation's name appears once**, in the agent that owns it. A foundation *attribute* appears only when it's the reason for a decision.
- **No working-directories table.** Catalog paths are derivable; only departures from the catalog are worth reporting.

**Nothing is written until the user accepts the plan.** That gate is real — what the plan doesn't do is open with a confirmation prompt or close with a questionnaire.

---

## Phase 5: Generation

Write the agent files. Only runs after the user approves the Phase 4 plan.

| Step | Produces |
|------|----------|
| 5.1 Load platform specs | The frontmatter shape for each target platform |
| 5.2 Pick the right template | `foundation-agent.template.md` when the agent owns registry rows, `agent.template.md` otherwise |
| 5.3 Generate agent files | The agents themselves, per platform |
| 5.4 Update instruction files | The pointer that lets the platform find them |

**Read [`references/guides/GENERATION.md`](references/guides/GENERATION.md) before writing any file** — it holds the per-platform frontmatter requirements, the hot-memory extraction rules, the exemplar-selection rule, the self-sufficiency check, and what each template expects. Platform field names and enforcement differ in ways that fail silently, so [`references/platforms.md`](references/platforms.md) is the authority on those.

Descriptions drive routing, so they come from each foundation's `Use when` lines rather than being re-derived — see [`DESCRIPTION-WRITING.md`](references/guides/DESCRIPTION-WRITING.md).

---

## Project Agents

The following agents are project-specific experts generated by agentkit. They own
foundations from `docs/FOUNDATIONS.md` (where applicable) and should be consulted
for their areas of expertise — including doc maintenance when foundations change.

| Agent | Owns Foundations | Expertise | Trigger When |
|-------|------------------|-----------|--------------|
| [agent-name] | [foundation list, or "—"] | [custom area] | [when to use] |

### Agent Routing

| If you're working with... | Consult |
|--------------------------|---------|
| [file pattern or directory] | [agent-name] |
| Updating FOUNDATIONS.md for `<foundation>` | [agent-name that owns it] |
| Cross-doc consistency check after foundation change | [agent-name that owns it] |
```

If the instruction file already has a `## Project Agents` section (from a previous agentkit run), **replace** that section rather than duplicating it.

#### If instruction file does not exist

Inform the user:

> No `CLAUDE.md` found. Run `/init` first to create your base instruction file — it will set up project conventions and build commands. Then re-run `/agentkit` or ask me to add the agent routing section.

Do not create instruction files from scratch — that is `/init`'s job. Agentkit only enriches existing ones.

#### Instruction file content per platform

**Claude (CLAUDE.md):**
- Agent routing table with trigger descriptions
- Note that agents live in `.claude/agents/`
- Include `<example>` trigger scenarios for each agent

**Antigravity (GEMINI.md or AGENTS.md):**
- Agent routing table
- Note that agents live in `.agents/agents/`
- Use whichever file already exists at the workspace root; if neither does, create `AGENTS.md`. Do **not** create both — Antigravity parses either, and two files means two places to drift.
- Do NOT emit the old `experimental.enableAgents` reminder — that was a Gemini CLI flag and does not apply to Antigravity

**Copilot (.github/copilot-instructions.md):**
- Agent routing table
- Note that agents live in `.github/agents/`
- Keep concise — Copilot instruction files should be focused

---

## Phase 6: Completion — Stop Here

Once Phases 1–5 are done, **stop**. Agentkit's job is finished. The agents are tools waiting on the shelf, not a team standing by for orders.

### Final summary to the user

Print a short closing summary:

```
Done. Created [N] agents:
  - <agent-1>  →  <platform paths>
  - <agent-2>  →  <platform paths>

Foundations covered: [list]
[If any] Hand-authored agents reviewed (not modified): [list with one-line recommendation each]
[If any] Instruction file updated: <path>

The agents are ready. They activate when you (or your AI assistant) actually need them.
```

That's the end. Return control to the user.

### Do NOT do any of these after generation

- **Don't ask "want me to test the agents?"** — there is nothing to test until a real feature or task arrives that calls for one of them.
- **Don't invoke an agent yourself to "verify it works."** — invoking agents costs tokens and doesn't validate anything meaningful in a vacuum. The first real feature that uses an agent IS the validation.
- **Don't suggest example tasks the user could try.** — the user knows their own work; you don't need to invent practice problems.
- **Don't ask "what would you like me to do next?"** — nothing is implied next. If the user has another task, they'll bring it.
- **Don't summarize the project's architecture** — you're not a product manager.

### Why agents wait

Sub-agents auto-trigger when their description matches user intent during real work, or get name-called explicitly (*"ask the auth agent about..."*). Until that real work arrives, an agent that's been generated and an agent that's been generated-and-tested are functionally identical to the user. There's no "warming up" to do.

The same applies to foundation-owner maintenance: the agent updates FOUNDATIONS.md *when its foundation changes in code*, not on a "let's see if it works" trial run.

### What the user can do later (informational, not prompted)

If the user asks what comes next, mention:

- The agents will auto-trigger when their description matches a task. Nothing to do.
- They can name-call an agent: *"have the data-layer agent look at this query"*
- When the codebase changes meaningfully: `/dockit sync` then `/agentkit sync` — that's the maintenance loop
- Feature planning is out of scope — agentkit documents the codebase that exists

But only mention these **if asked**. Don't list them unprompted.

---

## Sync Mode

`/agentkit sync` reconciles existing agents with the current state of FOUNDATIONS.md and the codebase. Full logic in [`references/guides/SYNC.md`](references/guides/SYNC.md).

### Flow

1. **Inputs** — gather existing agents, current FOUNDATIONS.md, code state
2. **Drift scan** — classify findings into six categories: orphaned, missing, path drift, invariant drift, status drift, and **trigger coverage gaps**
3. **Apply** — fix every agent the catalog already settled, without prompting: paths, statuses, invariant wording and tier, orphaned references, module-split rescopes, unowned catalogued foundations, missing platform copies. Edits stay inside agent files
4. **Report** — four sections: *Updated* (a table of what changed on existing agents), *New* (agents sync created, in the same four-field block init uses), *Left for you* (what it deferred and why), *Noted* (too small to act on). Close with a recommendation and its alternatives, never a question. Format and readability rules in [SYNC.md](references/guides/SYNC.md#sync-output-format)

**Sync acts; it doesn't interview.** The line is authority, not risk: *apply it when `FOUNDATIONS.md` already decided; defer it when applying would mean deciding.* So sync defers exactly four things — deleting an agent file (destructive), editing `FOUNDATIONS.md` (dockit's, never agentkit's), creating an agent for **uncovered code** (the catalog is silent on those directories, so that judgment is the user's), and folds that fail the layer test or breach the size budget. Everything else it fixes and reports.

Write the report for an engineer who didn't build the agent set and doesn't know agentkit's vocabulary: verdict first, no `none` sections, findings labelled by **agent name** (never by a platform config file), full paths, no "see above" cross-references. Four lines per deferred item — offer `explain <n>` rather than wrapping a paragraph. Close by naming the files touched and noting `git diff` reverses it.
Edits land in agent files in place; the `agentkit-managed` marker stays as-is (no timestamp). Cross-doc hits go in the report, never into the docs.

Categories 1–5 compare each agent against `FOUNDATIONS.md`. Category 6 compares the **agent set against the code** — directories, inheritance roots, and split modules that trigger no agent at all. That gap can't be seen from inside the agent set, so the scan runs every sync. It's also the one category that always defers, because the catalog is silent on uncovered code by definition. When closing one, apply the layer test in AGENT-SIZING.md: widening an agent until the report goes green trades a blindspot for an over-triggering agent.

### What sync does NOT do

- Re-run dockit's foundation detection (that's `/dockit sync`). Category 6 may **count** files and subclasses; it never scores, ranks, or writes a `FOUNDATIONS.md` row
- Rewrite invariants *silently* — it fixes them to match the catalog and prints the before/after
- Delete agent files, or create agents for uncovered code
- Auto-overwrite hand-authored agents (no `agentkit-managed` marker → warn and recommend, never replace)
- Modify source code or doc files

### Multi-platform sync

When the same agent exists on multiple platforms, sync applies the same change to all platforms in one pass. If an agent exists on only one platform, that's a **platform gap**: generate the missing copies and report it. The team already decided the agent should exist. (Not to be confused with a trigger coverage gap — code no agent covers on any platform.)

---

## Status Mode

`/agentkit status` runs the drift scan in read-only mode — no actions, just a report. It's sync's dry run, which is why sync needs no `--dry-run` flag. Use it to:

- Inventory what agents exist and what they own
- See which foundations are uncovered, and which source directories trigger no agent
- Look at the drift before sync changes anything

Output format in [`references/guides/SYNC.md`](references/guides/SYNC.md) under "Status Mode."

---

## Integration with /init and Other Skills

Agentkit builds on each platform's `/init` command and other repokit skills:

```
/init          → Base instruction file (conventions, build commands, project overview)
/dockit        → Human + AI docs, including FOUNDATIONS.md (the source of truth for agentkit)
/agentkit      → Foundation-owner agents + custom-code experts + routing in instruction file
```

**Recommended flow for new projects:**
1. Run `/init` to create the base instruction file
2. Run `/dockit init` to generate project documentation including FOUNDATIONS.md
3. Run `/agentkit` to generate foundation-owner + domain-expert agents
4. As the codebase evolves, run `/dockit sync` then `/agentkit sync` to keep both layers fresh

**Maintenance loop:**
- Code changes → `/dockit sync` (refreshes FOUNDATIONS.md catalog) → `/agentkit sync` (reconciles agents to new state)
- For routine doc updates, invoke the foundation-owner agent directly — it knows how to update its FOUNDATIONS.md row, the per-foundation sub-doc, and run the cross-doc consistency check.

Each tool owns its section of the instruction file. `/init` owns the foundation, `/dockit` owns the doc set including FOUNDATIONS.md, and `/agentkit` owns the agent routing table — and the agents themselves now own ongoing FOUNDATIONS.md maintenance for their assigned rows.

---

## What This Skill Does NOT Do

- **Does not hardcode framework knowledge** — discovers everything dynamically
- **Does not create agents without approval** — always presents a plan first
- **Does not create user-level agents** — all agents go in project directories
- **Does not modify hand-authored agents** — agents without the `agentkit-managed` marker are read-only to agentkit. They get a structured review (scope, foundation overlap, gaps, recommendation) but are never edited, overwritten, deleted, or stamped with the marker. Even on user request to "regenerate everything," agentkit asks before touching them.
- **Does not auto-overwrite agentkit-generated agents** — those are reconciled via sync against FOUNDATIONS.md, never silently replaced
- **Does not create agents for native framework features** — only for custom/extended code or foundations
- **Does not modify project source code** — only reads source code; writes agent files and (with foundation-owner permissions) doc files under `docs/`
- **Does not create instruction files** — that is `/init`'s job; agentkit only enriches them
- **Does not run dockit's foundation detection** — agentkit reads FOUNDATIONS.md but never re-scores foundations. If detection seems stale, recommend `/dockit sync`.
- **Does not write task files** — agentkit surfaces drift in its report; tracking it is the team's call and recommends
- **Does not invoke or test the generated agents** — after Phase 5, agentkit stops. Agents activate during real feature work, not during a post-generation "verification" step. There's nothing to demo.

## Audience

- Teams that want AI assistants to understand their custom code patterns
- Projects with significant framework extensions or custom conventions
- Monorepos where different services have distinct custom patterns
- Any project where AI keeps reinventing what the team already built
