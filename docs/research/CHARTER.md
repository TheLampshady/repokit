# Research Charter

Frame for research runs in this repo. Read for context; never cited as a source.

**Nothing here needs maintaining.** It holds only decisions that don't expire — no status, no focus, no inventory of what exists. Repo facts (structure, platforms, surfaces, terminology) live in `CLAUDE.md` and the research docs; duplicating them here would create the exact drift this project exists to prevent.

**Mandate** — Repokit bets that the decisions a team has already settled are the highest-value context you can hand an agent or a new contributor, and the ones most reliably missed. The code contains them; nobody reads the import graph before writing their first line. Research exists to test that bet and keep build-vs-wrap-vs-recommend calls evidence-backed. The field is young and full of confident claims with nothing behind them.

A line of generated context earns its place when it is **novel** to the reader, **action-changing right now**, and **cheap to state**. Overview fails novelty — the reader could derive it. Rationale fails immediacy — it matters only when the decision is reopened. That test is the working definition of "high value" here, and it is the thing research should sharpen rather than replace.

**The goal is a codebase that is easy to understand and accessible** — to an agent picking up a task and to a human in their first week. That's the outcome every surface is judged against, which makes legibility a correctness property rather than polish. Two consequences bind the output: a reader never has to learn repokit's internal vocabulary to act on what it says — a report that must be decoded has failed even when every number in it is right — and volume is a cost, so a check that passed and changes nothing is noise competing with the one line that does. Accessible also means the reverse of comprehensive: the shortest true report wins.

**Repokit is opinionated, and deference is earned.** The doc structure it applies is a research position, not a neutral container — it exists because the evidence says a particular shape of documentation serves agents and newcomers better than the sprawl most repos accumulate. So the default is to apply that opinion. A project earns deference by **demonstrating structural integrity** — discrete topical files, navigable headings, links that resolve, no wholesale duplication — not by merely having files. A 3000-line README is documentation and is exactly the case the opinion exists to fix.

This is safe to hold firmly only because restructuring never destroys: content is relocated, never dropped, and the move list is reported. Opinionated about *shape*, conservative about *substance*. Where research undermines part of the opinion, the opinion changes — that's what research is for; it does not become neutrality in the meantime.

**What generated agents are for.** Two failure modes. Everything agentkit produces is judged against them, and a feature that serves neither doesn't ship.

- **Architectural hallucination** — the agent invents structure the project doesn't have: a base class that was never written, a layer borrowed from the framework's documentation, an extension procedure that looks plausible and is wrong. Cured by hot memory that names real paths, real invariants, real extension procedures — measured from the code, not inferred from the stack.
- **Delegation blindspot** — real code that no agent claims, so work on it routes to a generic agent with no context. Cured by coverage: every load-bearing area of the repo triggers some agent, or the absence is reported.

Blindspots are the harder half. A hallucination announces itself the moment someone checks the claim; a blindspot produces work that merely lacks context, and nothing fails. So **detecting absence is a first-class requirement**, not a report-quality nicety — a tool that only validates what exists will pass a codebase it has half-covered.

This cuts both ways across the two layers. Detection thresholds tuned to find *utilities* will silently drop other shapes of foundation — a base class inherited a dozen times inside one layer has no cross-feature spread and is foundational anyway. Any filter justified as noise reduction should be checked for what shape of code it structurally cannot surface.

## Objectives

- What generation may write into a project's docs, and what must be left to a human.
- How context drift is detected, and what detection costs.
- Which context tooling to build, which to wrap, which to only recommend.
- What generated agents should carry, and how work gets routed to them.
- How an agent set proves it has no blindspots — what "covered" means, and what it costs to check.
- What a human needs from these docs that an agent doesn't, and where the two readers conflict.
- Whether surfacing a decision actually changes the action taken. Not "do docs help" — does *this* line, at *this* moment, prevent the reinvention it was written to prevent.

## Out of scope

Already decided against. Don't research these, and don't recommend them.

- **A retrieval layer** — maps, graphs, symbol servers are commodity; wrap or recommend, never build.
- **ADR generation** — the collapsed why-block is an on-ramp for later extraction, not a feature to grow.
- **Ticket creation** — tikkit owns it; repokit reads `.backlog/` and never writes.
- **Generated rationale**, at any confidence threshold.
- **Restating machine-enforced rules** — the linter already guarantees compliance.
- **Renaming `FOUNDATIONS.md`** — it's a tooling contract read by name.
- **New files for mined content** — it routes into existing structure or it doesn't ship.
- **Directional mining** (legacy-vs-current from git recency) — inverting it is confidently harmful.
- **Paid or proprietary tooling** — note it where relevant, never recommend it.

## Standard of evidence

Practitioner consensus is the floor, upgraded by benchmarks and skeptical reports where they exist. Order: peer-reviewed and benchmarked > official vendor docs > credentialed practitioner writing with working examples > vendor blogs.

A single vendor blog is a **lead, not a basis**.

Absence of evidence is **labeled as an absence claim**, never treated as a negative finding.

**Verify load-bearing claims against the primary source, not a summary.** Research here already caught a fully fabricated citation — a headline figure attributed to a nonexistent ACM/IEEE paper — one step from becoming load-bearing. The most confident-looking citation is sometimes the fake one.

## Constraints on recommendations

- Free and open source only.
- Must work across Claude, Antigravity, and Copilot — or say plainly that it doesn't.
- No compiled code, daemons, or paid services.
- **Anonymize field material.** No client or employer names, no identifying vendor + stack + path combinations. Cite as "a production project (user-supplied, anonymized)." Every doc should be safe to show anyone without a second pass.

## Terminology

Words this project uses in a specific way. Glosses only — each points at where the real definition lives, so this list can't drift out of sync with it.

- **Foundation** — a *thing*, not a rule: load-bearing code with high fan-in across features, meant to be reused and stay stable. Detected by measurement, not by living in `core/`. Full definition: `skills/dockit/references/templates/core/FOUNDATIONS.template.md`; detection method in `FOUNDATIONS-DETECTION.md`.
- **Overview / Choice / Rationale** — the three content bands. Overview describes what code does and is derivable, so it isn't generated. Choice is what the team settled on, and is the only band generation writes. Rationale is why, and is never generated. Full definition: `skills/dockit/references/guides/CHOICE-MINING.md`.
- **Convention** — a mined rule at the soft tier. Follow by default; deviating with a stated reason is fine. Generation may write these; the hard tier above it is human-authored only. Both tiers defined in `CHOICE-MINING.md`.
- **Measure to decide, then let go** — dockit measures a pattern to earn the right to *write* a mined rule, then discards the command. Nothing is stored in the docs and sync never re-measures an existing line. A choice **directs future work**; it is not a state tracker, so falling conformance is neither counted nor reported, and removal is triggered only by the code the rule governs disappearing. Ongoing conformance enforcement belongs to a linter (ArchUnit, import-linter, dependency-cruiser) — recommend, never rebuild. Full definition: `skills/dockit/references/guides/CHOICE-MINING.md`.
- **`intended`** — a status on a foundation or rule meaning *this is the sanctioned path, and the code hasn't caught up yet.* One vocabulary for two states that turn out to be the same one: a scaffolded module with no consumers, and a convention nobody follows yet. Zero adoption is what the marker declares, never evidence against the entry. **Declared, never measured** — nothing computes adoption to set it, nothing adds it because usage fell, nothing changes on elapsed time, and sync never overwrites it; those four constraints are what keep it from being conformance measurement renamed. The unmarked default means the code reflects the entry. Full definition: `skills/dockit/references/guides/CHOICE-MINING.md`.
- **`hotspot`** — a `health` value on a foundation row meaning high fan-in *and* high churn: load-bearing enough to qualify as a foundation, rewritten often enough that the abstraction is suspect. Not a quality grade on the code — the reading is that it may be wrong or carrying too much, so the remedy is sometimes to inline and rebuild rather than to document harder. **Measured, never declared** — the inverse of `intended`: scoring recomputes it each sync from the top quartile of churn within the foundation set, so nothing hand-sets it and nothing preserves it. Full definition: `skills/dockit/references/guides/FOUNDATIONS-DETECTION.md`; health values enumerated in `skills/dockit/references/templates/core/FOUNDATIONS.template.md`.
- **Named anti-pattern** — the specific accessor, import, or call a rule displaces, written into the visible line alongside the positive instruction and the repair (*"direct `os.environ` reads bypass validation — add a field to `Settings`"*). It's the operational half of a boundary rule: an agent can't recognise a violation it can't name. Harvested from what the discarded measurement command encoded, which is why removing verification made these mandatory rather than optional.
- **Checkable claim** — a sentence that asserts something about the code and can be settled by reading the code: "all handlers return `Result`", "auth lives in `src/auth/`". It is what makes drift observable, and the only licence to edit prose generation didn't write — the code disagrees, so the claim is fixed or cut (unless the code is the bug, which gets flagged instead). Content asserting nothing checkable is reported, never touched. Full definition: `skills/dockit/SKILL.md` § Delete authority.
- **Hot memory** — content embedded directly into a generated agent so it needs no lookup, as opposed to reference material the agent reads on demand.
- **Tombstone** — a line or file documenting something **no longer present**: "removed in v2", "moved to X", a migration log, a changelog section. Docs describe what *is*; git and the chat report cover what *was*. Generation never writes one, and the friendly-sounding variants (hand-off notes, "what changed" docs) are the same thing. The test is existence, not tense — a deprecation notice on code that still runs is current state and belongs in the doc; the same notice after the code is deleted is a tombstone. Full definition: `skills/dockit/SKILL.md` § Core Principle: Docs Describe What *Is*.
- **Rot and drift** — how long a piece of context has gone unverified or unanswered: an unfilled `[TODO: why?]`, a reference nothing has re-checked, a foundation past its review date. Distinct from **drift**, which is disagreement between docs and code measurable right now — rot is the time axis, drift is the correctness axis. A doc can rot without drifting (still true, nobody has confirmed it in a year) and drift without rotting (checked yesterday, wrong today). Measured from git history, never stamped into the doc — a written staleness date is itself a tombstone. Background in `docs/research/drift-detection-research.md`.
- **Context rot** — the published sense of the phrase, and **not** repokit's rot: model output quality degrading as input length grows, reproduced across 18 models even on simple tasks, with topically-related distractors amplifying the effect at longer context. It sits on neither axis above, because it is a property of the *reader* rather than of the doc — the same line is cheap in a focused agent and expensive buried in a 200k-token window. This is what makes volume a cost in the mandate above, and why a subagent's clean context is worth paying for. Background in `docs/research/subagent-value-research.md`.

<!-- Glosses, not definitions. If a definition changes, the pointer still holds. -->
