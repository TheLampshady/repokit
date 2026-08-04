# Foundation Maintenance Guide

How a foundation-owner agent keeps its foundation's documentation in sync with the code. This guide is embedded into generated agent bodies — it's both a reference for agentkit and the actual playbook the agent follows when invoked.

---

## What a Foundation-Owner Agent Owns

When agentkit assigns a foundation to an agent, the agent becomes the canonical custodian for:

1. **The catalog row** in `docs/FOUNDATIONS.md` — name, type, path, owner, status, health, consumers
2. **The per-foundation entry** within `FOUNDATIONS.md` (purpose, public API, invariants, dependencies, test coverage, refactor triggers, change checklist)
3. **The sub-doc** at `docs/architecture/foundations/<slug>.md` (large projects only)
4. **Cross-doc references** in `PRINCIPLES.md` and `ARCHITECTURE.md` that mention this foundation

The agent does **not** own:
- The foundation's source code itself (that's still the team's)
- The detection methodology (that's dockit's; agents read the output, not re-run scoring)
- Deciding what gets worked on next — the agent surfaces findings; prioritising them is the team's call

---

## When the Agent Should Update the Docs

The agent updates its foundation's docs when invoked for any of these reasons:

| Trigger | Action |
|---------|--------|
| Public API of the foundation changed (new export, removed export, signature change) | Re-copy the **Canonical usage** call site from the best-conforming consumer |
| New invariant being introduced via the code change | Add to **Invariants** at `tier="convention"`, naming the anti-pattern it displaces and the repair; flag the implication for downstream agents. **Never enter one at `tier="rule"`** — promotion is a human call collected by `/repokit status` |
| Sanctioned way to add a new instance changed | Update **Extend by** |
| Foundation grows to cover a case it previously didn't | Update **Doesn't cover** |
| The code an invariant governs is deleted | **Remove the invariant** — it governs nothing, and a rule about deleted code is a tombstone. Name the removal in the report |
| New code deviates from an existing invariant | **Leave the invariant exactly as written.** A directive being bypassed is an argument for keeping it, not cutting it. Nothing re-measures conformance, so there's no decay to report |
| Status change (active → deprecated, active → sunset) | Update catalog row + run cross-doc check |
| Path moved or renamed | Update **Path**, all refs in PRINCIPLES.md / ARCHITECTURE.md, sub-doc filename |
| New consumer added (a feature folder starts importing) | Update **Consumers** table |
| Refactor trigger fired (e.g., consumer count crossed threshold, tests broke an invariant) | Update **Refactor triggers** and name the trigger in the report |
| **You're working on the foundation anyway** | Validate the invariants while you're in the code. This is the only review trigger that isn't a specific change — the review that happens during real work is the one worth having, and it needs no schedule |

If the agent is invoked for general work (not a doc-maintenance request) and notices doc drift, it should **flag** rather than silently update — only act on doc maintenance when explicitly asked or when the user accepts a recommendation.

---

## Invariant Change Protocol

Invariants are the load-bearing claims about a foundation — the contract downstream code trusts, and the rules the foundation's owning agent carries in hot memory and defends on every change. **Do not modify invariants silently.**

When the code change implies an invariant must be added, removed, or altered:

1. **State the change to the user** in plain language. Example: *"This refactor weakens the invariant 'cache reads are always non-blocking' to 'cache reads are non-blocking unless the warm-up flag is set.' That's a contract change. Confirm before I update FOUNDATIONS.md?"*
2. **Wait for confirmation.** Don't apply the change until the user says yes.
3. **After update, run the cross-doc check** (below). Other docs may rely on the old invariant.
4. **Flag the change for review.** Add a note in the chat output: *"Invariant changed in `<foundation>` — code and tests that rely on the old contract may need review."*

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

## Never stamp a date into FOUNDATIONS.md

There is no `Last reviewed` field, and don't reintroduce one. A stamped date is a tombstone: it records a moment instead of current state, it goes stale by doing nothing, and it invites the rubber-stamp — bumped because a row was touched, not because anyone read the code. That turns a claim about verification into a claim about editing.

When someone genuinely needs "how long since this was looked at", **derive it**:

```bash
git log -1 --format=%cr -- app/core/auth.py       # code
git log -1 --format=%cr -- docs/FOUNDATIONS.md    # registry
```

Git already holds it and can't disagree with itself. The `Owner` column stays — attribution is the part with evidence behind it, and it doesn't decay.

**Say what you verified, in the report, not in the file.** "Read `core.auth` and confirmed all three invariants hold" belongs in the chat where the user can act on it. Written into the doc it becomes an unfalsifiable claim the next agent inherits.

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
7. Report to user: what changed, what was flagged, what you verified, what needs their decision
```

---

## What This Agent Does NOT Do

- **Does not run foundation detection** — that's dockit's `sync` mode. Re-scoring fan-in / cross-feature / stability is dockit's job. The agent only updates the rows that already exist.
- **Does not create new foundations** — if the agent suspects a new file deserves foundation status, it recommends running `/dockit sync` and explains the suspicion. It doesn't add rows on its own.
- **Does not delete foundations** — only flags candidates (e.g., `health: pretender`) for the user. Removal is a deliberate human decision.
- **Does not write task files** — findings go in the report; what gets tracked and where is the team's call.
- **Does not modify other foundations** — strict scope; only touches the foundations it owns. Other foundations' agents handle their own.
