# Foundations — Detection Guide

How dockit finds the foundational code in a project — even when it isn't named like a foundation, isn't living in `core/`, and the original author didn't realise they were creating one.

The premise: **a foundation is whatever the rest of the codebase actually depends on, regardless of where it lives or what it's called.** That's a measurable property — fan-in, cross-feature usage, and change stability — not a naming convention.

This guide produces input rows for `FOUNDATIONS.md`. Background and terminology in [`docs/reference/foundations-reference.md`](../../../../docs/reference/foundations-reference.md).

---

## When to use this guide

dockit runs this in two situations:

- **`init`** — first generation of `FOUNDATIONS.md`. Scan, score, propose top-N, ask the user to confirm.
- **`sync`** — refresh existing rows. Re-score, flag rows that changed category (foundation became hotspot, candidate became pretender, new hidden foundation appeared).

Skip this guide on **small projects** (one feature folder, < ~1k LOC of source). Foundations are obvious there; the registry is overkill.

---

## The signals

Three signals, computed per source file. Combine into a score; rank; surface the top of the list.

### Signal 1 — Afferent coupling (fan-in)

How many other files depend on this one. Foundations have many.

**Shell recipes** (run from project root; replace `src/` with the project's source dir):

| Language | Recipe |
|----------|--------|
| Python | `grep -rlE "(from\s+<module>|import\s+<module>)" src/ \| wc -l` |
| JS / TS | `grep -rlE "from\s+['\"]<path>['\"]\|require\(['\"]<path>['\"]\)" src/ \| wc -l` |
| Go | `grep -rl "<full-import-path>" --include="*.go" .` |
| Java / Kotlin | `grep -rlE "import\s+<fqn>" --include="*.java" --include="*.kt" .` |
| Rust | `grep -rlE "use\s+<path>" --include="*.rs" src/` |

**Limits.** Misses re-exports, barrel files, dynamic imports, reflection-loaded modules, build-time codegen. A grep-based count is a *lower bound*. Flag anything with confidence < high if exact precision matters.

### Signal 2 — Cross-feature usage

How many distinct feature folders import this file. A file imported 40 times within one feature is a *feature internal*. A file imported 5 times across 5 features is a *foundation*.

**Step 1 — identify feature folders.** Top-level dirs under `src/` (or `app/`, or `packages/*/src/`) that are *not* in this stop-list:

```
core, shared, lib, libs, utils, util, common, helpers, internal, base, foundation, foundations
```

Plus exclude: `tests`, `test`, `__tests__`, `node_modules`, `vendor`, `dist`, `build`.

**Step 2 — for each candidate file, count distinct feature folders containing importers:**

```bash
grep -rlE "<import-pattern>" src/ \
  | awk -F/ '{print $2}' \
  | sort -u \
  | wc -l
```

(Adjust `$2` to the column that holds the feature folder name for the project's layout.)

A foundation typically scores **≥ 2** distinct features. Single-feature usage (= 1) is a strong signal that the file is *not* foundational, regardless of fan-in.

### Signal 3 — Stability (change frequency)

Foundations are stable. Once they work, they change rarely while consumers churn on top.

```bash
git log --since=12.months --pretty=format: --name-only -- <file> | grep -c .
```

Result is the number of commits touching the file in the last year.

**Window guidance:**
- < 6 months of project history → use `--since=<project-age>`, halve all thresholds, drop confidence one level.
- > 24 months → use `--since=24.months` to avoid prehistoric noise.

**Excluded commits.** Add `--no-merges` to drop merge commits. Consider also excluding mass-rename commits via `--diff-filter=M`.

---

## The score

A minimum-viable formula that ranks reasonably across project sizes:

```
foundation_score = log(1 + fan_in)
                 * log(1 + distinct_features)
                 * stability_factor

where:
  stability_factor = 1 / (1 + change_count_last_year / 12)
                     # months-per-change, clamped
```

**Why log.** Fan-in and feature counts are long-tailed. Without log, one mega-imported utility drowns everything else.

**Why divide by churn.** A file imported everywhere but rewritten weekly is an architectural hotspot, not a stable foundation. The division pushes hotspots down the foundation list — they get surfaced separately (see failure modes below).

**Threshold.** Surface files with `foundation_score >= 1.0` *and* `distinct_features >= 2`. Tune by inspecting the top 20 on a sample project.

**Convention boost.** If the file lives in a conventional foundation directory (`core/`, `shared/`, `lib/`, `common/`, `internal/`), multiply the score by **1.2**. This nudges named-as-foundation files up the list without making naming a hard requirement.

---

## Failure modes

The same three signals identify three categories worth surfacing. Compute these alongside the foundation list — they're the most useful output of the scan.

| Category | fan_in | distinct_features | change_count | Action |
|----------|--------|-------------------|--------------|--------|
| **Foundation (healthy)** | high | high (≥ 2) | low | Add to `FOUNDATIONS.md` as `status: active` |
| **Architectural hotspot** | high | high (≥ 2) | high | Add to `FOUNDATIONS.md` as `status: active` with `health: hotspot`. Foundationtik (tikkit) will write a refactor ticket. |
| **Hidden foundation** | high | high (≥ 2) | low | High score, but **does not live in a conventional foundation directory** and may have a domain-feature-style name (e.g. `helpers.py`, `misc.ts`, `shared_stuff.py`). Add to registry; flag in chat: *"this file is acting as a foundation but isn't named like one — consider relocating to `core/`."* |
| **Pretender** | low | low (≤ 1) | any | Lives in `core/`/`shared/`/`lib/` but few or no cross-feature consumers. Surface as **out-of-band finding**, not a `FOUNDATIONS.md` row. Suggest inlining or moving back to a feature folder. |

### Detection rules

```
hotspot:           score above threshold AND change_count > median(change_count_for_top_quartile) * 2
hidden_foundation: score above threshold AND not in {core, shared, lib, common, internal, foundation*}
pretender:         file in {core, shared, lib, ...} AND foundation_score < 0.5
```

Hotspot vs. healthy is a **continuous** distinction — pick the top quartile of churn within the foundation set. Hidden vs. healthy is a **categorical** distinction by directory.

---

## Output format

For each scanned candidate, dockit produces an internal record:

```yaml
- path: src/services/helpers.py
  fan_in: 23
  distinct_features: 6
  change_count_12m: 3
  in_conventional_dir: false
  foundation_score: 4.21
  category: hidden_foundation
  confidence: high
```

The top-N records (where score ≥ threshold and category ∈ {foundation, hotspot, hidden_foundation}) become rows in `FOUNDATIONS.md`. Pretenders go into the dockit run report as **suggestions**, not registry rows.

### Confidence levels

| Level | Conditions |
|-------|------------|
| High | Score above threshold; ≥ 12 months of git history; ≥ 3 distinct features; fan-in ≥ 5 |
| Medium | Score above threshold but missing one of the above |
| Low | Marginal score, or git history < 6 months, or fan-in ≤ 3 |

Always show confidence to the user. Always ask before adding `Low`-confidence rows.

---

## When to ask the user

Halt and ask before proceeding if:

- **No feature folders detected.** The stop-list ate everything, or the project has a flat layout. Ask: *"What are the top-level feature directories in this project?"*
- **Project age < 6 months.** Behavioural signals are unreliable. Ask: *"Is this a new project? If yes, I'll skip the stability signal and rely on structural signals only."*
- **No files cross the threshold.** Either the project genuinely has no foundations yet, or detection missed (e.g., codegen-heavy or DI-container codebases). Ask: *"I didn't find clear foundation candidates. Is this a young codebase, or are foundations resolved at runtime (DI / plugin system)?"*
- **More than ~30 candidates above threshold.** Likely the threshold is too low for this project. Show the top 30 by score and ask: *"Where would you like me to cut the list?"*

---

## Exclusions

Always exclude from the scan:

- `tests/`, `test/`, `__tests__/`, `*_test.py`, `*.test.ts`, `*.spec.ts`
- `node_modules/`, `vendor/`, `target/`, `dist/`, `build/`, `.next/`, `__pycache__/`
- Generated code: anything under a `generated/`, `gen/`, `proto/` directory; files with a `# DO NOT EDIT` or `// generated` header
- Vendored / third-party: anything under `third_party/`, `external/`

Files that fail these exclusions can have absurdly high fan-in and pollute the ranking.

---

## Worked example

Project: a Python + React monorepo.

```bash
# Step 1 — find feature dirs
ls src/ | grep -vE '^(core|shared|lib|utils|common|tests?)$'
# → api/ tasks/ workspaces/ users/ websockets/

# Step 2 — score every .py under src/
for f in $(find src -name "*.py" -not -path "*/tests/*"); do
  fan_in=$(grep -rlE "(from|import).* $(echo $f | sed 's|src/||;s|.py$||;s|/|.|g')" src/ | wc -l)
  features=$(grep -rlE ... | awk -F/ '{print $2}' | sort -u | wc -l)
  changes=$(git log --since=12.months --pretty=format: --name-only -- $f | grep -c .)
  ...
done
```

Top results:

| path | fan_in | features | changes | category |
|------|--------|----------|---------|----------|
| `src/core/database.py` | 28 | 4 | 2 | foundation |
| `src/core/auth.py` | 24 | 4 | 1 | foundation |
| `src/services/helpers.py` | 19 | 5 | 3 | **hidden_foundation** |
| `src/core/notifications.py` | 22 | 3 | 14 | **hotspot** |
| `src/core/legacy_session.py` | 1 | 1 | 0 | **pretender** |

dockit writes the first four into `FOUNDATIONS.md`. The pretender goes into the report as a finding: *"`src/core/legacy_session.py` lives in `core/` but is only imported once. Consider inlining or relocating."*

---

## Cross-doc consistency check

When `sync` re-scores foundations and a foundation's category changes (active → pretender, active → sunset, or removed entirely), other docs may reference it in stale ways. Run this check after every sync.

### What to scan

| Doc | Why |
|-----|-----|
| `PRINCIPLES.md` | "Always use `<foundation>`" rules become invalid when the foundation is demoted |
| `ARCHITECTURE.md` | Component tables, diagram node labels, design-decision rows |
| `docs/architecture/foundations/*.md` | Sub-doc per foundation (large projects); may need deletion if foundation is removed |
| Any other doc under `docs/` containing the foundation's path or module name | Catches forgotten mentions |

### Recipes

For each demoted/removed foundation, run:

```bash
# Search for module-style references (e.g. "core.notifications")
grep -rn "<module-name>" docs/ README.md

# Search for path-style references (e.g. "app/core/notifications")
grep -rn "<path-without-extension>" docs/ README.md
```

Both are needed — module name catches imports and prose, path catches code blocks and component tables.

### How to act on hits

- **PRINCIPLES.md hit:** likely a *rule* citing the foundation. Ask the user whether the rule still applies (without this foundation), should be reworded, or removed entirely.
- **ARCHITECTURE.md hit:** likely a *table row* or *diagram node*. For tables, can usually be auto-removed (code-derived). For diagram nodes, ask before removing — diagrams are easier to break than tables.
- **Sub-doc hit (`docs/architecture/foundations/<name>.md`):** the entire sub-doc is now stale. If the foundation was *demoted* (still exists, just demoted to pretender), keep the file but flag with `[TODO: foundation demoted; review]`. If the foundation was *removed*, delete the file.

### Output to user

Don't silently rewrite — list every hit and prompt:

```
Foundation `core.notifications` demoted: active → pretender

Found references:
  - PRINCIPLES.md:47   "Always publish via core.notifications"
  - ARCHITECTURE.md:91 component table row
  - docs/architecture/foundations/core-notifications.md (entire file)

For each, [u]pdate / [r]emove / [t]ag with TODO / [s]kip?
```

This is the same prompt-shape sync uses for prose-heavy section deletions — keep the UX consistent.

---

## References

- Adam Tornhill — *Software Design X-Rays* (Pragmatic Bookshelf). Behavioural code analysis from git history. Methodology behind CodeScene.
- Robert C. Martin — *Clean Architecture* and ["Granularity"](https://www.cs.umd.edu/class/spring2003/cmsc838p/Design/granularity.pdf) paper. Stable Abstractions Principle, Stable Dependencies Principle, the "main sequence."
- Wikipedia — [Software package metrics](https://en.wikipedia.org/wiki/Software_package_metrics). Definitions of Ca, Ce, instability `I = Ce/(Ca+Ce)`.
- Sandi Metz — [The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction). Why hotspot foundations should sometimes be inlined and rebuilt.
