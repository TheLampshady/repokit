# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Repokit is a codebase maintenance toolkit for AI agents. It provides:
- **Skills** — cross-platform, invoked via slash commands, work on Claude, Gemini, and Copilot
- **Agents** — Claude-specific subagents that auto-trigger based on task context
- **Hooks & policies** — session lifecycle and security rules

There is no build system or compiled code. Everything is Markdown, TOML, and JSON.

## Directory Map

| Path | Purpose |
|------|---------|
| `skills/dockit/` | Documentation generation skill (init, sync, check, migrate, diagrams) |
| `skills/modernizer/` | Stack modernization skill — audits tooling, writes tickets to `specs/` |
| `skills/onboard/` | Onboarding skill — creates phased plans for new devs |
| `skills/agentkit/` | Agent generator skill — analyzes custom code, creates project-level agents for Claude/Gemini/Copilot |
| `skills/repokit/` | Maintenance hub — repo health dashboard, post-change sync, deep audits, project bootstrap (status, sync, audit, init) |
| `skills/tik/` | Default ticket creation skill — turns text requests into structured tickets in `specs/tickets/` |
| `skills/figtik/` | Figma-to-ticket skill — fetches Figma designs via API, creates implementation tickets |
| `skills/stitchtik/` | Stitch-to-ticket skill — analyzes Google Stitch UI exports against codebase, creates implementation tickets |
| `.agents/skills/` | Symlink to `skills/` for Gemini cross-compatibility |
| `agents/` | Distributed agents bundled with the plugin (sanity-checker, auditor) |
| `.claude/agents/` | Internal dev-only agents — NOT distributed (component-reviewer only) |
| `.claude-plugin/` | Claude plugin metadata (`plugin.json`) and marketplace catalog (`marketplace.json`) |
| `.mcp.json` | Bundled MCP servers (context7 for library documentation) |
| `hooks/` | Session lifecycle hooks |
| `policies/` | Gemini CLI policy engine rules |
| `specs/` | Ticket system — created at runtime by agents, gitignored in this repo |
| `GEMINI.md` | Gemini extension context (tool docs, not project context) |
| `gemini-extension.json` | Gemini extension manifest |

## Architecture

### Skills (`skills/`, cross-platform)

Skills have YAML frontmatter (`name`, `description`, `user-invocable: true`) and load on demand. Claude discovers from `skills/` at plugin root; Gemini discovers from `.agents/skills/` (symlinked to `skills/`); Copilot discovers from `skills/` via plugin install.

| Skill | Modes | Key Behavior |
|-------|-------|-------------|
| `dockit` | init, sync, check, migrate, diagrams | Scales docs by project size; detects frameworks; never destroys content |
| `modernizer` | analyze, status | Plans only, never executes; writes tickets to `specs/tickets/`, appends to `specs/backlog.md` with `[modernizer]` tag |
| `onboard` | (single mode) | Reads existing docs first; asks for role before proceeding; chat-only, creates no files |
| `agentkit` | (single mode) | Analyzes custom code; generates project-level agents for Claude, Gemini, Copilot; scales by project size |
| `repokit` | status, sync, audit, init | Maintenance hub — orchestrates other tools; repo health dashboard, post-change sync, deep audits, project bootstrap |
| `tik` | (single mode) | Default ticket skill — turns text requests into structured tickets in `specs/tickets/` |
| `figtik` | create, update | Fetches Figma design data via API; compares against codebase; writes tickets to `specs/tickets/` with `[figtik]` tag |
| `stitchtik` | (single mode) | Analyzes Google Stitch UI exports (`screen.png`, `code.html`, `DESIGN.md`) against codebase; writes tickets to `specs/tickets/` with `[stitchtik]` tag |

### Agents (`agents/`, distributed with plugin)

Agents auto-trigger based on their description. They run in isolated context windows.

| Agent | Auto-triggers | Output |
|-------|-------------|--------|
| `sanity-checker` | Before commit, after code changes, quality verification | lint → format → typecheck → test; fixes what it can; creates tickets for unfixable issues |
| `auditor` | Reviews codebase for outdated code, stale practices, automation gaps | Returns findings report; does not write tickets (modernizer writes tickets from findings) |

### Internal Dev Agent (`.claude/agents/`, NOT distributed)

| Agent | Purpose |
|-------|---------|
| `component-reviewer` | Reviews skills, agents, and commands for frontmatter correctness, description quality, and cross-platform compatibility — uses Opus, internal only |

### Ticket System (`specs/`)

All skills and agents that find work write to a shared location:
- `specs/backlog.md` — master checklist, one line per item, tagged by source
- `specs/tickets/<slug>.md` or `specs/tickets/<slug>/ticket.md` — individual tickets with full context

Format in `backlog.md` — position in the list IS the priority/dependency order:
```
- [ ] Design system tokens [stitchtik] → tickets/design-system-tokens/ticket.md
- [ ] Bottom nav bar [stitchtik] → tickets/bottom-nav-bar/ticket.md
- [ ] Add dark mode support [tik] → tickets/dark-mode-support.md
- [ ] Hero section redesign [figtik] → tickets/hero-section-redesign/ticket.md
- [ ] Testing setup [modernizer] → tickets/testing-setup.md
```

All skills use plain kebab-case slugs — no numeric prefixes. Dependencies are expressed via position in the backlog and references inside each ticket.

Always check `specs/backlog.md` before creating a ticket to avoid duplicates.

### Plugin Structure

This repo is both a **Claude plugin** and a **Gemini extension**:

- Claude: `.claude-plugin/plugin.json` (plugin metadata), `.claude-plugin/marketplace.json` (marketplace catalog pointing to `"."`)
- Gemini: `gemini-extension.json` (extension manifest, references `GEMINI.md` as context file)

The `plugins/` subdirectory no longer exists — the root is the plugin.

### Agents vs `.claude/agents/`

| Location | Who Gets It | Use For |
|----------|------------|---------|
| `agents/` | Plugin users (distributed) | sanity-checker, auditor |
| `.claude/agents/` | This repo's developers only | component-reviewer (internal tooling) |

## Adding a New Framework to dockit

1. Add detection rule to `skills/dockit/frameworks/_index.md`
2. Create `skills/dockit/frameworks/[name].md` (use `_default.md` as template)
3. Create `skills/dockit/references/templates/[name]/` with framework-specific templates
4. Add a sample to `skills/dockit/references/samples/[name]-project/`

## Hooks

`hooks/hooks.json` runs on session lifecycle events (Gemini; Claude uses `.claude/settings.json`):

| Event | Behavior |
|-------|----------|
| `SessionStart` | Shows count of open items in `specs/backlog.md` if any exist |
| `Stop` | Reminds user to run sanity-checker if code was modified |

## Policies

`policies/policies.toml` applies to Gemini CLI only. Rules by category:

| Category | Rules |
|----------|-------|
| Destructive ops | Confirm `rm -rf`, confirm deleting `specs/` or `agents/` dirs |
| Git | Confirm `git push` |
| Secrets | Deny reading `.env`/`id_rsa`/`passwd`, deny writing to `.env*` |
| Context files | Confirm before overwriting `CLAUDE.md` or `GEMINI.md` |
| Safety checker | Path validation on all file writes |

## Development Commands

```bash
make setup      # First-time setup: install pre-commit hooks + link Gemini extension
make check      # Run all pre-commit validations (JSON, TOML, YAML)
make link       # Link Gemini extension for local testing
make status     # Show open backlog items and extension link status
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
