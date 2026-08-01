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

There is no build system or compiled code. Everything is Markdown, TOML, and JSON.

> **Gemini CLI → Antigravity.** Gemini CLI stopped serving Pro/Ultra/free tiers on **2026-06-18**; its extensions became Antigravity plugins. Gemini CLI support is retained for Code Assist Standard/Enterprise licenses, so `gemini-extension.json` and `policies/policies.toml` stay. Antigravity is the primary Google target — and it's **two products**, the IDE (v2.x) and the CLI (`agy`, v1.x), which share plugin contents but have separate install dirs. `make antigravity` handles both.

> **Sibling plugin:** ticket creation (tik, figtik, stitchtik, modernizer + auditor agent) lives in [tikkit](https://github.com/TheLampshady/tikkit). Repokit reads `.backlog/backlog.md` for its dashboard; tikkit writes it.

## Directory Map

| Path | Purpose |
|------|---------|
| `skills/dockit/` | Documentation generation skill (init, sync/sync --deep, check, migrate, diagrams) |
| `skills/agentkit/` | Agent generator skill — analyzes custom code, creates project-level agents for Claude/Antigravity/Copilot |
| `skills/repokit/` | Maintenance hub — repo health dashboard, post-change sync, project bootstrap (status, sync, init) |
| `.claude/agents/` | Internal dev-only agents — NOT distributed (component-reviewer only) |
| `.claude-plugin/` | Claude plugin metadata (`plugin.json`) and marketplace catalog (`marketplace.json`) |
| `plugin.json` | **Antigravity** plugin manifest (root) — separate file and schema from `.claude-plugin/plugin.json` |
| `rules/` | Antigravity markdown rules (12k chars each) — Antigravity counterpart to `policies/` |
| `mcp_config.json` | Antigravity MCP config (root) — mirrors `.mcp.json` |
| `.mcp.json` | Claude MCP servers (context7 for library documentation) |
| `policies/` | Gemini CLI policy engine rules (legacy; hard enforcement) |
| `.backlog/` | Ticket system — read-only for repokit, written by tikkit; gitignored in this repo |
| `GEMINI.md` | Workspace context file — read by Antigravity and Gemini CLI (tool docs, not project context) |
| `gemini-extension.json` | Gemini CLI extension manifest (legacy) |

## Architecture

### Skills (`skills/`, cross-platform)

Skills have YAML frontmatter (`name`, `description`, `user-invocable: true`) and load on demand. Claude, Antigravity, and Copilot all discover from `skills/` at the plugin root and auto-activate from `description` — this is why the same `SKILL.md` works everywhere unchanged.

| Skill | Modes | Key Behavior |
|-------|-------|-------------|
| `dockit` | init, sync (`--deep`), check, migrate, diagrams | Scales docs by project size; detects frameworks; never destroys content. Mines choices into PRINCIPLES/FOUNDATIONS at the Convention tier only — never rationale, never Rules |
| `agentkit` | init, sync, status | Analyzes custom code; generates project-level agents for Claude, Antigravity, Copilot; scales by project size |
| `repokit` | status, sync, init | Maintenance hub — orchestrates other tools; repo health dashboard, post-change sync, project bootstrap. Also owns the **context-handoff check**: does the auto-loaded context file reference `docs/FOUNDATIONS.md`? `status` reports the gap, `init` offers to append the pointer. Never edits context files during `status` or `sync` |

### Agents

The plugin distributes **no agents of its own** — there is no `agents/` directory. Agents are an *output* of the toolkit, not part of it: `agentkit` generates them into the consuming project (`.claude/agents/`, `.agents/agents/`, `.github/agents/`). Don't reintroduce a distributed `agents/` dir here.

### Internal Dev Agent (`.claude/agents/`, NOT distributed)

| Agent | Purpose |
|-------|---------|
| `component-reviewer` | Reviews skills, agents, and commands for frontmatter correctness, description quality, and cross-platform compatibility — uses Opus, internal only |

### Ticket System (`.backlog/`)

Repokit **reads** a shared `.backlog/` directory in the consuming project and never writes to it. `/repokit status` surfaces open items so drift and open work appear in one dashboard; when a mode finds work worth a ticket, it says so and points at tikkit instead of creating the file.

- `.backlog/backlog.md` — master checklist, one line per item, tagged by source
- `.backlog/tickets/<slug>.md` or `.backlog/tickets/<slug>/ticket.md` — individual tickets with full context

Format in `backlog.md` — position in the list IS the priority/dependency order:
```
- [ ] Migrate auth to the shared client [tik] → tickets/migrate-auth-client.md
```

Slugs are plain kebab-case — no numeric prefixes. Dependencies are expressed via position in the backlog and references inside each ticket. If `.backlog/` doesn't exist, repokit omits the backlog rows rather than creating the directory.

### Cross-plugin contract with tikkit

[tikkit](https://github.com/TheLampshady/tikkit) owns ticket *creation*; repokit owns ticket *awareness*. Repokit contributes no tags of its own — tikkit writes `[tik]`, `[figtik]`, `[stitchtik]`, `[modernizer]`, and repokit reports whatever tags it finds without assuming a fixed set.

Neither plugin imports the other.

### Plugin Structure

The repo root **is** the plugin for every platform. Three manifests coexist because each platform reads a different file:

| Platform | Manifest | Notes |
|----------|----------|-------|
| Claude | `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` | Marketplace `source` must be `"./"` (trailing slash) |
| Antigravity (IDE + CLI) | `plugin.json` (root) | Minimal schema — `{"name": "repokit"}`. Optional siblings: `mcp_config.json`, `hooks.json`, `rules/`. **Two products, one plugin:** IDE installs by folder placement (`~/.gemini/config/plugins/`), CLI via `agy plugin install` (`~/.gemini/antigravity-cli/plugins/`). Contents identical; only install differs |
| Gemini CLI (legacy) | `gemini-extension.json` | References `GEMINI.md` as `contextFileName`; carries theme + `excludeTools` |

**Do not consolidate `plugin.json` and `.claude-plugin/plugin.json`.** Different files, different schemas, different readers. Claude's carries version/author/homepage/license; Antigravity's takes `name` and nothing else is required.

The `plugins/` subdirectory no longer exists — the root is the plugin.

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
| Destructive ops | Confirm `rm -rf`, confirm deleting `.backlog/`, agent dirs, or `docs/` |
| Git | Confirm `git push`; never force-push or rewrite published history unasked |
| Secrets | Deny reading `.env`/`id_rsa`/`passwd`, deny writing to `.env*`; read keys not values |
| Context files | Confirm before writing `CLAUDE.md`/`GEMINI.md`/`AGENTS.md`; append only, never reformat |
| Safety checker | Path validation on all file writes (`policies.toml` only — no rules equivalent) |

The `agents/` path in the destructive-ops guard protects agentkit's **generated** output in consumer projects (`.claude/agents/`, `.agents/agents/`, `.github/agents/`), not this repo — repokit ships no agents.

## Development Commands

```bash
make setup           # First-time setup: hooks + Antigravity (IDE+CLI) + Claude plugin
make check        # Run all pre-commit validations (JSON, TOML, YAML)
make antigravity     # Install for both Antigravity products (skips whichever is absent)
make antigravity-ide # IDE only — symlink into ~/.gemini/config/plugins/
make antigravity-cli # CLI only — `agy plugin install`
make claude          # Install Claude plugin locally for testing
make gemini          # [legacy] Link Gemini CLI extension
make status          # Show backlog items and per-platform install status
make help            # List all targets
```

`make hooks` uses `uv tool install` if uv is available, falls back to pip. Pre-commit config lives at `.config/.pre-commit-config.yaml`.

## Skill Frontmatter Format

```yaml
---
name: skill-name
description: 'Trigger phrases and what this skill does. Use when asked to: ...'
user-invocable: true
---
```

Keep `description` under 1024 characters. Include action verbs and "Use when asked to..." triggers.
