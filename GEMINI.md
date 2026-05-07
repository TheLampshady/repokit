# repokit Extension

**Keep your project's context in sync, then put it to work.** `dockit` scans this codebase and keeps documentation aligned with the code. That synced context powers three consumers: `onboard` for new developers, `feedback-loop` for validating completed work, and `agentkit` for generating project-specific AI agents.

> Ticket creation (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`) lives in the sibling [tikkit](https://github.com/TheLampshady/tikkit) extension. Install both for the full toolkit.

---

## Available Skills

Invoke with `/skill-name`. Gemini auto-detects them based on your request.

| Skill | Invoke | Use when... |
|-------|--------|-------------|
| **agentkit** | `/agentkit` | Asked to create project agents, generate AI helpers, set up subagents, or help AI understand custom code |
| **dockit** | `/dockit` | Asked to generate docs, update README, sync docs with code, check doc freshness, or explain doc structure |
| **onboard** | `/onboard` | A new team member needs to get started, or someone asks how to contribute |
| **repokit** | `/repokit` | Maintenance hub — check repo health (`status`), sync after changes (`sync`), or bootstrap a new project (`init`). Also shows the full tool menu. |

---

## Ticket System

When tools find work, they write to a shared backlog:

- `specs/backlog.md` — master checklist, items tagged by source
- `specs/tickets/` — individual ticket files with full context

Tags from repokit: `[feedback-loop]`. If tikkit is installed, it adds `[tik]`, `[figtik]`, `[stitchtik]`, `[modernizer]` to the same file.

Check `specs/backlog.md` before creating any ticket to avoid duplicates.

---

## Agents (if subagents are enabled)

| Agent | Triggers when... |
|-------|-----------------|
| **feedback-loop** | A feature is finished or a major plan section is complete — verify it's correctly implemented |

To enable subagents, see setup instructions in the [repokit README](https://github.com/TheLampshady/repokit).

---

## Policies Active

This extension enforces:
- Confirmation before `rm -rf` or deleting `specs/` / `agents/` directories
- Confirmation before `git push`
- Block on writing to `.env` files
- Confirmation before overwriting `CLAUDE.md` or `GEMINI.md`
