# Building Extensions, Plugins, and Marketplaces

This guide covers how to build and distribute tools for **Claude Code** (plugins + marketplaces) and **Gemini CLI** (extensions). repokit itself is a working example you can reference throughout.

---

## Table of Contents

1. [Concepts: Skills, Agents, Commands, Hooks](#concepts)
2. [Claude Code Plugins](#claude-code-plugins)
3. [Claude Code Marketplaces](#claude-code-marketplaces)
4. [Gemini CLI Extensions](#gemini-cli-extensions)
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
- `user-invocable: true` — marks the skill as directly user-invocable (Gemini compatibility flag)

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

> **Cross-platform note**: Claude Code supports a `color` field in agent frontmatter for UI display. Gemini does not — omit `color` from agents you intend to ship cross-platform.

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

The `contextFileName` field points to a Markdown file loaded at the start of every Gemini CLI session where this extension is active. Use it to:
- Describe what tools are available
- Explain how to invoke skills and commands
- Set up any persistent instructions

> **Important**: Write `GEMINI.md` as tool documentation, not as project-specific notes. The same file is loaded in every project where the extension is installed — avoid project-specific references.

Example:

```markdown
# My Toolkit

You have access to the following tools from the my-extension extension:

## Available Skills
- `/review` — Review code for quality, security, and performance issues
- `/docs` — Generate or update documentation for the current file

## Usage
Invoke any skill using the slash command. Skills work with the current file context.
```

### Custom Commands (`commands/*.toml`)

```toml
[command]
name = "review"
description = "Review code for quality issues"

[[command.prompts]]
type = "user"
content = "Please review the current file or selected code for bugs, security issues, and performance problems. Be concise and specific."
```

### Agent Skills (Experimental)

Gemini CLI supports agent skills as an experimental feature. Enable in `.gemini/settings.json`:

```json
{
  "experimental": {
    "enableAgents": true
  }
}
```

Place agent `.md` files in `.gemini/agents/` within the extension.

> **Note**: Gemini agents run in YOLO mode — no per-step confirmation. They are suitable for well-defined, bounded tasks.

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
├── .agents/
│   └── skills/
│       ├── my-skill/
│       │   └── SKILL.md   ← loaded by both platforms
│       └── other-skill/
│           └── SKILL.md
├── agents/                 ← distributed agents (Claude via plugin, Gemini optional)
│   └── my-agent.md
├── commands/
│   └── menu.toml
└── hooks/
    └── hooks.json
```

### Skills auto-discovery for cross-platform setups

Claude auto-discovers skills from `skills/` at the plugin root. If your skills live in `.agents/skills/` for Gemini cross-compatibility, create a symlink so Claude can find them:

```bash
ln -s .agents/skills skills
```

This keeps one canonical skill location (`.agents/skills/`) shared by both platforms without duplicating files.

### Platform Differences

| Feature | Claude Code | Gemini CLI |
|---------|-------------|------------|
| Skills | `.agents/skills/` or `skills/` | `.agents/skills/` |
| Agents | `.claude/agents/` or `agents/` (plugin) | `.gemini/agents/` (experimental, manual setup) |
| Commands | `commands/*.toml` | `commands/*.toml` |
| Context file | `CLAUDE.md` (project context) | `GEMINI.md` (set in manifest) |
| Agent `color` field | Supported | Not a valid field — ignored, does not error |
| Agent `tools` format | Comma-separated string: `Read, Grep` | YAML list with different names: `- read_file` |
| Agent `model` values | Aliases: `sonnet`, `opus`, `haiku`, `inherit` | Model IDs: `gemini-2.5-pro` |
| Agent turn limit field | `maxTurns` (camelCase) | `max_turns` (snake_case) |
| Agent confirmation | Per-step | YOLO mode (no confirmation) |

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

gemini:  ## Link as Gemini extension (live reload)
    gemini extensions link $(PWD)

un-gemini:  ## Uninstall Gemini extension
    gemini extensions uninstall my-extension

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

**Skills** appear under `/help` with the plugin namespace prefix (e.g. `/repokit:dockit`). If a skill isn't showing up, check that the `skills/` directory (or symlink) exists at the plugin root.

**Commands** (`.md` files in `commands/`) also appear under `/help`. If a `.toml` command isn't showing — that's expected; `.toml` is Gemini-only.

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
| Agents (experimental) | `.gemini/agents/` in your project |

**In-session:** Type `/` in Gemini CLI to see available commands including those from your extension.

---

### Quick Checklist

After running `make setup` (or the equivalent install steps), verify:

- [ ] **Claude agents**: `/agents` shows your agent(s) listed under the plugin name
- [ ] **Claude skills**: `/help` lists `/your-plugin:skill-name`
- [ ] **Claude commands**: `/help` lists `/your-plugin:command-name`
- [ ] **Gemini extension**: `gemini extensions list` shows your extension
- [ ] **Gemini commands**: `/` in a Gemini session shows your command(s)

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
├── gemini-extension.json   # Gemini manifest, contextFileName: "GEMINI.md"
├── GEMINI.md               # Tool docs loaded by Gemini in any project
├── .agents/skills/         # Cross-platform skills (canonical location)
│   ├── dockit/SKILL.md
│   ├── modernizer/SKILL.md
│   └── onboard/SKILL.md
├── skills -> .agents/skills # Symlink — lets Claude auto-discover skills
├── agents/                 # Distributed agents (no color field)
│   ├── sanity-checker.md
│   └── auditor.md
├── commands/repokit.toml   # /repokit menu command
├── hooks/hooks.json        # SessionStart backlog count
├── policies/policies.toml  # Safety guardrails
└── Makefile                # Dev workflow (make setup, make check)
```

---

## Further Reading

- **Claude Code plugins**: https://code.claude.com/docs/en/plugins
- **Claude Code marketplaces**: https://code.claude.com/docs/en/plugin-marketplaces
- **Gemini CLI extensions**: https://geminicli.com/docs/extensions/writing-extensions/
- **Gemini CLI getting started**: https://codelabs.developers.google.com/getting-started-gemini-cli-extensions
- **Gemini extensions gallery**: https://geminicli.com/extensions/browse/
- **Official Claude plugins directory**: https://github.com/anthropics/claude-plugins-official
