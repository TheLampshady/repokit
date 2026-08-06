# Reporting

The shape of what agentkit shows the user. Owns the Phase 4 plan format, the agent block that init and sync share, and the rule that reports state decisions instead of asking questions. Invoked from [`SKILL.md`](../../SKILL.md#phase-4-plan-and-user-review) § Phase 4; sync's own sections and readability rules live in [SYNC.md](./SYNC.md) § Sync Output Format and defer to this file for the agent block.

---

## The agent block

**Four fields per agent, identical for every agent, in this order.** Uniformity is the point — a report that carries whichever fact happened to be interesting for each agent reads as arbitrary, and the reader can't compare across it.

| Field | Carries |
|-------|---------|
| **Knows** | One line of what this agent understands that a generic assistant wouldn't. Concepts, not paths. |
| **Foundations** | The catalog names it owns, plus the coupling signals that grouped them when there's more than one. |
| **Triggers on** | Two or three realistic requests, phrased the way a developer would type them. These double as the routability evidence. |
| **Own agent because** | The [split trigger](./AGENT-SIZING.md) that fired. Always filled — for the first group, that it's the default group everything else split away from. |

**Never add a fifth field for one agent only.** A fact that applies to a single agent goes in **Own agent because** if it's a reason, and nowhere if it isn't.

The same four fields describe a proposed agent at init and a created agent under sync's **New** heading. An agent should read identically either way — a reader who learned the shape once shouldn't have to learn a second one.

## What a report may restate

**Report a foundation's *name* once, in the agent that owns it. Report a foundation *attribute* only when it's the reason for a decision.**

`health: hotspot`, `Owner:`, and `status: intended` all earn a mention when a boundary turned on them. Consumer counts, invariant counts, and catalog paths don't — they're in `FOUNDATIONS.md`, and restating them is the Overview band.

**No working-directories table.** Paths come straight from the catalog rows. What isn't derivable is where the plan *departed* from the catalog — a directory added beyond a foundation's registered path, or custom code absorbed by an agent that doesn't own it via a foundation — and that is what "Custom code folded in" is for.

## Plan format (foundation-led)

```markdown
## Agent plan

**[N] foundations → [N] agents.** Grouping starts from one agent owning everything and
splits only when a trigger fires, so read this as [N] triggers having fired — not a target.

**`auth`**
- **Knows** — how this project issues, validates, and revokes credentials, and how permission checks are expected to be written
- **Foundations** — `core.auth`, `core.permissions`, `core.sessions` *(grouped: joint invariants + shared consumers + same tree)*
- **Triggers on** — *"add a login endpoint"* · *"why is this permission check failing?"* · *"add a role to the admin group"*
- **Own agent because** — size budget. Change-coupled to `data-layer` and belonged in one agent with it; merged came to 11,900 chars against a 10,000 limit, so split on the weakest coupling boundary.

**`notifications`**
- **Knows** — the delivery pipeline's retry and deduplication rules, and which channels are wired
- **Foundations** — `core.notifications`
- **Triggers on** — *"send an email when an order ships"* · *"why did this push fire twice?"*
- **Own agent because** — `health: hotspot` while everything it would group with is `healthy`; its churn would force re-syncing an agent that mostly didn't need it

### Routability check

[N] agents, [N] pairs, all distinguishable. The sample requests above are the check.

Closest pair was `notifications` / `auth`: *"email the user a password reset link"* matched
both. Held by naming the boundary in both descriptions:

- `notifications` — *"...email, push, and in-app delivery mechanics. NOT auth flows or token content."*
- `auth` — *"...login, tokens, permission checks. Owns what a reset link contains; not how it's delivered."*

### Per-agent budgets

| Agent | Body | Patterns | Dirs | Foundations | |
|---|---|---|---|---|---|
| `auth` | 6,800 | 9 | 3 | 3 | ok |
| `notifications` | 3,900 | 5 | 1 | 1 | ok |
| *budget* | *10,000* | *12* | *6* | *5* | |

### Custom code folded in

- `custom-jwt-middleware` (4 files, `middleware/auth/`) → **`auth`** — imports `core.auth` as its base

### Assumptions you may want to correct

- **`core.search` is `status: intended`** — zero consumers, which is what that status means.
  Scoped to `search/` plus the two directories the scaffold generates into, both empty today.
  If adoption is meant to land elsewhere, that scope is wrong.
- **`auth` reads `login/session_start.py` → `class SessionStartView` as its exemplar** — newest
  consumer, added 2026-04. New code in that territory gets told to match its shape, so if it
  isn't what you'd point a new hire at, name the one that is.
- **No exemplar for `core.notifications`** — every consumer sits in a `hotspot` tree, and a
  shape the team is still arguing about is the wrong thing for new code to copy. The agent
  works from its invariants alone here.

### Uncovered, and staying that way

| Directory | Why |
|---|---|
| `dtos/` | Thin mapping structs — correct from framework knowledge alone. Fails the Core Test. |

Not re-raised on future syncs.

### Next

Writing [N] agent files to `[path]`, then appending a routing section to `[context file]`.
Nothing is on disk yet.

To reshape first: name a pair to group (`auth` + `data-layer` fit one agent if you'd rather
trade 1,900 chars of depth for a simpler set), a boundary to redraw, or a foundation to move.
```

**Domain-expert agents** (no foundation ownership) use the same four fields; **Foundations** reads `— none (custom code only)`.

**Assumptions are stated, not asked.** They're the non-derivable scoping decisions the plan had to make, and the plan stands if the reader says nothing.

**Sections appear only when they have contents.** Skipped foundations, skipped custom code, and borderline areas each get a heading only if something landed there. Pretenders never appear under skipped foundations — they aren't catalog rows, so nothing skipped them.

## Existing hand-authored agents (review only)

For each agent with no `agentkit-managed` marker, present the structured review built in step 1.5 of [DISCOVERY.md](./DISCOVERY.md). **Do not modify these files** — this is information for the user to act on.

```markdown
#### `.claude/agents/auth-helper.md` (hand-authored)

**Scope:** Helps with OAuth2 token management — refresh, scope validation, refresh-token rotation.

**Foundation overlap:**

| Foundation | Overlap | Notes |
|-----------|---------|-------|
| `core.auth` | partial | This agent covers tokens; the foundation also covers session lifecycle and replay-window enforcement |
| `core.permissions` | none | — |

**Gaps relative to FOUNDATIONS.md:**
- Doesn't acknowledge the `core.auth` invariant *"replay window must be enforced on all token validations"*
- No mention of the change checklist for auth foundations

**Recommendation: Merge content into the new `auth` agent, then retire**
- Copy the OAuth-specific patterns (token refresh, scope validation) into the new `auth` agent's `Custom Patterns` section
- Then delete `.claude/agents/auth-helper.md`
- Reasoning: the new `auth` agent will own `core.auth` plus this agent's specifics, and avoids the triggering conflict

(Other options shown when relevant: *Keep as-is alongside generated agents*, *Retire — covered by new agent*.)
```

With several hand-authored agents, repeat the block per agent. Don't lump them together — each gets its own scope, overlap, gaps, and recommendation.

## State decisions; don't run a questionnaire

**Every decision the report describes is already made.** Present it as a decision with its reason, and where a defensible alternative exists, name it. A report that ends in a list of questions makes the reader do the work again — and their answers are guesses, because the report holds the evidence and they don't.

| Decision | Not this | This |
|----------|----------|------|
| Foundation grouping | *"I clustered `core.notifications` and `core.events` into one `messaging` agent. Split them?"* | *"`core.notifications` and `core.events` share one agent — shared consumers and same tree. Splitting them would mean consulting two agents on every delivery feature."* |
| A foundation on its own | *"`core.database` has 14 consumers. Recommend its own agent. OK?"* | *"`core.database` is on its own because `Owner: platform-team` differs from the rest. Its 14 consumers aren't why — that's normal for a healthy foundation."* |
| Folding custom code | *"Your `custom-paginator.py` lives near `core.api`. Folding into the api agent. OK?"* | *"`custom-paginator.py` folded into `api` — it imports `core.api` as its base."* |
| Borderline custom code | *"Your `CustomPaginator` adds only `max_page_size`. Skip this or include?"* | *"`CustomPaginator` adds only `max_page_size`, so it's skipped — an assistant gets that right from framework docs. Including it costs `api` one pattern slot if you'd rather have it."* |
| Hand-authored agents | *"(k)eep, (r)etire, or (m)erge?"* | The per-agent review already ends in a recommendation. Leave the files untouched and let it stand; agentkit never deletes someone's agent on its own initiative. |

**Close with options or a recommendation, never a question.** Say what happens next and what to say to change it. A reader who agrees says nothing; a reader who doesn't names the one thing to change.

**Don't raise upgrade paths or native replacements at all.** If the framework version has a native replacement for one of the agent's patterns (the project is on Wagtail 6.0 but 6.3 added `TableBlock`), that goes in the generated agent's `Common Mistakes` or `Research` section as a flag. Upgrade decisions are the team's call, and planning is the wrong moment to surface one.

**The plan is still a gate — nothing is written until the user accepts it.** What changed is the shape of the ask, not whether one exists. Closing with what will happen and how to reshape it is not the same as opening with a confirmation prompt.
