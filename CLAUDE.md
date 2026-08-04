# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Repokit's premise: **a project's documentation is living context that AI agents and humans both consume**. Keep it in sync and you can do meaningful work on top of it.

The architecture is:

- **Foundation:** `dockit` scans the codebase and generates/syncs documentation. This is the context layer.
- **Consumer:** `agentkit` — generates project-level subject-matter-expert agents that own each foundation and understand custom code. Reads `docs/FOUNDATIONS.md` as its source of truth.
- **Hub:** `/repokit` orchestrates the loop with `status`, `sync`, and `init` modes.

Everything in the plugin serves that loop. Repokit owns the **decision phase** — routing agents to the right existing context — and deliberately builds no retrieval layer (maps, graphs, symbol servers are commodity; recommend or wrap them instead).

This repo distributes the toolkit as a **Claude plugin**, an **Antigravity plugin**, and a **Copilot plugin**. Components:
- **Skills** (`skills/`) — cross-platform; all three platforms discover `skills/<name>/SKILL.md` and auto-activate from `description`
- **Rules** (`rules/`) — Antigravity markdown rules (guidance, not enforcement)
- **Policies** (`policies/policies.toml`) — Gemini CLI policy engine (hard enforcement; legacy)

There is no build system and no compiled code — Markdown, TOML, and JSON only. `pyproject.toml` carries metadata; the only Python dependency is pre-commit. **The deliverable is prose an agent will execute**, so a change to a `SKILL.md` is a behavior change: read the surrounding phases before editing one, because modes reference each other by heading.

> **Gemini CLI → Antigravity.** Gemini CLI stopped serving Pro/Ultra/free tiers on **2026-06-18**; its extensions became Antigravity plugins. Gemini CLI support is retained for Code Assist Standard/Enterprise licenses, so `gemini-extension.json` and `policies/policies.toml` stay. Antigravity is the primary Google target — and it's **two products**, the IDE (v2.x) and the CLI (`agy`, v1.x), which share plugin contents but have separate install dirs. `make antigravity` handles both.

## Directory Map

| Path | Purpose |
|------|---------|
| `skills/dockit/` | Documentation generation skill (init, sync/sync --deep, migrate, diagrams) |
| `skills/agentkit/` | Agent generator skill — analyzes custom code, creates project-level agents for Claude/Antigravity/Copilot |
| `skills/repokit/` | Maintenance hub — repo health dashboard, post-change sync, project bootstrap (status, sync, init) |
| `docs/research/CHARTER.md` | Research charter — the rails. Objectives, what's already decided against, project terminology |
| `docs/` | Hand-written reference material (platform matrices, doc-tree spec, skill inventory) |
| `.claude/agents/` | Internal dev-only agents — NOT distributed (component-reviewer only) |
| `.claude-plugin/` | Claude plugin metadata (`plugin.json`) and marketplace catalog (`marketplace.json`) |
| `plugin.json` | **Antigravity** plugin manifest (root) — separate file and schema from `.claude-plugin/plugin.json` |
| `rules/` | Antigravity markdown rules — Antigravity counterpart to `policies/`. 12,000 chars is the per-file *limit*; all are ~1.5 KB |
| `mcp_config.json` | Antigravity MCP config (root) — mirrors `.mcp.json` |
| `.mcp.json` | Claude MCP servers (context7 for library documentation) |
| `policies/` | Gemini CLI policy engine rules (legacy; hard enforcement) |
| `.config/` | `.pre-commit-config.yaml` and `.commit-message-template` (installed as `commit.template` by `make hooks`) |
| `GEMINI.md` | Workspace context file — read by Antigravity and Gemini CLI (tool docs, not project context) |
| `gemini-extension.json` | Gemini CLI extension manifest (legacy) |

Generated and gitignored, so never hand-edit: `.cursorrules` (from `make cursorrules`), `.gemini/`, `.claude/settings.local.json`.

## Development Commands

```bash
make setup            # First-time setup: hooks + Antigravity (IDE+CLI) + Claude plugin
make check            # Run all pre-commit hooks on all files (also: check-json / check-toml / check-yaml)
make status           # Per-platform install status
make antigravity      # Install for both Antigravity products (skips whichever is absent)
make antigravity-ide  # IDE only — symlink into ~/.gemini/config/plugins/ (live reload)
make antigravity-cli  # CLI only — `agy plugin install`
make claude           # Install Claude plugin locally (local scope; `claude-project` for project scope)
make cursorrules      # Regenerate .cursorrules from SKILL.md descriptions
make gemini           # [legacy] Link Gemini CLI extension
make help             # List all targets
```

Each installer has an `un-` counterpart (`un-antigravity`, `un-claude`, `un-gemini`). `make hooks` uses `uv tool install` when uv is present, else pip.

**There is no test suite.** Validation is pre-commit (JSON/TOML/YAML syntax, EOF, trailing whitespace, private-key detection) plus the `component-reviewer` agent for skill and agent files. Behavior is verified by installing the plugin and running a skill against a real project — a syntactically valid `SKILL.md` can still be wrong.

Open design questions for this repo live in `docs/research/` — as open-questions sections inside the relevant research doc, not a separate checklist.

## Architecture

### Skills (`skills/`, cross-platform)

Skills have YAML frontmatter (`name`, `description`, `user-invocable: true`) and load on demand. Claude, Antigravity, and Copilot all discover from `skills/` at the plugin root and auto-activate from `description` — this is why the same `SKILL.md` works everywhere unchanged.

| Skill | Modes | Key Behavior |
|-------|-------|-------------|
| `dockit` | init, sync (`--deep`), migrate, diagrams | Scales docs by project size; detects frameworks; never destroys content. Mines choices into PRINCIPLES/FOUNDATIONS at the Convention tier only — never rationale, never Rules |
| `agentkit` | init, sync, status | Analyzes custom code; generates project-level agents for Claude, Antigravity, Copilot; scales by project size |
| `repokit` | status, sync, init | Maintenance hub — orchestrates other tools; repo health dashboard, post-change sync, project bootstrap. Also owns the **context-handoff check**: does the auto-loaded context file reference `docs/FOUNDATIONS.md`? `status` reports the gap, `init` offers to append the pointer. Never edits context files during `status` or `sync` |

**Progressive disclosure is the layout contract.** `SKILL.md` is the always-loaded entry point; everything deeper is pulled in only when a mode needs it:

```
skills/<name>/
├── SKILL.md              # entry point — frontmatter + phase flow
└── references/
    ├── guides/           # per-topic detail SKILL.md links to by name
    ├── templates/        # output shapes written into consumer projects
    └── samples/          # worked examples (small / medium / monorepo / wagtail)
```

New detail belongs in a `references/guides/` file that `SKILL.md` names, not inlined into `SKILL.md`. Growing the entry point taxes every invocation, including the ones that never reach that mode.

**dockit's delete authority is the load-bearing invariant** (`skills/dockit/SKILL.md` § Delete authority). Deletion rights come from *derivability*, not authorship: regenerable artifacts may be rebuilt (after diffing for human edits), a claim the code contradicts may be fixed, and content asserting nothing checkable is reported but never touched. Any change that lets a mode remove content needs to land inside that model.

### Docs in this repo (`docs/`)

`docs/` here is **hand-written reference material, not dockit output** — there's no `ARCHITECTURE.md` or `FOUNDATIONS.md`, and this repo doesn't apply dockit's own doc tree to itself. Don't "sync" it.

| File | Read it when |
|------|-------------|
| `research/CHARTER.md` | Before proposing a feature or a research run. Its **Out of scope** list is a set of standing decisions ("no retrieval layer", "no generated rationale", "never rename `FOUNDATIONS.md`"), and its **Terminology** section is the project glossary — foundation, the Overview/Choice/Rationale bands, Convention vs Rule, tombstone, drift vs rot, checkable claim |
| `research/*-research.md` | You need the evidence behind a design decision. Sourced, with an explicit hypothesis/absence-claim marker convention |
| `platform-feature-comparison.md` | Making any claim about what Claude / Antigravity / Copilot supports — frontmatter fields, paths, hook names, char limits |
| `building-extensions-and-plugins.md` | Changing manifests or install flow for any platform |
| `dockit-doc-tree.md` | Changing what dockit generates — scaling tiers, complexity triggers, content routing |

The charter's terminology entries are glosses that point at the real definition elsewhere; keep them that way rather than expanding them, and note that only its **Terminology** section may be appended automatically — every other field is hand-edited.

### Agents

The plugin distributes **no agents of its own** — there is no `agents/` directory. Agents are an *output* of the toolkit, not part of it: `agentkit` generates them into the consuming project (`.claude/agents/`, `.agents/agents/`, `.github/agents/`). Don't reintroduce a distributed `agents/` dir here.

### Internal Dev Agent (`.claude/agents/`, NOT distributed)

| Agent | Purpose |
|-------|---------|
| `component-reviewer` | Reviews skills, agents, and commands for frontmatter correctness, description quality, and cross-platform compatibility — uses Opus, internal only |

### Repokit tracks nothing of its own

No task files, no queue, no ticket format. When a mode surfaces work worth following up — an unowned foundation, a hotspot, a coverage gap — it says so in the report and stops. Whatever tracker a team uses is theirs to choose, and a second source of truth inside their docs starts drifting from the first immediately.

### Plugin Structure

The repo root **is** the plugin for every platform. Three manifests coexist because each platform reads a different file:

| Platform | Manifest | Notes |
|----------|----------|-------|
| Claude | `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` | Marketplace `source` must be `"./"` (trailing slash) |
| Antigravity (IDE + CLI) | `plugin.json` (root) | Minimal schema — `{"name": "repokit"}`. Optional siblings: `mcp_config.json`, `hooks.json`, `rules/`. **Two products, one plugin:** IDE installs by folder placement (`~/.gemini/config/plugins/`), CLI via `agy plugin install` (`~/.gemini/antigravity-cli/plugins/`). Contents identical; only install differs |
| Gemini CLI (legacy) | `gemini-extension.json` | References `GEMINI.md` as `contextFileName`; carries theme + `excludeTools` |

**Do not consolidate `plugin.json` and `.claude-plugin/plugin.json`.** Different files, different schemas, different readers. Claude's carries version/author/homepage/license; Antigravity's takes `name` and nothing else is required. Version bumps touch two files: `.claude-plugin/plugin.json` and `gemini-extension.json`.

The `plugins/` subdirectory no longer exists — the root is the plugin.

**Real files must stay in `skills/`.** Don't add a `.agents/skills` symlink to this repo — Claude's remote plugin fetch doesn't resolve symlinks. (`.agents/` *is* Antigravity's canonical consumer-workspace path; that's a different thing.)

### Where agent files live

| Location | Who Gets It | Use For |
|----------|------------|---------|
| `.claude/agents/` (this repo) | This repo's developers only | component-reviewer (internal tooling) |
| `.claude/agents/` (consumer project) | Generated by agentkit | Per-foundation SME agents (Claude) |
| `.agents/agents/` (consumer project) | Generated by agentkit | Per-foundation SME agents (Antigravity) |
| `.github/agents/` (consumer project) | Generated by agentkit | Per-foundation SME agents (Copilot) |

**Antigravity path gotcha:** subagents live at `.agents/agents/`, **not** `.gemini/agents/` (the retired Gemini CLI path). But Antigravity's *global* config stayed under `~/.gemini/` — `~/.gemini/config/agents/`, `~/.gemini/config/plugins/`, `~/.gemini/GEMINI.md`. Don't "correct" those to `~/.agents/`.

## Adding a New Framework to dockit

1. Add detection rule to `skills/dockit/frameworks/_index.md`
2. Create `skills/dockit/frameworks/[name].md` (use `_default.md` as template)
3. Create `skills/dockit/references/templates/[name]/` with framework-specific templates
4. Add a sample to `skills/dockit/references/samples/[name]-project/`

Wagtail is the only framework implemented; the Django / FastAPI / React rows in `_index.md` are marked future and have no module behind them yet. Detection is first-match-wins, so order matters — Wagtail must be checked before Django.

## Policies

Two parallel sets, because the platforms differ in kind:

| File | Platform | Mechanism |
|------|----------|-----------|
| `policies/policies.toml` | Gemini CLI (legacy) | Policy **engine** — matches tool calls by pattern, can hard-`deny` |
| `rules/*.md` | Antigravity | Markdown **guidance** injected into context — the model may or may not comply |

They are **not equivalent in strength.** A rule asking the agent not to read `.env` is weaker than a policy denying the call outright. Don't describe `rules/` as enforcement.

Coverage in both:

| Category | Rules |
|----------|-------|
| Destructive ops | Confirm `rm -rf`, confirm deleting agent dirs or `docs/` |
| Git | Confirm `git push`; never force-push or rewrite published history unasked |
| Secrets | Deny reading `.env`/`id_rsa`/`passwd`, deny writing to `.env*`; read keys not values |
| Context files | Confirm before writing `CLAUDE.md`/`GEMINI.md`/`AGENTS.md`; append only, never reformat |
| Safety checker | Path validation on all file writes (`policies.toml` only — no rules equivalent) |

The `agents/` path in the destructive-ops guard protects agentkit's **generated** output in consumer projects (`.claude/agents/`, `.agents/agents/`, `.github/agents/`), not this repo — repokit ships no agents.

## Skill Frontmatter Format

```yaml
---
name: skill-name
description: 'Trigger phrases and what this skill does. Use when asked to: ...'
user-invocable: true
argument-hint: "[mode] [target]"   # optional; agentkit uses this
---
```

Keep `description` under 1024 characters. Include action verbs and "Use when asked to..." triggers — the description is the only thing loaded before the skill fires, so it is the whole activation surface on all three platforms.

## Extra Rules
1) No tombstones. No "previous versions ..."
2) Dont update skills installed if they exist in this repo. Ex: dockit lives here, update it here, no the installed one.
