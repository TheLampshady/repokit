# Copilot Agent Format

## File Location

- Project level: `.github/agents/<name>.agent.md`
- Organization level: `{org}/.github/agents/<name>.agent.md` or `{org}/.github-private/agents/<name>.agent.md`
- File extension: `.agent.md`

## Frontmatter

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

## Required Fields

| Field | Type | Notes |
|-------|------|-------|
| `description` | string | Explains agent purpose — drives auto-invocation |

## Optional Fields

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `name` | string | filename | Display name (defaults to filename minus extension) |
| `tools` | list/string | all | Tool names the agent can access |
| `model` | string | inherit | LLM model for execution |
| `target` | string | both | `vscode` or `github-copilot`; defaults to both |
| `user-invocable` | boolean | true | Controls manual user selection |
| `disable-model-invocation` | boolean | false | When true, requires manual selection (no auto-trigger) |
| `mcp-servers` | object | — | Additional MCP servers (GitHub.com and CLI only) |
| `metadata` | object | — | Name/value pairs for annotation |

**Retired fields:** `infer` — use `disable-model-invocation` and `user-invocable` instead.

## Size Limit

**Maximum 30,000 characters** for the entire file (frontmatter + body).

Monitor character count during generation. If an agent would exceed this:
- Reduce code examples (show patterns, not full files)
- Move detailed file listings to a separate reference doc
- Split into multiple focused agents

## Description Best Practices

Copilot uses the description for both auto-invocation and display. Include:

1. **What the agent does** — clear purpose statement
2. **When to use it** — explicit scenarios
3. **Example use cases** — brief inline examples

Keep descriptions concise but specific. Copilot shows them as placeholder text in chat.

## VS Code Extensions

In VS Code, Copilot agents support additional fields:

| Field | Purpose |
|-------|---------|
| `argument-hint` | Guidance text for user interactions |
| `agents` | Subagent delegation (`*` for all, `[]` for none) |
| `handoffs` | Guided workflow transitions to other agents |
| `hooks` | Agent-scoped hook commands (preview feature) |

These are **VS Code only** — not available on GitHub.com.

## Body Structure

Same body structure as Claude and Gemini. The markdown content becomes the agent's system prompt.
