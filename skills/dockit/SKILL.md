---
name: dockit
description: 'Generate, update, and maintain project documentation. Use when asked to: create/write/add docs, generate/make/write a README, setup documentation, document this/my project/codebase, fill in docs, check doc freshness, explain doc structure, sync docs with code, verify docs against code, cross-reference docs with codebase, or run a deep/full scan of everything. Modes: init, sync (add --deep for a whole-repo scan), check, migrate, diagrams. Auto-detects frameworks and scales by project size.'
user-invocable: true
---

# dockit

Generate and maintain project documentation that humans read and that downstream AI tools (agentkit, plus any agent that loads the project's docs as context) consume as their context layer.

**Modes:** `init` | `sync` (`--deep`) | `check` | `migrate` | `diagrams`

**Frameworks:** Wagtail (dedicated module), others use `_default.md` (auto-detected)

**Generates:** README, ARCHITECTURE, PRINCIPLES, FOUNDATIONS, ENVIRONMENTS, CLOUD, TROUBLESHOOTING, CONTRIBUTING

**Scales:** Small (3 docs) → Medium (6 docs) → Large (7+ with sub-docs)

> For full structure details, ask "explain dockit structure" or see [`references/DOC-MAP.md`](references/DOC-MAP.md)

---

## Core Principle: Docs Describe What *Is*

Documentation reflects the **current state** of the code. It is not a changelog, not a tombstone, not a memory of what used to exist. Git history and release notes serve those purposes — duplicating them in docs adds clutter that developers skim past.

### Delete authority: derivability, not authorship

Before the mode-specific rules, one rule governs every mode: **dockit may delete only what it can regenerate.**

Not "only what dockit wrote" — authorship isn't observable. Dockit generated the file, a human edited it, another agent edited it in some unrelated session, and one person committed all of it. Nothing in the repo records who authored a line, and authorship is the wrong question anyway: an AI-drafted rationale a human read and kept is worth exactly as much as a hand-written one.

Derivability is observable, and it sorts content into three tiers:

| Tier | Examples | Authority |
|------|----------|-----------|
| **Generated artifact** | Foundation catalog table, consumers, dependencies, findings, command tables, env var lists, API endpoints, diagrams | Regenerate freely — **except where a human has edited it**, see below |
| **Checkable claim** | Prose asserting something about the code: "all handlers return `Result`", "auth lives in `src/auth/`" | The code arbitrates. Fix or delete when it contradicts |
| **No checkable claim** | Team notes, an unrecognized heading, a file dockit didn't create | Don't touch. **Report it** every run so a human can decide |

Three mechanics make this real rather than aspirational:

- **Generate, then swap.** Never a bare delete. Produce the replacement first; if it can't be produced, the content wasn't derivable and isn't yours to remove.
- **Anchor on the artifact, not the heading.** Replace *this table*, *this diagram*, *this list* — never the whole span between two headings. A human's two paragraphs under `## Commands` are the most common loss, and the section still looks correct afterward. If the artifact's boundary can't be identified, skip it and report; do not fall back to the span.
- **Diff before overwriting, because "regenerable" describes the artifact, not the edits in it.** "Sync can rebuild this table" is true of the rows dockit derives and false of a column someone added, a footnote under it, or a row they corrected by hand. That content is neither incorrect nor contradicting, so tier 1 does not authorise removing it. Regenerate into a scratch copy, diff against what's on disk, and account for every difference: changes explained by a code change are applied; anything else — an extra column, an annotation, a deliberate ordering — is carried across, or surfaced in the report when it can't be carried across mechanically. Silent overwrite is the failure this prevents; the section still looks right afterward, which is why nobody catches it.
- **Protected is not silent.** Tier-3 content appears in the `Untouched` block of every run's report ([Phase 5](#phase-5-validate--report)). Never deleting it is not the same as pretending it's fine — surfacing it is how a human gets the chance to cut it, and without that, protection becomes a ratchet where nothing improves.

One inherited caveat, already established for mined rules ([Mined rules are exempt from removal](#explicit-modes)): a doc that disagrees with the code may be right, and the code may be the bug. "All handlers return `Result`" with three that don't might be reporting a defect, not rotting. Flag those; don't quietly edit docs into agreement with broken code.

The mode-specific rules below apply that authority to each situation:

### Restructuring (init / migrate): Never destroy information

When reshuffling existing docs across files, **information must not be lost** — only relocated.

- **MIGRATE** team-specific content (VMs, corporate auth, security configs) to appropriate docs
- **KEEP** specifics even if they seem sensitive — most repos have restricted access
- **WARN** users about potentially sensitive content, but don't remove it
- **PRESERVE** the team's way of doing things (ENVIRONMENTS.md can have many approaches)

Routing examples:
- VM setup instructions → ENVIRONMENTS.md
- Corporate SSO/VPN auth → ENVIRONMENTS.md
- Security configurations → ENVIRONMENTS.md or CLOUD.md
- Team-specific workflows → CONTRIBUTING.md or PRINCIPLES.md

**Write no migration log.** A `MIGRATION-NOTES.md` is a tombstone by another name: it describes a state the repo is no longer in, and the restructure commit already records every move. The move list is still valuable — it belongs in the conversation, reported in full once the work is done (see [Phase 5](#phase-5-validate--report)), where the user can review it and ask for an amendment. A report you can reply to beats a file you can only read.

### Syncing (sync): Remove docs for removed code

When sync detects that a feature, module, command, env var, or service has been removed from the codebase:

- **DELETE** the corresponding doc section. The feature is gone; documenting its absence is noise.
- **DO NOT** leave tombstones like "*X was removed in v2*", "*no longer supported*", or "*this used to live in `foo/`*". The thing is gone; documenting its absence belongs in the changelog/git history.
- **DO** keep status markers for things that still exist. "*Deprecated — use `NewClient` instead; removed in v3*" is **current state, not a tombstone**, and on a public API or a shared internal module it is often the most valuable line on the page. The test is existence, not tense: **still in the code → document its status. Gone from the code → delete the section.**
- **DO NOT** write a removal or migration log anywhere under `docs/` — no "what changed" file, no notes doc, no appended table. Removals are reported in chat; git records the rest.
- **REPORT** removals in the chat completion summary (see [Phase 5](#phase-5-validate--report)) so the user can confirm. The conversation is the right place for "I removed X" — the docs are not.
- **ASK FIRST** before deleting prose that isn't regenerable (multi-paragraph narrative, design notes, lessons-learned). Prose can't be rebuilt, so it may hold intentional context worth keeping even after the code is gone. Untouched generated artifacts — command tables, env var lists, API endpoints, diagrams — are removed without prompting, since sync can rebuild them. One where a human has added a column, a note, or a hand-corrected row is not untouched: diff first and carry the edit across or surface it ([Delete authority](#delete-authority-derivability-not-authorship)).
- **NEVER** delete a heading dockit doesn't recognize, or a file dockit didn't create. Sync has no procedure to regenerate either one, so neither is sync's to remove — report them instead.

#### Foundation cross-doc consistency

When a foundation changes status during sync — `active → pretender`, `active → sunset`, or removed entirely — references to it in other docs become stale. Sync must check:

- `PRINCIPLES.md` — search for the foundation's path (`app/core/notifications`) and module name (`core.notifications`). Hits are likely "use this foundation" patterns that may now be invalid.
- `ARCHITECTURE.md` — same search. Hits are likely component-table rows or diagram nodes.
- Any sub-doc under `architecture/` or `architecture/foundations/`. (There is no `principles/` sub-doc directory — PRINCIPLES.md links to code, never to a second level of principles.)

For each hit, **ASK** the user:
> *"`core.notifications` was demoted to a pretender. Found a reference in `PRINCIPLES.md` line 47 ('Always publish via core.notifications'). Update, remove, or leave with `[TODO: review]`?"*

Don't auto-remove — these are usually principle-level claims with prose around them. Surface and prompt.

See [FOUNDATIONS-DETECTION.md](./references/guides/FOUNDATIONS-DETECTION.md) § "Cross-doc consistency check" for the grep recipes.

---

## Usage

```
/dockit
```

Auto-detects what to do based on project state.

### Auto-Detection

Explicit user intent (e.g. "run sync", "migrate", "scan everything") always wins over the state-based rules below. Only fall through to detection when the user is non-specific.

| Condition | Action |
|-----------|--------|
| No docs/ or README.md | → init |
| CI environment | → check |
| Git changes since docs | → sync |
| Docs exist, wrong structure | → suggest migrate |
| User asks to verify/cross-reference docs, or for a deep/full scan or "everything" | → `sync --deep` |
| Docs current | → "Up to date" |

### Explicit Modes

| Mode | Flow | Prompts? | Destructive? |
|------|------|----------|--------------|
| `init` | Questions → Plan → Confirm → Generate all docs from templates | Yes | Can restructure — **additive only when existing docs show structural integrity** |
| `sync` | Git diff → update stale sections → re-run stored predicates → regenerate diagrams if needed; removes docs for removed code | Only for prose-heavy deletions | Removes code-derived sections for removed features — **never a mined rule** (see below) |
| `check` | Detect drift → exit 0 (current) or exit 1 (stale) | No | Read-only |
| `sync --deep` | Everything `sync` does, plus a whole-repo pass: verify every doc reference resolves · catch silently-passing predicates · find code documented nowhere · re-apply the mining filters to existing rules. See [DEEP-SCAN.md](./references/guides/DEEP-SCAN.md) | Same as sync | Same as sync — the four extra checks are report-only |
| `migrate` | Questions → Plan → Confirm → merge into existing files | Yes | Can restructure |
| `diagrams` | Generate/update mermaid diagrams only | No | Updates diagrams only |

**Read-only modes:** `check`
**Auto-write modes** (no prompts for routine changes): `sync`, `diagrams`
**Interactive modes** (prompts, can restructure): `init`, `migrate`

> **`--deep` is a flag, not a mode.** Normal `sync` is diff-scoped and fast enough to run after every change; `--deep` reads every doc, every predicate, and every source file. Four checks only work at whole-repo scope — a broken path appears when *code* moves rather than when a doc changes; a silently-passing predicate is indistinguishable from a working one; undocumented code never shows up in a doc diff; and docs predating a filter were never tested against it. Trigger it on an explicit flag or on words like "deep", "full", "everything", "scan the whole repo". Never run it implicitly — it's slow, and normal sync is the right default.

> Sync removes doc sections when the underlying code is gone — see "Syncing: Remove docs for removed code" above. Removals are reported in the chat summary, not left as tombstones in the docs.

> **Predicates follow a fixed grammar.** Before running any `dockit:check` / `dockit:conform` command, check it against the grammar in [CHOICE-MINING.md § Predicate grammar](./references/guides/CHOICE-MINING.md#predicate-grammar) — read-only commands, no shell operators, no interpreters. A command that fails the grammar is flagged and left unverified, never run. Dockit keeps no approval file; execution is the runtime's call.

> **Mined rules are exempt from removal.** On sync, re-run every `dockit:check` / `dockit:conform` predicate in PRINCIPLES.md and the foundation entries. A failing predicate is **flagged, never deleted** — a decayed count means either the rule is wrong or the code is drifting away from a correct rule, and nothing in the evidence distinguishes those. Deleting on failure would quietly strip correct rules exactly when a codebase is going bad. Report the failure and let a human decide. See [CHOICE-MINING.md](./references/guides/CHOICE-MINING.md).

---

## Execution Flow

### Phase 1: Analyze

1. Auto-detect mode from project state
2. Detect framework (see `frameworks/_index.md`)
3. Detect project size (see [Project Scaling](#project-scaling))
4. Detect project name and description — see [DETECTION.md](./references/guides/DETECTION.md)
5. Load framework module or `_default.md`
6. Extract commands from package.json, Makefile, pyproject.toml
7. Discover environment variables — see [DETECTION.md](./references/guides/DETECTION.md)
8. Check for SDD artifacts — `.specify/memory/constitution.md`, `openspec/project.md`, `conductor/workflow.md`, `conductor/product-guidelines.md`. Read for comparison only; never write to them
9. Decide the generation posture — **documented** (a `docs/` dir exists, or README is >~50 lines of real content) or **doc-barren**. Strict overview ban applies only to documented repos; on a barren repo, generated orientation prose is the measured-helpful case. See [CHOICE-MINING.md § The overview ban is conditional](./references/guides/CHOICE-MINING.md#the-overview-ban-is-conditional--check-before-applying-it)

9b. Assess **structural integrity** — do the docs that exist actually work as a structure? Judge what exists, never what's missing; a repo documented in one well-organised README is fully documented. Sets the Phase 3 default. Signals and the distinction from step 9 are in [DETECTION.md § Structural Integrity](./references/guides/DETECTION.md#structural-integrity)
10. Mine choices for PRINCIPLES.md — see [CHOICE-MINING.md](./references/guides/CHOICE-MINING.md). Run both filters (name the rejected alternative; skip anything a linter enforces) before writing any line, attach a stored predicate to each one, and check the file against its size budget
11. Scan for foundations (medium/large only) — see [FOUNDATIONS-DETECTION.md](./references/guides/FOUNDATIONS-DETECTION.md). Score every source file by fan-in × cross-feature × stability; categorise as foundation / hotspot / hidden / pretender. Skipped on small projects.

### Phase 2: Questions

Ask clarifying questions BEFORE showing plan (max 3-5). Only ask what can't be auto-detected. Skip if confident.

**Don't ask for** project name, project description, framework, or project size. Each of these is reliably auto-detectable from package manifests, file extensions, and project shape (see Phase 1). Asking the user wastes a turn and signals the skill isn't pulling its weight — they invoked dockit *because* they don't want to spell out what's already in their `package.json`.

### Phase 3: Plan & Confirm

The structural-integrity assessment (Phase 1, step 9b) decides which option leads:

| Assessment | Option order | Rationale |
|------------|--------------|-----------|
| **Integrity present** | Additive first | They have a working structure; fill its gaps, leave the shape |
| **Integrity absent** | Restructure first | Sprawl or a stub — the case dockit's opinion exists to fix |

```
Option 1: Keep the existing doc structure — add only missing sections and files
Option 2: Full restructure per dockit templates
Option 3: Exit without changes
```

All three are always offered; only which one leads changes.

**Option 1 means their idiom, not dockit's.** Additive is not "restructure, slowly" — a new file dropped in dockit's shape beside their existing docs is a partial restructure they declined. So when Option 1 is chosen:

- **Write into their locations and their names.** Docs in `documentation/`? New files go there. They call it `SETUP.md` rather than `ENVIRONMENTS.md`? Add the missing content to `SETUP.md`. Match their heading style and depth.
- **Prefer a section in an existing file over a new file.** Only add a file when no existing doc has a plausible home for the content.
- **Add coverage, not conformance.** The gap worth filling is a topic nobody documented — deployment, environment setup, foundations. A topic they covered under a different name is not a gap.
- **Their structure is now the contract.** Later runs read it as the project's shape; don't drift back toward the templates one file at a time.

**Where a genuine tie lands: restructure.** Dockit's structure is derived from research, and applying it costs a reorganized file tree — not lost content, because restructuring relocates and reports every move ([Restructuring](#restructuring-init--migrate-never-destroy-information)). Deferring instead leaves a team with the sprawl they came to dockit to fix. Opinionated about shape, conservative about substance — that's the product.

**The choice is behavioral, not stored.** Dockit writes no config (see [Templates](#templates)), so nothing records "this team said no." The integrity assessment is re-run every time instead — and it is self-correcting: once dockit has restructured a repo, that repo now *has* structural integrity, so later runs assess it as integrity-present and go additive on their own. A team that declines a restructure and keeps their own shape will be re-offered it, which is the correct behaviour for an opinionated tool, not a bug to suppress.

This is a coarse choice about approach, not a per-move gate. The detailed account of what happened comes after the work, in [Phase 5](#phase-5-validate--report).

### Phase 4: Execute & Generate

Run the per-mode flow from the [Explicit Modes](#explicit-modes) table above. Generation is scaled to project size — see [Project Scaling](#project-scaling) below for which docs each tier produces.

When filling sections in `init` / `migrate` / `sync`, apply the **Earn the Heading** rule: a section's body must answer a question that requires reading multiple files or talking to a human. If the answer is recoverable from a single source file in 60 seconds, the section's body is redundant — leave the heading (the section name is a contract for downstream consumers) and write `[TODO: <question>]` underneath instead of synthesizing filler. Surface those `[TODO:]` markers in the completion report as "consider adding" prompts. See [WRITING-GUIDE.md § Earn the Heading](./references/guides/WRITING-GUIDE.md#earn-the-heading) for the full rule, examples, and the derivable-vs-non-derivable rubric.

### Phase 5: Validate & Report

1. Cross-link all docs
2. Validate markdown syntax
3. List remaining `[TODO:]` markers
3b. **Report the review queue** — the human-required work this run produced: conventions written at 80–99% conformance, empty `[TODO: why?]` slots, `[TODO: known hazard?]` questions on foundations that are new or newly a hotspot, `Doesn't cover:` intent questions, failed predicates awaiting the doc-wrong-or-code-drifting call, and SDD-artifact discrepancies. `/repokit status` reads this list. Best-practice observations (no tests on a foundation, duplicated retry logic, no scaffold path) go here too — **in chat only, never written into the docs**, since a generic recommendation sitting in a project's own documentation reads to the next agent as a decision the team made
4. **Report the run in chat** (never in docs), on **every mode that writes** — `init`, `migrate`, `sync`, `diagrams`. Changes are already applied, so this is the review pass: the user scans it, spots something they didn't expect, and asks for an amendment next turn. It's also the only place tier-3 content surfaces, which is what keeps "never delete it" from meaning "never mention it."

   Three blocks. `Moved` appears on restructures only; `Removed` and `Untouched` appear on every run, and say "none" rather than being omitted — an absent block is indistinguishable from a block nobody generated.

   ```
   Moved:
     README.md "System requirements"  → ENVIRONMENTS.md
     README.md "Architecture diagram" → ARCHITECTURE.md

   Removed:
     ARCHITECTURE.md → "LDAP Auth" section (module deleted: src/auth/ldap.py)
     README.md       → `--legacy-mode` flag (removed from CLI)

   Untouched (no checkable claim — yours to keep or cut):
     README.md            "Notes from the 2024 audit"
     docs/scratch-perf.md (whole file — dockit didn't create it)
     + 14 more across docs/architecture/ — ask to list them

   Anything here look wrong? Say so and I'll put it back or move it elsewhere.
   ```

   Four rules for this report:
   - **Name every change, never a count.** "Removed 4 stale sections" can't be reviewed, and reviewing it is the entire point. This binds `Moved` and `Removed` without exception — they're actions dockit took, and the user can only catch a mistake they can see.
   - **Group the `Untouched` block once it exceeds ~10 lines.** Counts are acceptable *here* and nowhere else, because this block lists things dockit deliberately did nothing to. A wall of untouched content trains the user to skip the whole report, which would cost them the two blocks that matter. Show the most recently modified, collapse the rest by directory, offer the full list on request.
   - **`Untouched` is not filler.** It's how the user confirms their non-conforming content survived, and how tier-3 content gets a chance to be deliberately cut rather than quietly accumulating. Silence about it reads as loss.
   - **Close with the amendment offer.** A report the user can act on is the whole reason this isn't a file.

5. Show completion report with next steps

---

## Project Scaling

Detect project size and adjust documentation accordingly.

| Size | Docs | Foundations? | Guide |
|------|------|--------------|-------|
| **Small** (≤20 files, single service) | README + 2 docs | No — foundations are obvious at this size | [SIZE-SMALL.md](./references/guides/SIZE-SMALL.md) |
| **Medium** (20-50 files, framework + DB) | README + 5 docs + FOUNDATIONS | Yes — flat catalog | [SIZE-MEDIUM.md](./references/guides/SIZE-MEDIUM.md) |
| **Large** (>50 files, monorepo, teams) | README + 7+ docs + sub-docs + FOUNDATIONS | Yes — catalog + per-foundation sub-docs under `architecture/foundations/` | [SIZE-LARGE.md](./references/guides/SIZE-LARGE.md) |

See guides for detection logic and document structure details.

**These counts describe topics to cover, not filenames to create.** They apply as written on a restructure or a greenfield repo. Under Phase 3 Option 1, map each one onto the team's existing docs first — their `SETUP.md` satisfies the environments slot, a `docs/adr/` tree may satisfy principles — and add a file only where a topic genuinely has no home. A tier that "isn't complete" because their filenames differ is complete.

---

## Detailed Guides

| Guide | Purpose |
|-------|---------|
| [SIZE-SMALL.md](./references/guides/SIZE-SMALL.md) | Small project documentation structure |
| [SIZE-MEDIUM.md](./references/guides/SIZE-MEDIUM.md) | Medium project documentation structure |
| [SIZE-LARGE.md](./references/guides/SIZE-LARGE.md) | Large project documentation structure |
| [WRITING-GUIDE.md](./references/guides/WRITING-GUIDE.md) | How to write explanatory documentation |
| [CHOICE-MINING.md](./references/guides/CHOICE-MINING.md) | What may be written into PRINCIPLES.md and foundation entries — the three bands, the Convention/Rule tiers, the two filters, stored predicates |
| [DIAGRAMS.md](./references/guides/DIAGRAMS.md) | Mermaid diagram standards |
| [DEEP-SCAN.md](./references/guides/DEEP-SCAN.md) | The `sync --deep` whole-repo pass — reference verification, predicate quality, undocumented code, filter re-application |
| [DETECTION.md](./references/guides/DETECTION.md) | Project name, description, and env var discovery; structural-integrity signals for the Phase 3 default |
| [FOUNDATIONS-DETECTION.md](./references/guides/FOUNDATIONS-DETECTION.md) | How to find foundational code via fan-in, cross-feature usage, and git stability |
| [GIT-HOOKS.md](./references/guides/GIT-HOOKS.md) | CI/pre-commit integration |

---

## Templates

Two sources, framework first:

1. `references/templates/[framework]/[file]` — framework-specific
2. `references/templates/core/[file]` — default fallback

**There is no per-project override, and dockit writes no config directory.** A template only shapes a doc's first generation; from then on sync preserves prose and updates code-derived sections in place, so editing the generated doc once achieves what an override would. A team wanting a house doc shape across many repos should ship its own `templates/core/`, not copy an override file into every project.

---

## Git Integration

See [GIT-HOOKS.md](./references/guides/GIT-HOOKS.md) for full CI/pre-commit integration.

### Change Detection

```bash
LAST_SYNC=$(git log -1 --format=%H -- docs/ README.md)
CHANGED=$(git diff --name-only $LAST_SYNC HEAD)
```

| Changed Files | Update |
|---------------|--------|
| package.json, pyproject.toml | README.md |
| src/, lib/, app/ | ARCHITECTURE.md + diagrams |
| src/core/, src/shared/, src/lib/, packages/*/src/ | FOUNDATIONS.md (re-score; refresh table, consumers, findings) |
| .env*, config/ | ENVIRONMENTS.md |
| infra/, .github/ | CLOUD.md |
| .specify/memory/constitution.md, openspec/project.md, conductor/workflow.md | PRINCIPLES.md — **compare and report only**, never merge |

---

## Spec-Driven-Development Artifacts: Compare, Never Merge

Projects using an SDD framework carry a file of conventions alongside dockit's own. **Read it, compare it, report the delta — write to none of them.**

| Framework | Artifact |
|-----------|----------|
| SpecKit | `.specify/memory/constitution.md` |
| OpenSpec | `openspec/project.md` |
| Conductor | `conductor/workflow.md`, `conductor/product-guidelines.md` |

These files are themselves usually agent-generated from the same codebase, which puts them in the same epistemic class as a mined convention — no better evidenced, subject to the same drift. Neither side is authoritative, so neither may overwrite the other. Letting one win destroys the other's content on every sync and launders generated text into apparent authority.

`conductor/code_styleguides/` is out of scope — a formatter enforces that content, so it fails the machine-enforced filter in [CHOICE-MINING.md](./references/guides/CHOICE-MINING.md).

On sync, report the three-way delta and stop:

```
SDD artifact: .specify/memory/constitution.md

  Only upstream:   "Prefer composition over inheritance"   → adopt as a Rule?
  Only local:      "Handlers return Result[T]"             → missing upstream?
  Conflict:        upstream requires 90% coverage; PRINCIPLES.md says 80%
```

| Scenario | Behavior |
|----------|----------|
| Artifact exists, no PRINCIPLES.md | Generate PRINCIPLES.md from the codebase as usual; report the artifact's contents as adoption candidates |
| Both exist | Compare, report the delta, change neither |
| Only PRINCIPLES.md | Nothing to compare |
| Neither | Generate from codebase |

---

## Sensitive Content Handling

**If content already exists in repo docs: PRESERVE IT.** Most repos have restricted access.

### Existing Content

If migrating docs that contain:
- Internal URLs, VPN/SSO instructions, corporate auth
- VM setup, infrastructure specifics
- Team-specific security configurations

**Action:** Move to appropriate doc (ENVIRONMENTS.md, CLOUD.md), warn user, but DO NOT delete.

### New Content

When generating new docs, warn user before including:
- Hardcoded secrets, API keys, credentials
- Production IP addresses or connection strings
- Personal information

**Action:** Add `[TODO: verify this should be documented]` marker and continue.

---

## Placeholders

| Token | Meaning |
|-------|---------|
| `[NAME]` | Required field |
| `[IF_X]...[ENDIF]` | Conditional section |
| `[REPEAT_FOR_X]...[END_REPEAT]` | Repeated section |
| `[TODO: desc]` | Needs manual input |

---

## Adding Frameworks

1. Add detection rule to `frameworks/_index.md`
2. Create `frameworks/[name].md` module
3. Create `templates/[name]/` folder
4. Add sample to `samples/[name]-project/`

Use `frameworks/_default.md` as template.

---

## Next Steps Output

After completion, recommend actionable next steps:

```
Next steps:
  1. Review generated docs for accuracy
  2. Fill in [TODO] markers
  3. Run setup commands:

     [FRAMEWORK_INIT_COMMANDS]
```

### Framework-specific commands

| Framework | Commands |
|-----------|----------|
| Django/Wagtail | `python manage.py migrate`, `createsuperuser`, `collectstatic` |
| Node | `npm install`, `npm run dev` |
| Python (general) | `pip install -e ".[dev]"`, `pytest` |

---

## Self-Explanation

When user asks about doc structure, topics, sizes, or "what docs do I need": read and present [`references/DOC-MAP.md`](references/DOC-MAP.md)
