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
| `init` | Fresh project, or starting over | Discover, plan, generate (Phases 1–5) |
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

Before doing anything else, check whether `docs/FOUNDATIONS.md` exists.

**If absent:**

> agentkit needs `docs/FOUNDATIONS.md` to know which foundations to assign to agents. It looks like dockit hasn't generated it yet.
>
> Run one of:
> - `/dockit init` — first-time setup, generates the full doc set including FOUNDATIONS.md
> - `/dockit sync` — refresh the registry if dockit was run before
>
> Then re-run `/agentkit`. (For very small projects where foundations aren't worth tracking, agentkit can fall back to custom-code-only analysis — say "skip dockit" and I'll proceed.)

**Wait for the user to either run dockit or explicitly skip.** If they skip, run the legacy custom-code-only flow — Phase 1.4 (custom-code scan) and Phase 3.2 (custom-code assessment) only; no Owned Foundations sections, no Maintenance sections.

**If present:** continue to Phase 1.

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
2. **Identify extension points** — What does this framework expect teams to customize? Where do custom implementations typically live?
3. **Check version delta** — Is the project on an older version? What native features were added in newer versions that the team might be reimplementing?

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

### 1.5 Detect Existing Agents

Check for pre-existing project agents:

| Platform | Path | Pattern |
|----------|------|---------|
| Claude | `.claude/agents/*.md` | All `.md` files |
| Gemini | `.gemini/agents/*.md` | All `.md` files |
| Copilot | `.github/agents/*.agent.md` | All `.agent.md` files |

For each existing agent, parse:
- The `<!-- agentkit-managed -->` marker (if present — marks agentkit-generated agents)
- The `## Owned Foundations` section (if present — names of foundations this agent claims)
- Frontmatter `description` (used to detect coverage areas for non-agentkit agents)

**Decision tree:**

| Situation | Default action |
|-----------|----------------|
| Agent has no `agentkit-managed` marker (user-authored or hand-edited) | **Warn and recommend** — list it in the plan, don't overwrite. Suggest the user re-author or accept replacement. |
| Agent has marker + ownership matches current FOUNDATIONS.md + invariants/paths match | Skip — already in sync |
| Agent has marker + ownership orphaned (foundation removed) | Flag for sync; don't generate a duplicate |
| Agent has marker + content drift (invariants or paths disagree with FOUNDATIONS.md) | Flag for sync; don't generate a duplicate |
| No agent exists for a current foundation | Add to the plan as new |

**Never auto-overwrite a hand-authored agent.** When in doubt, prompt.

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
Heavy?: [yes/no — see AGENT-SIZING.md "Heavy Foundation" criteria]
Consumers: [count] across [N] feature folders
Invariants: [count]
Sub-doc: [path or none]
Custom code in same tree: [list areas + file counts]
```

Then apply the **Mapping Heuristic** from `references/guides/AGENT-SIZING.md` to group foundations into agents:

- ≤ 3 foundations, all small → 1 combined agent
- 4–6 foundations, related domains → 2–3 agents grouped by domain or shared consumers
- > 6 foundations OR any heavy → 1 agent per heavy + cluster the rest by domain
- Monorepo with services → per-service grouping wins; one agent owns all foundations within its service

**Cap at 3–5 agents total.** Custom-code findings (3.2) fold into these — don't add separate agents unless the custom code is unrelated to any foundation.

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

### Existing Agents (warnings)
- `.claude/agents/legacy.md` — hand-authored, no `agentkit-managed` marker. **Recommend the user review or replace.** Will skip unless told otherwise.

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

- **Foundation grouping** — "I clustered `core.notifications` and `core.events` into one `messaging` agent (shared consumers, same domain). Split them?"
- **Heavy foundation own agent** — "`core.database` has its own sub-doc and 14 consumers. Recommend its own agent. OK?"
- **Folding custom code** — "Your `custom-paginator.py` lives near `core.api`. Folding into the api agent. OK?"
- **Borderline custom code** — "Your `CustomPaginator` adds only `max_page_size`. Skip this or include in the api agent?"
- **Potential native replacements** — "Wagtail 6.3 added native `TableBlock`. Your `CustomTableBlock` may be replaceable. Want the agent to flag this?"
- **Existing hand-authored agents** — "I see `.claude/agents/legacy.md` was hand-written. Leave alone, or replace with a foundation-aware version?"

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

For each agent:

#### Build the body (once, shared across platforms)

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

#### Prepend platform frontmatter (per platform)

For each selected platform, prepend frontmatter per `references/platforms.md`:

**Default agents (no foundation ownership):**
- Claude: `<example>` blocks in description, no `permissionMode` needed
- Gemini: read-only YOLO note in body, standard tools list
- Copilot: total size under 30,000 chars, standard tools list

**Foundation-owner agents:**
- Claude: `tools: Read, Edit, Write, Glob, Grep, Bash` and `permissionMode: acceptEdits`
- Gemini: foundation-owner YOLO note (authorized to edit `docs/`), expanded tools list, `max_turns: 20`
- Copilot: include `editFile`, `createFile`, `terminal` in tools

#### Write to output location

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
- **Does not auto-overwrite existing agents** — hand-authored agents are flagged for the user; agentkit-generated agents are reconciled via sync, never silently replaced
- **Does not create agents for native framework features** — only for custom/extended code or foundations
- **Does not modify project source code** — only reads source code; writes agent files and (with foundation-owner permissions) doc files under `docs/`
- **Does not create instruction files** — that is `/init`'s job; agentkit only enriches them
- **Does not run dockit's foundation detection** — agentkit reads FOUNDATIONS.md but never re-scores foundations. If detection seems stale, recommend `/dockit sync`.
- **Does not write tickets** — `tikkit:foundationtik` writes maintenance tickets; agentkit surfaces drift and recommends

## Audience

- Teams that want AI assistants to understand their custom code patterns
- Projects with significant framework extensions or custom conventions
- Monorepos where different services have distinct custom patterns
- Any project where AI keeps reinventing what the team already built
