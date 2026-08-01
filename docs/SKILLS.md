# Skills

Repokit ships three cross-platform skills. Each lives in `skills/<name>/SKILL.md` and is invoked via slash command on Claude, Gemini, or Copilot.

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
3. **repokit** — `/repokit status` reports doc and agent drift; `/repokit sync` reconciles both

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

Skills are auto-discovered from `skills/` by Claude and Copilot. Gemini discovers them via the `.agents/skills/` symlink.
