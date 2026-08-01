# Choice over Overview — Research

*Generate choices, defer rationale, cut overviews.*

**Date:** 2026-08-01
**Original request:** Define the overview / choice / rationale spectrum as the content rule for everything repokit generates; map the general context-tooling landscape onto it; settle whether "foundations" should become "conventions"; and enumerate what actually belongs in the "choice" band.
**Goal:** Turn the ETH instruction-vs-overview finding into an operational taxonomy — what generation may emit, what it may draft for confirmation, and what it must leave to humans — so choice-mining can be specified without crossing into invented judgment.
**Provenance:** This document stands alone — it references no other document in this repository. External claims cite primary sources inline. Positions that came out of project working discussions rather than published sources are marked **(repokit hypothesis)**: Zach's working position, unmeasured, and something to validate by experiment in repokit rather than treat as established.

---

## Executive summary

The ETH result splits context-file content into a type agents obey (instructions) and a type that adds cost without helping (repository overviews). Generalized — **(repokit hypothesis)** — that's a three-band spectrum. **Overview** describes what code does — fully derivable by reading, so restating it adds tokens without information. **Choice** is a decision visible in the code as evidence: what the team settled on — the chosen wrapper, the repeated pattern, the sanctioned way to add a new thing. Choices are *derivable-at-a-cost*: expensive for an agent to notice mid-task, cheap to state, and when stated as instructions they get followed. **Rationale** is why the choice was made, what was rejected, and what must stay true — not recoverable from code at all.

Why choice is the sweet spot **(repokit hypothesis)**: it is the only band that is both *novel to the agent* and *action-changing right now*. Overview fails novelty — the agent already has that information or can derive it, so each line pays attention cost for zero delta. Rationale fails immediacy — real information that changes nothing about the next action; it matters only when the choice itself is revised. Choice passes both, and adds a third property: it is cheap to state and mechanically verifiable. Novel × action-changing × cheap is the whole admission test.

The economics behind that **(repokit hypothesis)**: choice documentation **pre-pays expensive discovery**. A choice is derivable-at-a-cost — the import graph contains "use the wrapper," but no agent walks the import graph before writing its first line; under task pressure it skips discovery and builds bespoke (the field case). Choice-mining pays that discovery cost once, at documentation time, and converts it into a one-line instruction that every future session, agent, and teammate reads for near-free. Overview pre-pays nothing — the agent re-derives it cheaply anyway. Rationale pre-pays for a moment that rarely arrives. The amortization is the business case for the entire choice band.

The generation rule that falls out: **generation is banned from writing overview (except compressed to one-line pointers), licensed to draft choices (with evidence labels, as confirm-or-delete drafts), and locked out of rationale (omit or `[TODO:]`, never synthesize).** Most high-value doc lines are actually choice+rationale composites — "exclude boolean fields from facet requests *(choice, inferable from the code)* because the vendor API returns 400s *(rationale, human-only)*" — so generation drafts the left half and `[TODO: why?]` marks the missing right half **(repokit hypothesis)**. Naming verdict: **foundations stays**. A foundation is a *thing* (module, path, API, owner); a convention is a *rule* (a pattern of choice, possibly attached to no module). Conventions already have homes — PRINCIPLES.md for codebase-wide rules, per-foundation entries for foundation-scoped ones — and renaming FOUNDATIONS.md would break the tools that read it by name (agentkit and dockit sync).

## Key findings

- **The spectrum is grounded in the ETH split, not invented here.** *"Instructions in the context files are well followed by coding agents [while] repository overviews … are not helpful"*; context files are *"useful for specifying non-standard coding practices"* ([arXiv:2602.11988](https://arxiv.org/abs/2602.11988)). Instructions carrying choices = the followed type; overviews = the unhelpful type; "non-standard practices" = precisely choices + rationale, the two bands the code alone can't assert as rules. The three-band generalization itself is ours **(repokit hypothesis)**.

- **Instructions are followed even when wrong — the guardrails are load-bearing, not cautious.** The ETH agents followed context-file instructions *"rigorously but counterproductively"*, adding steps per task when the instructions were bad ([arXiv:2602.11988](https://arxiv.org/abs/2602.11988) — specific step counts are from the paper body, not independently re-verified here). Field audits report agents obeying stale claims ("we use Jest," surviving a Vitest migration) with full compliance ([Packmind](https://packmind.com/evaluate-context-ai-coding-agent/)). A wrong choice statement is not neutral noise; it is an obeyed error.

- **Negative constraints are the weak spot of instruction-following.** Constraints that oppose model defaults fail at 10–100% rates versus 99%+ compliance for conventional ones, and negative phrasing ("don't use Y") is measurably harder for LLMs than positive ([arXiv:2604.07192](https://arxiv.org/abs/2604.07192)); piling on structural constraints can degrade agent pass rates outright ([arXiv:2605.06445](https://arxiv.org/abs/2605.06445)). Consequence for the choice band: prefer positive phrasing ("use A for B operations") over prohibition, and back every negative rule with a mechanical drift check (does new code import B?) rather than trusting context alone **(repokit hypothesis on the mitigation)**. This also kills the strongest circulating pro-ADR claim — a ">60% regression reduction from rejected-option negative constraints" attributed to a 2024 ACM/IEEE paper that does not exist.

- **Choices rot — and the evidence label makes them the only mechanically re-verifiable band.** Staleness is a documented context-file failure mode, and the field's tooling response is early — a dedicated linter exists precisely because checked-in agent context rots ([agents-lint](https://github.com/giacomo/agents-lint); [Packmind](https://packmind.com/evaluate-context-ai-coding-agent/)). A mined choice carries recomputable evidence: conformance counts and import ratios can be re-checked on every `dockit sync`, so `11/13 conform` decaying to `6/13` flags the rule automatically. Overview prose and rationale can't be machine-verified this way. The inference that the evidence label doubles as a drift-check contract — and that this is where choice-mining meets repokit's context-in-sync premise — is ours **(repokit hypothesis)**.

- **The overview ban is conditional on the repo being documented.** The ETH gap-filler nuance: with other documentation removed, LLM-generated context files *did* help ([arXiv:2602.11988](https://arxiv.org/abs/2602.11988) — paper-body finding, not independently re-verified here). Auto-generation is defensible on doc-barren repos and net-negative on documented ones — dockit should encode that asymmetry rather than a flat ban.

- **"Derivable" has a middle band, and it's where generation earns its keep** **(repokit hypothesis, grounded in a field observation)**. A binary derivable/non-derivable rule misses the case that matters: in a production project (user-supplied, anonymized), an implement agent hand-rolled vendor-SDK calls even though the existing shared client was fully visible in the code — and stopped the moment the docs surfaced it. A choice can be derivable and still unknown at decision time: the import graph contains "use the wrapper," but no agent reads the import graph before writing its first line. Compressing that evidence into one instruction is the highest-leverage thing generation can do — and it is not overview, because it asserts a *selection*, not a description.

- **Examples are choices in executable form.** Agents replicate the structure of code patterns they see more strongly than they follow prose ([Srikanth R](https://www.linkedin.com/pulse/hidden-power-markdown-structuring-md-files-ai-coding-assistants-r-kdgof) — practitioner claim, not measured). A canonical example is therefore a choice-carrier: picking *which* instance is the exemplar is itself an inferable choice (the most-conforming, most-imported instance), and embedding it (agentkit hot memory) transmits the convention better than describing it **(repokit hypothesis)**.

- **Choice and rationale compose, and the seam is where `[TODO:]` lives** **(repokit hypothesis)**. An invariant is usually a constraint (inferable — the code does exclude boolean fields) welded to a reason (not inferable — the 400 errors). Generation may draft the constraint *as observed behavior*; the reason is omitted or marked. A fluent invented reason is the worst output on the spectrum because instructions-are-followed cuts both ways.

- **Bands have task-type affinities** **(repokit hypothesis)**. New-feature development turns on the build-vs-reuse moment, and choice is the band aimed at exactly that — extension points, boundaries, use-when. Revision and refactor work is where rationale pays: it's the payload when a settled decision gets reopened. Navigation is overview's job, and pull-based retrieval already serves it on demand. Consequence: for repokit's primary scenario — agents building new features — choice is the most valuable band; rationale is scheduled for later; overview is outsourced to retrieval.

- **The content spectrum is orthogonal to the delivery axis** **(repokit hypothesis)**. Overview/choice/rationale says *what kind of statement*; push/pull (always-loaded context files and agent descriptions vs on-demand docs and retrieval tools) says *when it reaches the agent*. A choice delivered pull-only can still be missed; an overview delivered push is still dead weight — both dimensions have to be right, independently.

### One subject, three bands

The same fact about a codebase written in each band, using the anonymized field case (a shared client wrapping a vendor search SDK):

> **Overview** — *don't generate; the agent learns this by reading the file*
> "`search/client.py` provides an abstraction layer over the vendor search SDK. It handles authentication, request construction, and response parsing, and exposes a unified interface for API handlers."

> **Choice** — *generate: instruction + pointer + evidence, as a confirm-or-delete draft*
> "Use `SearchClient` (`search/client.py`) for all vendor-search operations. Evidence: 9/9 handlers route through it; no direct SDK imports outside the client. `[TODO: intentional rule or accident?]`"

> **Rationale** — *never generate; human-supplied, stored for revision time*
> "We wrapped the SDK because raw calls leaked retry and auth handling into handlers and broke during a vendor migration. Direct SDK use was considered and rejected. Revisit if the vendor ships a stable async client."

Same subject three times. Only the middle one belongs in generation's output; only the last one matters when someone proposes replacing the client; the first one is what most auto-generated docs consist of — and it's the band the evidence says to cut.

### The spectrum, with everything we discussed placed on it

Band assignments are this project's analysis **(repokit hypothesis)**; per-tool behavior claims carry their own citations.

| Artifact / tool | Band | Notes |
|---|---|---|
| Repo maps ([aider](https://aider.chat/2023/10/22/repomap.html), [RepoMapper](https://github.com/pdavis68/RepoMapper)) | Overview | Aider's map is re-ranked per conversation turn; static checked-in maps drop exactly that step. No published ablation of the map's contribution was found (absence claim — uncited by nature) |
| Code graphs (CodeGraph, GitNexus, CodeGraphContext) | Overview (queryable, pull) | Execution-phase retrieval; carries no selection |
| Symbol servers ([Serena](https://github.com/oraios/serena) / LSP) | Overview on demand | Answers "where/what," never "which one is ours"; agents forget to use it after context compaction ([Serena issue #802](https://github.com/oraios/serena/issues/802)) — pull failure, documented |
| Repo packers / flatteners | Overview, maximal | The extreme case of paying for the derivable |
| [llms.txt](https://llmstxt.org/) | Overview (index) | Pointer-shaped, so the tolerable form |
| Auto-generated AGENTS.md summaries | Overview | The measured net-negative case ([arXiv:2602.11988](https://arxiv.org/abs/2602.11988)) |
| Purpose/architecture prose in generated docs | Overview risk zone | Allowed only compressed: one-line pointers ("shared search client lives at X") |
| FOUNDATIONS catalog rows (name, path, API, consumers) | Pointer (compressed overview) | Earns tokens by routing, not describing |
| Build/test/scaffold commands (context files) | Choice (config-encoded) | The classically useful context-file content ([Anthropic best practices](https://code.claude.com/docs/en/best-practices)) |
| `Use when:` trigger lines | Choice (task → chosen tool) | The routing form of a boundary choice **(repokit hypothesis — planned experiment)** |
| Agent descriptions (agentkit) | Choice, rendered for the router | Same content as trigger lines, on the push surface **(repokit hypothesis — planned experiment)** |
| Wrapper rules ("use A, don't import B") | Choice (boundary) | Import-graph evidence; the field case, automated |
| Structural conventions ("all handlers return X") | Choice (repetition) | Conformance-count evidence |
| Extension-point rules ("new component → scaffold, register in factory") | Choice (sanctioned path) | The most task-shaped choice; gold for generation **(repokit hypothesis)** |
| Canonical code examples (hot memory) | Choice (executable form) | Propagates harder than prose ([Srikanth R](https://www.linkedin.com/pulse/hidden-power-markdown-structuring-md-files-ai-coding-assistants-r-kdgof), anecdotal) |
| Invariants | Choice + rationale composite | Constraint draftable as observed; reason human-only |
| PRINCIPLES.md | Choice (codebase-wide conventions) + rationale | The existing home for module-less rules |
| ADRs | Composite: overview + choice + rationale | Per [MADR](https://adr.github.io/madr/)'s own structure: Decision Outcome = choice; Context = overview; Drivers / Rejected Options / Consequences = rationale. Agent-context evidence is practitioner-only ([Chris Swan](https://blog.thestateofme.com/2025/07/10/using-architecture-decision-records-adrs-with-ai-coding-assistants/)) |
| SpecKit constitution | Rationale + chosen principles | dockit reads it, never writes it (repokit design decision) |
| context7 / external library docs | Off-spectrum | Reference material about third-party code, not repo-derived |
| Per-task user context | Off-spectrum | Definitionally never a project artifact |

## How this applies to repokit

### The generation rule, per band **(repokit hypothesis — the experiment this doc exists to specify)**

- **Overview:** never generated as prose *in documented repos*. The only permitted form is the pointer — one line, existence + location + chosen-ness ("shared client for vendor search lives at `<path>` — use it"). Exception: doc-barren repos, where the ETH gap-filler result licenses fuller generation until humans have something to curate. Per-line admission test ([Anthropic](https://code.claude.com/docs/en/best-practices)): would removing this line cause an agent to make a mistake? If not, don't generate it.
- **Choice:** generation's licensed territory, under four conditions: (1) every emitted choice cites its evidence inline (`11/13 handlers conform — exceptions: x.py, y.py`), (2) it ships as a confirm-or-delete draft (`[TODO: intentional rule or accident?]`), (3) it is phrased as an instruction, not a description — and positive where possible, since negative constraints have measured-weak compliance and need a verification backstop, (4) its evidence is re-verified on every sync — decayed conformance or a dead path flags the rule, because stale instructions are obeyed ([Packmind](https://packmind.com/evaluate-context-ai-coding-agent/)).
- **Rationale:** omit or `[TODO: why?]`. Never synthesized, no exceptions. The composite pattern means most choice drafts end with an open rationale slot for a human. Rationale's value is revision-time, not generation-time — it is the payload when a settled choice gets reopened, so it is stored and pulled on demand, never always-loaded **(repokit hypothesis)**.

### The choice families (there are six, not three) **(repokit hypothesis — taxonomy from working discussions)**

Classified by **evidence source**, because evidence determines confidence and failure mode:

1. **Boundary choices** — a wrapper/facade exists and the import graph favors it over the thing it wraps. Evidence: artifact + import ratios. Output: "use A, don't import B directly." Failure mode: the wrapper is vestigial and the team actually abandoned it — the exception list catches this.
2. **Structural conventions** — repeated shape across instances: naming schemes, return types, layering, registration patterns. Evidence: N-of-M conformance counts. Failure mode: coincidence read as rule; the threshold and exceptions guard it.
3. **Extension-point choices** — the sanctioned way to add a new X: scaffold commands, registries, plugin directories. Evidence: the scaffolding/registry exists and past additions used it. The most valuable family because it's natively task-shaped ("adding a component? → this path").
4. **Config-encoded choices** — selections visible in config/dependencies that nothing machine-enforces. Evidence: config + usage. Explicitly excluded: anything a linter already enforces — restating an enforced rule fails the per-line test, since the linter already guarantees compliance.
5. **Canonical-example selection** — which instance is the exemplar of each convention. Evidence: most-conforming + most-referenced. Feeds agentkit hot memory.
6. **Directional choices** — old pattern and new pattern coexist; new code consistently uses the new one. Evidence: git recency correlation. Output: "prefer B; A is legacy." **Highest-risk family** — requires history mining and can invert the truth (B might be the failed experiment). Park it behind stricter confirmation or defer entirely.

Answering the specific question: a wrapper is not a convention — the wrapper is an *artifact*, "route through it" is the rule it implies, and as a detector family it's distinct because its evidence is the import graph rather than repetition. They meet only at the output format (both emit instructions).

And on whether choice is obtainable from code alone: five of the six families are draftable from code as it sits (family 6 needs history mining and stays parked). Code yields the *draft*; a human still supplies the *confirmation* (is this pattern intentional?) and the *why*. That's the division of labor the whole spectrum encodes.

### Naming: foundations stays, conventions get routed **(repokit design decision, from working discussions)**

- **Foundation** = a thing: path, public API, owner, health, consumers. The catalog of load-bearing code. FOUNDATIONS.md keeps its name — it's a tooling contract: agentkit and dockit sync read it by name, so renaming is a breaking change.
- **Convention** = a rule: a pattern of choice. Two homes, both existing: foundation-scoped conventions land in that foundation's entry (alongside its invariants); codebase-wide conventions land in PRINCIPLES.md, which already exists for exactly this content.
- Choice-mining therefore adds **no new file**: it feeds FOUNDATIONS entries, PRINCIPLES.md, `Use when:` lines, and agentkit hot memory through the existing structure.

### Improving FOUNDATIONS.md and PRINCIPLES.md around these findings **(repokit hypothesis — planned experiments)**

**FOUNDATIONS.md, per entry:**

- Lead with the choice content: a `Use when:` trigger line first, then invariants — positively phrased wherever possible.
- Demote purpose prose to pointer form: one line, existence + location + chosen-ness. The catalog table stays pure pointers.
- Give every invariant an evidence label and an explicit rationale slot (`[TODO: why?]`): constraint drafted from observation, reason human-owned. Render rationale last (or collapsed) — it's revision-time content and shouldn't spend generation-time attention.
- Pair every *negative* invariant ("never call the SDK directly") with a registered drift check that sync runs mechanically (e.g., an import scan) — negative constraints have measured-weak compliance, so verification backs up context.
- Admit lines by the per-line test; sync re-verifies all evidence counts and flags decay.

**PRINCIPLES.md:**

- Narrow the charter to choices: codebase-wide conventions as positive instructions, each carrying a conformance count and exception list.
- Apply the surprising-choices filter: only rules that deviate from ecosystem defaults earn a line — anything an agent would do anyway fails the per-line test.
- Exclude machine-enforced rules entirely; the linter restates itself.
- Same rationale slots and sync re-verification as FOUNDATIONS entries.
- No second disclosure level: principles link to code, never to further principle sub-docs.

### Where this lands in repokit's plans

Choice-mining slots into dockit's detection layer (extending the fan-in / cross-feature analysis dockit already performs) as the upstream feeder for the planned experiments: `Use when:` trigger lines, the instruction-density rule, omit-don't-invent at init, and agentkit's examples-first rule (family 5). Families 1–4 are buildable from analysis dockit already does or near-adjacent; family 6 is parked. All of these are **(repokit hypothesis)** — planned experiments, not established practice.

## Sources

| Source | Type | Why it matters |
|--------|------|----------------|
| [arXiv:2602.11988 — Evaluating AGENTS.md](https://arxiv.org/abs/2602.11988) | Academic paper (ETH Zurich SRI Lab) | The instruction-followed / overview-unhelpful split; "rigorously but counterproductively"; the gap-filler asymmetry (paper-body details not independently re-verified) |
| [Packmind — Evaluating context for AI coding agents](https://packmind.com/evaluate-context-ai-coding-agent/) | Practitioner field review | Stale context obeyed with full compliance (Jest/Vitest class of drift) |
| [agents-lint](https://github.com/giacomo/agents-lint) | OSS tool | Existence proof that checked-in agent context rots |
| [Anthropic — Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Vendor guidance | The per-line admission test; bloat warning |
| [HumanLayer — Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) | Practitioner article | <300-line consensus; ~150–200 instruction ceiling (practitioner numbers, not measured research) |
| [aider — repository map](https://aider.chat/2023/10/22/repomap.html) | Practitioner docs | The live per-turn ranking that static map clones drop |
| [Serena issue #802](https://github.com/oraios/serena/issues/802) | Issue | Agents forget pull tools exist after compaction |
| [Srikanth R — The Hidden Power of Markdown](https://www.linkedin.com/pulse/hidden-power-markdown-structuring-md-files-ai-coding-assistants-r-kdgof) | Practitioner article | Examples-propagate claim behind family 5 (anecdotal, not measured) |
| [Augment Code — How to Build AGENTS.md](https://www.augmentcode.com/guides/how-to-build-agents-md) | Practitioner guide | Independent statement of the write-only-the-non-discoverable rule |
| [Nygard — Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) / [MADR](https://adr.github.io/madr/) | Practitioner article / standard | Canonical ADR forms — the structure that shows ADRs span all three bands |
| [arXiv:2604.07192 — Compact Constraint Encoding](https://arxiv.org/abs/2604.07192) / [arXiv:2605.06445 — Constraint Decay](https://arxiv.org/abs/2605.06445) | Academic papers | Negative / counter-default constraints comply poorly; constraint pile-up degrades agents |
| [Chris Swan — Using ADRs with AI coding assistants](https://blog.thestateofme.com/2025/07/10/using-architecture-decision-records-adrs-with-ai-coding-assistants/) | Practitioner article | Best real source for the ADRs-as-agent-context thesis (unmeasured) |
| A production project's docs + generated agent (user-supplied, anonymized) | Field artifacts | The derivable-at-a-cost middle band: a visible choice, unknown at decision time |
| Working discussions, Zach, 2026-07-31 → 2026-08-01 | Conversation | Everything marked **(repokit hypothesis)**: the three-band generalization, choice families, evidence-label-as-drift-contract, composite pattern, naming verdict, orthogonal-axes framing — to be validated by experiment in repokit |

## Resolved (deliberately not doing)

- **Renaming FOUNDATIONS.md to CONVENTIONS.md.** Conflates thing with rule; breaks tools that read the file by name, for no informational gain.
- **A new file for mined choices.** Routed into existing homes (FOUNDATIONS entries, PRINCIPLES.md, trigger lines, hot memory).
- **Generating rationale under any confidence threshold.** The composite pattern (choice drafted, `[TODO: why?]` open) is the ceiling.
- **Restating machine-enforced rules.** Linter/formatter config self-enforces; a restated enforced rule fails the per-line test by construction.
- **ADR generation or scaffolding.** Reviewed the pro-ADR research (2026-08-01): the "ADRs as agent context" thesis is real but practitioner-only, and its headline quantitative claim (>60% regression reduction via rejected-option negative constraints, attributed to ACM/IEEE 2024) traces to a nonexistent paper — while real constraint research runs the other way. ADRs are composite artifacts whose choice content repokit's docs already carry; their unique payload (rationale) is revision-time and served by the `[TODO: why?]` slot plus on-demand storage. Their remaining marginal use is spec-phase decision review (a plan reopening a settled question), not generation-phase subagents. No ADR feature.

## Open questions

- **Family 6 (directional choices):** is git-recency inference ever safe enough to draft, or is legacy-vs-current permanently human-only? Wrong inversions are confidently harmful. Default: parked.
- **Conformance thresholds:** what N-of-M ratio justifies drafting a structural convention? No literature on the ratio; overall size budgets have practitioner numbers ([HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md): <300 lines, ~150–200 instruction ceiling) but those are consensus, not measurement. Ratio stays a labeled default (e.g., ≥80% with exceptions listed), revisited with evals.
- **Does choice-mining output stand alone** in the plain-harness configuration (no agentkit agents, docs only)? Untested.
- **The "surprising choices" filter:** the measured value of curated context concentrates in *non-obvious* facts, which suggests convention-mining needs a second filter beyond conformance — deviation-from-ecosystem-default (13/13 files following standard pytest layout is a true choice but fails the per-line test). How to detect "differs from default" mechanically is unspecified **(repokit hypothesis)**.
