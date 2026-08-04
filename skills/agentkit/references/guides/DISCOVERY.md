# Phase 1 — Discovery

How agentkit gathers everything it needs about a project before proposing any agents. Invoked from [`SKILL.md`](../../SKILL.md#phase-1-discovery) § Phase 1, which carries the step-to-output table this guide details.

**Everything here is automatic.** If a fact is observable from the repo, detect it — don't ask. A user asked to supply what the code already states will sometimes answer wrong, and then the agents are built on a contradiction.

---

All automatic. Do not ask the user for anything detectable.

### 1.0 Read FOUNDATIONS.md (lead input)

If `docs/FOUNDATIONS.md` exists, parse it as the **primary input** for agent grouping. Custom-code analysis (1.4) still runs but feeds into the foundation-led grouping.

Extract from FOUNDATIONS.md:

| Field | Source within doc | Used for |
|-------|-------------------|----------|
| Catalog rows | The `## Catalog` table | Names, paths, status, health, owner |
| Per-foundation entries | `## <Foundation Name>` sections | Agent payload — `Use when`, tiered invariants, canonical usage, `Extend by`, `Doesn't cover` — plus the change checklist. Everything under the entry's `Reference` heading is read on demand, not extracted |
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
3. **Note the version, don't speculate about upgrades** — Record the framework version. Don't brainstorm what newer versions could offer or whether the team should upgrade — that's a planning question, not agentkit's. Stay grounded in what the codebase uses today.

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
| Antigravity | `.agents/agents/*.md` (or `<name>/agent.md`) | All `.md` files |
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
