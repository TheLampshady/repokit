# Skills

Repokit ships four cross-platform skills. Each lives in `skills/<name>/SKILL.md` and is invoked via slash command on Claude, Gemini, or Copilot.

| Skill | Command | Role | Summary | Details |
|-------|---------|------|---------|---------|
| **dockit** | `/dockit` | Foundation | Scan the codebase and generate/sync living documentation — including a `FOUNDATIONS.md` catalog of shared/foundational code (detected by fan-in × cross-feature × stability scoring). Auto-detects frameworks and scales by project size. | [skills/dockit/SKILL.md](../skills/dockit/SKILL.md) |
| **onboard** | `/onboard` | Consumer | Personalized onboarding plans for new team members, grounded in real docs. | [skills/onboard/SKILL.md](../skills/onboard/SKILL.md) |
| **agentkit** | `/agentkit` | Consumer | Generate project-level AI subagents tailored to your codebase's custom code, conventions, and foundations. Uses `FOUNDATIONS.md` (when present) and other dockit docs as context. | [skills/agentkit/SKILL.md](../skills/agentkit/SKILL.md) |
| **repokit** | `/repokit` | Hub | Status dashboard, post-change sync, project bootstrap. Orchestrates the loop. | [skills/repokit/SKILL.md](../skills/repokit/SKILL.md) |

The `feedback-loop` agent (in `agents/`) is the third consumer of synced docs — auto-triggered at completion checkpoints.

For ticket creation (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`), install the [tikkit](https://github.com/TheLampshady/tikkit) sibling plugin.

---

## Recommended Flow

The architecture is **one foundation feeding three consumers**:

```
                   ┌─────────────────────┐
                   │   dockit (foundation)│
                   │   scans & syncs docs │
                   └──────────┬──────────┘
                              │
                       docs/ (context)
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
       /onboard         /agentkit        feedback-loop
       (humans)         (AI agents)      (validation)
```

1. **dockit first** — `/dockit init` bootstraps the context layer; `/dockit sync` keeps it current
2. **agentkit** — uses synced docs to generate project-specific AI agents
3. **onboard** — anytime a new team member joins, plans use the real docs
4. **feedback-loop** — auto-triggers at feature/plan completion to validate the work

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
