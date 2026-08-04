# Choice Mining

How dockit decides what to write into PRINCIPLES.md and into foundation entries — and what it must leave to a human.

> Companion to [WRITING-GUIDE.md § Earn the Heading](./WRITING-GUIDE.md#earn-the-heading). Earn the Heading says what to **cut**. This guide says what to **add**.

---

## The three bands

Every statement you could write about a codebase falls into one of three kinds. They are not equally worth writing.

| Band | What it is | Generate? |
|------|-----------|-----------|
| **Overview** | What the code does. `SearchClient` wraps the vendor SDK, handles auth, parses responses. | **No** — the agent gets this by reading the file. Only permitted compressed to a one-line pointer. |
| **Choice** | What the team settled on. "Use `SearchClient` for all vendor search." | **Yes** — this is the whole job. |
| **Rationale** | Why, and what was rejected. "Raw SDK calls leaked retry logic and broke during a vendor migration." | **Never** — not recoverable from code. Leave the slot open. |

### The overview ban is conditional — check before applying it

The evidence against generated overview was measured on repos that **already had documentation**. There, a generated summary duplicates what the agent could read for itself and costs tokens for nothing. On a repo with no docs, the same study found generated context *helped* — there was nothing else to read.

So check first, and pick a posture:

| Repo state | Detection | Posture |
|---|---|---|
| **Documented** | A `docs/` directory exists, or `README.md` is more than ~50 lines of real content | Strict. Overview only as one-line pointers. Everything in this guide applies as written. |
| **Doc-barren** | No `docs/`, and `README.md` is missing, a stub, or generated boilerplate | Relaxed. Write the fuller purpose and architecture prose an orientation needs. |

In the relaxed posture, say so in the run report: *"No existing docs found — generated fuller overview prose. Re-run sync once you've curated it and I'll tighten to pointers."* The next sync on a now-documented repo applies the strict rule and reports what it would cut.

**Two things do not relax, ever.** Rationale is still never invented — a barren repo is exactly where a plausible-sounding reason is most likely to survive unchallenged. And mined choices still enter at the Convention tier, still measured against their family's threshold before being written; a repo having no docs says nothing about whether a pattern was intentional.

Choice is the target because it's the only band that is simultaneously *novel* to the agent, *action-changing right now*, and *cheap to state*. Overview fails novelty. Rationale fails immediacy — it matters only when someone reopens the decision.

The economic argument: a choice is **derivable at a cost**. The import graph does contain "use the wrapper," but no agent walks the import graph before writing its first line — under task pressure it skips discovery and builds bespoke. Mining pays that discovery cost once and converts it into a line every future session reads for free.

### Same fact, three ways

> **Overview** — don't write it
> "`search/client.py` provides an abstraction over the vendor search SDK, handling authentication, request construction, and response parsing."

> **Choice** — write this
> "Use `SearchClient` (`search/client.py`) for all vendor-search operations."

> **Rationale** — leave it open for a human
> `[TODO: why?]`

---

## The two tiers

Mined statements are not all equally binding, and rendering them in one voice is how a coincidence gets promoted to law without anyone deciding it.

| Tier | Means | Who writes it |
|------|-------|---------------|
| **Convention** | How it's done here. Follow by default; deviating is fine with a stated reason. | dockit, freely |
| **Rule** | Deviating is a defect. | Humans only |

**dockit writes only Convention.** Promotion to Rule is always a human act. A wrong Convention costs a bit of misplaced consistency; a wrong Rule blocks correct work and breeds workarounds. That asymmetry is why the line is drawn here rather than behind a confirmation gate — a gate that blocks generation until someone drains a queue is a gate nobody uses twice.

The tiers do nothing unless the file declares them. Every generated PRINCIPLES.md and FOUNDATIONS.md opens with the legend verbatim:

```markdown
> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.
```

Without those two lines an agent reads the whole file as undifferentiated instruction and the tier is decoration.

> **This block is the canonical wording.** It's reproduced in `PRINCIPLES.template.md`, `FOUNDATIONS.template.md`, and every generated doc — templates need the literal text because consuming projects don't ship this guide. When changing it, change it here first and propagate; two files disagreeing about what "Convention" permits is worse than either wording alone.
>
> One copy is *deliberately* different: `agentkit`'s `foundation-agent.template.md` expands the same two definitions into behavioural instructions for an agent ("do not block them"). That's an elaboration, not a competing definition — don't collapse it back to match.

---

## What you may write without asking

Trust tracks one thing: **is this a measurement, or a judgment about intent?**

| Write it | Why |
|---|---|
| Any rule whose measurement clears its family threshold | Not a judgment. The scan finds 0 direct SDK imports, so the statement is true of the code today. |
| `Extend by:` backed by a scaffold command that exists and a git history showing it used | Mechanical. |
| Canonical example selection | Worst case you picked the second-best example. |
| Catalog rows, paths, consumers, counts | Already automatic. |

| Write it, but flag it in the report | Why |
|---|---|
| Conventions at 80–99% | Someone has to judge whether the exceptions matter. |
| Prohibitions | Highest blocking cost, and the weakest compliance. Convention tier only, never above, and the anti-pattern must be named in the line itself. |
| `Doesn't cover:` | Absence carries no marker distinguishing boundary from gap. |

| Never | Why |
|---|---|
| Promotion to Rule | Human act by definition. |
| Rationale | Invented, not found. A fluent guess is worse than a blank. |
| Legacy-vs-current calls (family 6) | Inverting it is confidently harmful. Parked. |

---

## The two filters

Run both before writing any line. Most candidate lines die here, and that's the point.

### 1. Name the alternative

**A rule must name the plausible alternative the team did not take.** If you can't name one, it isn't a decision — it's the path of least resistance, and the line is cut.

| Candidate | Alternative? | Verdict |
|---|---|---|
| "Tests live in `tests/`" | None — that's where pytest looks | ✂️ Cut. Ecosystem default. |
| "Use `SearchClient`, not the SDK directly" | Direct SDK calls | ✅ Write. |
| "Handlers return `Result[T]`" | Raising exceptions | ✅ Write. |
| "Type hints on all functions" | None — the type checker requires it | ✂️ Cut. See filter 2. |

This substitutes a test you can actually run for "does it deviate from ecosystem defaults," which has no mechanical implementation. It uses your own priors — the same priors that make a fact obvious or surprising to the agent reading it downstream. It also gives you half the rationale block for free, since the rejected alternative is one of its two fields.

### 2. Is a machine already enforcing it?

If a linter, formatter, type checker, or CI gate enforces the rule, **cut the line**. The tool guarantees compliance; restating it in prose changes nothing and costs tokens on every read.

Check before writing: `ruff.toml`, `.eslintrc*`, `biome.json`, `mypy.ini`, `tsconfig.json`, `.pre-commit-config.yaml`, CI workflow files.

---

## Size budget

Filters cut individual lines. They don't stop a file growing back over a year of syncs, and a rule nobody reads is a rule nobody follows. Practitioner consensus puts a context file under ~300 lines with a ceiling around 150–200 instructions; those are working numbers, not measured research, so treat them as a prompt to review rather than a hard stop.

| File | Soft budget |
|---|---|
| `PRINCIPLES.md` | ~200 lines · ~40 rules across both tiers |
| One `FOUNDATIONS.md` entry | ~8 invariants |

**Over budget is a report, not a refusal.** Never silently drop a rule to fit. Instead, rank the existing rules weakest-first and surface the bottom few for review:

1. Lowest conformance **as recorded when it was written** (an 81% Convention before a 100% one) — not re-measured, just read off the run that created it
2. Longest-unanswered `[TODO: why?]` — a rule nobody has justified in six months is a rule nobody missed
3. No named alternative — filter 1 should have caught it, and a rule that can't name what it rejected was never a decision
4. Newest, if the rest tie — an established rule has earned more benefit of the doubt

Report as: *"PRINCIPLES.md is at 247 lines / 51 rules, past the ~200 / ~40 budget. Weakest 5 by evidence: … — review?"* Route it to the review queue like any other decision.

If a project deliberately runs over, that's fine — it's their file. Say it once per sync and move on; don't nag every run.

---

## The six families

Classified by evidence source, because evidence determines both confidence and failure mode.

### 1. Boundary choices
One module is the only sanctioned door to a capability, and the import graph respects it.

A boundary is *about* negative space — where something may not appear — but **do not write it as a prohibition.** Negative phrasing is the weak spot of instruction-following: constraints opposing model defaults fail at 10–100% rates against 99%+ compliance for positively-phrased conventional ones ([arXiv:2604.07192](https://arxiv.org/abs/2604.07192) — *unverified citation, treat as a lead*).

Write the positive instruction, name the exceptions, and **name the anti-pattern inside the line** — the exact accessor or import the boundary displaces, plus the repair. On this family the anti-pattern is not optional detail; it's the only thing that lets an agent recognise a violation in code it's reading. See [What the command knew, the sentence must say](#what-the-command-knew-the-sentence-must-say).

Two shapes recur often enough to look for by name.

**1a. Vendor boundary** — a project module wraps a third-party SDK.

- **Detect:** for each module, list its third-party imports; for each of those packages, count importers elsewhere in the source tree.
- **Concentration test:** every importer inside one directory, or all but a nameable few → boundary.
- **Measure:** direct imports of the wrapped package outside the wrapper. Write only at ≥90% concentration.
- **Write:** "Use `SearchClient` (`search/client.py`) for all vendor-search operations. Importing `vendor_sdk` directly skips auth and retry handling — route the call through `SearchClient` instead." Exceptions listed inline.

**1b. Ambient-capability boundary** — one module owns access to something globally reachable.

Environment variables, the clock, randomness, direct DB connections, outbound HTTP. There's no vendor SDK here — the door is a project module like `settings.py` or `clock.py`, and the thing being confined is a language builtin. 1a's detection misses these entirely, because nothing appears in the dependency manifest.

| Capability | Python | JS / TS | Go |
|---|---|---|---|
| Environment | `os.getenv`, `os.environ` | `process.env` | `os.Getenv` |
| Clock | `datetime.now`, `time.time` | `Date.now`, `new Date(` | `time.Now` |
| Randomness | `random.`, `uuid.uuid4` | `Math.random`, `crypto.randomUUID` | `rand.` |
| Connections | `psycopg.connect`, `requests.` | `fetch(`, `new Pool(` | `sql.Open`, `http.Get` |

- **Detect:** grep the whole source tree for the accessor, group hits by containing module.
- **Concentration test:** ≥ 90% of hits in one module → Convention. Below that it's noise, not a boundary.
- **Write:** the accessor table above *is* the anti-pattern vocabulary — harvest the row you matched on straight into the line.

```markdown
**Read configuration through `settings`** (`src/settings.py`).
Direct `os.getenv` / `os.environ` reads bypass validation and defaults —
add a field to `settings` and read it from there.
```

- **Both shapes fail the same way:** the wrapper is vestigial and the team quietly abandoned it. The concentration test catches that — a boundary nobody respects doesn't reach the threshold, and gets reported as an observation instead of written as a rule.
- **Neither may be promoted to Rule by mining**, however clean the count. "Deviating is a defect" is the team's call, not the import graph's.

### 2. Structural conventions
A repeated shape: naming, return types, layering, registration.

- **Detect:** find the set of like things, count how many share the shape.
- **Threshold:** ≥80% conforming, exceptions named. Below that, say nothing. Count only members that *could* conform — see [Measurement hygiene](#measurement-hygiene).
- **Write:** name the shape and the shape it displaces — "handlers return `Result[T]`; raising past the handler boundary loses the error envelope — wrap it in `Result.err()`."
- **Fails when:** coincidence read as rule. The tier is the mitigation.

### 3. Extension-point choices
The sanctioned way to add a new X. **The most valuable family** — natively task-shaped, and what an agent most needs at the build-vs-reuse moment.

- **Detect, in order of strength:**
  1. Git history — take the last 3–5 additions of this kind of thing and intersect the files each one touched. The intersection *is* the procedure.
  2. Scaffold commands in `Makefile`, `package.json` scripts, `pyproject.toml`.
  3. Registry files — a module whose body is a list of registered things.
- **Write:** "New handler → `make scaffold-handler`, then register in `registry.py`."

### 4. Config-encoded choices
Selections visible in config or dependencies that nothing enforces.

- **Detect:** config file + actual usage in source.
- **Excluded by filter 2** whenever a tool enforces it — which covers most of them.

### 5. Canonical-example selection
Which instance is the exemplar. Feeds foundation entries and agentkit hot memory.

- **Detect:** most-conforming instance × most-referenced.
- **Write:** copy the real call site verbatim with a `path:line` comment. Never a synthesised example, and never a signature list — signatures are derivable and go stale on every rename.

### 6. Directional choices — **parked, do not mine**
Old and new patterns coexist; new code favours the new one. Requires history mining and can invert the truth — the "new" pattern may be the abandoned experiment. Not implemented.

---

## Measure to decide, then let go

A mined rule is dockit's **invention**, not the team's decision. Nobody chose it; dockit looked at a pattern and inferred it. The measurement is the only thing standing between "we found a real convention" and "we put a rule in someone's docs that an agent will now defend." So measure before writing — see each family above for its threshold — and then **discard the command.** Nothing is stored in the doc, and sync never re-runs it.

**Dockit measures to decide whether to write a line. It never re-measures a line that already exists.** That single rule is what keeps these docs *directive* rather than a state tracker, and most of what follows is a consequence of it.

**Never store the command in the doc.** Three reasons, so the rule survives someone thinking it sounds useful:

- **It reaches nobody who can act on it.** A command in a doc comment runs at sync time, in a report, to a human — never in the agent's context at the moment code gets written. Agentkit strips those comments before an agent sees the file.
- **Conformance isn't truth.** For a *directive* — "all config comes from `Settings`" — three violating files don't make the sentence false. They make it disobeyed. Measuring that is a compliance audit, a different job from keeping documentation honest.
- **Better tools own that job.** [ArchUnit](https://www.archunit.org/), [import-linter](https://import-linter.readthedocs.io/), and [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) enforce architectural rules on the hot path — pre-commit, CI, build failure — where enforcement works. A `grep` in a docs comment is a worse version of a solved problem; recommend one of these instead.

### What the command knew, the sentence must say

The valuable part of the measurement was never the count — it was the **pattern**. `grep -rE 'os.environ|os.getenv'` encodes *which specific API is the wrong path*, and that is the most actionable fact in the whole entry. Discard the command and keep only "use `Settings`", and that fact is lost.

So harvest it into the visible line. **Every boundary and every prohibition names the anti-pattern it displaces:**

```markdown
**All config comes from the `Settings` object** (`app/core/settings.py`).
Direct `os.environ` / `os.getenv` reads bypass validation and defaults —
replace them with a `Settings` field.
```

Three parts, in this order:

1. **The positive instruction** — what to do. Stays the headline; see the phrasing note below.
2. **The named anti-pattern** — the exact accessor, import, or call the rule displaces. This is the harvested grep pattern. An agent can't recognise a violation it can't name.
3. **The repair** — what to do on encountering one. Without it, an agent that spots a violation has no sanctioned next move and either leaves it or invents one.

**This is not a prohibition, and don't let it drift into one.** The imperative stays positive — "use `Settings`", not "never use `os.environ`". Negative phrasing is the weak spot of instruction-following (see family 1 above). Naming an anti-pattern inside a positive instruction is not the same as writing a negative instruction: the action requested is still the thing to do.

Keep the exception list visible for the same reason it always was — an agent needs to know where the rule doesn't apply, or it will "fix" the exceptions.

### Measurement hygiene

Dockit still runs `grep` to measure at write time, and two traps produce a *confident wrong answer* rather than an error. Both were found by running this design against a real codebase.

**Use `grep -E`, never `rg`.** Ripgrep isn't installed by default. When a command isn't found the pipeline still exits 0, so `| wc -l` yields `0` — and a concentration test reads that as a perfect boundary. It looks fine on the machine that wrote it, because that machine has `rg`. The same command returned `6` interactively and `0` under `/bin/sh` in testing. Use `-E` specifically: plain `grep` is basic regex, where `|` and `+` become literal characters and the pattern quietly stops matching.

**Count only things that could conform.** A denominator including items structurally incapable of matching yields a metric that can never reach 100%. Real case: counting `__init__.py` — a registry file with no handler in it — inside the handler population gave 6/8 = 75% against an 80% floor, and killed a healthy convention. Count the population the rule actually applies to.

A test that can never pass and one that can never fail read as equally authoritative.

---

## Rationale blocks

Rationale is never mined. When a human supplies one, it goes in a collapsed block directly under its rule:

```markdown
**Query through the SQLAlchemy ORM.** Raw SQL only in `migrations/`.

<details><summary>Why</summary>

Raw SQL bypassed the tenant filter twice and leaked rows across workspaces.
Rejected: a query linter — it can't see string interpolation.
</details>
```

Two fields: the reason, and the rejected alternative. Collapsing is for human readability, not token savings — an agent reads it either way. The point of attaching it to the rule is that a rule and its recorded reason can't drift apart the way a rule and a separate decision file do.

Until a human fills it, write `[TODO: why?]` and nothing else.

---

## On sync: a choice is not re-litigated

**Sync never re-measures an existing choice, and never removes one because the pattern thinned out.**

A choice earns its place once, at the moment it's written. After that it is a *directive* — it says what future work should do. Conformance sliding from 100% to 60% is not evidence the directive is wrong. It's just as likely to be evidence the directive is being ignored, which is an argument for keeping it, not cutting it. And since dockit no longer measures existing rules, no percentage exists to react to.

### Status: `intended` vs. the unmarked default

A rule can be decided before the code reflects it. That's the state a greenfield project is *entirely* made of, and it needs saying out loud, because the alternative is either silence (nothing written, so no agent knows the path exists) or a rule that reads as describing code it doesn't describe.

| Marker | Means |
|---|---|
| *(none)* | The code reflects this. The default, and unmarked so it costs nothing to read |
| **`[intended]`** | Decided; the code hasn't caught up. A scaffolded wrapper, a base class with no subclasses yet, a direction the team has committed to |

**`intended` qualifies the code, not the rule's force.** A Convention is deviable-with-a-reason and a Rule isn't, regardless of marker. An agent that treats `[intended]` as optional has misread it — the marker says *no precedent exists yet*, which makes the written rule the only guide available, not a weaker one.

Four rules keep this from becoming conformance measurement by another name:

1. **Declared, never measured.** A human sets it, or dockit sets it at write time for a rule the code doesn't yet demonstrate. Nothing computes adoption to decide a marker.
2. **No reverse transition.** Never add `[intended]` to an unmarked rule because fewer files follow it than before. That is the decay flag with a new label, and it is banned outright.
3. **No time-based transition.** Nothing changes because a date passed.
4. **Sync never overwrites it.** Same protection manual invariant edits carry. Goals change, the team re-declares, dockit leaves it alone.

**Promotion is offered, never applied.** When consumers now exist for an `[intended]` rule, `sync --deep` raises it as a review-queue question — *"`Settings` now has 12 consumers; drop the `[intended]` marker?"* Normal sync says nothing, because normal sync doesn't look.

### Removal requires feature work, not decay

| Situation | Action |
|---|---|
| The code the choice governs is **gone** — module deleted, capability removed | **Remove the choice.** It governs nothing, and a rule about deleted code is a tombstone |
| The choice names a path, command, or symbol that no longer exists | **Fix the reference.** The choice stands; its coordinates moved |
| The team replaced the sanctioned path — new wrapper, new base class | **Update the choice** to name the new path. This is feature work requiring it |
| Fewer files follow it than last month | **Nothing.** Not measured, not reported, not a signal |
| A human says cut it | Cut it |

The distinction that matters: removal follows from **the subject of the sentence disappearing**, never from the sentence being unpopular. `SearchClient` deleted → the rule about using it goes. `SearchClient` still there and bypassed in four new files → the rule stays exactly as written.

Same test for an `[intended]` rule, and it's worth stating because the intuition runs the other way: a rule nobody has followed *yet* is not a removal candidate — that's what the marker declares. Only the subject vanishing removes it.

This is the same test the tombstone rule applies everywhere else in dockit: does the thing still exist? Docs describe what *is*. A choice governing live code is current state, however well or badly it's followed.

---

## What goes to the review queue

Mining produces human-required work. Surface it in the completion report; `/repokit status` picks it up from there.

| Item | The question |
|---|---|
| Convention written at 80–99% | Real pattern, or should the exceptions be fixed? |
| Empty `[TODO: why?]` | One sentence of reason. |
| `[TODO: known hazard?]` | What has broken here that a newcomer wouldn't predict? |
| `Doesn't cover:` observation | Intentional boundary, or a gap? |
| Convention measured at 100% when written | Promote to Rule? |
| SDD-artifact discrepancy | Which side is right? |
| `[intended]` rule that now has consumers (`--deep` only) | Drop the marker? |

Every row except the last is produced **once, by the run that wrote the line.** The `[intended]` row is the single exception, and it's confined to `sync --deep`: opt-in, explicitly a re-examination, and one-directional — it can only ever offer to *remove* a marker. There is no decay row, because nothing re-measures an unmarked rule.

### The hazard question is the one worth interrupting someone for

Every other row above asks a human to *adjudicate* something mining already found. This one asks for content mining cannot reach at all.

Consider a real example, anonymized: *"exclude numeric and date fields from facet requests — the vendor returns 400."* No import graph implies it. No conformance count suggests it. It isn't in the type signatures, and the code that respects it looks like ordinary filtering. It exists because somebody shipped the obvious version and watched it fail in production, and it is worth more to the next agent than most of what scoring produces.

Rules of engagement, because a question this open-ended turns into nagging fast:

- **Asked once per foundation**, at registry entry or on the flip to `hotspot`. Not every sync.
- **"Nothing" closes it.** Delete the marker. An unanswered marker is the only one that persists.
- **Never inferred.** Not from issue titles, not from commit messages containing "fix", not from a `try/except` that looks defensive. A plausible hazard the team never actually hit is worse than no hazard, because it will be designed around forever.
- **The answer is a Rule, not a Convention.** Somebody paid for it already.

---

## Best-practice observations stay out of the docs

You will notice things worth saying — no tests on a foundation, retry logic duplicated across three consumers, no scaffold path for a common addition. **Report them in chat. Never write them into the docs.**

A generic recommendation sitting in a project's own documentation is indistinguishable, to the next agent, from a decision the team actually made. It starts getting built toward. The docs record what is true about this codebase; advice stays advice.
