# Building Extensions, Plugins, and Marketplaces

This guide covers how to build and distribute tools for **Claude Code** (plugins + marketplaces), **Antigravity** (plugins), and **Gemini CLI** (extensions, legacy). repokit itself is a working example you can reference throughout.

> **Gemini CLI is retired for most users.** It stopped serving Pro/Ultra/free tiers on **2026-06-18**; extensions are now Antigravity *plugins*. The Gemini CLI section below stays for Code Assist Standard/Enterprise license holders — for everyone else, read [Antigravity Plugins](#antigravity-plugins).

---

## Table of Contents

1. [Concepts: Skills, Agents, Commands, Hooks](#concepts)
2. [Claude Code Plugins](#claude-code-plugins)
3. [Claude Code Marketplaces](#claude-code-marketplaces)
4. [Gemini CLI Extensions (legacy)](#gemini-cli-extensions)
4b. [Antigravity Plugins](#antigravity-plugins)
5. [Cross-Platform Toolkit (Both Platforms)](#cross-platform-toolkit)
6. [Local Development Workflow](#local-development-workflow)
7. [Verifying Installation](#verifying-installation)
8. [Publishing and Distribution](#publishing-and-distribution)

---

## Concepts

Before building, understand what each component type does:

| Component | File type | Invocation | Best for |
|-----------|-----------|------------|----------|
| **Skill** | `skills/<name>/SKILL.md` | `/plugin:skill-name` | Complex multi-step workflows, cross-platform |
| **Agent** | `agents/<name>.md` | Auto-triggered by Claude based on description | Isolated specialist tasks with separate context |
| **Command** | `commands/<name>.toml` | `/command-name` | Simple prompt expansions, routing menus |
| **Hook** | `hooks/hooks.json` | Automatic on lifecycle events | Session start/stop, pre-commit integration |

**Skills vs Agents**: Skills are invoked explicitly by the user. Agents are invoked automatically by Claude when their description matches the situation. Use agents when you want hands-off specialization.

---

## Claude Code Plugins

**Official docs**: https://code.claude.com/docs/en/plugins

### Plugin Structure

A Claude Code plugin is a directory with a `.claude-plugin/plugin.json` manifest. Everything else lives at the plugin root — **not** inside `.claude-plugin/`.

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← manifest (only this file goes here)
├── skills/
│   └── hello/
│       └── SKILL.md
├── agents/
│   └── my-agent.md
├── commands/
│   └── my-cmd.toml
└── hooks/
    └── hooks.json
```

### `plugin.json`

```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  },
  "homepage": "https://github.com/you/my-plugin",
  "repository": "https://github.com/you/my-plugin",
  "license": "MIT"
}
```

The `name` becomes the skill namespace: `/my-plugin:hello`.

> **Note**: `plugin.json` contains only metadata. Do **not** add `components`, `skills`, `agents`, `commands`, or `hooks` keys — they are not valid and will cause installation to fail. Components are auto-discovered from their standard directories at the plugin root.

### Skills (`skills/<name>/SKILL.md`)

Skills are Markdown files with YAML frontmatter. The frontmatter `name` and `description` are required.

```markdown
---
name: review
description: Review code for bugs, security issues, and performance problems
---

Review the selected code or recent changes for:
- Bugs and edge cases
- Security vulnerabilities
- Performance issues

Be concise and actionable.
```

Optional frontmatter fields:
- `disable-model-invocation: true` — expands the skill text directly without invoking the model (useful for routing menus)
- `user-invocable: true` — marks the skill as directly user-invocable (cross-platform compatibility flag)

Use `$ARGUMENTS` to accept arguments: `/my-plugin:greet Alice`

```markdown
---
name: greet
description: Greet a named user
---

Greet "$ARGUMENTS" warmly and ask how you can help.
```

### Agents (`agents/<name>.md`)

Agents are auto-triggered by Claude when their description matches the situation. They run in an isolated context window.

```markdown
---
name: code-reviewer
description: Use this agent when you need a thorough code review before committing. Triggered automatically when the user asks to review code or check quality.
model: sonnet
---

You are an expert code reviewer. Review the provided code for:
- Logic errors and edge cases
- Security vulnerabilities
- Performance bottlenecks
- Code style consistency

Always provide specific line references and actionable suggestions.
```

> **Cross-platform note**: Claude Code supports a `color` field in agent frontmatter for UI display. Antigravity does not — omit `color` from agents you intend to ship cross-platform.

### Hooks (`hooks/hooks.json`)

Hooks run shell commands at lifecycle events:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session started. Run /my-plugin:status to see project health.'"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session ended. Remember to run tests before committing.'"
          }
        ]
      }
    ]
  }
}
```

Hook event names differ between platforms. Use `SessionEnd` instead of `Stop` — it works on both:

| Claude | Gemini | Purpose |
|--------|--------|---------|
| `SessionStart` | `SessionStart` | Session begins |
| `SessionEnd` | `SessionEnd` | Session ends (`Stop` is Claude-only and not cross-platform) |
| `PreToolUse` | `BeforeTool` | Before a tool call |
| `PostToolUse` | `AfterTool` | After a tool call |
| `PreCompact` | `PreCompress` | Before context compaction |
| — | `BeforeAgent` / `AfterAgent` | Agent lifecycle |
| — | `BeforeModel` / `AfterModel` | Model call lifecycle |

### Test Your Plugin Locally

```bash
# Load plugin for this session only
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two

# Then invoke your skill
/my-plugin:hello
```

### Install Locally (Permanent)

`claude plugin install` looks up a marketplace — it doesn't accept bare paths. First register the directory as a marketplace, then install from it:

```bash
# Install for your user account only
claude plugin marketplace add ./my-plugin --scope local
claude plugin install my-plugin@my-marketplace-name --scope local

# Install for all users on this project (shared via .claude/settings.json)
claude plugin marketplace add ./my-plugin --scope project
claude plugin install my-plugin@my-marketplace-name --scope project
```

The marketplace name comes from `"name"` in `.claude-plugin/marketplace.json`.

---

## Claude Code Marketplaces

**Official docs**: https://code.claude.com/docs/en/plugin-marketplaces

A marketplace is a catalog that groups multiple plugins for easy discovery and installation. It's just a `marketplace.json` file alongside one or more plugin directories.

### Marketplace Structure

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json     ← catalog listing all plugins
├── plugins/
│   ├── review-plugin/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/review/SKILL.md
│   └── docs-plugin/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/docs/SKILL.md
```

Or, if the repo **is** the plugin (like repokit), you can have one marketplace.json pointing to the root:

```
repokit/
├── .claude-plugin/
│   ├── plugin.json         ← plugin metadata
│   └── marketplace.json    ← single-plugin marketplace, source: "./"
├── skills/
└── agents/
```

### `marketplace.json`

```json
{
  "name": "my-tools",
  "owner": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "plugins": [
    {
      "name": "review-plugin",
      "source": "./plugins/review-plugin",
      "description": "Code review skill"
    },
    {
      "name": "docs-plugin",
      "source": "./plugins/docs-plugin",
      "description": "Documentation generator"
    }
  ]
}
```

For a single-plugin repo (where the root is the plugin), use `"./"` as the source:

```json
{
  "name": "my-marketplace",
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./",
      "description": "My plugin"
    }
  ]
}
```

> **Note**: The `source` field requires `"./"` for the current directory — `"."` is not valid and will fail schema validation.
```

For GitHub-hosted plugins, use the `github` source type:

```json
{
  "name": "my-org-tools",
  "plugins": [
    {
      "name": "my-plugin",
      "source": {
        "source": "github",
        "repo": "my-org/my-plugin",
        "ref": "v1.0.0",
        "sha": "abc123..."
      },
      "description": "My plugin from a separate repo"
    }
  ]
}
```

Other source types: `url` (any git URL), `npm`, `pip`.

### User Installation Flow

Once you push your marketplace to GitHub, users install with:

```bash
# Step 1: Add the marketplace (one-time)
/plugin marketplace add your-github-username/your-repo

# Step 2: Install a specific plugin from it
/plugin install my-plugin@my-tools

# Or the short form when the repo IS the plugin:
/plugin marketplace add your-github-username/repokit
/plugin install repokit@repokit-marketplace
```

### Validate Your Marketplace

```bash
# Check JSON structure
claude plugin validate .

# Or inside a Claude session:
/plugin validate .
```

### Private Marketplaces (Team Distribution)

Add to your team's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "review-tool@company-tools": true,
    "deploy-tool@company-tools": true
  }
}
```

For background auto-updates with private repos, set `GITHUB_TOKEN` (or `GITLAB_TOKEN`, `BITBUCKET_TOKEN`) in your shell environment.

### Submit to Official Marketplace

- Claude.ai: https://claude.ai/settings/plugins/submit
- Console: https://platform.claude.com/plugins/submit

---

## Gemini CLI Extensions

**Official docs**: https://geminicli.com/docs/extensions/writing-extensions/
**GitHub source**: https://github.com/google-gemini/gemini-cli/blob/main/docs/extensions/writing-extensions.md

### Extension Structure

```
my-extension/
├── gemini-extension.json    ← manifest (required)
├── GEMINI.md                ← context loaded into every session (optional)
├── commands/
│   └── my-cmd.toml          ← custom slash commands
└── skills/
    └── my-skill/
        └── SKILL.md
```

### `gemini-extension.json`

```json
{
  "name": "my-extension",
  "version": "1.0.0",
  "description": "What this extension does",
  "contextFileName": "GEMINI.md",
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["${extensionPath}/server.js"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

Variable substitution in the manifest:
- `${extensionPath}` — path to the installed extension directory
- `${workspacePath}` — current working directory
- `${/}` — platform path separator

### Context File: `GEMINI.md`

The `contextFileName` field points to a Markdown file Gemini loads when the extension activates and concatenates into every prompt during that session ([docs](https://geminicli.com/docs/cli/gemini-md/)). The cost is paid per turn, in every project where your extension is installed — so this file's contents should be the *minimum* an agent needs to behave correctly with your tools, not a feature pitch.

> **Important**: Write `GEMINI.md` as tool documentation, not as project-specific notes. The same file is loaded in every project where the extension is installed — avoid project-specific references.

#### What's worth the token cost

| Worth it | Skip it |
|----------|---------|
| Conventions the agent must follow but can't auto-discover (where to write tickets, naming rules, shared file locations) | Lists of available skills — every platform auto-discovers them from their descriptions |
| Cross-plugin contracts — a shared file two toolkits both write to, and which one owns what | Lists of distributed agents — they auto-trigger from their own descriptions |
| Architectural framing (one or two sentences) so the agent knows what your toolkit is for | Lists of active policies — `policies.toml` enforces them regardless of agent awareness |
| | Anything already in `README.md` for human users |
| | Self-evident facts derivable from project shape |

The pattern across real Gemini extensions is sparse. [`gemini-cli-extensions/looker-conversational-analytics`](https://github.com/gemini-cli-extensions/looker-conversational-analytics) is ~40 lines and references tools by name without listing them inline. Some extensions ship no `contextFileName` at all (e.g., [`upstash/context7`](https://github.com/upstash/context7/blob/master/gemini-extension.json)).

#### Size guidance

- Aim for **~12–50 lines / under 500 tokens** — every line is paid every turn.
- Multiple guides converge on "under 300 lines, ideally under 100." See [GitHub's analysis of 2,500+ AGENTS.md files](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/).
- Codex CLI silently truncates past 64 KiB.

#### Known issue

There's an open [bug (#15519)](https://github.com/google-gemini/gemini-cli/issues/15519) where an extension's `GEMINI.md` can be loaded twice due to a conflict between auto-discovery and the extension loader. Worth being aware of when budgeting tokens.

#### Example (lean)

```markdown
# My Toolkit

**Brief tagline.** One sentence on what the toolkit does.

> Sibling extension: [other-tool](url) — both write `config/shared.yml` if installed together.

## Shared Conventions

Write generated output under `build/my-toolkit/`. Never edit another toolkit's directory.

Check whether an entry already exists before appending — sibling tools share the file.
```

Skills, agents, and policies all auto-discover or auto-enforce — listing them in `GEMINI.md` is paid token cost without behavioral payoff.

### Custom Commands (`commands/*.toml`)

```toml
[command]
name = "review"
description = "Review code for quality issues"

[[command.prompts]]
type = "user"
content = "Please review the current file or selected code for bugs, security issues, and performance problems. Be concise and specific."
```

### Subagents (Experimental, legacy)

Gemini CLI gated subagents behind a flag in `.gemini/settings.json`:

```json
{
  "experimental": {
    "enableAgents": true
  }
}
```

Agent `.md` files went in `.gemini/agents/`, and ran in YOLO mode with no per-step confirmation.

> **Superseded.** On Antigravity, subagents are a standard feature — no flag — and live at `.agents/agents/`, with an enforced `tools` allowlist and `commandExecutionPolicy` instead of YOLO. See [Antigravity Plugins](#antigravity-plugins).

### Local Development

```bash
# Link your extension for live development (changes reflect immediately)
gemini extensions link .

# Verify it's linked
gemini extensions list

# When done, unlink
gemini extensions unlink my-extension
```

### Distribution

Share via a public git URL:

```bash
gemini extensions install https://github.com/your-username/my-extension
```

Browse community extensions at: https://geminicli.com/extensions/browse/

---

## Antigravity Plugins

Antigravity replaced Gemini CLI. Its plugin format is simpler than the Gemini extension manifest — no themes, no `excludeTools`, no `contextFileName`. A plugin is a directory with a manifest and whatever components you ship.

> **Antigravity is two products.** The **IDE** (v2.x) and the **CLI** (`agy`, v1.x) have separate plugin systems. The plugin *contents* are identical, so you build one directory — but each product installs it differently, and the CLI supports one extra component. Differences are called out below and tabulated in [platform-feature-comparison.md](platform-feature-comparison.md#antigravity-ide-vs-cli).

### Manifest (`plugin.json` at plugin root)

```json
{
  "name": "repokit"
}
```

That's the whole required schema. `name` is optional and defaults to the directory name — so the minimum viable Antigravity plugin is a `skills/` directory with a `plugin.json` next to it.

> **Two `plugin.json` files, on purpose.** Claude reads `.claude-plugin/plugin.json` (rich metadata: version, author, homepage, license). Antigravity reads `plugin.json` at the root. They're different files with different schemas — don't try to consolidate them, and don't copy Claude's fields into Antigravity's.

### Directory layout

```
plugins/<plugin-name>/
├── plugin.json          # manifest (required)
├── mcp_config.json      # optional — MCP servers
├── hooks.json           # optional — event-triggered scripts
├── skills/              # optional
│   └── <skill-name>/SKILL.md
├── rules/               # optional
│   └── <rule-name>.md
└── agents/              # optional — bundled subagents (CLI only)
```

### Install locations

**IDE** — no marketplace, no registry, no command. Installation is placing a folder:

| Scope | Path |
|-------|------|
| Workspace | `.agents/plugins/` or `_agents/plugins/` at workspace root |
| Global | `~/.gemini/config/plugins/` |

**CLI** — has real plugin management:

```bash
agy plugin install /path/to/local/plugin
agy plugin list
agy plugin disable <name>     # keep it staged, stop loading it
agy plugin enable  <name>
agy plugin uninstall <name>
```

Installed plugins land in `~/.gemini/antigravity-cli/plugins/<plugin_name>/`. The CLI also requires `name` in `plugin.json` to be alphanumeric plus hyphens/underscores.

To distribute for both: publish one repo, tell IDE users to clone it into a plugin dir and CLI users to `agy plugin install` the clone. Repokit's `make antigravity` does both locally, skipping whichever product isn't installed.

### Skills

Identical to what repokit already ships: `skills/<name>/SKILL.md` with YAML frontmatter. `description` is required; `name` is optional and defaults to the folder name. This is why repokit's skills work on Antigravity unchanged.

Invocation differs between the two products:

- **IDE** — the agent sees available skills and reads the full `SKILL.md` when one looks relevant. No slash command required, though you can mention a skill by name to force it.
- **CLI** — skills are compiled into slash commands.

A description written for auto-activation still works as a slash command, so you don't need two versions. But don't document auto-activation as universal.

### Rules (`rules/*.md`)

Markdown files that constrain agent behavior. **12,000 characters each.** Four activation modes:

| Mode | Behavior |
|------|----------|
| Manual | Activated by @mention in the input box |
| Always On | Applied to every request |
| Model Decision | The model decides from a natural-language description |
| Glob | Applied to files matching a pattern (e.g. `src/**/*.ts`) |

Workspace rules also live at `.agents/rules/` (with `.agent/rules` kept for backward compatibility); global rules at `~/.gemini/GEMINI.md`.

> **Rules are guidance, not enforcement.** Unlike Gemini CLI's `policies.toml` — a policy engine that could hard-`deny` a tool call — a markdown rule is instruction the model may or may not follow. When porting policies to rules, don't assume equivalent strength. Repokit keeps both: `policies/policies.toml` for Gemini CLI's engine, `rules/*.md` for Antigravity.

### Subagents

Standard feature, no flag. Workspace subagents live at `.agents/agents/` for **both** products, so generated agents need no per-product handling. Only the **CLI** additionally supports bundling `agents/` inside a plugin — the IDE plugin spec has no such component.

See the [platform comparison](platform-feature-comparison.md) for the full frontmatter schema. The three things that bite when migrating from Gemini CLI:

1. Path moved: `.agents/agents/<name>.md` (or `<name>/agent.md`), **not** `.gemini/agents/`
2. `tools` is now an **enforced** allowlist defaulting to `[]`, using Antigravity tool names (`view_file`, `grep_search`, `replace_file_content`, `run_command`)
3. `temperature`, `max_turns`, `timeout_mins`, and `kind` are gone; `model` takes tiers (`inherit`, `flash`, `pro`) not model IDs

### Context file

`GEMINI.md` or `AGENTS.md` at the workspace root, parsed on startup. Either works — pick one. Note that global config stayed under `~/.gemini/`, so `~/.gemini/GEMINI.md` is the global rules file even though workspace paths moved to `.agents/`.

---

## Cross-Platform Toolkit

To build a toolkit that works on **both** Claude Code and Gemini CLI:

### Shared Skills (`.agents/skills/`)

Both platforms recognize skills in `.agents/skills/`. This is the recommended location for cross-platform skills.

```
my-toolkit/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── gemini-extension.json
├── GEMINI.md
├── skills/                 ← canonical skill location (Claude auto-discovers here)
│   ├── my-skill/
│   │   └── SKILL.md
│   └── other-skill/
│       └── SKILL.md
├── agents/                 ← optional: distributed agents (Claude plugin; Antigravity CLI)
│   └── my-agent.md
├── rules/                  ← optional: Antigravity markdown rules
└── hooks/
    └── hooks.json
```

### Skills auto-discovery for cross-platform setups

**Keep skills in `skills/` at the plugin root and do nothing else.** Claude, Copilot, and Antigravity all discover them there.

> **Important**: Do not symlink `skills/` to anywhere — Claude's remote plugin fetch does not resolve symlinks, so the real files must live in `skills/`.
>
> Earlier versions of this guide recommended a `.agents/skills → ../skills` symlink for Gemini CLI cross-compatibility. That is obsolete: Antigravity reads plugin skills from `skills/`, and `.agents/skills/` is a *consumer workspace* location, not a plugin one. Repokit ships no such symlink.

### Platform Differences

| Feature | Claude Code | Antigravity | Gemini CLI (legacy) |
|---------|-------------|-------------|---------------------|
| Manifest | `.claude-plugin/plugin.json` | `plugin.json` (root) | `gemini-extension.json` |
| Skills | `skills/` | `skills/` in plugin; `.agents/skills/` in workspace | `.agents/skills/` |
| Agents | `.claude/agents/` or `agents/` (plugin) | `.agents/agents/` in workspace; `plugins/<name>/agents/` in plugin | `.gemini/agents/` (experimental) |
| Commands | `commands/*.md` | — (none; skills auto-activate) | `commands/*.toml` |
| Rules / policies | — | `rules/*.md` (12k chars each) | `policies/policies.toml` |
| MCP config | `.mcp.json` | `mcp_config.json` (root) | in `gemini-extension.json` |
| Hooks | `hooks/hooks.json` | `hooks.json` (root) | `hooks` in manifest |
| Context file | `CLAUDE.md` | `GEMINI.md` or `AGENTS.md` (workspace root) | `GEMINI.md` (set in manifest) |
| Agent `tools` format | Comma-separated string: `Read, Grep` | YAML list, **enforced**: `- view_file` | YAML list, parsed but NOT enforced |
| Agent `model` values | Aliases: `sonnet`, `opus`, `haiku`, `inherit` | Tiers: `inherit`, `flash`, `pro` | Model IDs: `gemini-2.5-pro` |
| Agent turn limit field | `maxTurns` (camelCase) | — (retired) | `max_turns` (snake_case) |
| Agent confirmation | Per-step | `commandExecutionPolicy` (default `sandbox`) | YOLO mode (no confirmation) |

### AGENTS.md: Emerging Cross-Tool Standard

[AGENTS.md](https://agents.md/) is a vendor-neutral context-file standard declared in 2025. It's recognized by **Codex CLI, Copilot CLI, Gemini CLI, Cursor, and Claude Code** — 20,000+ public repos use it. The recommended pattern:

- **`AGENTS.md`** at repo root — single source of truth for "context an agent needs in this project"
- **`CLAUDE.md`, `GEMINI.md`, `.cursorrules`** — thin pointers to `AGENTS.md`, or omitted entirely

This avoids the "three drifting copies" problem where each tool's context file falls out of sync with the others.

**Important distinction for extension/plugin authors:** the two roles serve different audiences. `AGENTS.md` at your repo root briefs *developers working on your extension*. Gemini's `contextFileName` (when it's distributed via `gemini-extension.json`) briefs *users who installed your extension* — concatenated into their sessions in their own projects. They can be the same file if the audiences align, but they often don't, and conflating them by default produces context bloat for whichever audience didn't need the other half.

See:
- [agents.md spec](https://agents.md/)
- [How to write a great AGENTS.md — GitHub blog](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [AI Coding Config Files Guide — DeployHQ](https://www.deployhq.com/blog/ai-coding-config-files-guide)

---

## Local Development Workflow

A clean development setup uses a Makefile to wrap the installation commands:

```makefile
.PHONY: setup link link-claude check

setup: hooks gemini claude  ## First-time dev setup

hooks:  ## Install pre-commit hooks
    @command -v uv >/dev/null 2>&1 \
        && uv tool install pre-commit --quiet \
        || pip install --quiet pre-commit
    pre-commit install

antigravity-ide:  ## Symlink into the Antigravity IDE global plugin dir
    @mkdir -p $(HOME)/.gemini/config/plugins
    @ln -sfn $(PWD) $(HOME)/.gemini/config/plugins/my-plugin

antigravity-cli:  ## Install into Antigravity CLI
    agy plugin install $(PWD)

gemini:  ## [legacy] Link as Gemini CLI extension (live reload)
    gemini extensions link $(PWD)

claude:  ## Install as Claude plugin (local scope)
    claude plugin marketplace add $(PWD) --scope local
    claude plugin install my-plugin@my-marketplace-name --scope local

un-claude:  ## Uninstall Claude plugin
    claude plugin uninstall my-plugin --scope local

check:  ## Validate JSON/TOML/YAML files
    pre-commit run --all-files
```

Then run:

```bash
make setup   # install hooks, link extension, install plugin
make check   # validate files before committing
```

---

## Verifying Installation

### Claude Code

**In-session commands** (run inside a Claude Code session):

| Command | What it shows |
|---------|--------------|
| `/agents` | Interactive list of all loaded agents — built-in, user, project, and plugin |
| `/help` | All available slash commands, including plugin-namespaced skills and commands |
| `/plugin` | Plugin manager — browse, install, enable/disable plugins |

**CLI commands** (run in your terminal):

```bash
# List all installed plugins
claude plugin list

# List all configured agents (grouped by source, shows overrides)
claude agents

# Check plugin cache — each installed plugin gets its own subdirectory
ls ~/.claude/plugins/cache/
```

**Agent files by scope:**

| Scope | Directory | Shared? |
|-------|-----------|---------|
| User agents | `~/.claude/agents/` | All your projects |
| Project agents | `.claude/agents/` | Team (check into git) |
| Plugin agents | `~/.claude/plugins/cache/<plugin>/agents/` | Via plugin install |

> **Note:** Agents are loaded at session start. After adding a file manually, either restart your session or use `/agents` to reload immediately.

**Skills** appear under `/help` with the plugin namespace prefix (e.g. `/repokit:dockit`). If a skill isn't showing up, check that the `skills/` directory exists at the plugin root and that each skill has `name` and `description` frontmatter.

**Commands** (`.md` files in `commands/`) also appear under `/help`. Antigravity has no command component — `commands/*.toml` was Gemini CLI only, and the migration path is to make it a skill. Repokit ships no `commands/` directory.

---

### Gemini CLI

**Terminal commands:**

```bash
# List all linked and installed extensions
gemini extensions list

# Check what Gemini loaded in a session — look for your extension name
gemini --debug
```

**Extension files by scope:**

| Scope | Location |
|-------|----------|
| Linked (dev) | Symlinked from your repo via `gemini extensions link` |
| Installed | `~/.gemini/extensions/<name>/` |
| Agents (experimental, legacy) | `.gemini/agents/` in your project |

**In-session:** Type `/` in Gemini CLI to see available commands including those from your extension.

---

### Quick Checklist

After running `make setup` (or the equivalent install steps), verify:

- [ ] **Claude agents**: `/agents` shows your agent(s) listed under the plugin name
- [ ] **Claude skills**: `/help` lists `/your-plugin:skill-name`
- [ ] **Claude commands**: `/help` lists `/your-plugin:command-name`
- [ ] **Antigravity plugin**: folder present under `.agents/plugins/` (or `~/.gemini/config/plugins/`)
- [ ] **Antigravity skills**: mention a skill by name and confirm the agent reads it
- [ ] **Antigravity agents**: `/agents` lists your generated agents
- [ ] **Gemini extension** (legacy): `gemini extensions list` shows your extension

---

## Publishing and Distribution

### GitHub (Recommended)

1. Push your repo to GitHub
2. Tag a release: `git tag v1.0.0 && git push --tags`
3. Share the install commands:

```bash
# Claude Code
/plugin marketplace add your-username/your-repo
/plugin install your-plugin@your-marketplace-name

# Gemini CLI
gemini extensions install https://github.com/your-username/your-repo
```

### Release Channels

For stable vs preview channels, create two separate marketplace entries pointing to different git refs:

```json
{
  "plugins": [
    {
      "name": "my-plugin-stable",
      "source": { "source": "github", "repo": "you/plugin", "ref": "stable" }
    },
    {
      "name": "my-plugin-preview",
      "source": { "source": "github", "repo": "you/plugin", "ref": "main" }
    }
  ]
}
```

The plugin `version` in `plugin.json` must differ between refs for Claude Code to detect updates.

### Quick Reference: repokit as Example

repokit uses this structure — use it as a reference implementation:

```
repokit/
├── .claude-plugin/
│   ├── plugin.json         # Claude plugin manifest (metadata only)
│   └── marketplace.json    # Single-plugin catalog, source: "./"
├── plugin.json             # Antigravity plugin manifest (root)
├── mcp_config.json         # Antigravity MCP config (root)
├── rules/                  # Antigravity rules (markdown, 12k chars each)
├── gemini-extension.json   # Gemini CLI manifest (legacy), contextFileName: "GEMINI.md"
├── GEMINI.md               # Tool docs loaded as workspace context
├── skills/                 # Cross-platform skills (Claude auto-discovers here)
│   ├── agentkit/SKILL.md
│   ├── dockit/SKILL.md
│   └── repokit/SKILL.md
├── .claude/agents/         # Internal dev agents — NOT distributed
├── policies/policies.toml  # Safety guardrails
└── Makefile                # Dev workflow (make setup, make check)
```

---

## Further Reading

- **Claude Code plugins**: https://code.claude.com/docs/en/plugins
- **Claude Code marketplaces**: https://code.claude.com/docs/en/plugin-marketplaces
- **Antigravity plugins**: https://antigravity.google/docs/plugins
- **Antigravity skills**: https://antigravity.google/docs/skills
- **Antigravity subagents**: https://antigravity.google/docs/subagents
- **Antigravity rules**: https://antigravity.google/docs/rules-workflows
- **Gemini CLI → Antigravity transition**: https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/
- **Gemini CLI extensions** (legacy): https://geminicli.com/docs/extensions/writing-extensions/
- **Official Claude plugins directory**: https://github.com/anthropics/claude-plugins-official
