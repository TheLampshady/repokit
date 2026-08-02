# Research Charter

Frame for research runs in this repo. Read for context; never cited as a source.

**Nothing here needs maintaining.** It holds only decisions that don't expire — no status, no focus, no inventory of what exists. Repo facts (structure, platforms, surfaces, terminology) live in `CLAUDE.md` and the research docs; duplicating them here would create the exact drift this project exists to prevent.

**Mandate** — Repokit bets that the decisions a team has already settled are the highest-value context you can hand an agent or a new contributor, and the ones most reliably missed. The code contains them; nobody reads the import graph before writing their first line. Research exists to test that bet and keep build-vs-wrap-vs-recommend calls evidence-backed. The field is young and full of confident claims with nothing behind them.

A line of generated context earns its place when it is **novel** to the reader, **action-changing right now**, and **cheap to state**. Overview fails novelty — the reader could derive it. Rationale fails immediacy — it matters only when the decision is reopened. That test is the working definition of "high value" here, and it is the thing research should sharpen rather than replace.

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
- **Convention** — a mined rule at the soft tier. Follow by default; deviating with a stated reason is fine. Generation may write these.
- **Rule** — the hard tier, where deviating is a defect. Humans only; promotion from Convention is never automatic. Both tiers defined in `CHOICE-MINING.md`.
- **Stored predicate** — the shell command that verifies a rule, kept in a comment beside it and re-run on sync. Not visible evidence prose.
- **Hot memory** — content embedded directly into a generated agent so it needs no lookup, as opposed to reference material the agent reads on demand.
- **Tombstone** — a line or file documenting something **no longer present**: "removed in v2", "moved to X", a migration log, a changelog section. Docs describe what *is*; git and the chat report cover what *was*. Generation never writes one, and the friendly-sounding variants (hand-off notes, "what changed" docs) are the same thing. The test is existence, not tense — a deprecation notice on code that still runs is current state and belongs in the doc; the same notice after the code is deleted is a tombstone. Full definition: `skills/dockit/SKILL.md` § Core Principle: Docs Describe What *Is*.
- **Rot** — how long a piece of context has gone unverified or unanswered: the age of a failing predicate, an unfilled `[TODO: why?]`, a section nothing has re-checked. Distinct from **drift**, which is disagreement between docs and code measurable right now — rot is the time axis, drift is the correctness axis. A doc can rot without drifting (still true, nobody has confirmed it in a year) and drift without rotting (checked yesterday, wrong today). Measured from git history, never stamped into the doc — a written staleness date is itself a tombstone. Background in `docs/research/drift-detection-research.md`.

<!-- Glosses, not definitions. If a definition changes, the pointer still holds. -->
