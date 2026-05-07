# Platform Reference

One agent body, three frontmatter formats. This file covers all platform differences in one place.

## Output Paths

| Platform | Path | Extension |
|----------|------|-----------|
| Claude | `.claude/agents/<name>.md` | `.md` |
| Gemini | `.gemini/agents/<name>.md` | `.md` |
| Copilot | `.github/agents/<name>.agent.md` | `.agent.md` |

Copilot also supports organization-level agents at `{org}/.github/agents/` or `{org}/.github-private/agents/`.

## Frontmatter Comparison

### Required Fields

| Field | Claude | Gemini | Copilot |
|-------|--------|--------|---------|
| `name` | yes (kebab-case) | yes | optional (defaults to filename) |
| `description` | yes — include `<example>` blocks | yes — plain text | yes — plain text |

### Optional Fields

| Field | Claude | Gemini | Copilot |
|-------|--------|--------|---------|
| `model` | `haiku`, `sonnet`, `opus`, `inherit` | Gemini model ID (e.g., `gemini-2.5-pro`) | model string |
| `tools` | comma-separated string | YAML list | YAML list or string |
| `maxTurns` / `max_turns` | `maxTurns` (integer) | `max_turns` (integer, default 15) | — |
| `temperature` | — | 0.0–2.0 (float) | — |
| `timeout_mins` | — | integer (default 5) | — |
| `disallowedTools` | comma-separated denylist | — | — |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` | — | — |
| `skills` | list (preloads skill content) | — | — |
| `mcpServers` | list | — | object (GitHub.com and CLI only) |
| `memory` | `user`, `project`, or `local` | — | — |
| `background` | boolean | — | — |
| `isolation` | `worktree` | — | — |
| `kind` | — | `local` | — |
| `target` | — | — | `vscode`, `github-copilot`, or both |
| `user-invocable` | — | — | boolean (default true) |
| `disable-model-invocation` | — | — | boolean (default false) |
| `metadata` | — | — | name/value pairs |

**Retired Copilot fields:** `infer` — use `disable-model-invocation` and `user-invocable` instead.

### Frontmatter Examples

**Claude:**
```yaml
---
name: agent-name
description: "Expert description with trigger phrases.

Examples:

<example>
Context: When this agent should trigger.
user: \"User message that should trigger this agent\"
assistant: \"How the assistant decides to use this agent\"
<Task tool call to launch agent>
</example>

<example>
Context: Another scenario.
user: \"Another triggering message\"
assistant: \"Assistant reasoning\"
<Task tool call to launch agent>
</example>"
---
```

**Gemini:**
```yaml
---
name: agent-name
description: 'Expert description with area of expertise and when to use.'
tools:
  - read_file
  - edit_file
  - grep_search
  - list_directory
  - web_search
model: gemini-2.5-pro
temperature: 0.2
max_turns: 15
timeout_mins: 5
---
```

**Copilot:**
```yaml
---
name: Agent Display Name
description: 'Expert description explaining the agent purpose and capabilities.'
tools:
  - readFile
  - editFile
  - search
---
```

## Platform Quirks

### Claude: `<example>` Blocks in Description

Claude uses `<example>` XML blocks in the description for reliable auto-triggering. These show the model when and how to invoke the agent. Include 2-3 examples with `Context:`, `user:`, and `assistant:` fields.

### Gemini: YOLO Mode

Gemini agents run without per-step confirmation. When generating for Gemini, insert this line immediately after the role statement in the body:

> **IMPORTANT:** This agent runs without per-step confirmation. Do NOT modify files unless explicitly asked. Default to read-only analysis and recommendations.

**Prerequisite:** Gemini subagents require opt-in:
```json
// .gemini/settings.json
{"experimental": {"enableAgents": true}}
```

### Copilot: 30,000 Character Limit

The entire file (frontmatter + body) must stay under 30,000 characters. Monitor character count during generation. If an agent exceeds this:
- Reduce code examples (show patterns, not full files)
- Move detailed file listings to a separate reference doc
- Split into multiple focused agents

### Copilot: VS Code-Only Fields

These fields work in VS Code but not on GitHub.com:

| Field | Purpose |
|-------|---------|
| `argument-hint` | Guidance text for user interactions |
| `agents` | Subagent delegation (`*` for all, `[]` for none) |
| `handoffs` | Guided workflow transitions to other agents |
| `hooks` | Agent-scoped hook commands (preview feature) |

## Description Best Practices

All platforms use the description to decide when to auto-trigger an agent. Keep descriptions specific — "Use for all Django model operations" is too broad. "Use when working with this project's custom model managers, audit mixins, and soft-delete patterns in `core/models/`" is better.

- **Claude:** Include `<example>` blocks showing user messages and assistant decisions
- **Gemini:** Plain text with scenario descriptions (no XML tags)
- **Copilot:** Plain text, concise — shown as placeholder text in chat

## Gemini Tools Reference

Common tools to include in Gemini agent frontmatter:

| Tool | Use |
|------|-----|
| `read_file` | Read source files |
| `edit_file` | Modify files |
| `grep_search` | Search code |
| `list_directory` | Explore structure |
| `web_search` | Research framework docs |
| `run_command` | Execute shell commands |

## Body Structure

Two templates ship with agentkit:

| Template | When to use |
|----------|-------------|
| `references/templates/agent.template.md` | Default — domain-expert agents that don't own any FOUNDATIONS.md row |
| `references/templates/foundation-agent.template.md` | When the agent owns ≥1 row in `docs/FOUNDATIONS.md` (adds Owned Foundations + Maintenance sections) |

Per-platform modifications:
- **Claude:** Use template as-is. For foundation-owner agents, also set `permissionMode: acceptEdits` in frontmatter so doc edits don't prompt.
- **Gemini:** Insert YOLO note (see below) after the role statement. **Inverted note for foundation-owners** — they ARE authorized to edit `docs/`.
- **Copilot:** Monitor total file size, trim if over 30,000 characters. Foundation-owners need `editFile` in the tools list.

---

## Foundation-Owner Frontmatter

When generating an agent that owns a FOUNDATIONS.md row, the frontmatter changes per platform.

### Claude (foundation-owner)

```yaml
---
name: agent-name
description: "..."
tools: Read, Edit, Write, Glob, Grep, Bash
permissionMode: acceptEdits
---
```

`acceptEdits` means doc edits inside `docs/` go through without per-step confirmation. The agent still has to follow the Invariant Change Protocol (which requires explicit user approval for invariant changes) — `acceptEdits` doesn't bypass that, it just removes the file-write prompt for routine updates.

`Bash` is included so the agent can run `git log` for last-touched checks and `grep -rn` for cross-doc consistency.

### Gemini (foundation-owner)

```yaml
---
name: agent-name
description: '...'
tools:
  - read_file
  - edit_file
  - write_file
  - grep_search
  - list_directory
  - run_command
  - web_search
model: gemini-2.5-pro
temperature: 0.2
max_turns: 20
timeout_mins: 10
---
```

`max_turns` is bumped to 20 because cross-doc maintenance often needs multiple grep + edit cycles.

### Copilot (foundation-owner)

```yaml
---
name: Agent Display Name
description: '...'
tools:
  - readFile
  - editFile
  - createFile
  - search
  - terminal
---
```

Copilot doesn't have a permission-mode equivalent; the tools allowlist controls what's allowed. Including `terminal` enables grep / git via shell.

---

## Gemini YOLO Note (Two Variants)

Gemini agents run without per-step confirmation. The body must include a safety note immediately after the role statement. **Use the right variant for the agent type:**

### Default (read-only domain expert)

> **IMPORTANT:** This agent runs without per-step confirmation. Do NOT modify files unless explicitly asked. Default to read-only analysis and recommendations.

### Foundation-owner (authorized to edit docs)

> **IMPORTANT:** This agent runs without per-step confirmation. You ARE authorized to edit `docs/FOUNDATIONS.md`, `docs/architecture/foundations/<slug>.md`, and the agent's own file when invoked for maintenance. Follow the Invariant Change Protocol — invariant changes require explicit user confirmation BEFORE editing. Do NOT modify source code outside `docs/`.

Pick based on whether the agent template is `agent.template.md` (default note) or `foundation-agent.template.md` (foundation-owner note).
