# Agentkit Sync Guide

How `agentkit sync` reconciles existing project agents with the current state of `FOUNDATIONS.md` and the codebase.

Sync is a three-way compare: **agent files** vs. **FOUNDATIONS.md** vs. **the code**. Where they disagree, sync **fixes the agent and reports what it did**.

## Sync acts; it doesn't interview

`sync` is a verb. It applies every change the catalog already decided, then prints a report of what changed and what it left alone. It does not walk the user through their own drift one prompt at a time — that turns a maintenance command into a quiz about a codebase the user knows better than sync does, and it gets abandoned halfway, leaving the agent set in a half-reconciled state that's worse than either end.

The dividing line is **authority, not risk**:

> **Apply it when `FOUNDATIONS.md` already decided. Defer it when applying would mean deciding.**

That follows the repo's split — dockit decides what a foundation is and what its invariants are; agentkit's job is to make the agents match. Reconciling an agent to a catalog row is not a judgment call, so it doesn't get a prompt.

| Sync applies, no prompt | Sync defers and reports |
|-------------------------|-------------------------|
| Path drift — repoint working directories | **Deleting an agent file** — destructive, and an agent owning nothing is still a reviewable artifact |
| Status/health drift — update the table | **Editing `FOUNDATIONS.md`** — agentkit never writes the catalog; recommend `/dockit sync` |
| Invariant drift — agent takes the catalog's wording and tier | **Coverage gaps** — nothing in the catalog says that directory matters, so creating an agent for it *is* the decision |
| Orphaned reference — drop it from `Owned Foundations` | **Folds that fail the layer test** in `AGENT-SIZING.md` |
| Catalogued foundation with no owner — create or fold per AGENT-SIZING | **`intended → active`** — the rescope is a scope change, not a table edit |
| Module-split drift — rescope from the dead file to the package | **Folds that would breach the size budget** (≥10,000 chars or >5 foundations) |
| In-scope inheritance root missing from hot memory — add it | **Hand-authored agents** (no `agentkit-managed` marker) |
| Platform gap — generate the missing platform's copy | |

Two things make acting-by-default safe, and the report has to carry both:

- **Every edit is confined to agent files**, which are generated artifacts under version control. Name the files changed so `git diff` is the undo button, and say so.
- **`agentkit status` is the dry run.** Anyone who wants to look before anything moves has a read-only mode already; that's what it's for. Sync does not need a second one.

## Contents

- [Inputs](#inputs)
- [Drift Categories](#drift-categories)
- [Sync Output Format](#sync-output-format)
- [Per-Finding Actions](#per-finding-actions)
- [Multi-Platform Considerations](#multi-platform-considerations)
- [Status Mode (Read-Only)](#status-mode-read-only)
- [How Sync Identifies Agentkit-Generated Agents](#how-sync-identifies-agentkit-generated-agents)
- [What Sync Does NOT Do](#what-sync-does-not-do)

---

---

## Inputs

Before running, sync gathers:

| Input | Source | What's needed |
|-------|--------|---------------|
| Existing agents | `.claude/agents/`, `.agents/agents/`, `.github/agents/` | All `*.md` and `*.agent.md` files |
| Current foundations | `docs/FOUNDATIONS.md` (catalog table + entries) | Names, paths, status, invariants |
| Per-foundation sub-docs | `docs/architecture/foundations/*.md` (if present) | Deeper context for large projects |
| Code state | Source files referenced by foundations | To detect path renames, public API drift |

If `FOUNDATIONS.md` is missing, sync stops and recommends running `/dockit init` — there's nothing to reconcile against.

---

## Drift Categories

Sync classifies findings by **comparing content** between the agent body and FOUNDATIONS.md. No timestamps involved — the question is always "do these match right now?"

Each category below says whether sync **applies** or **defers**, per the authority rule above. Category names are vocabulary for this guide, not report headings — the report groups by applied/deferred and uses the labels in [Sync Output Format](#sync-output-format).

### 1. Orphaned agents

The agent claims ownership of a foundation that no longer appears in `FOUNDATIONS.md` (removed, renamed, or demoted to pretender).

**Detection:** parse the agent's `Owned Foundations` section; check each named foundation against the current catalog.

**Applies:** remove the orphaned foundation from `Owned Foundations` and drop its hot-memory block.

**Defers:** deleting the file, even when nothing is left. Report it as *"`admin` now owns nothing — delete it?"* and leave it in place. An empty agent is inert; a deleted one is gone, and the destructive-ops guard covers agent directories for a reason.

### 2. Missing agents

A foundation exists in `FOUNDATIONS.md` but no agent claims ownership.

**Detection:** for each catalog row, check whether any existing agent's `Owned Foundations` section names it.

**Applies:** create the agent, or fold the foundation into an existing same-domain agent per the AGENT-SIZING grouping rules. A row in the catalog is the team saying this is a foundation, so no one needs to be asked whether it deserves an owner.

A fold that fails the layer test means **create instead** — the foundation still gets an owner, just not that one. A fold that breaches the size budget means **split the target and create**, per § Create / fold for a missing agent. Neither is a deferral: the catalog row already settled that this code has an owner, so only the *shape* was ever in question and sync can resolve it.

**Defers** two cases: the new agent's description would collide with an existing agent's, and the target has no clean split boundary because its foundations are all mutually change-coupled. Report the specific conflict — *"folding `core.notifications` into `messaging` would take it to 6 foundations, and every cut leaves both halves undescribable"* — not a generic "needs review."

### 3. Path drift

The foundation's path in the catalog changed (e.g., `core/notifications.py` → `core/notifications/dispatcher.py`), but the agent's `Working Directories` table still points at the old location.

**Detection:** compare each owned foundation's path in the catalog vs. the path(s) in the agent's Working Directories.

**Applies:** update the path. Then re-grep PRINCIPLES.md / ARCHITECTURE.md for the old path and report any hits — those are doc files, so sync names them and recommends `/dockit sync` rather than editing them.

### 4. Invariant drift

The catalog's invariants for a foundation differ from what's embedded in the agent's hot memory.

**Detection:** parse each foundation's `### Invariants` section in FOUNDATIONS.md and the matching `### <FoundationName>` block in the agent body.

An invariant in FOUNDATIONS.md is a **bold statement line** — including any named anti-pattern and repair that follows it — optionally followed by a `<!-- dockit:tier=... -->` comment and a `<details><summary>Why</summary>` block. In the agent, the same invariant appears as a bullet prefixed with its tier: `- **[Rule]** <text>`. Compare the statement text **and its anti-pattern clause**; ignore the `dockit:tier` comment and the `Why` blocks (not extracted). An agent whose invariant has lost the anti-pattern clause has drifted — that clause is the operational half.

A drift is any of:
- Invariant present in FOUNDATIONS.md, missing from agent
- Invariant present in agent, missing from FOUNDATIONS.md
- Wording differs in a way that changes meaning (use loose normalization — case + whitespace + punctuation — to avoid noise)
- **Tier differs** — the agent says `[Rule]` where the catalog says `tier="convention"`, or vice versa

Tier drift matters as much as text drift and is easier to miss: an agent enforcing a Convention as a Rule blocks work the team considers legitimate, and one treating a Rule as a Convention lets a real defect through. Always report it explicitly rather than folding it into a wording diff.

**Applies:** the agent takes the catalog's wording and tier verbatim. Invariants are load-bearing, which is the argument *for* fixing them immediately rather than leaving a known-wrong rule in an agent until someone finishes a prompt queue. Show the before/after in the report so the change is reviewable.

**Defers:** the case where the **agent** looks more right than the catalog — it carries a specific contract the catalog states only vaguely, or names an anti-pattern the catalog dropped. Sync still doesn't edit the agent's version away; it reports the pair and recommends `/dockit sync`. Agentkit never writes `FOUNDATIONS.md`.

> Sync never *promotes* an invariant. If the catalog and agent disagree on tier, the catalog wins in the agent — but moving something from Convention to Rule in the catalog itself is a human decision, collected by `/repokit status`.

### 5. Status drift

The foundation's `Status` (active / intended / experimental / deprecated / sunset) or `Health` (healthy / hotspot / unknown) changed in FOUNDATIONS.md but the agent's `Owned Foundations` table still shows the old value.

**Detection:** compare each owned foundation's status/health in the catalog vs. the agent's Owned Foundations table.

**Applies:** update the table. Run the cross-doc check if status flipped to `deprecated` or `sunset`.

**Defers: `intended → active` needs more than a table edit.** The foundation now has real consumers, which changes what the agent should carry:

- **Rescope `Working Directories`.** They were sourced from where consumers were *meant* to go; now use the catalog's actual `Consumers` column, keeping any intended-destination directory that's still empty.
- **Replace the no-precedent block with a canonical call site.** Real usage exists, so the agent should pattern-match against it instead of being told none exists.

Apply the status word; defer the rescope and report the proposal. The scope change is the substantive part, and it rests on where consumers *actually* are versus where the team meant them to go — a reading of the code, not of the catalog.

> **Never report foundation age.** Not from a date field (there isn't one — see [FOUNDATION-MAINTENANCE.md](./FOUNDATION-MAINTENANCE.md#never-stamp-a-date-into-foundationsmd)) and not derived from git either. *"Nobody has touched `core.auth` in 142 days"* is trivial to compute and is a calendar nag whichever source it comes from. Review is triggered by someone working on the foundation. Derive an age only if the user explicitly asks for one.

### 6. Scope drift — Trigger Coverage Gaps

Categories 1–5 all compare the agent against the catalog. This one compares the **agent set against the code**, and it catches the failure the others structurally cannot: `FOUNDATIONS.md` is entirely correct, every agent matches it, and a whole directory still triggers nothing.

That gap is invisible from inside the agent set. Nothing errors. Work in the uncovered directory routes to a generic assistant, which writes plausible code that ignores conventions no one told it about. It shows up in the field as *"we refactored one module into a package and the agent kept editing the old file"* and *"nobody noticed `presenters/` was never in any agent's scope."*

Detecting absence is the point. Run this pass on every sync.

#### Building the covered set

1. For each agent, collect its `Working Directories` paths, any file globs in its frontmatter description, and paths named in `Owned Foundations`.
2. Normalize to directories. A path covers itself and everything beneath it.
3. Union across **all** agents on all platforms — coverage is a property of the agent set, not of one agent.

#### Finding what's outside it

Use dockit's standard exclusions (`tests/`, `node_modules/`, `vendor/`, `dist/`, generated code, vendored code). Then flag three things:

**a. Uncovered active directories.** A directory containing source files, none of whose ancestors are in the covered set:

```bash
find src -type d -not -path "*/node_modules/*" -not -path "*/tests/*" \
  | while read d; do
      n=$(find "$d" -maxdepth 1 -type f \( -name "*.py" -o -name "*.ts" \) | wc -l)
      [ "$n" -ge 1 ] && echo "$n $d"
    done | sort -rn
```

Threshold by project size — flag at **≥ 10 files** on small/medium projects, **≥ 20** on large ones. Below that, list under a single "also uncovered (small)" line rather than as findings.

**b. Uncovered inheritance roots.** A type with **≥ 5 subclasses** in-repo whose defining file sits outside the covered set, or sits inside it but is named nowhere in any agent's hot memory.

Count occurrences, not files — one file can define several subclasses of the same base, and each is a separate consumer of its contract:

| Language | Recipe |
|----------|--------|
| Python | `grep -rhoE "class\s+\w+\([^)]*\b<Type>\b" src/ \| wc -l` |
| JS / TS | `grep -rhoE "class\s+\w+\s+extends\s+<Type>\b" src/ \| wc -l` |
| Java / Kotlin | `grep -rhoE "(extends\|implements\|:)\s+<Type>\b" --include="*.java" --include="*.kt" . \| wc -l` |
| Go (embedding) | `grep -rhoE "^\s+\*?<Type>\s*$" --include="*.go" . \| wc -l` |
| Rust | `grep -rhoE "impl\s+(<[^>]*>\s+)?<Type>\s+for\b" --include="*.rs" src/ \| wc -l` |

Inlined deliberately: skills load independently, so agentkit can't rely on reading a guide that ships inside dockit. If these fall out of step with dockit's Signal 1b, dockit's copy is authoritative — but a wrong subclass count here costs a mis-prioritized finding, not a bad catalog row.

An inheritance root inside a covered directory but absent from hot memory is still a finding. The agent will be *invoked*; it just won't know the base class exists, which is the hallucination case.

**c. Module-split drift.** A catalog path or Working Directory row that names a single file which no longer exists, where a *package of the same stem* does:

```bash
# agent says: service/api/utils/discovery_utils.py
[ ! -f service/api/utils/discovery_utils.py ] && ls service/api/utils/
```

This is the refactor that most reliably orphans an agent's scope while everything still looks superficially fine. Treat it as scope drift rather than path drift (category 3): the fix is usually "cover the package," not "repoint at one replacement file."

#### A gap is a question, not a defect

Plenty of directories *should* be uncovered — thin CRUD, config, glue, generated output, anything an AI gets right from framework knowledge alone. That's the Core Test in `AGENT-SIZING.md`, and it still governs. Report the gap, state what's in the directory, and let the user decide.

**Defers — this is the one category that always defers.** Everywhere else sync acts because the catalog already decided; here the catalog is silent by definition. An uncovered directory isn't in `FOUNDATIONS.md`, so "this deserves an agent" would be agentkit's own judgment, and it's the judgment agentkit is worst at: the Core Test turns on whether an AI would get the directory right from framework knowledge alone, which the person who wrote it knows and a scan does not.

Report each gap with a concrete proposal — the agent it would create, or the agent it would fold into — so accepting is one word. Never a bare "needs review."

**One exception, and it applies:** an inheritance root *inside* the covered set but missing from hot memory. Scope is already assigned, so no one is deciding anything; the agent is just under-informed. Add the pattern and report it under applied changes.

Before proposing a fold, run the **layer test** in [`AGENT-SIZING.md`](./AGENT-SIZING.md) § "Closing a coverage gap without inflating an agent." Folding four architectural layers into one agent to make a coverage report go green trades a blindspot for an agent that triggers on everything and knows each layer shallowly. Sync must not recommend that silently.

### 7. Exemplar drift

The agent's `Exemplar` row names a file the agent is told to read before writing, and the address no longer holds.

**Detection:** for each exemplar row, check that the path resolves and that the named symbol is still in the file (`grep -q "<symbol>" <path>`). Cheap, and it's what makes the address worth using instead of a paste — see [`GENERATION.md`](./GENERATION.md) § Why an address and not the code.

**Applies:** re-run [`GENERATION.md`](./GENERATION.md) § Exemplar selection for that foundation and replace the row, add date included. Selection is cheap and its inputs are the catalog plus `git log`, so there's nothing to ask about.

If selection now yields nothing — the consumers moved into a hotspot tree, or the set emptied — remove the row and report that, rather than leaving an address that doesn't resolve.

A **renamed symbol in a file that still exists** is the common case, and it's a real finding rather than noise: the thing the agent was told to study is gone under that name. Re-select and replace; don't guess at the new name.

**Does not detect:** an exemplar that still resolves but has stopped being representative. The file is intact, the symbol is intact, and the pattern moved on around it; nothing in the address disagrees with anything in the code, so there is no drift to see. The add date in the row is the only signal, and it's a signal for the human reader. Don't manufacture a check for this by re-running selection every sync and diffing — that would replace a stable, reviewed pointer with whatever landed most recently, on every pass.

---

## Sync Output Format

The report's audience is **an engineer who did not build the agent set and does not know agentkit's vocabulary.** They should be able to act on it without reading this guide. Optimize for that reader, not for completeness of the taxonomy.

### Readability rules

These are requirements, not style preferences. A report that violates them is a defect even if every finding in it is correct.

1. **Lead with a verdict, then counts, then findings.** The first three lines answer "is anything actually wrong, and how much of my time is this?" A reader who stops there should still have the gist.

2. **Group by applied vs. deferred, not by drift category.** Four sections, always in this order: **Updated** (agents that already existed), **New** (agents sync created), **Left for you** (what it deferred, and why), **Noted** (too small to act on). Never print the six category names as top-level sections — that ordering serves the scanner, not the reader. Updated and New are separate because they ask different things of the reader: an update is skimmed for surprises, a new agent is a new routing target they need to recognise.

3. **Omit empty buckets and empty categories entirely.** Never print `none`. Zero findings of a kind is information for the summary line, not a section heading.

4. **Identify each finding by agent name, then foundation.** Never by the platform's config file. A label like `config.yaml` repeated across four findings identifies nothing — the reader can't tell which agent is affected, and two findings that look identical aren't. Use the agent's frontmatter `name`; add the file path only when the reader needs to open it.

5. **Use full paths, never bare basenames.** `base.py` is ambiguous the moment a project has two of them. `src/presenters/base.py` is not.

6. **Number every finding, and never cross-reference "above."** If one finding's resolution depends on another's, they are **one finding with sub-bullets**, not two. *"Handle according to the decision on presenters above"* is a merge that didn't happen.

7. **Applied changes get one line each; a table is ideal.** They already happened — the reader is skimming for anything surprising, not deciding. Reserve prose for the deferred items.

8. **Cap each deferred item at four lines of prose.** One line of what it is, one of why it matters, one recommendation, one line of what to say. Detail beyond that goes behind an offer — *"say `explain 3` for the file list"* — because a wrapped paragraph inside a bulleted list is the single biggest source of unreadability in the old format.

9. **End with options or a recommendation, never a question.** Close the deferred list with what you'd do and what the alternatives are — *"I'd create `helpers-expert` and `presenters-expert`. Widening `component-expert` instead would take it to three layers."* The reader acts on it or ignores it and the sync still stands. No closing `Proceed?`, no `(2 of 5)` walk, no per-item `Action?` line. A recommendation the reader can decline is more useful than a question they have to answer before anything is settled.

10. **Say the consequence, not the category.** "Invariant drift" names a taxonomy slot. "The agent's version drops the variable names, so it can't tell an AI what to check" tells the reader why it matters.

11. **Name the changed files and offer the undo.** One line at the end: which files sync touched and that `git diff` reverses all of it. Acting without asking is only reasonable if reverting is obvious.

12. **Describe a new agent the same way init does.** Under **New**, use the four fields from [REPORTING.md](./REPORTING.md) § The agent block — *Knows*, *Foundations*, *Triggers on*, *Own agent because* — in that order, for every new agent. An agent should read identically whether it was proposed at init or created during a sync; a reader who learned the shape once shouldn't have to learn a second one. *Triggers on* is not optional here: a new agent is a new routing target, and sample requests are the only part of the entry that tells the reader when it will fire.

13. **A split is one entry, not two.** When a budget breach splits an existing agent, the rescoped original and the new agent are one event. Report it once under **New**, naming both sides in *Own agent because* — *"split from `notifications`, which was full at 5 foundations when `core.events` arrived."* Two entries that each say "see the other" is rule 6's merge that didn't happen.

14. **Routability belongs in the verdict when it's clean, in Left for you when it isn't.** A set where every description pair still routes cleanly is one clause in the opening lines — *"all 15 description pairs still route cleanly"* — not a section. A collision is a deferred item: name both agents and the request that matches both, and say that the fix is a boundary change rather than a description tweak, because that is what makes it the reader's call and not sync's.

15. **Print the budget table only when a number is close to a limit or a split moved one.** Per-agent budgets are reassuring at init, where the reader is judging a proposed shape. In a sync they're noise unless something is at 5 of 5 foundations, within ~10% of the body limit, or just came down from a breach. Otherwise fold the relevant number into the entry that turned on it — a new agent's *Own agent because* is where a breach earns its mention.

### Category → reader-facing label

Use the left column when talking to yourself in this guide; use the right column in the report.

| Internal category | Reader-facing label |
|-------------------|--------------------|
| Orphaned agent | Agent owns a foundation that no longer exists |
| Missing agent | Foundation with no owner |
| Path drift | Agent points at the old path |
| Invariant drift | Agent's rule disagrees with the docs |
| Status drift | Status out of date |
| Trigger coverage gap | Code no agent covers |
| Exemplar drift | Example file the agent was told to read has moved |
| Platform gap | Agent missing on one platform |
| Routability collision | Two agents now answer to the same request |

### Shape

Markdown, matching `/repokit status` — terminals render it and the visual hierarchy survives a narrow window, which ASCII rules and indented bullet trees do not.

```markdown
## agentkit sync — enterprise-partners-directory

**Synced 3 changes and created 1 agent.** Nothing was broken — every foundation has an
owner, no agent contradicts the docs, and all 10 description pairs still route cleanly.
What's left is coverage: 38 files no agent will ever be invoked for.

5 agents · Antigravity (`.agents/agents/`) · checked against `docs/FOUNDATIONS.md`

### Updated

| Agent | Change |
|-------|--------|
| `component-expert` | Repointed at `frontend/src/components/factory.py` (was `src/components/`), in its working directories and its registration rule |
| `component-expert` | Added the GA config pattern to hot memory — it owns `CtaGaConfig` (6 subclasses) and `GaConfig` (20) but had never been told they exist |
| `schema-agent` | Rescoped from `utils/discovery_utils.py`, which is now a 4-module package, to `utils/` |

`PRINCIPLES.md:47` still cites the old factory path — that's a doc, so it's dockit's to fix. Run `/dockit sync`.

### New

**`partner-sync`**

- **Knows** — how partner records reconcile against the upstream feed, and which conflicts resolve automatically versus which halt the run
- **Foundations** — `integrations.partner_feed`
- **Triggers on** — *"add a field to the partner import"* · *"why did last night's sync skip 12 records?"*
- **Own agent because** — `integrations.partner_feed` entered the catalog unowned. Folding it into `schema-agent` failed the layer test: `integrations/` is integration layer where `schema-agent` owns data, with only one coupling signal.

### Left for you — 2

Both are coverage gaps: code no agent covers. Nothing in `FOUNDATIONS.md` says these
directories matter, so whether they deserve an agent is your call, not sync's.

**1. `helpers/` — 27 files across `helpers/` and `helpers/utils/`**

Edits here route to a generic assistant that has never read your conventions; the Chrome
recommendation rules live in this directory. Nearest agent is `component-expert`, but that
owns UI components — folding shared utilities and business logic in would make it trigger
on nearly everything.

**2. `presenters/` — 11 files, plus `src/presenters/base.py` (9 subclasses)**

Same shape, different layer: view-model presenters vs. UI components.

I'd create `helpers-expert` and `presenters-expert` — one per layer, each describable
without either one reaching into the other's territory. Widening `component-expert` to
cover both instead would take one agent across three layers, which closes the gaps and
leaves an over-triggering agent that knows each layer shallowly. Leaving them uncovered
is also a real option if edits there are rare. (`explain 1` for the file lists.)

### Noted

Too small to warrant an agent: `services/` (6), `dao/` (5), `routers/` (3), `gcp_services/` (3), `perks/` (3), `controllers/` (2).

Changed `.agents/agents/component-expert.md` and `schema-agent.md`, added `partner-sync.md` — `git diff .agents/agents/` to review, `git checkout` to undo.
```

Details in that example that are load-bearing:

- **The deferred items are renumbered from 1.** They're the only list the reader acts on, so they own the numbering. Numbering applied changes invites *"undo 2,"* which git does better.
- **The `⚠` glyph is gone.** When the reason a fold is a bad idea is stated in a sentence, the warning symbol adds urgency without information — and it made every gap look like a failure rather than a question.
- **The close is a recommendation with named alternatives, and one of them is "do nothing."** Per rule 9 it isn't a question, and it doesn't pretend the recommendation is the only defensible answer.
- **Routability appears once, in the second line, because it was clean.** No section, no table — rule 14.
- **No budget table**, because nothing was near a limit. The breach that created `partner-sync` would have been named in its *Own agent because* if a budget had been the trigger — rule 15.

---

## Per-Finding Actions

### Update an agent

For every applied change:

1. Read the current agent file
2. Apply the specific change (path, invariant, owned-foundation list, status)
3. Re-grep cross-docs if the change affects PRINCIPLES.md / ARCHITECTURE.md
4. Don't record that a review happened — sync didn't review, it reconciled. `FOUNDATIONS.md` carries no date field for this, and the distinction matters: reconciling an agent against a catalog row is not the same as reading the code and confirming the invariants hold.

### Delete an agent

Never during sync. When orphan cleanup leaves an agent owning nothing, sync strips the dead references and reports *"`legacy-cache` now owns no foundations — delete it?"* The file stays until the user says so.

### Create / fold for a missing agent

Applies when a **catalogued** foundation has no owner. (Uncovered *code* is a coverage gap — always deferred.)

- **Create** — generate a new agent following the standard Phase 4 template (foundation-agent.template.md). Check its description against every existing agent's before writing it; there is no cap on how many agents the set holds.
- **Fold** — add the foundation to an existing agent's `Owned Foundations` section. Update the body's hot-memory section to reference it. Add a Working Directory row.

If folding would push an agent over the size budget (≥10,000 chars or >5 owned foundations), **a split trigger has fired** — the budget overrides every argument for grouping. Split the target agent on its weakest change-coupling boundary, land the new foundation on the side it belongs to, and report the whole thing as one **New** entry naming both resulting agents. This is still creating an agent for a catalogued foundation, which is sync's authority; the owner was never optional.

Defer only when no clean boundary exists — the target's foundations are all mutually change-coupled, so any cut leaves both halves undescribable. Then report the number it would breach and say why the split has nowhere to land, because at that point the fix is a design decision.

If the create would produce a description a router couldn't tell from an existing agent's, defer it and name the agent it collides with: that fix is a boundary change, which is also the user's call.

### Reconcile invariant drift

Two possible resolutions, and only one of them is sync's:

1. **Agent is wrong** — the catalog has the truth. Update the agent body; report the before/after.
2. **Catalog is wrong** — the team changed the invariant in code without updating FOUNDATIONS.md. Sync leaves both alone, reports the pair, and recommends `/dockit sync` then a re-run.

Sync can't tell these apart by comparing text, so use a **specificity heuristic and state which one you applied**: if the catalog's version is the more specific of the two — names the variables, the call, the anti-pattern — treat the agent as stale and fix it. If the *agent* holds the specific contract and the catalog only gestures at it, that asymmetry means the catalog lost something, so leave it and report. Either way the agent never ends up claiming an invariant the catalog doesn't endorse.

---

## Multi-Platform Considerations

When a project has agents on multiple platforms (Claude + Antigravity, etc.), the same drift may appear in each platform's copy of an agent. Apply changes to **all platforms** in one pass — never let Claude and Antigravity agents drift apart.

If only one platform has the agent (e.g., Claude has `auth.md` but Antigravity doesn't), that's a **platform gap** rather than drift: generate the missing copies and report it as an applied change. The team already decided this agent should exist; which platforms get it isn't a separate decision.

(Distinct from a **trigger coverage gap**, category 6 — that's code no agent covers on *any* platform. A platform gap is the same agent missing a copy.)

---

## Status Mode (Read-Only)

`agentkit status` runs the same drift scan and **changes nothing**. It is sync's dry run — the mode for looking before anything moves — so it never needs a `--dry-run` flag on sync. The readability rules above apply here too: verdict first, agent names not file names, no `none` rows.

```markdown
## agentkit status — enterprise-partners-directory

**4 agents, 2 need attention.** All foundations are owned; 3 areas of code aren't.

6/6 foundations owned · 11 of 14 source directories covered

| Agent | Owns | State |
|-------|------|-------|
| `auth` | core.auth, core.permissions | 🟢 matches the docs |
| `data-layer` | core.database, core.cache | 🟢 matches the docs |
| `messaging` | core.notifications, core.events | 🟡 one rule worded differently |
| `admin` | nothing — its foundation was removed | 🟡 safe to delete or repoint |

**Code no agent covers:** `src/presenters/` (14 files) · `src/dao/base.py` (12 subclasses, in scope but not in hot memory) · `service/api/utils/` (agent still scoped to one file that became a package)

`/agentkit sync` fixes 3 of these outright; the 2 coverage gaps will come back as questions.
```

The last line matters more than it looks. It tells the reader that most of a five-row report isn't theirs to handle — without it, five 🟡 rows read as a project in trouble rather than one command.

---

## How Sync Identifies Agentkit-Generated Agents

Each generated agent has a marker comment near the top of the body:

```html
<!-- agentkit-managed -->
```

No date — just a marker. Hand-authored agents (no marker) are off-limits to sync; agentkit warns about them but never replaces them without explicit user approval.

Drift is detected by **content comparison** between the agent body and FOUNDATIONS.md, not by timestamp comparison. If the user wants to know when an agent file was last touched, `git log -1 .claude/agents/<name>.md` is authoritative — agentkit doesn't duplicate that.

---

## What Sync Does NOT Do

- **Does not run dockit's foundation detection** — never re-scores fan-in, cross-feature spread, or stability, and never writes a `FOUNDATIONS.md` row. That's dockit's job. If sync sees the catalog is stale, it tells the user to run `/dockit sync`.

  The category-6 coverage scan is deliberately on the near side of that line. It may **count** — files per directory, subclasses per type — because counting is what "is this covered?" requires. It may not **score** or **rank**, and when a coverage gap looks like an uncatalogued foundation, the recommendation is `/dockit sync`, not a row written by agentkit. Two scanners that both decide what a foundation is will drift; one that counts and one that scores will not.
- **Does not rewrite invariants silently** — it rewrites them to match the catalog and prints the before/after. "Silently" was the problem, not "without a prompt": a known-wrong rule left in an agent because someone abandoned a prompt queue is the failure this avoids.
- **Does not delete agent files** — orphan cleanup strips dead references and leaves the file, then asks.
- **Does not decide that uncovered code deserves an agent** — the catalog is silent on those directories, so sync reports the gap with a proposal and stops.
- **Does not modify foundation source code or doc files** — only agent files. Cross-doc hits are named in the report and handed to `/dockit sync`.
- **Does not create FOUNDATIONS.md** — that's dockit's `init`.
