# Foundations

Registry of shared, foundational code in this project — the abstractions, services, and primitives that the rest of the codebase depends on. This document is the source of truth for `agentkit` (per-foundation subagents), `feedback-loop` (invariant validation), and `foundationtik` in tikkit (maintenance tickets).

A "foundation" here means: code with high fan-in across multiple features, intended to be reused, and expected to remain stable. Detection methodology in [dockit's FOUNDATIONS-DETECTION guide](../skills/dockit/references/guides/FOUNDATIONS-DETECTION.md). Background concepts in [foundations-reference](../docs/reference/foundations-reference.md).

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

### Purpose

[FOUNDATION_PURPOSE]
<!-- One paragraph: what this foundation provides and why it exists. Avoid implementation detail; that's what the code is for. -->

### Public API

[PUBLIC_API_DESCRIPTION]
<!-- Bullet or table form: the surface that consumers depend on. Symbol name + one-line purpose. -->

```[LANGUAGE]
[PUBLIC_API_EXAMPLE]
```

### Invariants

<!-- Rules that must hold for any change to this foundation. feedback-loop validates against these. -->

- [INVARIANT_1]
- [INVARIANT_2]

### Consumers

[CONSUMERS_CONTEXT]
<!-- Number of importers, distinct feature folders, links to top consumers. -->

| Feature / Module | Usage |
|------------------|-------|
[CONSUMERS_TABLE]

### Dependencies

[DEPENDENCIES_CONTEXT]
<!-- What this foundation depends on. Should be short — foundations have low efferent coupling. -->

- [DEPENDENCY_1]
- [DEPENDENCY_2]

### Test coverage

[TEST_COVERAGE_DESCRIPTION]
<!-- Test file path, coverage % if known, what's tested vs. what isn't. -->

### Refactor triggers

<!-- When to revisit this foundation. Concrete thresholds, not aspirational. -->

- [TRIGGER_1]
- [TRIGGER_2]

### Change checklist

<!-- What a contributor must do when modifying this foundation. -->

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

### Re-running detection

```bash
/repokit:dockit sync
```

Refreshes the catalog from current code state. Existing manual edits to invariants, refactor triggers, and change checklists are preserved — dockit only updates the table, consumers, dependencies, and findings.

---

## Related documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design context
- [PRINCIPLES.md](./PRINCIPLES.md) — patterns and conventions that foundations implement
- [CONTRIBUTING.md](./CONTRIBUTING.md) — workflow for changes that touch foundations
