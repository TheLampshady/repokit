# Gemini Agent Format

## File Location

- Project level: `.gemini/agents/<name>.md`
- File extension: `.md`

## Prerequisites

Gemini subagents require opt-in. The user must have:

```json
// .gemini/settings.json
{"experimental": {"enableAgents": true}}
```

## Frontmatter

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

## Required Fields

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | Agent identifier |
| `description` | string | Specialization summary — drives auto-triggering |

## Optional Fields

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `kind` | string | `local` | Agent kind |
| `tools` | YAML list | all | Available tools (YAML list format, not comma-separated) |
| `model` | string | — | Gemini model ID (e.g., `gemini-2.5-pro`) |
| `temperature` | float | — | 0.0–2.0 (lower = deterministic, higher = creative) |
| `max_turns` | integer | 15 | Max execution turns |
| `timeout_mins` | integer | 5 | Max execution time in minutes |

## Important: YOLO Mode

Gemini agents run without per-step confirmation. Design accordingly:
- Include guardrails in the system prompt ("do NOT modify files unless asked")
- Be explicit about read-only vs write operations
- Add safety checks ("verify before overwriting")

## Description Best Practices

Gemini uses the description to decide when to delegate to a subagent. Include:

1. **Area of expertise** — what this agent specializes in
2. **When it should be used** — explicit trigger conditions
3. **Example scenarios** — brief examples of when to invoke

Unlike Claude, Gemini descriptions do not use `<example>` XML tags. Use plain text with scenario descriptions.

## Tools Reference

Common Gemini tools to include:

| Tool | Use |
|------|-----|
| `read_file` | Read source files |
| `edit_file` | Modify files |
| `grep_search` | Search code |
| `list_directory` | Explore structure |
| `web_search` | Research framework docs |
| `run_command` | Execute shell commands |

## Body Structure

Same as Claude — the markdown body is the system prompt. Include YOLO-mode safety guardrails.
