# Foundation Maintenance Guide

How a foundation-owner agent keeps its foundation's documentation in sync with the code. This guide is embedded into generated agent bodies — it's both a reference for agentkit and the actual playbook the agent follows when invoked.

---

## What a Foundation-Owner Agent Owns

When agentkit assigns a foundation to an agent, the agent becomes the canonical custodian for:

1. **The catalog row** in `docs/FOUNDATIONS.md` — name, type, path, owner, status, health, consumers, last reviewed
2. **The per-foundation entry** within `FOUNDATIONS.md` (purpose, public API, invariants, dependencies, test coverage, refactor triggers, change checklist)
3. **The sub-doc** at `docs/architecture/foundations/<slug>.md` (large projects only)
4. **Cross-doc references** in `PRINCIPLES.md` and `ARCHITECTURE.md` that mention this foundation

The agent does **not** own:
- The foundation's source code itself (that's still the team's)
- The detection methodology (that's dockit's; agents read the output, not re-run scoring)
- Tickets created for stale review (that's `tikkit:foundationtik`'s)

---

## When the Agent Should Update the Docs

The agent updates its foundation's docs when invoked for any of these reasons:

| Trigger | Action |
|---------|--------|
| Public API of the foundation changed (new export, removed export, signature change) | Update **Public API** section + bump **Last reviewed** |
| New invariant being introduced via the code change | Add to **Invariants** list; flag the implication for downstream agents |
| Status change (active → deprecated, active → sunset) | Update catalog row + run cross-doc check |
| Path moved or renamed | Update **Path**, all refs in PRINCIPLES.md / ARCHITECTURE.md, sub-doc filename |
| New consumer added (a feature folder starts importing) | Update **Consumers** table |
| Refactor trigger fired (e.g., consumer count crossed threshold, tests broke an invariant) | Update **Refactor triggers** with a dated note; consider opening a foundationtik ticket |
| 90+ days since `Last reviewed` | Read the code, validate each invariant still holds, update the date |

If the agent is invoked for general work (not a doc-maintenance request) and notices doc drift, it should **flag** rather than silently update — only act on doc maintenance when explicitly asked or when the user accepts a recommendation.

---

## Invariant Change Protocol

Invariants are the load-bearing claims about a foundation. They're how `feedback-loop` validates work and how downstream code can trust the foundation's contract. **Do not modify invariants silently.**

When the code change implies an invariant must be added, removed, or altered:

1. **State the change to the user** in plain language. Example: *"This refactor weakens the invariant 'cache reads are always non-blocking' to 'cache reads are non-blocking unless the warm-up flag is set.' That's a contract change. Confirm before I update FOUNDATIONS.md?"*
2. **Wait for confirmation.** Don't apply the change until the user says yes.
3. **After update, run the cross-doc check** (below). Other docs may rely on the old invariant.
4. **Flag the change to feedback-loop.** Add a note in the chat output: *"Invariant changed in `<foundation>` — feedback-loop assertions touching this foundation may need review."*

---

## Cross-Doc Consistency Check

Whenever the agent updates a foundation's status, path, or invariants, other docs may have stale references. Run this check before declaring done.

### What to scan

| Doc | Why |
|-----|-----|
| `PRINCIPLES.md` | "Always use `<foundation>`" rules become invalid when status flips |
| `ARCHITECTURE.md` | Component tables, diagram nodes, design-decision rows |
| `docs/architecture/foundations/*.md` | Per-foundation sub-docs may need deletion or TODO flag |
| Any other file under `docs/` mentioning the foundation's path or module name | Catches stragglers |

### Recipes

For each affected foundation, run two greps:

```bash
# Module-style references (e.g. "core.notifications")
grep -rn "<module-name>" docs/ README.md

# Path-style references (e.g. "app/core/notifications")
grep -rn "<path-without-extension>" docs/ README.md
```

Module name catches imports and prose. Path catches code blocks and component tables. Both are needed.

### How to act on hits

| Doc location | Default action |
|--------------|----------------|
| `PRINCIPLES.md` (rule citing the foundation) | Ask the user — reword, remove, or leave with `[TODO: review]` |
| `ARCHITECTURE.md` table row | Auto-update if code-derived; ask for prose or diagram nodes |
| `docs/architecture/foundations/<slug>.md` | Update in place; if foundation removed, delete file; if demoted, flag with `[TODO: foundation demoted; review]` |
| Other docs | List hits, ask user per-hit |

This is the same prompt-shape dockit's sync uses for prose-heavy section deletions. Keep the UX consistent.

---

## What "Last Reviewed" Means

The `Last reviewed` date is not just a timestamp — it's a claim that the agent (or a human) has read the code and confirmed every invariant still holds. Bump it only when that's true.

Routine touch-ups (consumer count, public API symbol added) do **not** require a full review. Reset the date only when:

- An invariant was checked against the code
- A status change was applied
- A 90-day cadence review was completed

If you're updating a row but haven't re-verified invariants, leave the date alone.

---

## Maintenance Workflow Summary

```
1. Receive request → identify which owned foundation(s) it touches
2. Read FOUNDATIONS.md (catalog + per-foundation entry)
3. Read the foundation's source files
4. For each change:
   a. Determine which doc field(s) need updating
   b. If invariant change → invariant change protocol (ask first)
   c. Apply the update
5. Run cross-doc consistency check
6. Resolve every hit (update / ask / flag)
7. Update Last reviewed if a real review happened
8. Report to user: what changed, what was flagged, what needs their decision
```

---

## What This Agent Does NOT Do

- **Does not run foundation detection** — that's dockit's `sync` mode. Re-scoring fan-in / cross-feature / stability is dockit's job. The agent only updates the rows that already exist.
- **Does not create new foundations** — if the agent suspects a new file deserves foundation status, it recommends running `/dockit sync` and explains the suspicion. It doesn't add rows on its own.
- **Does not delete foundations** — only flags candidates (e.g., `health: pretender`) for the user. Removal is a deliberate human decision.
- **Does not write tickets** — `tikkit:foundationtik` owns ticket creation. The agent surfaces the trigger, tikkit writes the ticket.
- **Does not modify other foundations** — strict scope; only touches the foundations it owns. Other foundations' agents handle their own.
