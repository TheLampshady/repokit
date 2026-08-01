# Skills

Repokit ships three cross-platform skills. Each lives in `skills/<name>/SKILL.md`. Claude and Copilot invoke them as slash commands; Antigravity's IDE auto-activates them from the `description` and its CLI compiles them into slash commands.

| Skill | Command | Role | Summary | Details |
|-------|---------|------|---------|---------|
| **dockit** | `/dockit` | Foundation | Scan the codebase and generate/sync living documentation — including a `FOUNDATIONS.md` catalog of shared/foundational code (detected by fan-in × cross-feature × stability scoring). Auto-detects frameworks and scales by project size. | [skills/dockit/SKILL.md](../skills/dockit/SKILL.md) |
| **agentkit** | `/agentkit` | Consumer | Generate project-level AI subagents tailored to your codebase's custom code, conventions, and foundations. Uses `FOUNDATIONS.md` (when present) and other dockit docs as context. | [skills/agentkit/SKILL.md](../skills/agentkit/SKILL.md) |
| **repokit** | `/repokit` | Hub | Status dashboard, post-change sync, project bootstrap. Orchestrates the loop. | [skills/repokit/SKILL.md](../skills/repokit/SKILL.md) |

The plugin ships no agents of its own — agents are what `agentkit` *produces*, generated into the consuming project rather than distributed from here.

For ticket creation (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`), install the [tikkit](https://github.com/TheLampshady/tikkit) sibling plugin.

---

## Recommended Flow

The architecture is **one foundation feeding one consumer**, with the hub keeping both current:

```
        ┌──────────────────────┐
        │  dockit (foundation) │
        │  scans & syncs docs  │
        └──────────┬───────────┘
                   │
            docs/ (context)
            FOUNDATIONS.md
                   │
                   ▼
             /agentkit
          (project agents)
                   │
                   ▼
     .claude/ .gemini/ .github/ agents
                   ▲
                   │
              /repokit
        (status · sync · init)
```

1. **dockit first** — `/dockit init` bootstraps the context layer; `/dockit sync` keeps it current
2. **agentkit** — reads `FOUNDATIONS.md` and custom code to generate project-specific agents
3. **repokit** — `/repokit status` reports doc drift, agent drift, and whether your context file points at `FOUNDATIONS.md`; `/repokit sync` reconciles docs and agents

For tooling audits and modernization tickets, install [tikkit](https://github.com/TheLampshady/tikkit) and run `/modernizer analyze`.

---

## Skill File Structure

Each skill follows the same layout:

```
skills/<name>/
├── SKILL.md              # Entry point (YAML frontmatter + instructions)
└── references/           # Supporting material (optional)
    ├── guides/           # Detailed how-to guides
    ├── templates/        # Output templates
    └── samples/          # Example outputs
```

All three platforms auto-discover skills from `skills/` at the plugin root — Claude, Copilot, and Antigravity alike. No symlink or per-platform copy is needed.

> Do **not** add a `.agents/skills` symlink to this repo. Claude's remote plugin fetch doesn't resolve symlinks, so the real files must stay in `skills/`. (`.agents/skills/` is a *consumer workspace* path in Antigravity — unrelated to how this plugin ships.)
