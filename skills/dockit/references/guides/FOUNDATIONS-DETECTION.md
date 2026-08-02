# Foundations — Detection Guide

How dockit finds the foundational code in a project — even when it isn't named like a foundation, isn't living in `core/`, and the original author didn't realise they were creating one.

The premise: **a foundation is whatever the rest of the codebase actually depends on, regardless of where it lives or what it's called.** That's a measurable property — fan-in, cross-feature usage, and change stability — not a naming convention.

This guide produces input rows for `FOUNDATIONS.md`.

---

## When to use this guide

dockit runs this in two situations:

- **`init`** — first generation of `FOUNDATIONS.md`. Scan, score, propose top-N, ask the user to confirm.
- **`sync`** — refresh existing rows. Re-score, flag rows that changed category (foundation became hotspot, candidate became pretender, new hidden foundation appeared).

Skip this guide on **small projects** (one feature folder, < ~1k LOC of source). Foundations are obvious there; the registry is overkill.

---

## The signals

Four signals, computed per source file. Combine into a score; rank; surface the top of the list.

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

### Signal 1b — Inheritance fan-in (subclass count)

**Not all dependency edges mean the same thing.** An import says "this file calls that one." A subclass declaration says "this file *is* a specialization of that one, and every rule the parent enforces applies here." The second is a far stronger claim of foundational status, and counting it inside the import total buries it.

Count it separately.

**Step 1 — extract the types the candidate file defines:**

```bash
grep -oE "^\s*(class|abstract class|interface|trait|type)\s+\w+" <file> | awk '{print $NF}'
```

**Step 2 — for each type name, count declarations across the repo that specialize it:**

| Language | Recipe |
|----------|--------|
| Python | `grep -rhoE "class\s+\w+\([^)]*\b<Type>\b" src/ \| wc -l` |
| JS / TS | `grep -rhoE "class\s+\w+\s+extends\s+<Type>\b" src/ \| wc -l` |
| TS interfaces | `grep -rhoE "(interface\s+\w+\s+extends\|implements)\s+<Type>\b" src/ \| wc -l` |
| Java / Kotlin | `grep -rhoE "(extends\|implements\|:)\s+<Type>\b" --include="*.java" --include="*.kt" . \| wc -l` |
| Go (struct/interface embedding) | `grep -rhoE "^\s+\*?<Type>\s*$" --include="*.go" . \| wc -l` |
| Rust | `grep -rhoE "impl\s+(<[^>]*>\s+)?<Type>\s+for\b" --include="*.rs" src/ \| wc -l` |

Use `-o` and count *occurrences*, not files — one file can define several subclasses of the same base, and each is a separate consumer of the base's contract.

`subclass_count` is the maximum across the types the file defines. A file defining both a widely-inherited base and an unused helper scores on the base.

**Why this signal exists.** The key-class-detection literature (Zaidman & Demeyer 2008 onward; see References) converged on multi-type edge weighting — inheritance, instantiation, return-type, and call edges each carry a different weight — because treating them uniformly demonstrably loses the architecturally significant classes. Signal 1b is the cheap version of that finding.

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

A foundation typically scores **≥ 2** distinct features, and this used to be a hard filter. It no longer is, because it has a systematic blind spot: **a layer foundation.** A `BasePresenter` inherited by twelve presenters, or a `BaseDao` inherited by fifteen DAOs, has `distinct_features = 1` by construction — its consumers all live in the one directory whose shape it defines. Filtering on spread deletes exactly the class an agent most needs to know about.

Single-feature usage is now a **penalty carried in the score**, not an exclusion, with one explicit exemption (see The score). The bias runs deliberately toward recall: a candidate the user rejects costs one line of a confirmation prompt, and a foundation never surfaced costs every future agent that writes code around it.

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
reach = fan_in + 2 * subclass_count

foundation_score = log(1 + reach)
                 * log(1 + distinct_features)
                 * stability_factor
                 * convention_boost

where:
  stability_factor = 1 / (1 + change_count_last_year / 12)
                     # months-per-change, clamped
  convention_boost = 1.2 if the file lives in core/ shared/ lib/ common/ internal/
                     else 1.0
```

**Why log.** Fan-in and feature counts are long-tailed. Without log, one mega-imported utility drowns everything else.

**Why inheritance is weighted 2×.** A subclass inherits the parent's contract wholesale; an importer borrows one function. The weight is a coarse stand-in for the multi-type edge weighting the key-class literature uses. Note that a subclass also *imports* its parent, so it contributes to both terms — that double-count is intentional, not a bug.

**Why divide by churn.** A file imported everywhere but rewritten weekly is an architectural hotspot, not a stable foundation. The division pushes hotspots down the foundation list — they get surfaced separately (see failure modes below).

**Threshold.** Surface files with `foundation_score >= 1.0` **and** (`distinct_features >= 2` **or** `subclass_count >= 5`).

The second clause is the **layer-foundation exemption**. It admits a base class whose children all live in one directory, which the old `distinct_features >= 2` filter excluded outright. Worked case: a `BaseDao` with 12 subclasses in a single `dao/` package scores `reach = 12 + 24 = 36`, `log(37) × log(2) × 0.86 ≈ 2.15` — comfortably above threshold, and previously discarded by the gate before the score was ever consulted.

Tune the threshold by inspecting the top 20 on a sample project.

**Filename conventions are a tiebreaker, not a boost.** Files named `base.*`, `abstract.*`, `interface.*`, or `protocol.*` are usually foundational, and it is tempting to score them for it. Don't — the whole premise of this guide is that naming is the signal that fails in the projects most in need of help, and no key-class-detection method in the literature uses filenames. Use the name only to break a tie at the cut line: when two candidates score within ~10% of each other and only one fits in the top-N, prefer the conventionally-named one, and say in the prompt that the name broke the tie. A name may never put a file into the registry on its own.

---

## Failure modes

The same three signals identify three categories worth surfacing. Compute these alongside the foundation list — they're the most useful output of the scan.

| Category | reach | distinct_features | change_count | Action |
|----------|-------|-------------------|--------------|--------|
| **Foundation (healthy)** | high | high (≥ 2) | low | Add to `FOUNDATIONS.md` as `status: active` |
| **Architectural hotspot** | high | high (≥ 2) | high | Add to `FOUNDATIONS.md` as `status: active` with `health: hotspot`. Foundationtik (tikkit) will write a refactor ticket. |
| **Hidden foundation** | high | high (≥ 2) | low | High score, but **does not live in a conventional foundation directory** and may have a domain-feature-style name (e.g. `helpers.py`, `misc.ts`, `shared_stuff.py`). Add to registry; flag in chat: *"this file is acting as a foundation but isn't named like one — consider relocating to `core/`."* |
| **Layer foundation** | high, mostly inherited | 1 | low | Qualifies via the subclass exemption. Its consumers are one layer, and that layer's shape *is* what it defines. Add to `FOUNDATIONS.md` as `status: active`, `type: abstraction`, with the consuming directory in the `Consumers` column — that's what agentkit reads to decide which agent should own it. No new schema field: `abstraction` already means "interface / base class / pattern." |
| **Pretender** | low | low (≤ 1) | any | Lives in `core/`/`shared/`/`lib/` but few or no cross-feature consumers **and no subclasses**. Surface as **out-of-band finding**, not a `FOUNDATIONS.md` row. Suggest inlining or moving back to a feature folder. |

### Detection rules

```
hotspot:           score above threshold AND change_count > median(change_count_for_top_quartile) * 2
hidden_foundation: score above threshold AND not in {core, shared, lib, common, internal, foundation*}
layer_foundation:  score above threshold AND distinct_features == 1 AND subclass_count >= 5
pretender:         file in {core, shared, lib, ...} AND foundation_score < 0.5 AND subclass_count < 5
```

Hotspot vs. healthy is a **continuous** distinction — pick the top quartile of churn within the foundation set. Hidden vs. healthy is a **categorical** distinction by directory.

The `subclass_count < 5` clause on `pretender` matters: without it, an abstract base parked in `lib/` and inherited throughout one layer gets recommended for deletion. That is the most damaging false positive this guide can produce, because the suggestion sounds authoritative and the code is load-bearing.

---

## Output format

For each scanned candidate, dockit produces an internal record:

```yaml
- path: src/services/helpers.py
  fan_in: 23
  subclass_count: 0
  reach: 23
  distinct_features: 6
  change_count_12m: 3
  in_conventional_dir: false
  foundation_score: 4.21
  category: hidden_foundation
  confidence: high

- path: src/dao/base.py
  fan_in: 12
  subclass_count: 12        # signal 1b — all in src/dao/
  reach: 36
  distinct_features: 1      # exempted via subclass_count >= 5
  change_count_12m: 2
  in_conventional_dir: false
  foundation_score: 2.15
  category: layer_foundation
  consuming_layer: src/dao/
  confidence: medium        # single-feature spread caps confidence
```

The top-N records (where score ≥ threshold and category ∈ {foundation, hotspot, hidden_foundation, layer_foundation}) become rows in `FOUNDATIONS.md`. Pretenders go into the dockit run report as **suggestions**, not registry rows.

### Confidence levels

| Level | Conditions |
|-------|------------|
| High | Score above threshold; ≥ 12 months of git history; ≥ 3 distinct features; reach ≥ 5 |
| Medium | Score above threshold but missing one of the above — includes every `layer_foundation`, which by definition has one distinct feature |
| Low | Marginal score, or git history < 6 months, or reach ≤ 3 |

A `layer_foundation` caps at Medium and therefore always gets confirmed with the user before it becomes a row. That is the intended trade for relaxing the spread filter: more candidates surface, and the human does the final cut.

Always show confidence to the user. Always ask before adding `Low`-confidence rows.

---

## Mining the entry, once a foundation is confirmed

Scoring finds *which* code is foundational. Filling its entry is a second pass, and it reuses the same import data you already collected. Full rules — the tiers, the two filters, what may never be written — are in [CHOICE-MINING.md](./CHOICE-MINING.md); this section is only the hook into detection.

Three of the six choice families fall directly out of the scan:

**Boundary invariants (family 1)** — you already know the foundation's fan-in. Now invert the question: how many modules import the thing the foundation *wraps*, rather than the foundation itself?

```bash
# What third-party packages does the foundation import?
rg '^(from|import) (\w+)' app/core/cache.py -or '$2' | sort -u

# Who else imports them?
rg -l '^(from|import) redis' app/ --glob '!app/core/cache.py'
```

Zero hits outside the foundation is a boundary invariant with a ready-made predicate. A handful of hits is the exception list. Many hits means the wrapper is vestigial — say nothing, and report it as an observation.

**Structural conventions (family 2)** — the consumers table is the population. Count how many of them share a shape: the same dependency, the same return type, the same registration call. ≥80% conforming is a Convention with a `conform` predicate; below that, silence.

**Extension procedure (family 3)** — this is the `Extend by:` field, and git history answers it better than static analysis:

```bash
# Find commits that added an instance of this kind of thing
git log --diff-filter=A --format='%H' -- 'app/repositories/*.py' | head -5

# For each, what else changed in that commit?
git show --stat --format= <sha>
```

Intersect the file sets across the last few additions. Files appearing every time *are* the procedure. Cross-check against scaffold targets in `Makefile` / `package.json` scripts and any registry module whose body is a list of registered things.

**`Doesn't cover:`** is not scored — it's the residue. Consumers that reach past the foundation to the underlying library, or a sibling module handling an adjacent case, are the observable half. Write the observation, mark the intent question, and let a human answer it.

Two things the scan must not do: promote anything to the Rule tier, and fill in a `Why` block. Both are human-only.

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

| path | fan_in | subclasses | features | changes | category |
|------|--------|-----------|----------|---------|----------|
| `src/core/database.py` | 28 | 0 | 4 | 2 | foundation |
| `src/core/auth.py` | 24 | 0 | 4 | 1 | foundation |
| `src/services/helpers.py` | 19 | 0 | 5 | 3 | **hidden_foundation** |
| `src/core/notifications.py` | 22 | 0 | 3 | 14 | **hotspot** |
| `src/dao/base.py` | 12 | 12 | 1 | 2 | **layer_foundation** |
| `src/core/legacy_session.py` | 1 | 0 | 1 | 0 | **pretender** |

dockit writes the first five into `FOUNDATIONS.md`, confirming `src/dao/base.py` with the user first (Medium confidence). The pretender goes into the report as a finding: *"`src/core/legacy_session.py` lives in `core/` but is only imported once and has no subclasses. Consider inlining or relocating."*

`src/dao/base.py` is the row the previous version of this guide missed: it never reached the scoring step, because `distinct_features == 1` excluded it at the gate.

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

- Zaidman & Demeyer — ["Automatic identification of key classes in a software system using webmining techniques"](https://onlinelibrary.wiley.com/doi/abs/10.1002/smr.370), *JSME* 2008. Founding paper of key-class detection; importance as a measured graph property.
- Şora et al. — ["Finding key classes in object-oriented software systems by techniques based on static analysis"](https://www.sciencedirect.com/science/article/abs/pii/S0950584919301727), *IST* 2019. Graph-ranking over static dependency structure.
- ["Structure Entropy Weighted LeaderRank"](https://www.hindawi.com/journals/mpe/2020/9234042/), *MPE* 2020. Multi-type edge weighting — inheritance, instantiation, return-type, and call edges weighted separately. Basis for Signal 1b.
- Adam Tornhill — *Software Design X-Rays* (Pragmatic Bookshelf). Behavioural code analysis from git history. Methodology behind CodeScene.
- Robert C. Martin — *Clean Architecture* and ["Granularity"](https://www.cs.umd.edu/class/spring2003/cmsc838p/Design/granularity.pdf) paper. Stable Abstractions Principle, Stable Dependencies Principle, the "main sequence."
- Wikipedia — [Software package metrics](https://en.wikipedia.org/wiki/Software_package_metrics). Definitions of Ca, Ce, instability `I = Ce/(Ca+Ce)`.
- Sandi Metz — [The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction). Why hotspot foundations should sometimes be inlined and rebuilt.
