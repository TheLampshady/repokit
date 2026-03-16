---
name: agentkit
description: 'Generate project-level AI subagents tailored to your codebase. Analyzes custom code patterns, extensions, and team conventions then creates agents that help AI assistants understand and follow your project patterns instead of using framework defaults. Use when asked to: create agents for this project, generate AI helpers, set up subagents, help AI understand my custom code, create coding assistants, generate project agents. Supports Claude, Gemini, and Copilot.'
user-invocable: true
argument-hint: "[claude|gemini|copilot|all]"
---

# agentkit

Generate project-level AI subagents that understand your team's custom code, conventions, and extensions.

## Philosophy

- **Dynamic discovery** — No hardcoded framework lists. Detects what's in your project, researches what's native vs custom, and builds agents around the delta.
- **Living experts, not static maps** — Generated agents know their framework versions, can research newer features, and understand why the custom code exists.
- **Plans first, generates second** — Always presents a plan for user review. Asks questions when something could be native instead of custom.
- **Cross-platform** — Generates agents for Claude, Gemini, and Copilot from the same analysis.

---

## Phase 1: Discovery

All automatic. Do not ask the user for anything detectable.

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

Check for pre-existing project agents to avoid duplicates:

Search for existing agent files in:
- `.claude/agents/*.md`
- `.gemini/agents/*.md`
- `.github/agents/*.agent.md`

If existing agents cover some of the detected custom areas, note them and skip those areas (or offer to update/replace).

---

## Phase 1.5: User Preferences

Ask only what cannot be detected. **Maximum 3 questions.**

### Question 1: Target Platforms

Skip if `$ARGUMENTS` specifies a platform (e.g., `/agentkit claude`).

> Which platforms should I generate agents for?
> - Claude
> - Gemini
> - Copilot
> - All (recommended)

### Question 2: Areas to Skip

Only ask if custom code was found in 3+ areas.

> I detected custom/extended code in these areas: [list areas with file counts].
> Any of these you'd like to skip?

### Question 3: Scope Preference

Skip for small projects (always broad). Skip if only 1-2 areas detected.

> Do you prefer **fewer broad agents** (one per major area, easier to maintain) or **more focused agents** (one per custom pattern, more precise triggering)?

---

## Phase 2: Analysis

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

### Grouping into Agents

Apply the scaling logic from `references/guides/AGENT-SIZING.md`:

1. Sort findings by file count (descending)
2. Group related findings (same framework area, same domain)
3. Apply project size limits
4. Merge small groups into larger ones
5. Name each proposed agent descriptively (e.g., `custom-blocks`, `data-layer`, `api-middleware`)

---

## Phase 3: Plan and User Review

Present the analysis as a clear plan. **Do not generate any files yet.**

### Plan Format

```markdown
## Proposed Agents

### Project: [name] | Size: [Small/Medium/Large] | Custom Areas: [N] | Agents Proposed: [N]

| # | Agent Name | Expertise | Custom Patterns | Files | Framework @ Version |
|---|-----------|-----------|----------------|-------|---------------------|
| 1 | [name] | [area] | [key patterns] | [N] | [framework version] |
| 2 | ... | ... | ... | ... | ... |

### Skipped (native alternatives exist)
- [area] ([N] files) — [why it's native]

### Borderline (your call)
- [area] ([N] files) — [why it's borderline, what the alternative is]

### Questions
1. [Any clarifications needed]
2. [Any "did you mean to customize this?" questions]
```

### What to Ask About

- **Borderline items** — "Your `CustomPaginator` adds only `max_page_size`. Skip this or include in the api-middleware agent?"
- **Potential native replacements** — "Wagtail 6.3 added native `TableBlock`. Your `CustomTableBlock` may be replaceable. Want the agent to flag this?"
- **Unused custom code** — "Your `legacy_middleware.py` hasn't been modified in 2 years. Skip this?"
- **Scope decisions** — "Your `utils/` has 30 files. Should this be its own agent or split across related agents?"

**Wait for user approval before proceeding to Phase 4.**

---

## Phase 4: Generation

For each approved agent, generate agent files for each selected platform.

### 4.1 Load Platform Specs

Read `references/platforms.md` to get the exact frontmatter format and platform quirks for each target.

### 4.2 Load Agent Template

Read the unified template from `references/templates/agent.template.md`. The body is the same across all platforms — only frontmatter differs per platform.

### 4.3 Generate Agent Files

For each agent:

#### Build the body (once, shared across platforms)

Use the unified template. Fill each section:

1. **Architecture Context** — pull the relevant excerpt from `ARCHITECTURE.md` or `README.md` (if dockit generated them). Keep to 5-10 lines. If no docs exist, summarize from code.

2. **Working Directories** — list the directories this agent operates in. Files outside these are not its concern.

3. **Framework Context** — framework name and version from the dependency file. What's native vs what's custom in this area.

4. **Conventions** — extract from actual code patterns: naming conventions, file organization, error handling, test patterns in this agent's domain.

5. **Custom Patterns (hot memory)** — for the 2-3 most critical patterns, **read the actual source files** and embed representative code snippets. For the rest, describe in prose with file paths. The agent should be effective without reading any files.

6. **Key Files** — table of files for deeper context, with "read when" guidance so the agent knows when to go deeper.

7. **When to Trigger** — scenarios with examples.

8. **Common Mistakes** — what AI gets wrong without this agent. This is the highest-value section.

9. **Research** — check project docs first (README, ARCHITECTURE, docs/), then framework docs via context7 or web search, then check for native alternatives in newer versions.

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

For each selected platform, prepend the appropriate frontmatter from the platform spec:
Refer to `references/platforms.md` for each platform's frontmatter format and quirks:
- Claude: include `<example>` blocks in description
- Gemini: add YOLO mode safety note to body, tools as YAML list
- Copilot: check total size stays under 30,000 chars

3. **Write to output location:**
   - Claude: `.claude/agents/<agent-name>.md`
   - Gemini: `.gemini/agents/<agent-name>.md`
   - Copilot: `.github/agents/<agent-name>.agent.md`

4. **Check Copilot size limit** — if any agent exceeds 30,000 characters, split into multiple agents or trim examples.

Create output directories if they don't exist.

### 4.4 Update Instruction Files

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

The following agents are project-specific experts generated by agentkit. They understand
this project's custom code patterns and should be consulted for their areas of expertise.

| Agent | Expertise | Trigger When |
|-------|-----------|-------------|
| [agent-name] | [custom area] | [when to use] |

### Agent Routing

| If you're working with... | Consult |
|--------------------------|---------|
| [file pattern or directory] | [agent-name] |
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

## Integration with /init and Other Skills

Agentkit is designed to build on top of each platform's `/init` command and other repokit skills:

```
/init          → Base instruction file (conventions, build commands, project overview)
/dockit        → Human docs (README, ARCHITECTURE, ENVIRONMENTS)
/agentkit      → SME agents + agent routing section in instruction file
```

**Recommended flow for new projects:**
1. Run `/init` to create the base instruction file
2. Run `/dockit init` to generate project documentation
3. Run `/agentkit` to generate SME agents and add routing to the instruction file

Each tool owns its section of the instruction file. `/init` owns the foundation, `/dockit` can reference generated docs, and `/agentkit` owns the agent routing table.

---

## What This Skill Does NOT Do

- **Does not hardcode framework knowledge** — discovers everything dynamically
- **Does not create agents without approval** — always presents a plan first
- **Does not create user-level agents** — all agents go in project directories
- **Does not replace existing agents** — detects and skips already-covered areas
- **Does not create agents for native framework features** — only for custom/extended code
- **Does not execute or modify project code** — only reads code and writes agent files
- **Does not create instruction files** — that is `/init`'s job; agentkit only enriches them

## Audience

- Teams that want AI assistants to understand their custom code patterns
- Projects with significant framework extensions or custom conventions
- Monorepos where different services have distinct custom patterns
- Any project where AI keeps reinventing what the team already built
