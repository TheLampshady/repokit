# Platform Reference

One agent body, three frontmatter formats. This file covers all platform differences in one place.

## Output Paths

| Platform | Path | Extension |
|----------|------|-----------|
| Claude | `.claude/agents/<name>.md` | `.md` |
| Antigravity | `.agents/agents/<name>.md` or `.agents/agents/<name>/agent.md` | `.md` |
| Copilot | `.github/agents/<name>.agent.md` | `.agent.md` |

Copilot also supports organization-level agents at `{org}/.github/agents/` or `{org}/.github-private/agents/`. Antigravity supports global agents at `~/.gemini/config/agents/<name>/agent.md`.

> **Antigravity replaced Gemini CLI.** Gemini CLI stopped serving Pro/Ultra/free tiers on **2026-06-18**; only Code Assist Standard/Enterprise licenses still reach it. Antigravity discovers subagents under `.agents/agents/` — **not** the old `.gemini/agents/`. Writing to `.gemini/agents/` produces files nothing will load. Note the asymmetry: agent and skill discovery moved to `.agents/`, but global config stayed under `~/.gemini/` (`~/.gemini/config/agents/`, `~/.gemini/GEMINI.md`) — don't "fix" those to `~/.agents/`.

## Frontmatter Comparison

### Required Fields

| Field | Claude | Antigravity | Copilot |
|-------|--------|-------------|---------|
| `name` | yes (kebab-case) | yes | optional (defaults to filename) |
| `description` | yes — include `<example>` blocks | yes — plain text | yes — plain text |

### Optional Fields

| Field | Claude | Antigravity | Copilot |
|-------|--------|-------------|---------|
| `model` | `haiku`, `sonnet`, `opus`, `inherit` | `inherit`, `flash`, `pro` (tier names, **not** model IDs; default `inherit`) | model string |
| `tools` | comma-separated string (enforced) | YAML list (**enforced allowlist**; default `[]`) | YAML list or string (enforced) |
| `commandExecutionPolicy` | — | `off`, `auto`, `eager`, `sandbox` (default `sandbox`) | — |
| `subagent` | — | boolean (default `true`) — allows `invoke_subagent` | — |
| `mainAgent` | — | boolean (default `true`) — selectable as primary agent | — |
| `maxTurns` / `max_turns` | `maxTurns` (integer) | — | — |
| `disallowedTools` | comma-separated denylist | — | — |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` | — (use `commandExecutionPolicy` + `tools`) | — |
| `skills` | list (preloads skill content) | list of skill paths (default `[]`) | — |
| `plugins` | — | list of plugin dependencies (default `[]`) | — |
| `mcpServers` | list | list of objects (default `[]`) | object (GitHub.com and CLI only) |
| `memory` | `user`, `project`, or `local` | — | — |
| `background` | boolean | — | — |
| `isolation` | `worktree` | — | — |
| `target` | — | — | `vscode`, `github-copilot`, or both |
| `user-invocable` | — | — | boolean (default true) |
| `disable-model-invocation` | — | — | boolean (default false) |
| `metadata` | — | — | name/value pairs |

**Retired Gemini CLI fields:** `temperature`, `timeout_mins`, `max_turns`, `kind: local`, and Gemini model IDs (`gemini-2.5-pro`). None are part of the Antigravity subagent spec — drop them rather than carrying them forward.

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

**Antigravity:**
```yaml
---
name: agent-name
description: 'Expert description with area of expertise and when to use.'
tools:
  - view_file
  - grep_search
subagent: true
mainAgent: false
model: inherit
commandExecutionPolicy: sandbox
---
```

> **Antigravity `tools` IS an enforced allowlist** — unlike Gemini CLI, which parsed the field and ignored it. Two consequences: an omitted `tools` list defaults to `[]`, and **misspelled or unmapped tool names can hang the subagent process** (a documented known issue). Use exact Antigravity tool names — `view_file`, `grep_search`, `run_command`, `replace_file_content` — not Claude's (`Read`, `Grep`, `Bash`, `Edit`). Copying a Claude tools list verbatim into an Antigravity agent is the most likely way to break one.

> `mainAgent: false` is the field that matters for generated SME agents: it keeps them out of the primary-agent picker in `/agents` while leaving them delegable. `subagent` already defaults to `true`, so setting it is optional — include it for explicitness, but it isn't what makes the agent invocable.

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

### Antigravity: Enforcement Moved Into Frontmatter

Gemini CLI had no per-agent enforcement, so agentkit scoped Gemini agents entirely through body prose (the "YOLO note"). **Antigravity changed this** — `tools` is an enforced allowlist and `commandExecutionPolicy` governs shell execution, so scope is declared in frontmatter and actually held.

| Concern | Gemini CLI (old) | Antigravity (now) |
|---------|------------------|-------------------|
| Tool access | body prose only | `tools` allowlist, enforced |
| Shell execution | body prose only | `commandExecutionPolicy` |
| Approval prompts | none (YOLO) | inline prompt in `/agents`; approve `a` / deny `d` |

`commandExecutionPolicy` defaults to `sandbox`, which prompts inline for protected operations rather than running them silently. **Don't set `off`, `auto`, or `eager` on generated agents** — `sandbox` is the safe default and the only value agentkit should emit unless the user explicitly asks otherwise.

Keep a short scope note in the body anyway. Frontmatter constrains what the agent *can* do; the body still communicates what it *should* do, and that's what keeps an agent from making in-scope-but-unwanted edits:

> **Scope:** Default to read-only analysis and recommendations. Do NOT modify files unless explicitly asked.

**No opt-in flag required.** The old Gemini CLI prerequisite (`experimental.enableAgents` in `.gemini/settings.json`) does not apply to Antigravity — subagents are a standard feature. Don't emit that instruction.

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
- **Antigravity:** Plain text with scenario descriptions (no XML tags) — the planner reads it to decide delegation
- **Copilot:** Plain text, concise — shown as placeholder text in chat

## Antigravity Tools — Important Note

Antigravity **does** enforce the frontmatter `tools` allowlist. This is a reversal from Gemini CLI, and it changes how agentkit generates for this platform: include an explicit `tools` list, because the default is `[]`.

Use Antigravity's tool names. They don't match Claude's:

| Purpose | Antigravity | Claude |
|---------|-------------|--------|
| Read a file | `view_file` | `Read` |
| Search contents | `grep_search` | `Grep` |
| Edit a file | `replace_file_content` | `Edit` |
| Run a shell command | `run_command` | `Bash` |

Two failure modes to avoid:

1. **Misspelled or unmapped tool names can hang the subagent process** — a documented known issue, not a graceful error. Verify names against the [subagent spec](https://antigravity.google/docs/subagents#custom-subagents) rather than guessing.
2. **Under-listing silently breaks the agent.** A foundation-owner that can't `replace_file_content` will read its docs, decide an edit is needed, and fail to make it.

Frontmatter is now the load-bearing mechanism, but keep the body's scope note and the `Working Directories` / `Maintenance` / `What This Agent Does NOT Do` sections. They cover what the allowlist can't express: *which* files inside the permitted set the agent should touch.

## Body Structure

Two templates ship with agentkit:

| Template | When to use |
|----------|-------------|
| `references/templates/agent.template.md` | Default — domain-expert agents that don't own any FOUNDATIONS.md row |
| `references/templates/foundation-agent.template.md` | When the agent owns ≥1 row in `docs/FOUNDATIONS.md` (adds Owned Foundations + Maintenance sections) |

Per-platform modifications:
- **Claude:** Use template as-is. For foundation-owner agents, set `tools: Read, Edit, Write, Glob, Grep, Bash` and `permissionMode: acceptEdits` in frontmatter — these ARE enforced by Claude.
- **Antigravity:** Include an enforced `tools` list using Antigravity tool names, plus `mainAgent: false` and `commandExecutionPolicy: sandbox`. Insert the scope note after the role statement; the foundation-owner variant authorizes editing `docs/`.
- **Copilot:** Monitor total file size, trim if over 30,000 characters. Foundation-owners need `editFile` in the tools list (Copilot DOES enforce its tools allowlist).

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

### Antigravity (foundation-owner)

```yaml
---
name: agent-name
description: '...'
tools:
  - view_file
  - grep_search
  - replace_file_content
  - run_command
subagent: true
mainAgent: false
model: pro
commandExecutionPolicy: sandbox
---
```

A foundation-owner needs `replace_file_content` to update `FOUNDATIONS.md` and its sub-doc, and `run_command` for the `git log` last-touched check and `grep -rn` cross-doc consistency pass. Omitting either produces an agent that diagnoses correctly and then can't act.

`model: pro` (not `inherit`) because cross-doc maintenance is the reasoning-heavy case. `commandExecutionPolicy: sandbox` keeps shell operations behind an inline approval prompt.

Antigravity has no `permissionMode` equivalent — there's no `acceptEdits`, so routine doc edits will prompt. That's the platform's behavior, not something to work around by loosening `commandExecutionPolicy`.

The body still carries the load for *which* files to edit: the foundation-owner scope note authorizes `docs/` and forbids source outside it, the description's `Do NOT use for:` clause prevents mis-delegation, and the Maintenance section spells out the protocols. Frontmatter says what's possible; the body says what's appropriate.

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

## Antigravity Scope Note (Two Variants)

The body carries a scope note immediately after the role statement. Under Gemini CLI this was the *only* control; under Antigravity it complements the enforced `tools` allowlist by saying which files inside the permitted set the agent should actually touch. **Use the right variant for the agent type:**

### Default (read-only domain expert)

> **Scope:** Default to read-only analysis and recommendations. Do NOT modify files unless explicitly asked.

### Foundation-owner (authorized to edit docs)

> **Scope:** You ARE authorized to edit `docs/FOUNDATIONS.md`, `docs/architecture/foundations/<slug>.md`, and this agent's own file when invoked for maintenance. Follow the Invariant Change Protocol — invariant changes require explicit user confirmation BEFORE editing. Do NOT modify source code outside `docs/`.

Pick based on whether the agent template is `agent.template.md` (default note) or `foundation-agent.template.md` (foundation-owner note).

The default variant pairs with a read-only `tools` list (`view_file`, `grep_search`); the foundation-owner variant pairs with the editing list above. Keep frontmatter and note consistent — a read-only note over an editing allowlist is a mixed signal, and the allowlist is what wins.
