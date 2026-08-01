# Platform Feature Comparison: Skills, Agents & Commands

Comparison of component headers and capabilities across **Claude Code**, **Antigravity** (Google), and **GitHub Copilot** (VS Code).

> **Gemini CLI → Antigravity.** Gemini CLI stopped serving Pro/Ultra/free tiers on **2026-06-18** and its extensions are now Antigravity *plugins*. Where this doc says Antigravity, the old Gemini CLI value is noted inline when it differs — those are migration hazards, not alternatives. Code Assist Standard/Enterprise licenses still reach Gemini CLI.
>
> **Antigravity is two products.** The **IDE** (v2.x) and the **CLI** (`agy`, v1.x) ship separate plugin systems with separate install directories. Plugin *contents* are identical — same `plugin.json`, `skills/`, `rules/`, `mcp_config.json`, `hooks.json` — so one plugin serves both. Where they diverge, this doc says IDE or CLI explicitly. See [Antigravity: IDE vs CLI](#antigravity-ide-vs-cli).

---

## Concept Mapping

Each platform uses different terminology for the same concepts:

| Concept | Claude Code | Antigravity | GitHub Copilot |
|---------|-------------|-------------|----------------|
| Reusable prompt invoked by user or AI | **Skill** (`SKILL.md`) | **Agent Skill** (`SKILL.md`) | **Agent Skill** (`.skill.md`) or **Prompt File** (`.prompt.md`) |
| Specialist AI with isolated context | **Subagent** (`.claude/agents/*.md`) | **Subagent** (`.agents/agents/*.md`) | **Custom Agent** (`.github/agents/*.agent.md`) |
| Slash command / prompt shortcut | **Command** (`commands/*.md`) | — (skills auto-activate; no TOML commands) | **Prompt File** (`.github/prompts/*.prompt.md`) |
| Always-on context file | `CLAUDE.md` | `GEMINI.md` or `AGENTS.md` at workspace root | `.github/copilot-instructions.md` or `.github/instructions/*.instructions.md` |
| Conditionally-loaded rules | — | **Rules** (`.agents/rules/*.md`, 12k chars each) | `.github/instructions/*.instructions.md` (`applyTo` globs) |
| Distributable bundle | **Plugin** (`.claude-plugin/plugin.json`) | **Plugin** (`plugin.json`) | — |

---

## Skills

### Frontmatter Fields

| Field | Claude Code | Antigravity | Copilot (`.skill.md`) |
|-------|-------------|-------------|----------------------|
| `name` | Optional — defaults to dir name, max 64 chars | Optional — defaults to folder name | **Required** — max 64 chars |
| `description` | Recommended — max 1024 chars; used for auto-invocation | **Required** — what it does and when to apply it | **Required** — max 1024 chars |
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

**Antigravity**
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

| | Claude Code | Antigravity | Copilot |
|-|-------------|-------------|---------|
| User invoke | `/plugin:skill-name` | Mention the skill by name (no slash prefix) | `/skill-name` |
| AI auto-invoke | Yes — based on `description` match | Yes — the agent sees available skills and reads the full `SKILL.md` when one looks relevant | Yes — based on `description` match |
| Arguments | `$ARGUMENTS`, `$1`, `$2` | — (no documented arg substitution) | `${variableName}` |

### Example

**Claude Code / Antigravity (shared `SKILL.md`):**
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

| Field | Claude Code | Antigravity | GitHub Copilot |
|-------|-------------|-------------|----------------|
| `name` | **Required** — kebab-case | **Required** | Optional — defaults to filename, max 64 chars |
| `description` | **Required** — trigger phrases + examples | **Required** — read by the planner for delegation | **Required** — max 1024 chars |
| `tools` | Optional — comma-separated string: `Read, Grep` | Optional — YAML list, **enforced**, default `[]`: `- view_file` ⚠ different format & names | Optional — array or `["*"]` for all |
| `disallowedTools` | Optional — comma-separated denylist | — | — |
| `model` | Optional — `sonnet`, `opus`, `haiku`, `inherit` | Optional — tier only: `inherit`, `flash`, `pro` ⚠ not model IDs | Optional — model name string |
| `commandExecutionPolicy` | — | Optional — `off`, `auto`, `eager`, `sandbox` (default `sandbox`) | — |
| `subagent` | — | Optional bool (default `true`) — allows `invoke_subagent` | — |
| `mainAgent` | — | Optional bool (default `true`) — selectable as primary agent | — |
| `plugins` | — | Optional — list of plugin dependencies | — |
| ~~`kind`~~ | — | **Retired** — was `local`/`remote` on Gemini CLI | — |
| ~~`temperature`~~ | — | **Retired** — was float `0.0`–`2.0` on Gemini CLI | — |
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

| Scope | Claude Code | Antigravity | GitHub Copilot |
|-------|-------------|-------------|----------------|
| User (all projects) | `~/.claude/agents/` | `~/.gemini/config/agents/<name>/agent.md` ⚠️ see note | `~/.github/agents/` |
| Project | `.claude/agents/` | `.agents/agents/<name>.md` or `.agents/agents/<name>/agent.md` | `.github/agents/` |
| Plugin | `agents/` in plugin | `plugins/<name>/agents/` (**CLI only** — the IDE plugin spec has no `agents/` component) | `.github/agents/` |

> Antigravity's *project* paths moved to `.agents/` but its *global* config stayed under `~/.gemini/`. Old Gemini CLI project path was `.gemini/agents/` — agents left there are silently ignored.
>
> ⚠️ **Global agent path is unresolved in the docs.** `/docs/cli/subagents` gives `~/.gemini/config/agents/`, but CLI plugins and skills live under `~/.gemini/antigravity-cli/`. Either subagents are shared with the IDE or the docs are inconsistent — verify before relying on the global path. **The project path is the same for both products**, and that's where agentkit writes, so generated agents are unaffected either way.

### Execution Model

| | Claude Code | Antigravity | GitHub Copilot |
|-|-------------|-------------|----------------|
| Confirmation | Per-step (unless `bypassPermissions`) | Inline approval prompt per `commandExecutionPolicy` (default `sandbox`); approve `a` / deny `d` | Varies |
| Tool allowlist enforced | Yes | **Yes** — reversal from Gemini CLI, which parsed `tools` and ignored it | Yes |
| Can spawn subagents | No (agents cannot nest) | Invoked via `invoke_subagent` (`subagent: true`, default) | Supports `handoffs` |
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

**Antigravity:**
```yaml
---
name: code-reviewer
description: Specialized in reviewing code for quality, bugs, and security issues.
mainAgent: false
commandExecutionPolicy: sandbox
tools:
  - view_file
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

> ⚠ **`tools` field conflict**: Claude uses a comma-separated string with Claude tool names (`Read, Grep`). Antigravity uses a YAML list with its own names (`- view_file`). Copilot uses a JSON array. These are **not cross-platform compatible** — agents are platform-specific files. All three now *enforce* the list, so a copied-across `tools` value doesn't merely get ignored; it produces an agent that can't act, and on Antigravity an unmapped name can hang the subagent.

---

## Commands / Prompt Files

> **Antigravity has no command component.** Gemini CLI's `commands/*.toml` has no counterpart in the Antigravity plugin spec — skills auto-activate from their `description` instead. The Gemini CLI column below is retained as legacy reference for anyone migrating a TOML command; the migration path is to make it a skill. Repokit removed its `commands/` directory some time ago, so nothing here is live.

### Frontmatter Fields

| Field | Claude Code (`.md`) | Gemini CLI (`.toml`, legacy) | Copilot (`.prompt.md`) |
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

**Gemini CLI (`commands/my-cmd.toml`, legacy):**
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
| Gemini CLI (legacy) | `{{args}}` | All args; also `!{cmd}` for shell output, `@{file}` for file content |
| GitHub Copilot | `${selectedText}`, `${file}`, `${workspaceFolder}` | IDE context variables |

### Invocation

| | Claude Code | Gemini CLI (legacy) | Copilot |
|-|-------------|---------------------|---------|
| In-session invoke | `/plugin:command-name` | `/command-name` | `/command-name` |
| With args | `/plugin:cmd arg1 arg2` | `/cmd some text` | `/cmd` (uses IDE selection) |

---

## Always-On Context Files

These files are always loaded — not invoked by slash command.

| Platform | File | Scope | Notes |
|----------|------|-------|-------|
| Claude Code | `CLAUDE.md` | Project (nearest parent wins) | Project context, coding conventions |
| Antigravity | `GEMINI.md` or `AGENTS.md` | Workspace root — parsed on startup | Either works; don't ship both, or they drift |
| Antigravity | `.agents/rules/*.md` | Workspace — 12,000 chars per file | Four activation modes: Manual (@mention), Always On, Model Decision, Glob |
| Antigravity | `~/.gemini/GEMINI.md` | Global — all workspaces | Note: global config stayed under `~/.gemini/`, not `~/.agents/` |
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

| Feature | Claude ↔ Antigravity | Claude ↔ Copilot | Antigravity ↔ Copilot |
|---------|----------------------|------------------|-----------------------|
| Skill `SKILL.md` shared | ✓ `name` + `description` compatible | Partial — extra fields ignored | ✓ Minimal shared fields |
| Agent files shared | ✗ Different dirs, `tools` format conflicts | ✗ Different dirs + fields | ✗ Different dirs + fields |
| Command files shared | ✗ Antigravity has no command component | Partial — `.md` format similar | ✗ |
| `color` field | Claude only (Antigravity ignores) | Copilot ignores | — |
| `tools` field | ⚠ Incompatible format + names; **both enforce** | ⚠ Incompatible values | ⚠ Incompatible |
| `model` field | ⚠ Aliases vs tiers (`inherit`/`flash`/`pro`) | ⚠ Different value spaces | ⚠ Different value spaces |
| `maxTurns` / `max_turns` | ✗ Antigravity retired turn limits entirely | ✗ | ✗ |
| Permission model | ✗ `permissionMode` vs `commandExecutionPolicy` | ✗ | ✗ |
| Hook event names | ⚠ Antigravity event names undocumented — verify | ✗ | ✗ |

**Safe cross-platform fields (Skills):** `name`, `description`, `user-invocable`, `disable-model-invocation`

**Agent files are always platform-specific** — store them in platform-specific directories, not shared locations.

---

## Hook Event Name Reference

Hook event names differ significantly between platforms:

> ⚠️ **Unverified for Antigravity.** The column below documents **Gemini CLI** event names. Antigravity carries hooks over (configured via `hooks.json` at the plugin root), but its published plugin spec does not enumerate event names. Verify against Antigravity's docs before relying on any name here.

| Purpose | Claude Code | Gemini CLI (legacy) |
|---------|-------------|---------------------|
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

> Use `SessionEnd` (not `Stop`) when writing hooks for cross-platform plugins — it was valid on both Claude and Gemini CLI. Repokit currently ships no hooks, so nothing here is load-bearing yet.

---

## Antigravity: IDE vs CLI

Two products, two plugin systems, identical plugin contents.

| | IDE (v2.x) | CLI (`agy`, v1.x) |
|---|---|---|
| Manifest | `plugin.json` | `plugin.json` — `name` required (alphanumeric, hyphens, underscores); optional `description` |
| Components | `skills/`, `rules/`, `mcp_config.json`, `hooks.json` | same **plus `agents/`** (bundled subagent templates) |
| Global plugin dir | `~/.gemini/config/plugins/` | `~/.gemini/antigravity-cli/plugins/<name>/` |
| Workspace plugin dir | `.agents/plugins/` or `_agents/plugins/` | — |
| Install mechanism | folder placement (no command) | `agy plugin install /path/to/plugin` |
| Manage | delete the folder | `agy plugin list` / `enable` / `disable` / `uninstall` |
| Global skills | `~/.gemini/config/skills/` | `~/.gemini/antigravity-cli/skills/` |
| Workspace skills | `.agents/skills/<name>/` | `.agents/skills/` |
| Workspace subagents | `.agents/agents/` | `.agents/agents/` |
| Skill invocation | auto-activates from `description`; mention by name to force | compiled into **slash commands** |

**What this means in practice:** ship one plugin directory, install it twice. Repokit's `make antigravity` runs both the IDE symlink and `agy plugin install`, skipping whichever product isn't present.

**Two things the published docs don't settle** — flagged rather than guessed:

1. **Skill invocation.** The CLI page describes skills compiling into slash commands; the IDE page describes automatic activation from the description. A `description` written for auto-activation still works as a slash command, so repokit's skills are fine either way — but don't claim auto-activation for the CLI.
2. **Global subagent path.** See the ⚠️ note under [File Locations](#file-locations). Workspace paths agree, which is what matters for agentkit.

---

## Further Reading

- **Claude Code Skills**: https://code.claude.com/docs/en/skills
- **Claude Code Subagents**: https://code.claude.com/docs/en/sub-agents
- **Antigravity Plugins**: https://antigravity.google/docs/plugins
- **Antigravity Skills**: https://antigravity.google/docs/skills
- **Antigravity Subagents**: https://antigravity.google/docs/subagents
- **Antigravity Rules**: https://antigravity.google/docs/rules-workflows
- **Gemini CLI → Antigravity transition**: https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
- **Copilot Custom Instructions**: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- **Copilot Agent Skills**: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- **Copilot Custom Agents**: https://code.visualstudio.com/docs/copilot/customization/custom-agents
- **Copilot Prompt Files**: https://code.visualstudio.com/docs/copilot/customization/prompt-files
