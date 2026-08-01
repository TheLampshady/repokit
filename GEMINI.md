# repokit

**Keep your project's context in sync, then put it to work.** `dockit` keeps docs aligned with the code; `agentkit` consumes that synced context to build project-level agents.

Skills auto-activate from their descriptions — mention `dockit`, `agentkit`, or `repokit` by name to force one.

> This file is read as workspace context by **Antigravity** (`GEMINI.md` or `AGENTS.md` at the workspace root) and by Gemini CLI (via `contextFileName`). Antigravity replaced Gemini CLI on 2026-06-18.

> Sibling plugin: [tikkit](https://github.com/TheLampshady/tikkit) adds ticket creation (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`).

## Generated Subagents

`/agentkit` writes Antigravity subagents to **`.agents/agents/<name>.md`** — not the retired `.gemini/agents/`. Run `/agents` to confirm they're discovered. Generated agents carry an enforced `tools` allowlist, `mainAgent: false`, and `commandExecutionPolicy: sandbox`.

## Shared Backlog

Repokit **reads** the backlog, it never writes to it — `/repokit status` surfaces open items in its health dashboard so drift and open work show up in one place.

- `.backlog/backlog.md` — master checklist, one line per item, tagged by source
- `.backlog/tickets/<slug>.md` — full ticket with details

Ticket creation comes from [tikkit](https://github.com/TheLampshady/tikkit) (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`). Install it if you want findings captured as work items. If `.backlog/` doesn't exist, repokit simply omits the row.
