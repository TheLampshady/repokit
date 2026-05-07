---
name: agentkit
description: 'Generate, sync, and maintain project-level AI subagents tailored to your codebase. Reads dockit FOUNDATIONS.md as the source of truth and analyzes custom code patterns, then creates agents that own foundations, understand custom extensions, and keep their own docs in sync. Modes: init, sync, status. Use when asked to: create agents for this project, generate AI helpers, set up subagents, sync project agents, check agent drift, update agents after foundation changes, help AI understand my custom code, create coding assistants, generate project agents. Supports Claude, Gemini, and Copilot.'
user-invocable: true
argument-hint: "[init|sync|status] [claude|gemini|copilot|all]"
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
- **Cross-platform** — Generates and syncs agents for Claude, Gemini, and Copilot from the same analysis.

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
| No agents in `.claude/agents/`, `.gemini/agents/`, `.github/agents/` | → `init` (with FOUNDATIONS.md guard, below) |
| Agents exist + content drift detected (invariants/paths in agent body don't match FOUNDATIONS.md) | → `sync` |
| Agents exist + content matches | → `status` |

---

## FOUNDATIONS.md Guard

Before doing anything else, detect the project's state from observable signals — no markers, no metadata files. Two checks:

1. **Source file count** — run the same scan Phase 1.3 uses (count `*.py`, `*.ts`, `*.go`, etc. excluding the standard exclusions). This tells you whether the project is small, medium, or large.
2. **Documentation state** — does `docs/FOUNDATIONS.md` exist? Does `docs/` have other files? Does `README.md` reference docs?

### State table

| Source files | FOUNDATIONS.md | Other docs | State | Action |
|--------------|----------------|------------|-------|--------|
| any | exists | any | **1: foundations available** | Continue to Phase 1 |
| > 20 | missing | yes (ARCHITECTURE.md, PRINCIPLES.md, etc.) | **2: dockit ran but pre-foundations** | Recommend `/dockit sync` |
| > 20 | missing | no | **3: no docs at all** | Recommend `/dockit init` |
| ≤ 20 | missing | any | **4: small project** | Confirm with user, then custom-code-only flow |

The size check is the same one Phase 1.3 already runs — we just do it once up front so the guard can branch on it.

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

If the user confirms, run the custom-code-only flow: Phase 1.4 (custom-code scan) and Phase 3.2 (custom-code assessment). No Owned Foundations sections, no Maintenance sections. Use `agent.template.md`, not `foundation-agent.template.md`.

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

Why: agents are generated to support the team's **current** codebase. Speculation about future directions belongs in tickets (`tikkit:foundationtik`, `tikkit:modernizer`), not in the agent-generation conversation. Asking the user "where do you want to take this" wastes their time and produces agents that drift from reality.

If the user asks agentkit a future-direction question (e.g., "what features should we add?"), redirect: *"That's a question for `/tikkit:modernizer` (stack audit + improvement tickets) or your team's planning process. Agentkit's job is to set up agents for what's in the codebase today — want me to proceed with that?"*

---

## Phase 1: Discovery

All automatic. Do not ask the user for anything detectable.

### 1.0 Read FOUNDATIONS.md (lead input)

If `docs/FOUNDATIONS.md` exists, parse it as the **primary input** for agent grouping. Custom-code analysis (1.4) still runs but feeds into the foundation-led grouping.

Extract from FOUNDATIONS.md:

| Field | Source within doc | Used for |
|-------|-------------------|----------|
| Catalog rows | The `## Catalog` table | Names, paths, status, health, owner, last reviewed |
| Per-foundation entries | `## <Foundation Name>` sections | Public API, invariants, consumers, dependencies, refactor triggers, change checklist |
| Findings | `## Findings` (hotspots, hidden, pretenders) | Inform priority — hotspots get their own agent |
| Sub-doc presence | Existence of `docs/architecture/foundations/<slug>.md` | Marks the foundation as "heavy" — own agent |

For each foundation, record:
- **slug** (kebab-case from name)
- **path** and module name (for cross-doc grep)
- **status / health** (active / hotspot / etc.)
- **invariants** (verbatim — these go into agent hot memory)
- **change checklist** (verbatim)
- **consumer count and distinct features** (signals weight)

Skip foundations marked `status: sunset` or `health: pretender` — those are slated for removal, no agent.

### 1.1 Detect Dependencies and Versions

Read dependency files to build a complete picture of the project's stack:

| File | Language | What to Extract |
|------|----------|----------------|
| `pyproject.toml` | Python | `[project.dependencies]`, `[tool.poetry.dependencies]` |
| `requirements.txt` / `requirements/*.txt` | Python | Direct dependency list |
| `setup.py` / `setup.cfg` | Python (legacy) | `install_requires` |
| `package.json` | JavaScript/TypeScript | `dependencies`, `devDependencies` |
| `go.mod` | Go | `require` block |
| `Cargo.toml` | Rust | `[dependencies]` |
| `Gemfile` | Ruby | `gem` declarations |
| `composer.json` | PHP | `require` |
| `pom.xml` / `build.gradle` / `build.gradle.kts` | Java/Kotlin | Dependencies block |

For each dependency, record:
- **Name** and **pinned version**
- **Category**: framework, library, tool, or dev-only
- **Role**: backend framework, frontend framework, ORM, API layer, testing, etc.

### 1.2 Research Framework Capabilities

For each **major framework** detected (not every small library — focus on the 2-3 that define the project's architecture):

1. **Resolve library docs** — Use `context7` (resolve-library-id → query-docs) to pull current documentation
2. **Identify extension points at the project's pinned version** — Where does this framework expect teams to customize at the version this project uses? This tells you what `core/`, `middleware/`, `blocks/`, etc. are *supposed* to contain, so you can spot custom code that diverges from convention.
3. **Note the version, don't speculate about upgrades** — Record the framework version. Do NOT brainstorm what newer versions could offer or whether the team should upgrade — that's `tikkit:modernizer`'s job, not agentkit's. Stay grounded in what the codebase uses today.

**What counts as a "major framework":**
- Web frameworks (Django, FastAPI, Express, Rails, Spring, Gin, etc.)
- Frontend frameworks (React, Vue, Angular, Svelte, etc.)
- CMS/platform frameworks (Wagtail, WordPress, Strapi, etc.)
- ORM/data layers if heavily customized (SQLAlchemy, Prisma, etc.)

Do NOT research: testing libraries, linters, build tools, small utilities.

### 1.3 Scan Project Structure

Search for source files matching `*.py`, `*.js`, `*.ts`, `*.tsx`, `*.jsx`, `*.go`, `*.rs`, `*.java`, `*.kt`, `*.rb`, `*.php`. Exclude `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`, `__pycache__/`, and `migrations/`. Use platform-native search tools (Glob, find, etc.) and count the results.

Classify project size:

| Size | Source Files | Agent Strategy |
|------|-------------|---------------|
| Small | 1–20 | 1–2 agents max (single "project-expert" covering all custom patterns) |
| Medium | 21–50 | 2–4 agents (one per major custom area) |
| Large | 51+ | 3–5 agents (specialized; may split by service in monorepos) |

Detect structure type:
- **Monorepo** — multiple `package.json`/`pyproject.toml` files, or directories like `services/`, `packages/`, `apps/`
- **Single service** — one primary app directory
- **Library** — `src/` with no server/app entry point, published to a registry

### 1.4 Find Custom and Extended Code

This is the core of agentkit. For each major framework, scan for code that extends, overrides, or customizes framework behavior.

#### What to Look For

**Subclasses of framework base classes:**
- Python: Search for `class \w+\(` patterns in `*.py` files (exclude test files)
- JS/TS: Search for `extends \w+` patterns in `*.ts`, `*.tsx`, `*.js` files (exclude node_modules, test files)

**Files in conventional extension directories:**
Look for directories that indicate custom logic:
- `middleware/`, `middlewares/`
- `hooks/`, `custom_hooks/`
- `blocks/`, `components/`
- `plugins/`, `extensions/`
- `mixins/`, `decorators/`
- `managers/`, `querysets/`
- `validators/`, `permissions/`
- `signals/`, `receivers/`
- `templatetags/`, `filters/`
- `management/commands/`
- `context/`, `providers/`
- `services/`, `repositories/`
- `utils/`, `helpers/` (only if they wrap framework functionality)

**Custom patterns to detect:**
- Custom base classes that other project code inherits from
- Decorators defined in the project (not imported from libraries)
- Factory functions that produce framework objects with project-specific defaults
- Configuration files that significantly diverge from framework defaults
- Growing areas — directories with many files following the same custom pattern

**How to distinguish custom from boilerplate:**
- **Custom**: Has methods/logic beyond what the framework base provides. The team wrote behavior here.
- **Boilerplate**: Inherits from a framework class but adds nothing (or only standard config). No agent needed.
- **Borderline**: Small extensions (1-2 methods, simple overrides). Present to user for decision.

#### Grouping Findings

Group related custom code into agent-sized clusters:
- Same framework extension point → same agent (e.g., all custom middleware → one agent)
- Same domain/feature area → same agent (e.g., all payment-related custom code)
- Merge small clusters (<3 files) into the nearest related agent
- Never create an agent for a single file unless it's highly complex (100+ lines of custom logic)

### 1.5 Detect and Review Existing Agents

Check for pre-existing project agents:

| Platform | Path | Pattern |
|----------|------|---------|
| Claude | `.claude/agents/*.md` | All `.md` files |
| Gemini | `.gemini/agents/*.md` | All `.md` files |
| Copilot | `.github/agents/*.agent.md` | All `.agent.md` files |

#### Hard rule: never modify hand-authored agents

If an agent file does **not** contain the `<!-- agentkit-managed -->` marker, it is hand-authored. Agentkit treats those as off-limits:

- Do not overwrite
- Do not edit
- Do not append `agentkit-managed`
- Do not delete

Even if the user explicitly asks to "regenerate everything," ask before touching a hand-authored file. Hand-authored agents represent thought the team put in deliberately; rewriting them silently destroys that work.

The agentkit-generated agents (with the marker) follow the normal sync rules — those CAN be updated by sync mode without prompt.

#### What to do instead: review the agent

For each hand-authored agent, produce a structured review that the user reads in Phase 4. The review answers four questions:

1. **What does this agent do?** — read its frontmatter description and body. Summarize its scope in 1–2 lines.
2. **Which foundations does it touch?** — compare its scope against FOUNDATIONS.md catalog rows. An overlap exists when the agent's working directories, named patterns, or expertise area matches a foundation's path or domain.
3. **Where does it not align with the foundations registry?** — gaps relative to FOUNDATIONS.md: invariants the agent doesn't acknowledge, foundations in the same domain it ignores, change-checklist items it misses.
4. **How should it coexist with the agents agentkit would generate?** — identify whether agentkit's planned grouping would create coverage overlap, leave it as a useful specialist alongside the new agents, or supersede it entirely.

#### Detection signals for foundation overlap

The agent doesn't have to declare ownership for the analysis to find overlaps. Use these signals:

- **Path mention** — the agent's body or frontmatter references a foundation's path (e.g., `core/auth/`, `core.notifications`)
- **Working directory match** — the agent's "Working Directories" section (or equivalent) overlaps a foundation's directory tree
- **Domain match** — the agent's description names a domain that matches a foundation (auth, data, notifications, etc.)
- **Pattern match** — embedded code patterns reference a foundation's public API or invariant subject

#### Three recommendation types

For each hand-authored agent, end the review with one recommendation. **Don't apply the recommendation** — present it as an option for the user.

| Recommendation | When to use |
|---------------|-------------|
| **Keep as-is alongside generated agents** | Agent covers a niche the foundation registry doesn't (e.g., a vendor-SDK helper). Low overlap, useful specialist. Note potential triggering conflicts if any. |
| **Retire — covered by new agent** | Agent's scope is fully contained in a planned foundation-owner agent. The new agent will know more (it has FOUNDATIONS.md context). Recommend deletion after the user reviews. |
| **Merge content into a generated agent, then retire** | Agent has unique knowledge worth preserving (custom patterns, project-specific gotchas) but lives in a domain a new foundation-owner would cover. Recommend the user copy specific sections into the new agent's `Custom Patterns` before deleting. Identify which sections. |

If you can't decide between two recommendations, present both with the reasoning — the user picks.

#### Decision tree (agentkit-generated agents only)

For agents that DO have the `agentkit-managed` marker, the simpler rules apply:

| Situation | Default action |
|-----------|----------------|
| Marker + ownership matches current FOUNDATIONS.md + invariants/paths match | Skip — already in sync |
| Marker + ownership orphaned (foundation removed) | Flag for sync; don't generate a duplicate |
| Marker + content drift (invariants or paths disagree with FOUNDATIONS.md) | Flag for sync; don't generate a duplicate |
| No agent exists for a current foundation | Add to the plan as new |

---

## Phase 2: User Preferences

Ask only what cannot be detected. **Maximum 3 questions.**

### Question 1: Target Platforms

Skip if `$ARGUMENTS` specifies a platform (e.g., `/agentkit claude`).

> Which platforms should I generate agents for?
> - Claude
> - Gemini
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

Foundation-led when FOUNDATIONS.md exists; custom-code-led otherwise.

### 3.1 Foundation Assessment (when FOUNDATIONS.md present)

For each foundation from Phase 1.0, build:

```
Foundation: [name]
Slug: [kebab-case]
Path: [path]
Status: [active/deprecated/etc.]
Health: [healthy/hotspot/unknown]
Owner: [team/person from FOUNDATIONS.md]
Consumers: [count] across [N] feature folders
Invariants: [count]
Sub-doc: [path or none]
Custom code in same tree: [list areas + file counts]
```

Then apply the **Grouping Principle: Change-coupling beats domain-tidiness** from `references/guides/AGENT-SIZING.md`. Default to merging:

1. Start by assuming **one agent owns all foundations**.
2. For each foundation, run "the test" from AGENT-SIZING:
   > *"If a feature came in that needed to touch this foundation and another, would I be OK with the human (or LLM) consulting two agents and merging their advice — every time, for the life of this project?"*
3. Only split off a foundation when **change-coupling is genuinely absent** — different owner team, orthogonal invariants, hotspot/healthy mismatch, or different consumer base. See AGENT-SIZING § "When to keep foundations separate."
4. Apply the size budget as a final check — if a merged agent exceeds 10,000 chars body, split on the weakest change-coupling boundary.

The point is **fewer agents**. Two agents that both touch a feature when it lands will conflict on triggering and drift apart on maintenance. One agent with broader ownership keeps the picture coherent.

**Sanity ceilings (not targets):**

| Project | Soft ceiling on agent count |
|---------|------------------------------|
| Small (≤20 source files) | 1 |
| Medium (21–50) | up to 3 |
| Large (51+) | up to 5 |
| Large monorepo with services | up to 5 — per-service grouping wins |

Many projects should land below these. Numbers exist to flag "you've split too far," not to push you to split.

Custom-code findings (3.2) fold into the foundation agents — don't add separate agents unless the custom code is unrelated to any foundation.

### 3.2 Custom Code Assessment (always runs)

For each custom code area from Phase 1.4, build an assessment:

### Assessment Format

```
Area: [e.g., "Custom Wagtail StreamField Blocks"]
Extends: [framework feature/class being extended]
Framework: [name] @ [version]
Files: [count] ([list key files])
Complexity: low | medium | high
Custom logic: [brief description of what the team added]
Native alternative: [yes/no — if yes, explain what native feature could replace this]
Agent value: [why an agent helps here — what would AI get wrong without it]
```

### Native Alternative Detection

For each finding, check whether the framework handles this natively. Use the research from Phase 1.2.

**Flag as "native/skip" when:**
- The framework provides this exact functionality out of the box
- The custom code adds nothing beyond configuration
- A newer version of the framework (that the project could upgrade to) provides this natively

**Flag as "borderline — ask user" when:**
- The custom code is small (<20 lines) and extends a native feature minimally
- A newer framework version provides a similar (but not identical) native feature
- The custom code exists but may be legacy/unused

**Flag as "agent-worthy" when:**
- Significant custom logic that AI assistants would get wrong
- Custom base classes that other project code depends on
- Patterns that look like framework defaults but behave differently (the most dangerous for AI)
- Growing areas with many files following the same custom pattern

### 3.3 Grouping into Agents

Apply the scaling logic from `references/guides/AGENT-SIZING.md`:

**Foundation-led path (FOUNDATIONS.md present):**
1. Apply the Mapping Heuristic — produce the foundation→agent assignments
2. For each custom-code area (3.2), find the foundation it belongs to (same directory tree, extends a foundation, or same domain) and **fold it in**
3. Custom-code areas with no foundation home become separate domain-expert agents (no foundation ownership) — only if they pass the agent-worthy bar
4. Cap at 3–5 agents total; if over, merge the smallest

**Custom-code-only path (no FOUNDATIONS.md):**
1. Sort findings by file count (descending)
2. Group related findings (same framework area, same domain)
3. Apply project size limits
4. Merge small groups into larger ones
5. Name each proposed agent descriptively

---

## Phase 4: Plan and User Review

Present the analysis as a clear plan. **Do not generate any files yet.**

### Plan Format (foundation-led)

```markdown
## Proposed Agents

### Project: [name]  |  Size: [S/M/L]  |  Foundations: [N]  |  Agents Proposed: [N]

| # | Agent | Owns Foundations | Folded Custom Code | Working Dirs | Notes |
|---|-------|------------------|--------------------|--------------|-------|
| 1 | auth | core.auth, core.permissions | custom-middleware (4 files) | core/auth/, middleware/ | hotspot — 90d review due |
| 2 | data-layer | core.database, core.cache | custom-querysets (6 files) | core/db/, models/ | healthy |
| 3 | messaging | core.notifications | — | core/notifications/ | sub-doc exists |

### Domain-Expert Agents (no foundation ownership)
- [name] — [why it stands alone]

### Existing Agents (review only — won't be modified)

For each hand-authored agent (no `agentkit-managed` marker), present the structured review built in Phase 1.5. Do not modify any of these files; this is information for the user to act on.

```markdown
#### `.claude/agents/auth-helper.md` (hand-authored)

**Scope:** Helps with OAuth2 token management — refresh, scope validation, refresh-token rotation.

**Foundation overlap:**

| Foundation | Overlap | Notes |
|-----------|---------|-------|
| `core.auth` | partial | This agent covers tokens; the foundation also covers session lifecycle and replay-window enforcement |
| `core.permissions` | none | — |

**Gaps relative to FOUNDATIONS.md:**
- Doesn't acknowledge the `core.auth` invariant *"replay window must be enforced on all token validations"*
- No mention of the change checklist for auth foundations

**Recommendation: Merge content into the new `auth` agent, then retire**
- Copy the OAuth-specific patterns (token refresh, scope validation) from this agent into the new `auth` agent's `Custom Patterns` section
- Then delete `.claude/agents/auth-helper.md`
- Reasoning: the new `auth` agent will own `core.auth` from FOUNDATIONS.md plus this agent's specifics, and avoids the triggering conflict

(Other recommendation options shown if relevant: *Keep as-is alongside generated agents*, *Retire — covered by new agent*.)
```

If multiple hand-authored agents are present, repeat this block per agent. Don't lump them together — each gets its own scope/overlap/gaps/recommendation.

### Skipped Foundations
- [name] — [reason: sunset / pretender / user opted out]

### Skipped Custom Code (native alternatives exist)
- [area] ([N] files) — [why it's native]

### Borderline (your call)
- [area] ([N] files) — [why it's borderline, what the alternative is]

### Questions
1. Confirm the foundation→agent grouping above
2. [Any "did you mean to customize this?" questions]
3. [Any handling decisions for existing hand-authored agents]
```

### What to Ask About

Only ask questions that affect the **grouping plan above**. Don't ask the user about future direction, upgrades, or what features they might add — that's out of scope (see Scope Boundary).

- **Foundation grouping** — "I clustered `core.notifications` and `core.events` into one `messaging` agent (shared consumers, same domain). Split them?"
- **Heavy foundation own agent** — "`core.database` has its own sub-doc and 14 consumers. Recommend its own agent. OK?"
- **Folding custom code** — "Your `custom-paginator.py` lives near `core.api`. Folding into the api agent. OK?"
- **Borderline custom code** — "Your `CustomPaginator` adds only `max_page_size`. Skip this or include in the api agent?"
- **Existing hand-authored agents** — present the per-agent review (scope / foundation overlap / gaps / recommendation) and ask: "For each, do you want to (k)eep alongside, (r)etire, or (m)erge content first then retire?" Default: leave them untouched until the user picks.

**Don't ask the user about upgrade paths or native replacements.** If the agent's framework version has a known native replacement for one of its patterns (e.g., the project is on Wagtail 6.0 but 6.3 added `TableBlock`), put that in the generated agent's `Common Mistakes` or `Research` section as a *flag*, not as a question to the user during planning. Modernizer/foundationtik handle upgrade tickets — agentkit just records the fact.

**Wait for user approval before proceeding to Phase 5.**

---

## Phase 5: Generation

For each approved agent, generate agent files for each selected platform.

### 5.1 Load Platform Specs

Read `references/platforms.md` to get the exact frontmatter format and platform quirks for each target. Pay attention to the **foundation-owner frontmatter** section — frontmatter differs based on whether the agent owns foundations.

### 5.2 Pick the Right Template

| Agent type | Template |
|------------|----------|
| Owns ≥1 foundation from FOUNDATIONS.md | `references/templates/foundation-agent.template.md` |
| Domain-expert with no foundation ownership | `references/templates/agent.template.md` |

Foundation-owner agents get extra sections: `Owned Foundations`, `Invariants (hot memory)`, `Maintenance` (with cross-doc check + invariant change protocol). See `references/guides/FOUNDATION-MAINTENANCE.md` for what each section must contain.

### 5.3 Generate Agent Files

For each agent, follow this sequence — frontmatter first, body second, validate, then write. Skipping any step (especially the frontmatter step) produces an inert agent file that no platform can discover.

#### Step 1 — Build the frontmatter (REQUIRED on every platform)

Every agent file starts with frontmatter. Two fields are non-negotiable:

| Field | Purpose | Without it |
|-------|---------|-----------|
| `name` | Identifier — what the agent is called for routing/triggering | Some platforms reject the file; on others the filename is used silently |
| `description` | When to trigger and what the agent does — primary mechanism for auto-invocation | The agent never auto-triggers; it only exists if name-called |

**Compose `name`:** kebab-case from the agent's domain (e.g., `auth`, `data-layer`, `messaging`). Match the filename you'll write to.

**Compose `description` — scope-bounded.** This is the field that decides when the host AI delegates to this agent. The description has to do **two jobs**:

1. **Define positive scope** — what the agent owns: foundations by name, working directories with paths, file patterns. Use concrete codebase references, not topic words. *"Use when modifying `core/auth/`"* triggers correctly; *"Use for auth"* triggers on every casual auth mention.
2. **Define negative scope** — what looks similar but should NOT trigger this agent: generic library questions, third-party SDK help, work in other parts of the codebase, adjacent areas owned by other agents.

A description with only positive scope **over-triggers** (the agent fires on topical keywords like "JWT" or "database" even when the work isn't in its territory). A description with only negative scope under-triggers. Both are required.

**Per-platform pattern:**
- **Claude** — include at least one negative `<example>` showing a query that sounds related but should NOT trigger this agent. Claude uses these to learn the boundary.
- **Gemini / Copilot** — include an explicit "Do NOT use for:" clause naming the near-misses.

**Foundation-owner skeleton:**

```
Owner of [foundation list] in [project name]. Use when:
- modifying code in [working directories]
- modifying code that imports from [foundations]
- updating FOUNDATIONS.md entries for [foundations]
- [foundation-specific triggers]

Do NOT use for:
- generic [topic] questions unrelated to this project
- third-party SDK help
- work in other parts of the codebase that do not import [foundations]
- [adjacent areas owned by other agents]
```

Keep the full description under 1024 characters. Full pattern guide with examples per platform: [`references/guides/DESCRIPTION-WRITING.md`](references/guides/DESCRIPTION-WRITING.md).

**Add platform-specific fields:** read `references/platforms.md` and add them. For foundation-owner agents:

- **Claude** — `tools: Read, Edit, Write, Glob, Grep, Bash` plus `permissionMode: acceptEdits` (Claude enforces both — without them the agent can't edit `docs/`)
- **Copilot** — include `editFile`, `createFile`, `terminal` in `tools` (Copilot enforces the allowlist)
- **Gemini** — do NOT add a `tools:` field. Gemini doesn't enforce it. Scope is governed by the body's YOLO note (foundation-owner variant authorizes editing `docs/`), the description, and the agent's self-policing — not frontmatter. Adding a `tools` list creates false confidence.

#### Step 2 — Build the body (once, shared across platforms)

**Always include (both templates):**

1. **Architecture Context** — pull the relevant excerpt from `ARCHITECTURE.md` or `README.md`. Keep to 5-10 lines. If no docs exist, summarize from code.

2. **Working Directories** — list the directories this agent operates in.

3. **Framework Context** — framework name and version. What's native vs what's custom in this area.

4. **Conventions** — extract from actual code patterns: naming, file organization, error handling, tests.

5. **Custom Patterns (hot memory)** — for the 2-3 most critical patterns, **read the source files** and embed real code snippets. Prose for the rest.

6. **Key Files** — table with "read when" guidance.

7. **When to Trigger** — scenarios with examples.

8. **Common Mistakes** — what AI gets wrong without this agent.

9. **Research** — project docs first, framework docs via context7 second, check for native alternatives third.

**Additional sections for foundation-owner agents (from foundation-agent.template.md):**

10. **Owned Foundations** — table of foundations this agent owns (name, path, status, sub-doc).

11. **Invariants (hot memory)** — copied verbatim from FOUNDATIONS.md per foundation.

12. **Public API (hot memory)** — code blocks pulled from FOUNDATIONS.md per foundation.

13. **Maintenance** — Change Checklist (verbatim from FOUNDATIONS.md), When to Update Docs table, Invariant Change Protocol, Cross-Doc Consistency Check.

14. **agentkit-managed marker** — HTML comment near the top of the body: `<!-- agentkit-managed -->`. Marks the agent as agentkit-generated so sync mode knows it's safe to update without prompting; hand-authored agents (no marker) are always treated as off-limits unless the user opts in.

#### Step 3 — Pre-write validation (do not skip)

Before writing the file, confirm every requirement is satisfied:

| Check | Required value |
|-------|----------------|
| Frontmatter starts with `---` and ends with `---` | yes |
| Frontmatter contains `name:` | yes, kebab-case, matches filename |
| Frontmatter contains `description:` | yes, includes positive scope (paths/foundations), negative scope ("Do NOT use for" or negative `<example>` on Claude), and "Use when..." triggers; under 1024 chars |
| Frontmatter contains platform-specific required fields | per `platforms.md`: **Claude** foundation-owners need `tools` + `permissionMode: acceptEdits` (both enforced); **Copilot** foundation-owners need `editFile`/`createFile`/`terminal` in `tools` (enforced); **Gemini** does NOT enforce frontmatter tools — do NOT add a `tools` field on Gemini, scope comes from the body |
| Body has `<!-- agentkit-managed -->` near the top | yes (agentkit-generated agents only) |
| Body has Owned Foundations + Maintenance sections | yes (foundation-owner agents only) |

**If any check fails, fix it before writing.** Do not write a file without `name` and `description` — that produces a file no platform discovers. It's worse than not generating the agent at all, because the user thinks they have an agent and don't.

#### Size check — split if too large

After building the body, check its size. An effective agent needs enough context to be useful but not so much that it becomes bloated or hits platform limits.

**Target size per agent:**

| Metric | Target | Split Signal |
|--------|--------|-------------|
| Body length | 3,000–8,000 characters | >10,000 characters |
| Embedded code snippets | 2–3 critical patterns | >5 snippets |
| Custom patterns covered | 3–10 per agent | >12 patterns |
| Working directories | 1–4 directories | >6 directories |

**If an agent exceeds the split signal:**

1. Look for a natural domain boundary to divide on (e.g., "custom blocks" and "custom page types" instead of one "wagtail-customs" agent)
2. Split into two focused agents, each with their own hot memory
3. Re-check that each resulting agent still covers 3+ files (don't create tiny agents)
4. Update the plan and confirm with the user before generating

**Splitting is better than trimming.** Two focused agents with rich context outperform one bloated agent with thin coverage. The goal is: each agent has enough embedded knowledge to be useful *without reading any files*, but stays focused enough to trigger reliably.

**Granularity guard — do NOT create:**
- One agent per class or file (too specific, triggers overlap)
- One agent per base class (unless 10+ files inherit from it)
- Agents for isolated utilities with no shared pattern

The right level is **one agent per domain area**: a group of related custom code that shares conventions, directories, and framework extension points.

#### Per-platform frontmatter quirks (reference)

Frontmatter is built in Step 1, but the platform-specific fields differ. Crucially, **Gemini does not enforce frontmatter `tools` or any permission mode** — the body's YOLO note + description + self-policing instructions are what scope a Gemini agent. Recap of what `platforms.md` covers:

**Default agents (no foundation ownership):**
- Claude: `<example>` blocks inside the description string; no `permissionMode` needed; `tools` optional
- Gemini: read-only YOLO note in body; **no `tools:` field** (Gemini ignores it); `model`, `temperature`, `max_turns`, `timeout_mins` are honored
- Copilot: keep total file size under 30,000 chars; tools allowlist IS enforced

**Foundation-owner agents:**
- Claude: `tools: Read, Edit, Write, Glob, Grep, Bash` plus `permissionMode: acceptEdits` (both enforced)
- Gemini: foundation-owner YOLO note in body (authorized to edit `docs/`, forbidden outside it); `max_turns: 20`; **still no `tools:` field**. Scoping comes from the body, not frontmatter.
- Copilot: include `editFile`, `createFile`, `terminal` in tools (enforced)

#### Step 4 — Write to output location

| Platform | Path |
|----------|------|
| Claude | `.claude/agents/<agent-name>.md` |
| Gemini | `.gemini/agents/<agent-name>.md` |
| Copilot | `.github/agents/<agent-name>.agent.md` |

Create directories if missing. Check Copilot size limit (30,000 chars) — if exceeded, split or trim.

### 5.4 Update Instruction Files

After generating agent files, enrich the project's AI instruction files with an agent routing section. This builds on the base instruction file created by each platform's `/init` command.

#### Detection

Check which instruction files exist:

| Platform | Instruction File | Created By |
|----------|-----------------|------------|
| Claude | `CLAUDE.md` | `/init` in Claude Code |
| Gemini | `GEMINI.md` | `/init` in Gemini CLI |
| Copilot | `.github/copilot-instructions.md` | `/init` in Copilot CLI |

#### If instruction file exists

Ask the user: "I see you have a `CLAUDE.md`. Want me to add the agent routing section?"

If yes, **append** (do not overwrite existing content) an agent routing section:

```markdown
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

**Gemini (GEMINI.md):**
- Agent routing table
- Note that agents live in `.gemini/agents/`
- Reminder that subagents require `experimental.enableAgents` in `.gemini/settings.json`

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
- For new features: `/tikkit:tik`, `/tikkit:figtik`, `/tikkit:stitchtik` — agentkit doesn't plan features

But only mention these **if asked**. Don't list them unprompted.

---

## Sync Mode

`/agentkit sync` reconciles existing agents with the current state of FOUNDATIONS.md and the codebase. Full logic in [`references/guides/SYNC.md`](references/guides/SYNC.md).

### Flow

1. **Inputs** — gather existing agents, current FOUNDATIONS.md, code state
2. **Drift scan** — classify findings into five categories: orphaned, missing, path drift, invariant drift, stale review
3. **Report** — present a structured drift report (see SYNC.md for the exact format)
4. **Per-finding decisions** — prompt the user for each drifted item: update / replace / skip / delete
5. **Apply** — update agent files in place, run cross-doc check if foundations changed; the `agentkit-managed` marker stays as-is (no timestamp)

### What sync does NOT do

- Re-run dockit's foundation detection (that's `/dockit sync`)
- Silently rewrite invariants
- Auto-overwrite hand-authored agents (no `agentkit-managed` marker → warn and recommend, never replace)
- Modify foundation source code

### Multi-platform sync

When the same agent exists on multiple platforms, sync applies the same change to all platforms in one pass. If an agent exists on only one platform, sync flags it as a coverage gap and asks whether to extend.

---

## Status Mode

`/agentkit status` runs the drift scan in read-only mode — no actions, just a report. Use it to:

- Inventory what agents exist and what they own
- See which foundations are uncovered
- See drift before deciding to run sync

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
- **Does not write tickets** — `tikkit:foundationtik` writes maintenance tickets; agentkit surfaces drift and recommends
- **Does not invoke or test the generated agents** — after Phase 5, agentkit stops. Agents activate during real feature work, not during a post-generation "verification" step. There's nothing to demo.

## Audience

- Teams that want AI assistants to understand their custom code patterns
- Projects with significant framework extensions or custom conventions
- Monorepos where different services have distinct custom patterns
- Any project where AI keeps reinventing what the team already built
