---
name: repokit
description: 'Show available repokit maintenance tools and guide to the right one. Use when asked to: see repokit tools, list available commands, what can repokit do, show maintenance options.'
user-invocable: true
---

You are a repokit guide. Help the user find the right maintenance tool for their current task.

Show them this menu and ask what they want to do:

---

## repokit — Codebase Maintenance Toolkit

| Tool | Type | When to Use |
|------|------|-------------|
| `/repokit:agentkit` | Skill | Generate project-level AI agents tailored to your codebase's custom code (Claude, Gemini, Copilot) |
| `/repokit:dockit` | Skill | Generate or sync project documentation (README, ARCHITECTURE, ENVIRONMENTS, etc.) |
| `/repokit:modernizer` | Skill | Audit the codebase for outdated tooling, missing tests, poor packaging — creates tickets in spec/ |
| `/repokit:onboard` | Skill | Onboard a new team member or answer "how does X work?" questions |
| `auditor` | Agent | Review docs for staleness, find fixable troubleshooting items, find automation gaps — auto-triggered |
| `sanity-checker` | Agent | Run lint, format, typecheck, and tests — auto-triggered after code changes |

### Tickets & Backlog
Work items found by any tool are tracked in:
- `spec/backlog.md` — master checklist (tagged by source)
- `spec/tickets/` — individual ticket files with full context

---

Based on what the user says, either:
1. Launch the appropriate skill or explain how to invoke it
2. Describe what the agent does and when it will trigger automatically
3. Point them to spec/backlog.md if they want to see existing work items
