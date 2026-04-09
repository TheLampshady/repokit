# Skills

Repokit ships five cross-platform skills. Each lives in `skills/<name>/SKILL.md` and is invoked via slash command on Claude, Gemini, or Copilot.

| Skill | Command | Summary | Details |
|-------|---------|---------|---------|
| **dockit** | `/dockit` | Generate, sync, and maintain project documentation. Auto-detects frameworks and scales by project size. | [skills/dockit/SKILL.md](../skills/dockit/SKILL.md) |
| **agentkit** | `/agentkit` | Generate project-level AI subagents tailored to your codebase's custom code patterns. Supports Claude, Gemini, and Copilot. | [skills/agentkit/SKILL.md](../skills/agentkit/SKILL.md) |
| **modernizer** | `/modernizer` | Audit the codebase for outdated tooling, missing quality infrastructure, and AI-readiness gaps. Writes tickets to `specs/`. | [skills/modernizer/SKILL.md](../skills/modernizer/SKILL.md) |
| **onboard** | `/onboard` | Create personalized onboarding plans for new team members based on role or feature focus. | [skills/onboard/SKILL.md](../skills/onboard/SKILL.md) |
| **repokit** | `/repokit` | Show the full tool menu and guide the user to the right tool. | [skills/repokit/SKILL.md](../skills/repokit/SKILL.md) |

---

## Recommended Flow

```
/dockit init  -->  /agentkit  -->  /modernizer analyze
   |                  |                  |
   v                  v                  v
 docs/           SME agents        specs/tickets/
```

1. **dockit** first — bootstrap project documentation
2. **agentkit** next — uses docs as context to build project-specific agents
3. **modernizer** — audit tooling and generate improvement tickets
4. **onboard** — anytime a new team member joins, create a ramp-up plan

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
