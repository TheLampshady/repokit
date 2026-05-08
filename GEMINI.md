# repokit Extension

**Keep your project's context in sync, then put it to work.** `dockit` keeps docs aligned with the code; `onboard`, `feedback-loop`, and `agentkit` consume that synced context.

> Sibling extension: [tikkit](https://github.com/TheLampshady/tikkit) adds ticket creation (`/tik`, `/figtik`, `/stitchtik`, `/modernizer`). Both write to the same shared backlog if installed together.

## Shared Backlog

Tickets go to:
- `.backlog/backlog.md` — master checklist, one line per item, tagged by source
- `.backlog/tickets/<slug>.md` — full ticket with details

Repokit tags: `[feedback-loop]`. Tikkit (if installed): `[tik]`, `[figtik]`, `[stitchtik]`, `[modernizer]`.

Check `.backlog/backlog.md` before creating a ticket — avoid duplicates.
