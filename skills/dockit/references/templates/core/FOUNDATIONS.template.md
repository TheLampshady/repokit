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
<!-- One-sentence framing: how many foundations, what categories, last sync date -->

| Name | Type | Path | Owner | Status | Health | Consumers | Last Reviewed |
|------|------|------|-------|--------|--------|-----------|---------------|
[FOUNDATIONS_TABLE]

**Type values:** `service` (stateful, has runtime behaviour) · `abstraction` (interface / base class / pattern) · `primitive` (utility, pure function set) · `design-system` (UI tokens, components)

**Status values:** `active` · `experimental` · `deprecated` · `sunset`

**Health values:** `healthy` · `hotspot` (high churn — see findings below) · `unknown` (low confidence detection)

---

[REPEAT_FOR_EACH_FOUNDATION]

## [FOUNDATION_NAME]

**Path:** `[FOUNDATION_PATH]`
**Type:** [FOUNDATION_TYPE]
**Owner:** [OWNER_TEAM_OR_PERSON]
**Status:** [STATUS]
**Last reviewed:** [YYYY-MM-DD]

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

<!-- Positively phrased where possible. Each carries a stored predicate that sync re-runs;
     a failing predicate is flagged, never auto-deleted. Prohibitions are admissible only
     with a predicate, and only at Convention tier. -->

**[INVARIANT_1]**[IF_HAS_EXCEPTIONS] Exceptions: [EXCEPTION_LIST].[ENDIF]
<!-- dockit:[check|conform] cmd="[VERIFY_COMMAND]" [expect="0"|total="[TOTAL_COMMAND]" min="80%"] tier="[convention|rule]" last="[YYYY-MM-DD]" -->

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
     incident in its Why block. Human-authored Rules need no predicate (though this kind
     often supports one — write it if the check is a one-liner).

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

### Review schedule

Foundations are reviewed on a rolling cadence. A foundation's `Last reviewed` date should be no more than **90 days** old.

| Trigger | Action |
|---------|--------|
| `Last reviewed` > 90 days | foundationtik writes a `foundation-stale-review` ticket |
| Health flips to `hotspot` | foundationtik writes a `foundation-wrong-abstraction` or `foundation-bloat` ticket |
| New hidden foundation detected | dockit `sync` adds a row, flags for review |
| Consumer count drops below threshold | foundationtik writes a `foundation-deprecation-candidate` ticket |
| Invariant predicate fails | dockit `sync` flags it; `/repokit status` asks whether the doc is wrong or the code is drifting |

### Re-running detection

```bash
/repokit:dockit sync
```

Refreshes the catalog from current code state, and re-runs every stored predicate. Manual edits to invariants, refactor triggers, and change checklists are preserved — dockit only updates the table, consumers, dependencies, and findings.

**Nothing here is auto-removed on a failed predicate.** A decayed count means either the invariant is wrong or the code is drifting away from a correct invariant, and the evidence doesn't distinguish those. Sync flags; a human decides.

---

## Related documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design context
- [PRINCIPLES.md](./PRINCIPLES.md) — codebase-wide conventions and rules; foundation-scoped ones live here
- [CONTRIBUTING.md](./CONTRIBUTING.md) — workflow for changes that touch foundations
