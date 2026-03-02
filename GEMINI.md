# repokit Extension

You have access to the **repokit** codebase maintenance toolkit. Use these tools to help maintain, document, and improve this project.

---

## Available Skills

Invoke with `/skill-name`. Gemini auto-detects them based on your request.

| Skill | Invoke | Use when... |
|-------|--------|-------------|
| **dockit** | `/dockit` | Asked to generate docs, update README, sync docs with code, check doc freshness, or explain doc structure |
| **modernizer** | `/modernizer` | Asked to audit the codebase, modernize tooling, find missing tests/hooks/CI, or check if dependencies are outdated |
| **onboard** | `/onboard` | A new team member needs to get started, or someone asks how to contribute |

---

## Ticket System

When tools find work to be done, they write to a shared backlog:

- `spec/backlog.md` — master checklist, items tagged by source (`[modernizer]`, `[auditor]`, `[dockit]`)
- `spec/tickets/` — individual ticket files with full context

Check `spec/backlog.md` before creating any ticket to avoid duplicates.

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
- Confirmation before `rm -rf` or deleting `spec/` / `agents/` directories
- Confirmation before `git push`
- Block on writing to `.env` files
- Confirmation before overwriting `CLAUDE.md` or `GEMINI.md`
