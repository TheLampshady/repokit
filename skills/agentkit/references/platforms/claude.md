# Claude Agent Format

## File Location

- Project level: `.claude/agents/<name>.md`
- File extension: `.md` (not `.agent.md`)

## Frontmatter

```yaml
---
name: agent-name
description: "Expert description with trigger phrases and example scenarios.

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

## Required Fields

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | kebab-case identifier |
| `description` | string | Include `<example>` blocks for reliable auto-triggering |

## Optional Fields

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `model` | string | inherit | `haiku`, `sonnet`, `opus`, or `inherit` |
| `tools` | string | all | Comma-separated list to restrict available tools |
| `disallowedTools` | string | none | Comma-separated denylist |
| `maxTurns` | integer | — | Bounds agentic loops |
| `permissionMode` | string | default | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `skills` | list | — | Preloads skill content into agent context |
| `mcpServers` | list | — | MCP servers available to agent |
| `memory` | string | — | `user`, `project`, or `local` |
| `background` | boolean | false | Run as background task |
| `isolation` | string | — | `worktree` for isolated git worktree |

## Description Best Practices

The description is critical for auto-triggering. Include:

1. **Area of expertise** — what this agent knows about
2. **When it should be used** — explicit trigger conditions
3. **Example scenarios** — 2-3 `<example>` blocks showing user messages and assistant decisions

Keep descriptions specific. "Use for all Django model operations" is too broad. "Use when working with this project's custom model managers, audit mixins, and soft-delete patterns in `core/models/`" is better.

## Body Structure

The markdown body below frontmatter is the agent's system prompt. Structure it as:

1. **Role statement** — "You are an expert in..."
2. **What you know** — overview of the custom patterns
3. **Custom patterns** — detailed catalog with file paths and examples
4. **Key files** — table of important files
5. **Common mistakes** — what to avoid
6. **Research capability** — how to look up framework docs
