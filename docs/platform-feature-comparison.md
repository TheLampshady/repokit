# Platform Feature Comparison: Skills, Agents & Commands

Comparison of component headers and capabilities across **Claude Code**, **Gemini CLI**, and **GitHub Copilot** (VS Code).

---

## Concept Mapping

Each platform uses different terminology for the same concepts:

| Concept | Claude Code | Gemini CLI | GitHub Copilot |
|---------|-------------|------------|----------------|
| Reusable prompt invoked by user or AI | **Skill** (`SKILL.md`) | **Skill** (`SKILL.md`) | **Agent Skill** (`.skill.md`) or **Prompt File** (`.prompt.md`) |
| Specialist AI with isolated context | **Subagent** (`agents/*.md`) | **Subagent** (`.gemini/agents/*.md`) | **Custom Agent** (`.github/agents/*.agent.md`) |
| Slash command / prompt shortcut | **Command** (`commands/*.md`) | **Command** (`commands/*.toml`) | **Prompt File** (`.github/prompts/*.prompt.md`) |
| Always-on context file | `CLAUDE.md` | `GEMINI.md` (via `contextFileName`) | `.github/copilot-instructions.md` or `.github/instructions/*.instructions.md` |

---

## Skills

### Frontmatter Fields

| Field | Claude Code | Gemini CLI | Copilot (`.skill.md`) |
|-------|-------------|------------|----------------------|
| `name` | Optional — defaults to dir name, max 64 chars | **Required** | **Required** — max 64 chars |
| `description` | Recommended — max 1024 chars; used for auto-invocation | **Required** | **Required** — max 1024 chars |
| `argument-hint` | Optional — shown in autocomplete | — | Optional |
| `user-invocable` | Optional bool (default `true`) — hides from `/` menu if `false` | — | Optional bool (default `true`) |
| `disable-model-invocation` | Optional bool (default `false`) — requires manual `/` invoke | — | Optional bool (default `false`) |
| `allowed-tools` | Optional — comma-separated; grants tools without permission prompts | — | — |
| `model` | Optional — `sonnet`, `opus`, `haiku` | — | Optional — model identifier |
| `context` | Optional — `fork` runs skill in isolated subagent | — | — |
| `agent` | Optional — subagent to use when `context: fork` | — | — |
| `hooks` | Optional — lifecycle hooks scoped to skill | — | — |
| `version` | — | — | Optional — semver string |

### File & Directory Structure

**Claude Code**
```
skills/
└── my-skill/
    ├── SKILL.md          ← frontmatter + instructions
    ├── reference.md      ← optional supporting docs
    └── scripts/          ← optional scripts
```

**Gemini CLI**
```
.agents/skills/
└── my-skill/
    └── SKILL.md          ← frontmatter + instructions
```

**GitHub Copilot**
```
.github/skills/
└── my-skill/
    └── SKILL.md          ← frontmatter + instructions
```

### Invocation

| | Claude Code | Gemini CLI | Copilot |
|-|-------------|------------|---------|
| User invoke | `/plugin:skill-name` | `/skill-name` | `/skill-name` |
| AI auto-invoke | Yes — based on `description` match | Yes — based on `description` match | Yes — based on `description` match |
| Arguments | `$ARGUMENTS`, `$1`, `$2` | `{{args}}` | `${variableName}` |

### Example

**Claude Code / Gemini (shared `SKILL.md`):**
```yaml
---
name: review
description: Review code for bugs and security issues. Use when asked to review, audit, or check code quality.
user-invocable: true
---

Review the provided code for:
- Logic errors and edge cases
- Security vulnerabilities
- Performance concerns
```

**Copilot (`.skill.md`):**
```yaml
---
name: review
description: Review code for bugs and security issues. Use when asked to review, audit, or check code quality.
user-invocable: true
version: 1.0.0
---
```

---

## Agents / Subagents

### Frontmatter Fields

| Field | Claude Code | Gemini CLI | GitHub Copilot |
|-------|-------------|------------|----------------|
| `name` | **Required** — kebab-case | **Required** | Optional — defaults to filename, max 64 chars |
| `description` | **Required** — trigger phrases + examples | **Required** | **Required** — max 1024 chars |
| `tools` | Optional — comma-separated string: `Read, Grep` | Optional — YAML list: `- read_file` ⚠ different format & names | Optional — array or `["*"]` for all |
| `disallowedTools` | Optional — comma-separated denylist | — | — |
| `model` | Optional — `sonnet`, `opus`, `haiku`, `inherit` | Optional — model ID: `gemini-2.5-pro` ⚠ different values | Optional — model name string |
| `kind` | — | Optional — `local` (default) or `remote` | — |
| `temperature` | — | Optional — float `0.0`–`2.0` | — |
| `max_turns` | — | Optional — integer (default `15`) | — |
| `timeout_mins` | — | Optional — integer (default `5`) | — |
| `maxTurns` | Optional — integer | — | — |
| `permissionMode` | Optional — `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` | — | — |
| `skills` | Optional — list of skill names to preload into context | — | — |
| `mcpServers` | Optional — server names or inline config | — | — |
| `mcp-servers` | — | — | Optional — MCP server config object |
| `hooks` | Optional — lifecycle hooks object | — | — |
| `memory` | Optional — `user`, `project`, `local` | — | — |
| `background` | Optional bool (default `false`) | — | — |
| `isolation` | Optional — `worktree` | — | — |
| `color` | Optional — UI display color (**Claude only**) | ❌ Not supported | — |
| `target` | — | — | Optional — `vscode` or `github-copilot` |
| `user-invokable` | — | — | Optional bool (default `true`) |
| `disable-model-invocation` | — | — | Optional bool (default `false`) |
| `handoffs` | — | — | Optional — array of handoff objects |
| `metadata` | — | — | Optional — string key-value pairs |

### File Locations

| Scope | Claude Code | Gemini CLI | GitHub Copilot |
|-------|-------------|------------|----------------|
| User (all projects) | `~/.claude/agents/` | `~/.gemini/agents/` | `~/.github/agents/` |
| Project | `.claude/agents/` | `.gemini/agents/` | `.github/agents/` |
| Plugin / Extension | `agents/` in plugin | `.gemini/agents/` in extension | `.github/agents/` |

### Execution Model

| | Claude Code | Gemini CLI | GitHub Copilot |
|-|-------------|------------|----------------|
| Confirmation | Per-step (unless `bypassPermissions`) | **YOLO mode** — no confirmation | Varies |
| Can spawn subagents | No (agents cannot nest) | No | Supports `handoffs` |
| Persistent memory | Yes — `memory: user/project/local` | No | No |
| Isolated worktree | Yes — `isolation: worktree` | No | No |
| Background execution | Yes — `background: true` | No | No |

### Example

**Claude Code:**
```yaml
---
name: code-reviewer
description: Expert code reviewer. Use proactively after writing or modifying code. Triggered automatically when user asks to review code or check quality.
tools: Read, Grep, Glob, Bash
model: sonnet
---
```

**Gemini CLI:**
```yaml
---
name: code-reviewer
description: Specialized in reviewing code for quality, bugs, and security issues.
kind: local
tools:
  - read_file
  - grep_search
model: gemini-2.5-pro
temperature: 0.2
max_turns: 10
---
```

**GitHub Copilot:**
```yaml
---
name: code-reviewer
description: Expert code reviewer. Use when reviewing code or checking quality.
tools: ["read_file", "search_files"]
model: Claude Sonnet 4
---
```

> ⚠ **`tools` field conflict**: Claude uses a comma-separated string with Claude tool names (`Read, Grep`). Gemini uses a YAML list with Gemini tool names (`- read_file`). Copilot uses a JSON array. These are **not cross-platform compatible** — agents are platform-specific files.

---

## Commands / Prompt Files

### Frontmatter Fields

| Field | Claude Code (`.md`) | Gemini CLI (`.toml`) | Copilot (`.prompt.md`) |
|-------|---------------------|----------------------|------------------------|
| `name` | Optional — defaults to filename | — | Optional |
| `description` | Recommended | Optional | Optional |
| `argument-hint` | Optional | — | Optional |
| `user-invocable` | Optional bool | — | — |
| `disable-model-invocation` | Optional bool | — | — |
| `allowed-tools` | Optional — comma-separated | — | — |
| `model` | Optional — `sonnet`, `opus`, `haiku` | — | Optional — model name |
| `agent` | — | — | Optional — `ask`, `agent`, `plan`, or custom name |
| `tools` | — | — | Optional — array of tool names |
| `prompt` | *(body below frontmatter)* | **Required** — TOML string | *(body below frontmatter)* |

### File Format

**Claude Code (`commands/my-cmd.md`):**
```markdown
---
description: Summarize recent git changes
argument-hint: [branch-name]
---

Summarize the recent changes in $ARGUMENTS, grouped by feature area.
```

**Gemini CLI (`commands/my-cmd.toml`):**
```toml
description = "Summarize recent git changes"

prompt = """
Summarize the recent changes in {{args}}, grouped by feature area.
"""
```

Or using the array format:
```toml
description = "Summarize recent git changes"

[[command.prompts]]
type = "user"
content = "Summarize the recent git changes, grouped by feature area."
```

**GitHub Copilot (`.github/prompts/my-cmd.prompt.md`):**
```markdown
---
description: Summarize recent git changes
agent: ask
model: Claude Sonnet 4
---

Summarize the recent changes in ${selectedText}, grouped by feature area.
```

### Argument Placeholders

| Platform | Syntax | Notes |
|----------|--------|-------|
| Claude Code | `$ARGUMENTS`, `$1`, `$2` | Positional args |
| Gemini CLI | `{{args}}` | All args; also `!{cmd}` for shell output, `@{file}` for file content |
| GitHub Copilot | `${selectedText}`, `${file}`, `${workspaceFolder}` | IDE context variables |

### Invocation

| | Claude Code | Gemini CLI | Copilot |
|-|-------------|------------|---------|
| In-session invoke | `/plugin:command-name` | `/command-name` | `/command-name` |
| With args | `/plugin:cmd arg1 arg2` | `/cmd some text` | `/cmd` (uses IDE selection) |

---

## Always-On Context Files

These files are always loaded — not invoked by slash command.

| Platform | File | Scope | Notes |
|----------|------|-------|-------|
| Claude Code | `CLAUDE.md` | Project (nearest parent wins) | Project context, coding conventions |
| Gemini CLI | `GEMINI.md` | Set via `contextFileName` in `gemini-extension.json` | Extension tool docs — write as platform docs, not project notes |
| Copilot | `.github/copilot-instructions.md` | Repo-wide | All chats in the repo |
| Copilot | `.github/instructions/*.instructions.md` | Path-scoped via `applyTo` glob | Agent-specific or file-type-specific |

**Copilot `.instructions.md` frontmatter:**

| Field | Required | Values | Notes |
|-------|----------|--------|-------|
| `name` | No | Any string | Display name |
| `description` | No | Text, 1–500 chars | Shown on hover |
| `applyTo` | No | Glob pattern (`**/*.ts`, `**/tests/**`) | Which files trigger these instructions |
| `excludeAgent` | No | `code-review`, `coding-agent` | Hide from specific Copilot agents |

---

## Cross-Platform Compatibility Summary

| Feature | Claude ↔ Gemini | Claude ↔ Copilot | Gemini ↔ Copilot |
|---------|-----------------|------------------|------------------|
| Skill `SKILL.md` shared | ✓ `name` + `description` compatible | Partial — extra fields ignored | ✓ Minimal shared fields |
| Agent files shared | ✗ Different dirs, `tools` format conflicts | ✗ Different dirs + fields | ✗ Different dirs + fields |
| Command files shared | ✗ `.md` vs `.toml` — different formats | Partial — `.md` format similar | ✗ `.toml` vs `.prompt.md` |
| `color` field | Claude only (Gemini ignores) | Copilot ignores | — |
| `tools` field | ⚠ Incompatible format + names | ⚠ Incompatible values | ⚠ Incompatible |
| `model` field | ⚠ Different value spaces | ⚠ Different value spaces | ⚠ Different value spaces |
| `maxTurns` / `max_turns` | ✗ Different key names | ✗ | ✗ |
| Hook event names | ✗ `Stop` vs `SessionEnd` (use `SessionEnd`) | ✗ | ✗ |

**Safe cross-platform fields (Skills):** `name`, `description`, `user-invocable`, `disable-model-invocation`

**Agent files are always platform-specific** — store them in platform-specific directories, not shared locations.

---

## Hook Event Name Reference

Hook event names differ significantly between platforms:

| Purpose | Claude Code | Gemini CLI |
|---------|-------------|------------|
| Session begins | `SessionStart` | `SessionStart` |
| Session ends | `SessionEnd` ✓ (also `Stop`, Claude-only) | `SessionEnd` |
| Before tool call | `PreToolUse` | `BeforeTool` |
| After tool call | `PostToolUse` | `AfterTool` |
| Before compaction | `PreCompact` | `PreCompress` |
| Agent starts | `SubagentStart` | `BeforeAgent` |
| Agent ends | `SubagentStop` | `AfterAgent` |
| Before model call | — | `BeforeModel` |
| After model call | — | `AfterModel` |
| Tool selection | — | `BeforeToolSelection` |
| User submits prompt | `UserPromptSubmit` | — |
| Permission requested | `PermissionRequest` | — |
| Notification | `Notification` | `Notification` |

> Use `SessionEnd` (not `Stop`) when writing hooks for cross-platform plugins — it is valid on both Claude and Gemini.

---

## Further Reading

- **Claude Code Skills**: https://code.claude.com/docs/en/skills
- **Claude Code Subagents**: https://code.claude.com/docs/en/sub-agents
- **Gemini CLI Skills**: https://geminicli.com/docs/cli/creating-skills/
- **Gemini CLI Subagents**: https://geminicli.com/docs/core/subagents/
- **Gemini CLI Commands**: https://geminicli.com/docs/cli/custom-commands/
- **Gemini CLI Hooks**: https://geminicli.com/docs/hooks/reference/
- **Copilot Custom Instructions**: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- **Copilot Agent Skills**: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- **Copilot Custom Agents**: https://code.visualstudio.com/docs/copilot/customization/custom-agents
- **Copilot Prompt Files**: https://code.visualstudio.com/docs/copilot/customization/prompt-files
