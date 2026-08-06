# Agent Sizing Guide

How to determine the right number and scope of agents for a project.

## The Core Test

Before creating any agent, ask: **"Would an AI assistant get this wrong without project-specific context?"**

If the answer is no — if standard framework knowledge is sufficient — skip the agent. Agents exist to close the gap between what AI knows generically and what your project does specifically.

## When to Create an Agent

**This section and the next govern the custom-code-only path** — projects with no `docs/FOUNDATIONS.md`. When foundations exist, a catalog row is the team declaring the code load-bearing, so the question is never *whether* it gets an owner but *which* agent owns it: see [Split triggers](#split-triggers). The Core Test above stays in force on both paths, and applies to coverage gaps either way.

Create an agent when ALL of these apply:

1. **Custom code that looks like framework defaults** — The project overrides or extends framework behavior in ways that AI would miss. This is the most dangerous category: AI confidently writes "correct" code that breaks the project's patterns.
2. **Multiple files follow the same custom convention** — A shared pattern across 3+ files indicates a team convention worth teaching. Isolated one-offs don't justify an agent.
3. **Project-specific knowledge is required** — The pattern can't be understood from framework docs alone. Someone needs to know *this project's* approach.
4. **Getting it wrong is expensive** — Breaking the pattern causes bugs, inconsistencies, or significant rework. Low-stakes deviations don't need enforcement.

## When NOT to Create an Agent

- Standard framework usage with no custom extensions
- Boilerplate (inherits from framework base, adds nothing)
- Single configuration overrides
- Legacy/unused code (no imports, no recent commits)
- A native framework feature handles this (flag for user, suggest removal)
- An existing agent already covers this area
- Isolated single-file customizations (unless extremely complex)
- Patterns already documented in project docs or instruction files

## Agent Count Is an Output

Count is derived, never chosen. Start from one agent owning everything, split only when a [trigger](#split-triggers) fires, and the number that falls out is the right one. There is no target and no ceiling on the total. Two **per-agent** budgets bound the result, and they are the only numbers in this guide:

- **Size budget** — 10,000 characters of body, 12 patterns, 6 working directories, 5 owned foundations. Past any of these, an agent knows its territory too shallowly to advise on it. Full table: [GENERATION.md](./GENERATION.md) § Size check.
- **Routability** — every agent's `description` must be distinguishable from every other agent's in the set without reading the bodies. See [Check routability before proposing the set](#check-routability-before-proposing-the-set).

Both are per-agent, so they bound the system from the other end: merging is the default, and count rises only when a trigger fires or a budget forces a split. A large agent set is therefore evidence about the project — many genuinely uncoupled areas — not a number to be brought down.

Project shape still suggests a starting strategy:

| Size | Source Files | Strategy |
|------|-------------|----------|
| Small | 1–20 | Single "project-expert" agent covering all custom patterns |
| Medium | 21–50 | One agent per major custom area |
| Large | 51+ | Specialized agents; may split by service in monorepos |

## Counting Source Files

Count files with these extensions, excluding generated/vendor directories:
- Python: `.py`
- JavaScript/TypeScript: `.js`, `.ts`, `.tsx`, `.jsx`
- Go: `.go`
- Rust: `.rs`
- Java/Kotlin: `.java`, `.kt`
- Ruby: `.rb`
- PHP: `.php`

Exclude: `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`, `__pycache__/`, `migrations/`, generated files.

## Grouping Rules

### Merge small clusters
If a custom code area has fewer than 3 files, merge it into the nearest related agent rather than creating a standalone agent.

### Never create single-file agents
Unless the file is highly complex (100+ lines of custom logic, multiple classes, or a critical base class that the entire project inherits from).

### Group by relationship, not by type
Prefer grouping by domain ("payment processing" agent covers payment models + payment middleware + payment serializers) over grouping by type ("all middleware" agent).

Exception: if the custom code IS the type — e.g., a project with 15 custom Wagtail blocks should get a "custom-blocks" agent, not split blocks across domain agents.

### Monorepo splitting
For monorepos with distinct services:
- If services share custom patterns → one shared agent
- If services have independent custom code → one agent per service (within the max)
- Mix is fine: shared "data-layer" agent + per-service "service-x-api" agent

## Scope Preferences

When the user chooses:
- **Broad agents** — aim for the lower end of the range. Combine related areas.
- **Focused agents** — aim for the higher end. Keep areas separate for precise triggering.
- **No preference** — default to broad for maintainability.

---

## Foundations as Input

When `docs/FOUNDATIONS.md` exists (generated by dockit), it becomes the **primary input** for agent grouping. Custom-code analysis still runs, but foundations lead — the rest gets folded into them.

### Grouping Principle: Change-coupling beats domain-tidiness

**When in doubt, merge.** The default failure mode for agentkit is *over-specialization*, not under-specialization.

Two agents that each own one tightly-related foundation will drift apart whenever a feature touches both — and most features touch multiple foundations. The coordination cost of "ask agent A, ask agent B, reconcile" is paid every single feature, forever. The cost of one slightly broader agent is paid once, at planning time.

This is the **Common Closure Principle** (Robert C. Martin) applied to agents: *things that change for the same reason belong together.* Operationalised: group foundations into one agent when **a typical feature would update them together**. That's the test.

#### The test

Before splitting two foundations into separate agents, ask:

> *"If a feature came in that needed to touch both, would I be OK with the human (or LLM) consulting two agents and merging their advice — every time, for the life of this project?"*

If you flinch, merge.

#### Signals that foundations change together

In rough order of strength:

1. **Shared change history** — they've appeared in the same commits historically. Use as a tiebreaker only — don't run heavy git analysis during planning, but if `git log --name-only --since=12.months -- <pathA> <pathB>` shows them co-occurring in 3+ commits, they're change-coupled.
2. **Shared consumers** — feature folders that import one tend to import the other; updating either to satisfy a new feature requires touching both.
3. **Joint invariants** — an invariant in foundation A references foundation B (e.g., *"every auth token must be issued by core.auth and validated by core.permissions"*).
4. **Same directory tree** — `core/auth/`, `core/auth/permissions/`. The team already grouped them spatially, which usually reflects how they think about features.
5. **Same domain** — auth, data layer, notifications. Weakest signal alone; combine with one of the above.

If two foundations hit ≥ 2 of these signals, **merge them**. If they hit 0–1, the case for keeping them separate is stronger.

### Split triggers

This is the whole authority for splitting a foundation off. **Any one is sufficient**; if none fires, group it.

| Trigger | Test |
|---------|------|
| **Different owner team** | The `Owner` field in FOUNDATIONS.md differs. A platform-team foundation and a feature-team foundation shouldn't share an agent even when they're related. |
| **Hotspot mismatch** | Its `health` is `hotspot` while the rest of the cluster is `healthy`. The hotspot's churn would force constant re-syncing of an agent that mostly didn't need it. |
| **Orthogonal invariants** | You cannot construct a feature that would touch both. If you can, they're change-coupled and this trigger hasn't fired. |
| **Different consumer base** | One serves a boundary the others don't — a public-API foundation among internal-only foundations. |
| **Size budget breach** | The merged agent would exceed 10,000 chars, 12 patterns, 6 working dirs, or 5 owned foundations. At that point merging hurts more than splitting, and this trigger overrides every argument for grouping. |

**Not triggers**, though each gets proposed as one: 5+ invariants, 10+ consumers, or having a per-foundation sub-doc. All three are normal for a healthy foundation and say nothing about coupling. A sub-doc matters only if the invariants inside it turn out to be orthogonal, which is the third trigger doing the work, not the sub-doc.

### Check routability before proposing the set

Delegation is decided by reading `description` fields, so a split only pays off if the descriptions can express it. Write each proposed agent's one-line description first, then for every pair in the set ask:

> *"Would a request that matches one of these plausibly match the other?"*

If yes, the boundary is wrong. Re-split along a boundary the descriptions can express, or merge the pair back and say in the plan that routability is why. **A split you can't describe is a split the router can't act on.**

When a pair is close but genuinely distinct, the fix is a mutual negative scope — each description points at the other for the boundary case. [DESCRIPTION-WRITING.md](./DESCRIPTION-WRITING.md) § Negative scope phrases owns how to write that; this guide only decides when it's required.

Run this on the proposed set in Phase 3, before the user sees the plan. A routing collision is cheap to fix in a plan and expensive to fix across six generated files. Sync re-runs it, because a foundation can drift into a neighbour's territory long after the boundary was drawn.

### Combined Agents (Foundation + Custom Code)

Custom-code findings from step 1.4 of [DISCOVERY.md](./DISCOVERY.md) don't get their own agents when foundations are present. Instead, fold them into the foundation agent whose directory or domain they overlap with:

| Custom-code finding location | Folds into |
|------------------------------|------------|
| Inside a foundation's directory tree | That foundation's agent |
| Imports a foundation as its base class | That foundation's agent |
| Same domain as a foundation (e.g., custom auth middleware vs. core auth foundation) | That foundation's agent |
| Unrelated to any foundation | A separate domain-expert agent (no foundation ownership) |

The goal: **fewer agents, each with broader ownership**. Two agents that both touch authentication will conflict on triggering. One auth agent that owns the foundation AND the custom middleware avoids that.

### Closing a coverage gap without inflating an agent

`agentkit sync` category 6 reports directories and inheritance roots that trigger no agent. The obvious fix — widen the nearest agent's `Working Directories` until the report goes green — is usually the wrong one, and it is what teams reach for first.

Observed in the field: an agent scoped to `components/` was missing `presenters/`, so the remedy proposed was to expand it to `dao/`, `dtos/`, `presenters/`, **and** `services/`. That closes four gaps and creates a worse problem. One agent now owns four architectural layers, its description must trigger on all of them, and it knows each shallowly. The blindspot is gone; a permanently over-triggering, thinly-informed agent has replaced it.

**A coverage report measures whether code has an owner. It does not measure whether the owner is any good.** Optimizing the first number at the expense of the second is a net loss.

#### The layer test

Before folding an uncovered directory into an existing agent, ask whether the new directory sits in the **same architectural layer** as what the agent already owns. Layer-denoting directory names, roughly:

```
controllers, routes, views, presenters, templates      → presentation
services, handlers, usecases, domain                   → application
dao, repositories, models, entities, dtos, schemas     → data
clients, adapters, gateways, integrations              → integration
utils, helpers, lib                                    → cross-cutting
```

| Situation | Action |
|-----------|--------|
| Same layer as the agent's existing dirs | **Fold.** This is the normal case. |
| Different layer, but ≥ 2 change-coupling signals (see above) | **Fold**, and name in the report which signals justified crossing the layer. |
| Different layer, 0–1 change-coupling signals | **Propose a new agent**, and check it for routability against the existing set before putting it in the plan. |
| Folding pushes the agent past 6 working dirs, 12 patterns, or 10,000 chars | **Split**, regardless of layer. The existing size budget wins. |

#### Budgets still bind

Coverage never justifies breaching a per-agent budget. If closing a gap would push an agent past its size budget or collide its description with another agent's, the honest report is *"this directory is uncovered, and folding it into `messaging` would take that agent to 7 working directories"* — not one agent stretched over three layers. Name the budget and the number. An uncovered directory the user has seen and accepted is a better outcome than a covered one whose owner can't advise on it.

**"We're out of agents" is never the reason.** Count isn't capped, so a gap stays open because it fails the Core Test or because closing it would breach a per-agent budget — never because the set is full.

#### Not every gap wants an owner

Apply the Core Test at the top of this guide. If an AI assistant would get the directory right from framework knowledge alone — thin CRUD, config, glue, generated output — the correct resolution is to leave it uncovered, list it under the report's "Noted" section, and not re-raise it as a finding on the next sync.

### When No Foundations Exist

If `docs/FOUNDATIONS.md` is absent, fall back to the original custom-code-driven grouping rules (the rest of this guide). But note: agentkit's preferred path is to ask the user to run `/dockit sync` (or `/dockit init`) first, since FOUNDATIONS.md is the durable source of truth that agents will sync against.
