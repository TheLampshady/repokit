# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Repokit's premise: **a project's documentation is living context that AI agents and humans both consume**. Keep it in sync and you can do meaningful work on top of it.

The architecture is:

- **Foundation:** `dockit` scans the codebase and generates/syncs documentation. This is the context layer.
- **Consumer:** `agentkit` — generates project-level subject-matter-expert agents that own each foundation and understand custom code. Reads `docs/FOUNDATIONS.md` as its source of truth.
- **Hub:** `/repokit` orchestrates the loop with `status`, `sync`, and `init` modes.

This repo distributes that toolkit as a Claude plugin, a Gemini extension, and a Copilot plugin. Components:
- **Skills** — cross-platform, invoked via slash commands
- **Agents** — Claude-specific subagents that auto-trigger based on task context
- **Policies** — Gemini security rules

There is no build system or compiled code. Everything is Markdown, TOML, and JSON.

> **Sibling plugin:** ticket creation (tik, figtik, stitchtik, modernizer + auditor agent) lives in [tikkit](https://github.com/TheLampshady/tikkit). Both plugins write to the same `.backlog/backlog.md` if installed together.

## Directory Map

| Path | Purpose |
|------|---------|
| `skills/dockit/` | Documentation generation skill (init, sync, check, migrate, diagrams) |
| `skills/agentkit/` | Agent generator skill — analyzes custom code, creates project-level agents for Claude/Gemini/Copilot |
| `skills/repokit/` | Maintenance hub — repo health dashboard, post-change sync, project bootstrap (status, sync, init) |
| `.claude/agents/` | Internal dev-only agents — NOT distributed (component-reviewer only) |
| `.claude-plugin/` | Claude plugin metadata (`plugin.json`) and marketplace catalog (`marketplace.json`) |
| `.mcp.json` | Bundled MCP servers (context7 for library documentation) |
| `policies/` | Gemini CLI policy engine rules |
| `.backlog/` | Ticket system — created at runtime by agents, gitignored in this repo |
| `GEMINI.md` | Gemini extension context (tool docs, not project context) |
| `gemini-extension.json` | Gemini extension manifest |

## Architecture

### Skills (`skills/`, cross-platform)

Skills have YAML frontmatter (`name`, `description`, `user-invocable: true`) and load on demand. Claude, Gemini, and Copilot all discover from `skills/` at the plugin root.

| Skill | Modes | Key Behavior |
|-------|-------|-------------|
| `dockit` | init, sync, check, audit, migrate, diagrams | Scales docs by project size; detects frameworks; never destroys content |
| `agentkit` | init, sync, status | Analyzes custom code; generates project-level agents for Claude, Gemini, Copilot; scales by project size |
| `repokit` | status, sync, init | Maintenance hub — orchestrates other tools; repo health dashboard, post-change sync, project bootstrap |

### Agents

The plugin distributes **no agents of its own** — there is no `agents/` directory. Agents are an *output* of the toolkit, not part of it: `agentkit` generates them into the consuming project (`.claude/agents/`, `.gemini/agents/`, `.github/agents/`). Don't reintroduce a distributed `agents/` dir here.

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

- Claude: `.claude-plugin/plugin.json` (plugin metadata), `.claude-plugin/marketplace.json` (marketplace catalog pointing to `"."`)
- Gemini: `gemini-extension.json` (extension manifest, references `GEMINI.md` as context file)

The `plugins/` subdirectory no longer exists — the root is the plugin.

### Where agent files live

| Location | Who Gets It | Use For |
|----------|------------|---------|
| `.claude/agents/` (this repo) | This repo's developers only | component-reviewer (internal tooling) |
| `.claude/agents/` (consumer project) | Generated at runtime by agentkit | Per-foundation SME agents |

## Adding a New Framework to dockit

1. Add detection rule to `skills/dockit/frameworks/_index.md`
2. Create `skills/dockit/frameworks/[name].md` (use `_default.md` as template)
3. Create `skills/dockit/references/templates/[name]/` with framework-specific templates
4. Add a sample to `skills/dockit/references/samples/[name]-project/`

## Policies

`policies/policies.toml` applies to Gemini CLI only. Rules by category:

| Category | Rules |
|----------|-------|
| Destructive ops | Confirm `rm -rf`, confirm deleting `.backlog/` or `agents/` dirs |
| Git | Confirm `git push` |
| Secrets | Deny reading `.env`/`id_rsa`/`passwd`, deny writing to `.env*` |
| Context files | Confirm before overwriting `CLAUDE.md` or `GEMINI.md` |
| Safety checker | Path validation on all file writes |

## Development Commands

```bash
make setup      # First-time setup: install pre-commit hooks, link Gemini extension, install Claude plugin
make check      # Run all pre-commit validations (JSON, TOML, YAML)
make gemini     # Link Gemini extension for local testing
make claude     # Install Claude plugin locally for testing
make status     # Show open backlog items and extension/plugin install status
make help       # List all targets
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
