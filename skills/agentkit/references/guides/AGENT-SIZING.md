# Agent Sizing Guide

How to determine the right number and scope of agents for a project.

## The Core Test

Before creating any agent, ask: **"Would an AI assistant get this wrong without project-specific context?"**

If the answer is no — if standard framework knowledge is sufficient — skip the agent. Agents exist to close the gap between what AI knows generically and what your project does specifically.

## When to Create an Agent

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

## Project Size Tiers

The sweet spot is **3–4 agents** for most projects. More agents means more context for the AI to juggle, and quality degrades as agent count increases ("context rot").

| Size | Source Files | Max Agents | Strategy |
|------|-------------|-----------|----------|
| Small | 1–20 | 1–2 | Single "project-expert" agent covering all custom patterns |
| Medium | 21–50 | 2–4 | One agent per major custom area |
| Large | 51+ | 3–5 | Specialized agents; may split by service in monorepos |

**Why cap at 5?** Research from Anthropic and industry practitioners shows that agent effectiveness plateaus around 3–4 agents. Beyond that, overlap increases, triggering becomes unreliable, and the AI spends more tokens routing than solving. If you need more than 5, consider whether some agents can be merged or whether the project should be split.

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
