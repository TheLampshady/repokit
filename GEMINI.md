# repokit Extension

You have access to the **repokit** codebase maintenance toolkit. Use these tools to help maintain, document, and improve this project.

---

## Available Skills

Invoke with `/skill-name`. Gemini auto-detects them based on your request.

| Skill | Invoke | Use when... |
|-------|--------|-------------|
| **agentkit** | `/agentkit` | Asked to create project agents, generate AI helpers, set up subagents, or help AI understand custom code |
| **dockit** | `/dockit` | Asked to generate docs, update README, sync docs with code, check doc freshness, or explain doc structure |
| **modernizer** | `/modernizer` | Asked to audit the codebase, modernize tooling, find missing tests/hooks/CI, or check if dependencies are outdated |
| **onboard** | `/onboard` | A new team member needs to get started, or someone asks how to contribute |
| **repokit** | `/repokit` | Maintenance hub — check repo health (`status`), sync after changes (`sync`), deep audit (`audit`), or bootstrap a new project (`init`). Also shows the full tool menu. |
| **tik** | `/tik` | Asked to create a ticket, write a task, draft a feature request, or turn a request into a ticket (no Figma/Stitch context) |
| **figtik** | `/figtik` | User mentions Figma (URL, file key, or the word "figma") AND wants a ticket or wants to update an existing ticket with Figma data |
| **stitchtik** | `/stitchtik` | User mentions Stitch, references a `stitch/` directory, or asks about UI mockups when Stitch exports exist |

---

## Ticket System

When tools find work to be done, they write to a shared backlog:

- `specs/backlog.md` — master checklist, items tagged by source (`[tik]`, `[figtik]`, `[stitchtik]`, `[modernizer]`, `[auditor]`, `[dockit]`)
- `specs/tickets/` — individual ticket files with full context

Check `specs/backlog.md` before creating any ticket to avoid duplicates.

---

## Agents (if subagents are enabled)

| Agent | Triggers when... |
|-------|-----------------|
| **sanity-checker** | Asked to verify code quality, before committing, after fixing a bug |
| **auditor** | Asked to review doc health, find stale content, or audit automation gaps |

To enable subagents, see setup instructions in the [repokit README](https://github.com/TheLampshady/repokit).

---

## Policies Active

This extension enforces:
- Confirmation before `rm -rf` or deleting `specs/` / `agents/` directories
- Confirmation before `git push`
- Block on writing to `.env` files
- Confirmation before overwriting `CLAUDE.md` or `GEMINI.md`
