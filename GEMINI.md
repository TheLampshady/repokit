# repokit

**Keep your project's context in sync, then put it to work.** `dockit` keeps docs aligned with the code; `agentkit` consumes that synced context to build project-level agents.

> Sibling extension: [tikkit](https://github.com/TheLampshady/tikkit) adds ticket creation (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`). Both write to the same shared backlog if installed together.

## Shared Backlog

Repokit **reads** the backlog, it never writes to it — `/repokit status` surfaces open items in its health dashboard so drift and open work show up in one place.

- `.backlog/backlog.md` — master checklist, one line per item, tagged by source
- `.backlog/tickets/<slug>.md` — full ticket with details

Ticket creation comes from [tikkit](https://github.com/TheLampshady/tikkit) (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`). Install it if you want findings captured as work items. If `.backlog/` doesn't exist, repokit simply omits the row.
