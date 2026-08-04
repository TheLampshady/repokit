# Foundations

Registry of shared, foundational code in this project — the abstractions, services, and primitives that the rest of the codebase depends on. This document is the source of truth for `agentkit` (per-foundation subagents) and `foundationtik` in tikkit (maintenance tickets).

A "foundation" here means: code with high fan-in across multiple features, intended to be reused, and expected to remain stable. Regenerate this file with `/repokit:dockit sync`.

<!-- Never link from a generated doc into the dockit skill's own files. The reader of this
     document has the project checked out, not the plugin, so those paths resolve to
     nothing. Name the command to run instead. -->


> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.

<!-- The legend above is load-bearing — an agent reads an undeclared tier as plain
     instruction. Canonical wording lives in CHOICE-MINING.md § The two tiers; copy it
     verbatim rather than paraphrasing. -->

---

## Catalog

[CATALOG_CONTEXT]
<!-- One-sentence framing: how many foundations, what categories. No dates. -->

| Name | Type | Path | Owner | Status | Health | Consumers |
|------|------|------|-------|--------|--------|-----------|
[FOUNDATIONS_TABLE]

<!-- No date column, deliberately. A stamped date is a tombstone: it records a moment
     rather than current state, it rubber-stamps once someone bumps it without reading
     the code, and it goes stale by doing nothing at all. When "how long since anyone
     touched this" is genuinely needed, derive it from git at that moment
     (`git log -1 --format=%cr -- <path>`) — the history is already authoritative and
     can't drift from itself. Keep the Owner column: attribution is the part with
     evidence behind it, and it doesn't decay. -->

**Type values:** `service` (stateful, has runtime behaviour) · `abstraction` (interface / base class / pattern) · `primitive` (utility, pure function set) · `design-system` (UI tokens, components)

**Status values:** `active` · `intended` · `experimental` · `deprecated` · `sunset`

**`intended` means: this is the sanctioned path, and the code hasn't caught up yet.** A wrapper written to be the only door to a capability, a base class with no subclasses so far, a service the team scaffolded before building on it. Zero consumers is the *normal state* of an `intended` foundation — it is never evidence against one.

<!-- Rules for `intended`, all four load-bearing:

     1. DECLARED, NEVER MEASURED. A human sets it, or dockit sets it at write time when
        it registers a foundation the code doesn't demonstrate yet. Nothing re-measures
        adoption to decide the status.
     2. NO REVERSE TRANSITION. `active` -> `intended` because fewer files use it than
        before is the decay flag wearing a new label. Never do this.
     3. NO TIME-BASED TRANSITION. Nothing changes because a date passed.
     4. SYNC NEVER OVERWRITES IT. Same protection manual invariant edits have. Goals
        change; the team re-declares; dockit does not correct them.

     Promotion `intended` -> `active` is OFFERED on `sync --deep` as a review-queue
     question when consumers now exist. Never applied automatically, never on normal sync.

     Removal follows the universal rule: the subject of the sentence disappearing. An
     `intended` foundation whose module is deleted goes. One nobody has built on yet
     stays. -->

**Suppressed for `intended` rows:** the pretender finding and the deprecation-candidate trigger. Both key off low consumer counts, which is what `intended` declares in advance.

**Health values:** `healthy` · `hotspot` (high churn — see findings below) · `unknown` (low confidence detection)

---

[REPEAT_FOR_EACH_FOUNDATION]

## [FOUNDATION_NAME]

**Path:** `[FOUNDATION_PATH]`
**Type:** [FOUNDATION_TYPE]
**Owner:** [OWNER_TEAM_OR_PERSON]
**Status:** [STATUS]

<!--
AGENT PAYLOAD — the four sections below are extracted verbatim into agentkit hot memory
and agent descriptions. Keep them tight, instruction-shaped, and self-contained: an agent
must be able to act on them without opening this file.

Everything after "Reference" is pulled on demand and is not extracted.
-->

### Use when

[USE_WHEN_TRIGGERS]
<!-- Task-shaped trigger lines, not a description. "Reading or writing X", "adding a Y".
     agentkit turns these into the agent's description, so they drive routing — this is the
     highest-leverage line in the entry. -->

### Invariants

<!-- Positively phrased: say what to do, never lead with a prohibition. Every invariant that
     displaces something names the anti-pattern it displaces plus the repair — that named
     accessor or import is the part an agent acts on. Measured once when written, never
     re-measured. Prohibitions are Convention tier only. -->

**[INVARIANT_1]**[IF_DISPLACES_SOMETHING] [ANTI_PATTERN] [WHY_IT_HURTS] — [REPAIR].[ENDIF][IF_HAS_EXCEPTIONS] Exceptions: [EXCEPTION_LIST].[ENDIF]
<!-- dockit:tier="[convention|rule]" -->

<!-- Worked shape:
     **All config comes from the `Settings` object** (`app/core/settings.py`).
     Direct `os.environ` / `os.getenv` reads bypass validation and defaults —
     add a field to `Settings` and read it from there. -->

[IF_HAS_RATIONALE]
<details><summary>Why</summary>

[REASON]
Rejected: [REJECTED_ALTERNATIVE]
</details>
[ENDIF]
[IF_NO_RATIONALE]
[TODO: why?]
[ENDIF]

[IF_NEW_OR_HOTSPOT]
[TODO: known hazard?]
<!-- Emitted ONCE — when this foundation first enters the registry, or when it flips to
     health: hotspot. Never generated content: this solicits an invariant no analysis can
     reach, the kind learned by breaking something. "Numeric and date fields must be
     excluded from facet requests — the vendor rejects them with a 400" is not in the
     import graph, the git history, or the type signatures. Somebody hit it in production.

     A human answers, and the answer becomes a normal Rule-tier invariant above with the
     incident in its Why block. Nothing is measured — the team asserted it, which is
     stronger evidence than any scan.

     "Nothing comes to mind" is a valid answer: delete the marker and don't re-emit it.
     Unanswered is the only state that persists. Never fill this in by inference. -->
[ENDIF]

### Canonical usage

<!-- A real call site copied verbatim from the best-conforming consumer, with a path:line
     comment. NOT a signature list — signatures are derivable by opening the file and go
     stale on every rename. A real invocation additionally carries construction, async-ness,
     and house style. Picking which consumer to copy is itself a recorded choice. -->

```[LANGUAGE]
# from [SOURCE_PATH]:[LINE]
[CANONICAL_CALL_SITE]
```

### Extend by

[EXTENSION_PROCEDURE]
<!-- The sanctioned path to add a new instance of whatever this foundation manages.
     Detect from git history first: take the last few additions of this kind and intersect
     the files each one touched — that intersection is the procedure. Then scaffold commands
     and registry files.

     This is the field that lets the entry say something other than "use the existing thing." -->

### Doesn't cover

[UNCOVERED_SCOPE]
<!-- The foundation's deliberate edge, so an agent can tell when building something new is
     correct rather than a violation. Only half-inferable: the observation is visible
     ("4 features write directly, bypassing this"), the intent is not.
     Draft the observation, then: [TODO: intentional boundary, or a gap?] -->

---

#### Reference

<!-- Pulled on demand. Not extracted into agents. -->

**Consumers**

[CONSUMERS_CONTEXT]

| Feature / Module | Usage |
|------------------|-------|
[CONSUMERS_TABLE]

**Dependencies**

[DEPENDENCIES_CONTEXT]
<!-- Should be short — foundations have low efferent coupling. -->

- [DEPENDENCY_1]
- [DEPENDENCY_2]

**Test coverage**

[TEST_COVERAGE_DESCRIPTION]

**Refactor triggers**

<!-- When to revisit this foundation. Concrete thresholds, not aspirational. -->

- [TRIGGER_1]
- [TRIGGER_2]

**Change checklist**

<!-- What a contributor must do when modifying this foundation. Extracted into agentkit
     hot memory alongside the invariants. -->

- [ ] [CHECKLIST_ITEM_1]
- [ ] [CHECKLIST_ITEM_2]

[END_REPEAT]

---

## Findings

[IF_HAS_FINDINGS]

Surfaced by the most recent dockit foundation scan. These are **not** registry rows — they are flags for the maintainer.

### Hotspots

[HOTSPOTS_CONTEXT]
<!-- Active foundations whose churn places them in the top quartile — likely the wrong abstraction or under active redesign. foundationtik will write refactor tickets. -->

| Foundation | Changes (12mo) | Note |
|------------|----------------|------|
[HOTSPOTS_TABLE]

### Hidden foundations

[HIDDEN_CONTEXT]
<!-- Files acting as foundations (high fan-in across features) but not living in a conventional foundation directory. Consider relocating. -->

| Path | Fan-in | Distinct features | Suggested location |
|------|--------|-------------------|--------------------|
[HIDDEN_TABLE]

### Pretenders

[PRETENDERS_CONTEXT]
<!-- Files in core/, shared/, lib/, etc. with low fan-in. Consider inlining back into a feature folder, or deleting. -->

| Path | Fan-in | Note |
|------|--------|------|
[PRETENDERS_TABLE]

[ENDIF]

[IF_NO_FINDINGS]
> No findings from the most recent scan. All foundations are healthy and well-located.
[ENDIF]

---

## Maintenance

### Review triggers

Reviews are triggered by **events, not by the calendar.** Nothing here fires because time passed.

| Trigger | Action |
|---------|--------|
| Health flips to `hotspot` | foundationtik writes a `foundation-wrong-abstraction` or `foundation-bloat` ticket |
| New hidden foundation detected | dockit `sync` adds a row, flags for review |
| Consumer count drops to zero **and the module is gone** | foundationtik writes a `foundation-deprecation-candidate` ticket |
| The code an invariant governs is deleted | dockit `sync` removes the invariant and names it in the run report |
| Someone works on the foundation | Validate the invariants while you're in there — the review that happens during real work is the one worth having |

**Want to know what hasn't been looked at lately?** Derive it, don't store it: `git log -1 --format=%cr -- <foundation-path>` for code, `git log -1 --format=%cr -- docs/FOUNDATIONS.md` for the registry. Git already knows, and a stamped date in this file would only add a second answer that can disagree with the first.

### Re-running detection

```bash
/repokit:dockit sync
```

Refreshes the catalog from current code state. Manual edits to invariants, refactor triggers, and change checklists are preserved — dockit only updates the table, consumers, dependencies, and findings.

**Invariants are not re-measured.** An invariant is measured once, when it's written, and after that it's a directive: it says what future work should do. Fewer files following it is not a signal, isn't counted, and isn't reported. The only removal trigger is the code it governs disappearing. For ongoing conformance enforcement, use a linter — ArchUnit, import-linter, and dependency-cruiser run on the hot path where enforcement actually works.

---

## Related documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design context
- [PRINCIPLES.md](./PRINCIPLES.md) — codebase-wide conventions and rules; foundation-scoped ones live here
- [CONTRIBUTING.md](./CONTRIBUTING.md) — workflow for changes that touch foundations
