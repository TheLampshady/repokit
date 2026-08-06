# Choice over Overview — Research

*Generate choices, defer rationale, cut overviews.*

**Written:** 2026-08-01
**Last updated:** 2026-08-06
**Original request:** Define the overview / choice / rationale spectrum as the content rule for everything repokit generates; map the general context-tooling landscape onto it; settle whether "foundations" should become "conventions"; and enumerate what actually belongs in the "choice" band.
**Charter:** `docs/research/CHARTER.md`
**Provenance:** Sourced claims cite primary sources inline; everything under Hypotheses is unmeasured. This doc stands alone.

## Summary

### Goal

Turn the measured instruction-vs-overview split into an operational taxonomy — what generation may emit, what it may draft for a human to confirm, and what it must never write — so choice-mining can be specified without crossing into invented judgment.

### Claims

14 findings, 20 hypotheses.

**Overview, choice, rationale** — Not everything about a codebase is worth documenting. Some things a reader works out instantly, some cost real effort to discover, and some can't be worked out from the code at all. Only the middle group pays for itself.

*Findings (sourced):*
- [Instructions are followed; repository overviews are not.](#f-instructions-over-overviews)
- [Project Context Conflicts are 24.56% of coding hallucinations.](#f-project-context-conflicts)
- [ADRs span all three bands by their own canonical structure.](#f-adrs-span-bands)
- [Agents forget pull tools exist after context compaction.](#f-pull-tools-forgotten)
- [No published ablation of a repo map's contribution exists](#f-no-repomap-ablation) *(absence claim)*.

*Hypotheses (unsourced):*
- [**H1**](#h1) — Documentation divides into three bands by recovery cost: free, costly, impossible.
- [**H2**](#h2) — Content earns its place only if novel, action-changing, and cheap to state.
- [**H3**](#h3) — Derivability isn't binary; documenting the costly middle pre-pays a discovery nobody makes.
- [**H9**](#h9) — The bands have task-type affinities; new work wants the middle one.
- [**H10**](#h10) — What a statement says is independent of when it reaches the reader.

**Mining choices from code** — Some team decisions leave visible traces: a file everyone routes through, a shape every similar file repeats. These claims are about which traces a tool can find, and which decisions leave none behind.

*Findings (sourced):*
- [Dependency retrieval favors recall over precision, explicitly.](#f-recall-over-precision)
- [Architecture conformance is commodity; the field keeps enforcement in the linter.](#f-conformance-commodity)
- [Agents replicate structure they see more strongly than prose they read.](#f-structure-propagates)

*Hypotheses (unsourced):*
- [**H13**](#h13) — Recoverable conventions partition by evidence source, which predicts the failure mode.
- [**H17**](#h17) — Some constraints are reachable by no analysis; asking is the only channel.
- [**H6**](#h6) — Missing true context costs more than including irrelevant context, for mining too.
- [**H8**](#h8) — An example is a rule in executable form, and the exemplar is recoverable.

**Writing a mined rule** — Once you know what to say, the wording decides whether it gets followed. These claims are about phrasing, and about what has to be left blank because only a person knows it.

*Findings (sourced):*
- [Negative constraints comply measurably worse than positive ones.](#f-negative-constraints)

*Hypotheses (unsourced):*
- [**H18**](#h18) — Naming the anti-pattern inside a positive instruction beats both the bare instruction and the prohibition.
- [**H7**](#h7) — A useful rule composites a recoverable constraint with an unrecoverable reason.
- [**H16**](#h16) — Worth writing only if the drafter can name the alternative not taken.
- [**H19**](#h19) — A status marker is read as qualifying the rule's force, not the code's state.

**What a foundation entry must express** — A description of what already exists cannot tell someone where it is fine to build something new. These claims are about the gap that leaves.

*Findings (sourced):*
- [SDD frameworks carry conventions in known file locations.](#f-sdd-locations)

*Hypotheses (unsourced):*
- [**H14**](#h14) — A doc that only describes what exists can't say where building new is correct.
- [**H21**](#h21) — Mined conventions have existing homes; this is a content problem, not a structural one.

**Keeping generation safe** — A tool that writes documentation will sometimes write something wrong, and wrong instructions get followed as readily as right ones. These claims are about limiting the damage rather than trying to prevent it.

*Findings (sourced):*
- [Instructions are followed even when wrong — an obeyed error, not noise.](#f-obeyed-error)
- [Checked-in agent context rots: 23% of 356 repos carried stale code references.](#f-context-rot)
- [The overview ban is conditional on the repo already being documented.](#f-overview-ban-conditional)
- [Practitioner consensus caps context files at <300 lines, ~150–200 instructions.](#f-size-consensus)

*Hypotheses (unsourced):*
- [**H11**](#h11) — Generation's value is band-dependent and conditional on existing documentation.
- [**H12**](#h12) — Strength tiers cap harm better than a confirmation gate, if the document declares them.
- [**H15**](#h15) — Mined and declared rules read identically unless separated by origin.
- [**H22**](#h22) — A filtered document regrows; a budget needs ranked eviction, not silent truncation.
- [**H20**](#h20) — Post-write review trades a hard failure for a soft one, and the soft one is likelier.

## Key findings

- <a id="f-instructions-over-overviews"></a>**Instructions are followed; repository overviews are not.** *"Instructions in the context files are well followed by coding agents [while] repository overviews … are not helpful"*; context files are *"useful for specifying non-standard coding practices"* ([ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd)). The publisher page confirms the venue (MemAgents @ ICLR 2026, Oral & Runner-up Best Paper) and the headline — *"no improvement in task success rates, while also increasing inference cost by over 20%"* — and concludes that human-written context files "should describe only minimal requirements."

- <a id="f-obeyed-error"></a>**Instructions are followed even when wrong, so the guardrails are load-bearing.** The agents followed context-file instructions *"rigorously but counterproductively"*, adding steps per task when the instructions were bad ([ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd) — specific step counts are paper-body detail, not independently verified here). Field audits report agents obeying stale claims ("we use Jest," surviving a Vitest migration) with full compliance ([Packmind](https://packmind.com/evaluate-context-ai-coding-agent/)). A wrong choice statement is not neutral noise; it is an obeyed error.

- <a id="f-negative-constraints"></a>**Negative constraints are the weak spot of instruction-following.** Constraints that oppose model defaults fail at 10–100% rates against 99%+ compliance for conventional ones, and negative phrasing ("don't use Y") is measurably harder for LLMs than positive ([arXiv:2604.07192](https://arxiv.org/abs/2604.07192)); piling on structural constraints can degrade agent pass rates outright ([arXiv:2605.06445](https://arxiv.org/abs/2605.06445)). This also kills the strongest circulating pro-ADR claim — a ">60% regression reduction from rejected-option negative constraints," attributed to a 2024 ACM/IEEE paper that does not exist.

- <a id="f-context-rot"></a>**Checked-in agent context rots, and it has been measured.** DOCER over **612 config files across 356 repos found 23.0% carrying stale code references — 230 total, 64% confirmed genuine on manual validation** ([Treude & Baltes](https://arxiv.org/html/2606.09090)), which also names the phenomenon *context rot* and recommends reusing existing documentation-consistency tooling rather than inventing new mechanisms. A dedicated linter exists for the same reason ([agents-lint](https://github.com/giacomo/agents-lint); [Packmind](https://packmind.com/evaluate-context-ai-coding-agent/)). The staleness measured is *does the named element still exist* — descriptive, not a conformance ratio on a directive.

- <a id="f-overview-ban-conditional"></a>**The overview ban is conditional on the repo being documented.** With other documentation removed, LLM-generated context files *did* help ([ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd) — paper-body finding, not independently verified here). Auto-generation is defensible on doc-barren repos and net-negative on documented ones; the asymmetry is the finding, not a flat ban.

- <a id="f-project-context-conflicts"></a>**The failure the choice band exists to prevent has a name and a measured frequency.** A hand-annotated taxonomy of hallucinations across six models puts **Project Context Conflicts at 24.56%** of all coding hallucinations, dominant subtype **Dependency Conflicts at 11.26%** — the model inventing project-internal functions that don't exist. Their worked example is a model calling `generate_default_schema()` when the repository defines `generate_default_observer_schema_dict()`. Root-cause analysis names **repository-level context awareness** as one of four contributing factors ([arXiv:2409.20550](https://arxiv.org/abs/2409.20550) / [PACMSE](https://dl.acm.org/doi/10.1145/3728894); percentages verified against the paper body).

  **Two caveats, both load-bearing.** Their RAG mitigation improved Pass@1 by only **0.87–3.05 points** across six models, so "supply repository context and the hallucination goes away" is *not* established — the paper supports the problem statement far more strongly than any solution. And the model cohort (CodeGen, PanGu-α, ChatGPT, CodeLlama, StarCoder2, DeepSeekCoder) is stale relative to 2026 frontier models, so the *rates* should not be quoted forward. The field's term is **Project Context Conflict**; "architectural hallucination" is repokit's coinage and is not established terminology.

- <a id="f-recall-over-precision"></a>**Retrieval evidence favors recall over precision.** On repository-level generation benchmarks, sparse and dense retrievers reach recall 0.51–0.57 at precision <0.09–0.12, while a dependency-aware retriever reaches 0.89–0.92 recall at modest precision. The authors defend the trade verbatim: *"for code generation, failing to retrieve true dependencies is far more damaging than including some irrelevant context"* ([arXiv:2602.11671](https://arxiv.org/pdf/2602.11671) — quote and figures verified in the paper body, not the abstract). Similarity-based retrieval does worst on *class* dependencies (functions 0.65–0.75, variables <0.4).

- <a id="f-conformance-commodity"></a>**Architecture conformance is a commodity, and the field keeps enforcement out of the document.** [ArchUnit](https://www.archunit.org/), [import-linter](https://import-linter.readthedocs.io/), and [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) enforce architectural rules on the hot path — pre-commit, CI, build failure. [Factory.ai](https://factory.ai/news/using-linters-to-direct-agents) states the split independently: prose establishes *why* a standard matters, linting creates the *guarantee*, with each prose guideline mapped to a lint rule ID. Decision-record practice agrees from the other side — records are point-in-time and effectively never machine-verified, with a human review cadence and a "last verified" date as the accepted remedies and automated tests recommended as a *separate* mechanism ([techdebt.best](https://techdebt.best/architectural-decisions/); [Azure Well-Architected](https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record)). Executable-documentation prior art marks the same boundary: what gets tested is documented procedures and examples, never a conformance ratio on a directive ([Docs as Tests](https://www.docsastests.com/); Rust doc-tests).

- <a id="f-structure-propagates"></a>**Agents replicate structure they see more strongly than prose they read** ([Srikanth R](https://www.linkedin.com/pulse/hidden-power-markdown-structuring-md-files-ai-coding-assistants-r-kdgof) — practitioner claim, not measured).

- <a id="f-size-consensus"></a>**Practitioner consensus caps context-file size at <300 lines and ~150–200 instructions** ([HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — practitioner numbers, not measured research). The write-only-the-non-discoverable rule is stated independently ([Augment Code](https://www.augmentcode.com/guides/how-to-build-agents-md); [Anthropic](https://code.claude.com/docs/en/best-practices), which also supplies the per-line admission test: would removing this line cause an agent to make a mistake?).

- <a id="f-no-repomap-ablation"></a>**No published ablation of a repository map's contribution to task success was found** *(absence claim)*. Aider's map is re-ranked per conversation turn ([aider](https://aider.chat/2023/10/22/repomap.html)); static checked-in map clones drop exactly that step, and nothing measures the difference.

- <a id="f-pull-tools-forgotten"></a>**Agents forget pull tools exist after context compaction** ([Serena issue #802](https://github.com/oraios/serena/issues/802)) — a documented pull-surface failure, not a claim about map quality.

- <a id="f-adrs-span-bands"></a>**ADRs span all three bands by their own canonical structure.** Per [MADR](https://adr.github.io/madr/): Decision Outcome = choice, Context = overview, Drivers / Rejected Options / Consequences = rationale ([Nygard](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions)). Evidence for ADRs-as-agent-context is practitioner-only ([Chris Swan](https://blog.thestateofme.com/2025/07/10/using-architecture-decision-records-adrs-with-ai-coding-assistants/)).

- <a id="f-sdd-locations"></a>**SDD frameworks carry conventions in known locations**, verified 2026-08-01: [SpecKit](https://github.com/github/spec-kit) `.specify/memory/constitution.md`; [OpenSpec](https://github.com/Fission-AI/OpenSpec) `openspec/project.md` and `openspec/AGENTS.md`; [Conductor](https://github.com/gemini-cli-extensions/conductor) `conductor/product-guidelines.md`, `conductor/workflow.md`, `conductor/code_styleguides/`.

## Hypotheses

Positions developed in working discussions (2026-07-31 → 2026-08-04) rather than found in literature: unmeasured, and the reason the Actions below are worth taking. IDs are permanent — assigned once, never renumbered, never reused — so they do not run in order within a group.

### Overview, choice, rationale

<a id="h1"></a>**H1 — Documentation of a codebase divides into three bands by what it costs a reader to recover: what is derivable by reading, what is a decision visible in the code as evidence, and why the decision was made — which is recoverable from code at no cost, at a cost, and not at all.** · *open* · added 2026-08-01
- **Builds on:** the measured instruction/overview split ([ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd)) — extends a two-type result by separating a third band it does not address.
- **Unsourced because:** Searched for prior three-band taxonomies of context-file content; found only the two-type split, which stops short of separating rationale.
- **Check:** Two independent raters classify a sample of real context files into the three bands. The taxonomy earns its keep only if the middle band is separable in practice.

<a id="h2"></a>**H2 — Content is worth writing for an agent only when it is novel to the reader, action-changing at the moment of reading, and cheap to state — and only the middle band clears all three.** · *open* · added 2026-08-01
- **Builds on:** [H1](#h1).
- **Unsourced because:** No published admission test beyond the per-line "would removing this cause a mistake?" heuristic, which is a weaker version of the same idea.
- **Check:** Apply the three-part test and the per-line test to the same file. If they never disagree, the three-part framing is decoration.

<a id="h3"></a>**H3 — Derivability is not binary: a fact can be fully visible in the code and still unknown at decision time, because discovery has a cost and an agent under task pressure declines to pay it. Documenting such a fact pre-pays that discovery once and converts it into something every later reader gets for free.** · *open* · added 2026-08-01
- **Unsourced because:** Searched for cost-of-discovery or amortization models for agent context; found none. The nearest measured work is dependency-retrieval recall ([arXiv:2602.11671](https://arxiv.org/pdf/2602.11671)), which is about fetching, not pre-paying. The band itself rests on a field observation rather than literature: in a production project (user-supplied, anonymized), an implement agent hand-rolled vendor-SDK calls though the shared client was fully visible, and stopped the moment the docs surfaced it. n=1, uncontrolled.
- **Check:** Same task, same repo, two arms — with and without the mined boundary rule. Does the agent route through the wrapper on first write?

<a id="h4"></a>**H4 — Retired 2026-08-06, merged into [H3](#h3).** Stated the derivable-at-a-cost band as a separate position, but it resolved on the same experiment, so it was never a separate hypothesis. ID kept dead rather than reused.

<a id="h9"></a>**H9 — The bands have task-type affinities: new work turns on the build-versus-reuse moment and wants the choice band, revision work is where rationale pays, and navigation is served by retrieval on demand.** · *open* · added 2026-08-01
- **Builds on:** [H1](#h1).
- **Unsourced because:** Searched for task-type breakdowns of context-file value; the measured work reports aggregate task success, not per-task-type deltas.
- **Check:** Segment an eval by task type and compare per-band contribution. Requires a task corpus repokit does not yet have.

<a id="h10"></a>**H10 — What a statement says is independent of when it reaches the reader: content band and delivery mode are orthogonal axes, and both have to be right for the statement to land.** · *open* · added 2026-08-01
- **Unsourced because:** Both axes appear separately in the literature; nothing states their independence. The delivery-failure half has a documented instance ([Serena #802](https://github.com/oraios/serena/issues/802)) but that's one point, not the claim.
- **Check:** Deliver the same mined choice push-only and pull-only on the same task. Equal outcomes refute the orthogonality.

### Mining choices from code

<a id="h13"></a>**H13 — Conventions recoverable from code partition by evidence source, and the evidence source predicts the failure mode — so a detector's trustworthiness is a property of what it looks at, not of how much it finds.** · *open* · added 2026-08-01, extended 2026-08-02
- **Builds on:** [H3](#h3).
- **Unsourced because:** Searched for existing taxonomies of mineable code conventions; found detector-specific work but no classification by evidence source. The six families this yields are listed under *How this applies*; family 1b was added after a field report where two of four blind spots were ambient-capability leaks a vendor-SDK detector could never see, which is itself evidence that the partition is incomplete rather than settled. The ≥90% concentration threshold for 1b is a proposal with nothing behind it.
- **Check:** Run all six detectors against repos with known conventions and count precision and recall per family. Whether 1a and 1b are one family or two is part of the same check.

<a id="h17"></a>**H17 — Some load-bearing constraints are reachable by no analysis at any cost, because code that complies with them is indistinguishable from ordinary code. They exist only because someone shipped the obvious version and watched it fail, so asking directly is the only channel that reaches them.** · *open* · added 2026-08-02
- **Builds on:** [H3](#h3) — the boundary case on the far side of derivable-at-a-cost.
- **Unsourced because:** The motivating case is a field artifact — *"exclude numeric and date fields from facet requests; the vendor returns 400"* — which no import graph implies and no conformance count suggests. n=1, and no literature on eliciting non-derivable constraints.
- **Check:** Ask the question across a set of components, with "nothing" a valid answer. Measure what fraction yield an answer, whether answers are genuinely non-derivable or merely not-yet-derived, and whether repeated asking trains users to dismiss the channel.

<a id="h6"></a>**H6 — The retrieval finding that missing true context costs more than including irrelevant context carries over to mining, which cuts against any threshold justified purely as noise reduction.** · *open* · added 2026-08-02
- **Builds on:** the recall-over-precision result ([arXiv:2602.11671](https://arxiv.org/pdf/2602.11671)).
- **Unsourced because:** The transfer is ours and nothing tests it. The mechanisms differ — a retriever's false positive costs tokens, a document's false positive is an obeyed error.
- **Check:** Vary the threshold across runs on the same repo and count both missed real conventions and written-but-wrong rules. If the second curve is flat, recall should win.

<a id="h8"></a>**H8 — An example is a rule in executable form, and which instance serves as the exemplar is itself recoverable from code (most-conforming, most-referenced).** · *open* · added 2026-08-01
- **Builds on:** the examples-propagate claim ([Srikanth R](https://www.linkedin.com/pulse/hidden-power-markdown-structuring-md-files-ai-coding-assistants-r-kdgof) — anecdotal).
- **Unsourced because:** Nothing measures whether an *automatically selected* exemplar carries the same weight as a hand-picked one.
- **Check:** Compare agent output against a hand-picked exemplar versus the automatically selected pick on the same convention.

### Writing a mined rule

<a id="h5"></a>**H5 — Retired 2026-08-06, merged into [H18](#h18).** Stated the repair for weak prohibition-compliance as a positive instruction naming the wrong path and the fix — the position [H18](#h18) states measurably, resolving on the same three-arm experiment. ID kept dead rather than reused.

<a id="h18"></a>**H18 — The repair for weak compliance with prohibitions is a positive instruction that names the anti-pattern and the fix: naming the wrong path inside a positive instruction improves compliance over both the bare positive instruction and the same rule phrased as a prohibition.** · *open* · added 2026-08-04, absorbed [H5](#h5) 2026-08-06
- **Builds on:** the negative-constraint compliance gap ([arXiv:2604.07192](https://arxiv.org/abs/2604.07192)).
- **Unsourced because:** The compliance gap is measured; this construction — positive imperative carrying the anti-pattern plus a repair — is ours, and no source tests this particular repair. Originally proposed as a positive rule backed by a stored predicate; the predicate was removed (see Decisions) and the anti-pattern harvested into the visible line instead: *"direct `os.environ` reads bypass validation and defaults — add a field to `Settings`."* The stored-predicate question it replaced turned out to be structurally unanswerable (see Decisions).
- **Check:** Three arms, same task and repo: rule alone; rule plus named anti-pattern plus repair; rule as prohibition.

<a id="h7"></a>**H7 — A useful documented rule is usually a composite of a recoverable constraint and an unrecoverable reason, so the two halves need separate treatment inside one entry rather than one voice covering both.** · *open* · added 2026-08-01
- **Builds on:** [H1](#h1).
- **Unsourced because:** No literature on splitting a documented rule into inferable and non-inferable halves. The composite is observable in real invariants — "exclude boolean fields from facet requests *(constraint)* because the vendor returns 400s *(reason)*" — but that's an example, not evidence.
- **Check:** Sample real invariants from a production project and count what fraction decompose cleanly. A low fraction means the seam is imaginary.

<a id="h16"></a>**H16 — A pattern is worth documenting as a rule only if the drafter can name the plausible alternative that was not taken; without one, the pattern is the path of least resistance rather than a selection.** · *open* · added 2026-08-01
- **Builds on:** [H2](#h2) — a mechanical stand-in for the novelty term.
- **Unsourced because:** Substitutes for a comparison against ecosystem baselines that has no mechanical implementation. Needs no corpus and no defaults database, only the drafting model's own priors — which is exactly the knowledge that makes a fact obvious-or-not to the agent reading it downstream. Nothing tests whether that substitution holds.
- **Check:** Run the filter over a set of known-obvious and known-surprising conventions and measure discrimination. Open risk: a sufficiently fluent drafter can name an alternative for anything, so the filter may under-cut.

<a id="h19"></a>**H19 — A status marker attached to an instruction is read as qualifying the instruction's force, not the state of the code it describes.** · *open* · added 2026-08-04
- **Cuts against:** [H12](#h12) — if a marker is read as force, it silently overrides the tier the document declared, and the tier model only works if nothing else moves force.
- **Unsourced because:** No source on how agents read status markers on instructions. The design intends the opposite — a Convention stays deviable-with-a-reason and a Rule stays not, marker or no marker — but design intent isn't behavior.
- **Check:** The [H18](#h18) setup plus a marked arm on a component with zero consumers. The failure mode is asymmetric: reading the marker as weakening the rule is exactly what keeps a new sanctioned path unused.

### What a foundation entry must express

<a id="h14"></a>**H14 — A component document that only describes what exists cannot say where building something new is correct, so a reader meeting an uncovered case either forces the work through the wrong abstraction or breaks a rule it cannot tell is soft.** · *open* · added 2026-08-01
- **Builds on:** [H9](#h9) — the gap falls exactly on the task type the choice band is aimed at.
- **Unsourced because:** No source on what fields an agent-facing component catalog needs. The gap is observable but observing a gap isn't measuring one. Of the two fields proposed to close it (A5, A6), the sanctioned-path one is confidently draftable from scaffold commands, registries, and files that changed together across recent additions; the deliberate-edge one is only half-inferable, since absence carries no marker distinguishing an intentional boundary from an unfinished feature from a bug.
- **Check:** Give agents a task falling outside every documented component, with and without the two fields, and compare what they build.

<a id="h21"></a>**H21 — Mined conventions have natural homes in the documentation a project already keeps, so convention-mining is a content problem rather than a structural one.** · *open* · added 2026-08-01
- **Unsourced because:** An architectural prediction; nothing external bears on it.
- **Check:** Build the first four detectors and route their output. A new file or mode turning out to be necessary refutes it.

### Keeping generation safe

<a id="h11"></a>**H11 — The value of generating documentation is band-dependent and conditional on what documentation already exists: overview written into a documented repo is net-negative and into a barren one it helps, while rationale is unsafe to generate at any documentation level.** · *open* · added 2026-08-01
- **Builds on:** [H1](#h1) and the conditional gap-filler result ([ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd)).
- **Unsourced because:** The overview half rests on the measured result plus its exception; the pointer form, the posture switch, and the never-synthesize rule are ours. No source tests a conditional generation posture.
- **Check:** Run generation under both postures on a documented and a doc-barren repo, and compare agent task success against no generated context at all.

<a id="h12"></a>**H12 — Tiering instructions by strength caps the harm of a wrong one better than gating writes on human confirmation, because a gate that blocks output produces a queue nobody drains — and the tiers exist only if the document declares them.** · *open* · added 2026-08-01
- **Builds on:** the obeyed-error finding ([ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd); [Packmind](https://packmind.com/evaluate-context-ai-coding-agent/)).
- **Unsourced because:** No literature on tiering agent-facing instructions by strength. The argument is asymmetric harm — a wrong soft rule costs misplaced consistency, a wrong hard rule blocks correct work — which is reasoning, not evidence.
- **Check:** Does an agent given a two-line legend deviate from the soft tier with a stated reason and refuse to deviate from the hard one? Same task, legend present and absent.

<a id="h15"></a>**H15 — Mined and human-declared rules read identically to an agent unless the document separates them by origin, which is how a coincidental pattern gets obeyed as law.** · *open* · added 2026-08-01
- **Builds on:** [H12](#h12) — origin is what the tier is supposed to encode.
- **Unsourced because:** No source addresses organizing rules by origin rather than topic. The failure it targets is real in shape — topic organization renders a coincidental 11-of-13 pattern in the same voice as a mandatory constraint — but unmeasured.
- **Check:** Ask raters to identify which lines in a topic-organized file are mined versus declared. Poor accuracy is the case for the split.

<a id="h22"></a>**H22 — A filtered document regrows across syncs, so holding a size budget requires ranked eviction with the weakest line named; silent truncation is worse than a visible ranking because nobody sees what left.** · *open* · added 2026-08-06
- **Builds on:** [H15](#h15) — the ranking needs origin to rank on.
- **Unsourced because:** Split out of [H15](#h15) on 2026-08-06; it resolves on a different experiment. The size numbers are practitioner consensus ([HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)), not measurement, and nothing addresses eviction policy.
- **Check:** Track file size and rule count across repeated syncs on a live repo, with and without a budget. Does the file converge or creep?

<a id="h20"></a>**H20 — Deferring review to a post-write channel trades a hard failure (a gate stalls output) for a soft one (output accumulates unreviewed), and the soft failure is the more likely of the two.** · *open* · added 2026-08-01
- **Builds on:** [H12](#h12) — the tier model is what makes post-write review the design rather than a compromise.
- **Unsourced because:** Which failure actually occurs is unmeasured.
- **Check:** Instrument the review walk and measure completion rate over real syncs.

## How this applies to repokit

The measured result is narrow — instructions get followed, overviews don't, and a wrong instruction gets followed too. Everything repokit wants to do with it depends on [H1](#h1) holding: that the useful residue between "derivable, so worthless" and "not derivable, so unwritable" is a real band and not a gradient someone drew a line across.

If it is real, the consequences chain. The economics ([H3](#h3)) say mining is worth building at all — not because the information is unavailable, but because it's available at a cost every agent declines to pay under task pressure. The obeyed-error finding says a wrong mined line is worse than no line, which is what forces the tier model ([H12](#h12)) rather than a confirmation gate: gating on human review produces a queue nobody drains, so the safety valve has to cap harm instead of preventing writes. The negative-constraint finding then routes the highest-risk output — prohibitions — into the lowest tier with a named anti-pattern attached ([H18](#h18)).

Two findings pull against the design rather than supporting it, and both are live. Recall-over-precision ([H6](#h6)) argues that conformance thresholds justified as noise reduction are cutting the wrong way; the retrieval authors are explicit that missing a true dependency costs more than including an irrelevant one, and if that transfers, repokit's instinct to filter hard is a mistake. And the commodity finding says architecture conformance belongs in the linter, on the hot path — which is what removed stored predicates entirely and left mining with a narrower job than it started with: direct future work, don't audit past work.

The naming question resolves against renaming. A **foundation** is a thing (module, path, API, owner); a **convention** is a rule, a pattern of choice possibly attached to no module. Conventions already have homes — PRINCIPLES.md for codebase-wide rules, per-foundation entries for foundation-scoped ones — and FOUNDATIONS.md is a tooling contract that agentkit and dockit sync read by name.

On the specific question of whether choice is obtainable from code alone: five of the six families in [H13](#h13) are draftable from code as it sits. Code yields the *draft*; a human supplies the *confirmation* (was this intentional?) and the *why*. That division is what the whole spectrum encodes, and it's why [H7](#h7)'s `[TODO:]` seam is structural rather than a politeness.

### One subject, three bands

The same fact about a codebase written in each band, using the anonymized field case (a shared client wrapping a vendor search SDK):

> **Overview** — *don't generate; the agent learns this by reading the file*
> "`search/client.py` provides an abstraction layer over the vendor search SDK. It handles authentication, request construction, and response parsing, and exposes a unified interface for API handlers."

> **Choice** — *generate: instruction + pointer + named anti-pattern, at Convention tier*
> "Use `SearchClient` (`search/client.py`) for all vendor-search operations — direct SDK imports bypass retry and auth handling. `[TODO: intentional rule or accident?]`"

> **Rationale** — *never generate; human-supplied, stored for revision time*
> "We wrapped the SDK because raw calls leaked retry and auth handling into handlers and broke during a vendor migration. Direct SDK use was considered and rejected. Revisit if the vendor ships a stable async client."

Only the middle one belongs in generation's output; only the last matters when someone proposes replacing the client; the first is what most auto-generated docs consist of.

### The spectrum, applied

Band assignments are [H1](#h1) applied to specific artifacts; per-tool behavior claims carry their own citations.

| Artifact / tool | Band | Notes |
|---|---|---|
| Repo maps ([aider](https://aider.chat/2023/10/22/repomap.html), [RepoMapper](https://github.com/pdavis68/RepoMapper)) | Overview | Aider re-ranks per turn; static checked-in clones drop that step |
| Code graphs (CodeGraph, GitNexus, CodeGraphContext) | Overview (queryable, pull) | Execution-phase retrieval; carries no selection |
| Symbol servers ([Serena](https://github.com/oraios/serena) / LSP) | Overview on demand | Answers "where/what," never "which one is ours" |
| Repo packers / flatteners | Overview, maximal | The extreme case of paying for the derivable |
| [llms.txt](https://llmstxt.org/) | Overview (index) | Pointer-shaped, so the tolerable form |
| Auto-generated AGENTS.md summaries | Overview | The measured net-negative case |
| Purpose/architecture prose in generated docs | Overview risk zone | Allowed only as one-line pointers |
| FOUNDATIONS catalog rows | Pointer (compressed overview) | Earns tokens by routing, not describing |
| Build/test/scaffold commands | Choice (config-encoded) | The classically useful context-file content |
| `Use when:` trigger lines | Choice (task → chosen tool) | The routing form of a boundary choice |
| Agent descriptions (agentkit) | Choice, rendered for the router | Same content as trigger lines, on the push surface |
| Wrapper rules | Choice (boundary) | Import-graph evidence; family 1a |
| Ambient-capability rules | Choice (boundary) | Grep-and-concentrate evidence; family 1b |
| Structural conventions | Choice (repetition) | Conformance-count evidence |
| Extension-point rules | Choice (sanctioned path) | The most task-shaped choice |
| Canonical code examples (hot memory) | Choice (executable form) | [H8](#h8) |
| Invariants | Choice + rationale composite | [H7](#h7) |
| PRINCIPLES.md | Choice (codebase-wide) + rationale | The existing home for module-less rules |
| ADRs | Composite: all three bands | Per [MADR](https://adr.github.io/madr/)'s own structure |
| SDD artifacts | Rationale + chosen principles | Usually agent-generated, so not authoritative |
| context7 / external library docs | Off-spectrum | Third-party reference, not repo-derived |
| Per-task user context | Off-spectrum | Never a project artifact |

### The six choice families

Classified by **evidence source**, because evidence determines confidence and failure mode. This is [H13](#h13); the detectors are A16.

1. **Boundary choices** — one module is the only sanctioned door to a capability. Two shapes. **1a, vendor boundary:** a project module wrapping a third-party SDK, found by listing its third-party imports and counting importers of those packages elsewhere. **1b, ambient-capability boundary:** one module owning access to something globally reachable with no manifest entry — env vars, the clock, randomness, DB connections, outbound HTTP. Detection is a grep for the accessor across the tree, grouped by containing module, with a concentration threshold (proposed ≥90%). Both emit the same output form. Failure mode: the wrapper is vestigial and the team abandoned it.
2. **Structural conventions** — repeated shape across instances: naming, return types, layering, registration. Evidence: N-of-M conformance counts. Failure mode: coincidence read as rule.
3. **Extension-point choices** — the sanctioned way to add a new X. Evidence: the scaffolding or registry exists and past additions used it. The most valuable family, because it's natively task-shaped.
4. **Config-encoded choices** — selections visible in config or dependencies that nothing machine-enforces. Explicitly excludes anything a linter already enforces.
5. **Canonical-example selection** — which instance is the exemplar. Evidence: most-conforming plus most-referenced.
6. **Directional choices** — old and new patterns coexist and new code uses the new one. Evidence: git recency. **Highest-risk family** — can invert the truth, since the newer pattern might be the failed experiment. Parked.

A wrapper is not a convention: the wrapper is an *artifact*, "route through it" is the rule it implies, and as a detector family it's distinct because its evidence is the import graph rather than repetition. They meet only at the output format.

## Actions

**FOUNDATIONS.md, per entry:**

- **A1 — Lead each entry with a `Use when:` trigger line, then invariants, positively phrased** · *proposed*
  **Because:** [H9](#h9), [H11](#h11), [arXiv:2604.07192](https://arxiv.org/abs/2604.07192)
- **A2 — Demote purpose prose to pointer form (one line: existence, location, chosen-ness); keep the catalog table pure pointers** · *proposed*
  **Because:** [H1](#h1), [H10](#h10), [H11](#h11), [ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd)
- **A3 — Give every invariant an explicit rationale slot as an inline collapsed block (`<details><summary>Why</summary>`) directly beneath its rule, holding the reason and the rejected alternative** · *proposed*
  **Because:** [H7](#h7), [H16](#h16)
- **A4 — Replace the public-API signature list with a canonical call site lifted from the best-conforming consumer** · *proposed*
  **Because:** [H8](#h8), [Srikanth R](https://www.linkedin.com/pulse/hidden-power-markdown-structuring-md-files-ai-coding-assistants-r-kdgof)
- **A5 — Add an `Extend by:` field, inferred from scaffold commands, registry files, and the files that changed together across recent additions** · *proposed*
  **Because:** [H14](#h14), [H13](#h13) (family 3)
- **A6 — Add a `Doesn't cover:` field: draft the observation, mark the intent question** · *proposed*
  **Because:** [H14](#h14), [H7](#h7)
- **A7 — Admit lines by the per-line test at write time** · *proposed*
  **Because:** [H2](#h2), [Anthropic](https://code.claude.com/docs/en/best-practices)

**PRINCIPLES.md:**

- **A8 — Narrow to choices: codebase-wide conventions as positive instructions, each with an exception list** · *proposed*
  **Because:** [H11](#h11), [arXiv:2604.07192](https://arxiv.org/abs/2604.07192)
- **A9 — Split the file by modality — an observed section (mined, Convention tier) and a declared section (human-owned, Rule tier, never auto-edited)** · *proposed*
  **Because:** [H15](#h15), [H12](#h12)
- **A10 — Apply the name-the-alternative filter at draft time; cut the line when no alternative can be named** · *proposed*
  **Because:** [H16](#h16), [H6](#h6)
- **A11 — Exclude machine-enforced rules entirely** · *proposed*
  **Because:** [H2](#h2), [Factory.ai](https://factory.ai/news/using-linters-to-direct-agents)
- **A12 — Keep the decisions table's rationale column and leave it `[TODO: why?]` when unfilled** · *proposed*
  **Because:** [H7](#h7), [ETH SRI](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd)
- **A13 — Cut derivable sections: test-directory trees, test command lists, and anything a formatter or type checker enforces** · *proposed*
  **Because:** [H11](#h11), [Augment Code](https://www.augmentcode.com/guides/how-to-build-agents-md)
- **A14 — Enforce no second disclosure level: principles link to code, never to further principle sub-docs** · *proposed*
  **Because:** [H11](#h11)
- **A15 — Carry a size budget (~200 lines and ~40 rules for PRINCIPLES.md, ~8 invariants per foundation entry) producing a weakest-first review list, never a silent drop** · *proposed*
  **Because:** [H22](#h22), [HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)

**Detection and delivery:**

- **A16 — Build detectors for families 1–4 in dockit's detection layer, extending the existing fan-in / cross-feature analysis; leave family 6 unbuilt** · *proposed*
  **Because:** [H13](#h13), [H3](#h3)
- **A17 — Emit every mined rule at Convention tier as a positive instruction carrying a named anti-pattern and a repair, with `[intended]` where the code hasn't caught up** · *proposed*
  **Because:** [H12](#h12), [H18](#h18), [H19](#h19)
- **A18 — Declare a two-line Convention/Rule legend at the top of every generated file that carries tiered content** · *proposed*
  **Because:** [H12](#h12)
- **A19 — Route human-required items — unconfirmed conventions, empty rationale slots, `Doesn't cover:` intent questions, promotion candidates, SDD discrepancies — into the maintenance hub's existing status mode, read-only until the user opts into the walk** · *proposed*
  **Because:** [H20](#h20), [H21](#h21)
- **A20 — Implement compare-never-merge for SDD artifacts: read whichever are present, write to none, report the three-way delta (present only upstream / present only locally / directly contradictory)** · *proposed*
  **Because:** [H21](#h21), [SpecKit](https://github.com/github/spec-kit), [OpenSpec](https://github.com/Fission-AI/OpenSpec), [Conductor](https://github.com/gemini-cli-extensions/conductor)
- **A21 — Add a one-time `[TODO: known hazard?]` marker per foundation at registry entry or hotspot flip, with "nothing" a valid closing answer** · *proposed*
  **Because:** [H17](#h17)

## Decisions (deliberately not doing)

- **Stored predicates and any ongoing conformance measurement** (decided 2026-08-04). Dockit measures a pattern once, to earn the right to write a mined rule, then discards the command. It never re-measures an existing line. Three reasons, in order of force:

  1. **The check never reached the reader who could act on it.** Agentkit strips `dockit:` comments when copying invariants into agent hot memory, by explicit design — "those are sync's business." The predicate ran at sync time, in a report, to a human. The agent never saw it. So the mitigation prescribed for the negative-constraint finding was structurally incapable of doing the job it was credited with, and no A/B was needed to establish that. Fatal on its own.
  2. **Conformance isn't truth for a directive.** "All config comes from `Settings`" with three violating files is not a *false* sentence; it's a disobeyed one. Measuring that is a compliance audit, a different job from keeping documentation honest. Choice docs **direct future work** — they are not state trackers, and the two goals were conflated.
  3. **Commodity, and done better elsewhere.** [ArchUnit](https://www.archunit.org/), [import-linter](https://import-linter.readthedocs.io/), and [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) enforce architectural rules on the hot path. A stored `grep` in a docs comment is a worse version of a solved problem, and the charter says to wrap or recommend commodity capability rather than build it.

  **Corollary — removal requires feature work, not decay.** A mined rule is removed only when the subject of the sentence disappears: the module deleted, the capability gone. Never because the rule became unpopular. `SearchClient` deleted → the rule goes. `SearchClient` bypassed in four new files → the rule stays exactly as written, because a directive being ignored is an argument for keeping it. This also removed the "N/M conform (100%)" roll call and the decay-disambiguation row from the review queue.

  **What this does not remove: drift detection.** Sync still compares checkable claims against code, and `--deep` still verifies that every referenced path, symbol, command, and named anti-pattern resolves. Context rot is measured ([Treude & Baltes](https://arxiv.org/html/2606.09090)) — but what they measured is *does the thing this doc names still exist*, the descriptive check, not a conformance ratio on a prescriptive rule.

- **Writing boundaries as explicit prohibitions** (decided 2026-08-01, re-decided 2026-08-04). On 2026-08-02 the opposite position — that boundaries need explicit prohibitions because negative space is what positive guidance can't supply — was written into the choice-mining guide as settled reasoning, in direct contradiction of the measured 10–100% failure rates. It was caught on re-reading this document and reverted the same day. Recorded because the generalization matters: a plausible mechanism argued from first principles will beat a cited finding in a drafting agent's attention unless the corpus is actually re-read.

- **Running an A/B on the stored predicate's effect on authoring behavior** (decided 2026-08-04). The question was well-posed and would have measured something the architecture made impossible. Reading the data path first was cheaper than the eval. Worth remembering as a class of mistake — an experiment on a mechanism whose wiring nobody traced.

- **Renaming FOUNDATIONS.md to CONVENTIONS.md.** Conflates thing with rule, and breaks the tools that read the file by name, for no informational gain.

- **A new file for mined choices.** Routed into existing homes instead — FOUNDATIONS entries, PRINCIPLES.md, trigger lines, hot memory.

- **Generating rationale under any confidence threshold.** The composite pattern (choice drafted, `[TODO: why?]` open) is the ceiling. A fluent invented reason is the worst output on the spectrum, because instructions-are-followed cuts both ways.

- **Restating machine-enforced rules.** Linter and formatter config self-enforces; a restated enforced rule fails the per-line test by construction.

- **ADR generation or scaffolding.** The ADRs-as-agent-context thesis is real but practitioner-only, and its headline quantitative claim traces to a nonexistent paper while real constraint research runs the other way. ADRs are composite artifacts whose choice content repokit's docs already carry; their unique payload is revision-time rationale, served by the `[TODO: why?]` slot. **A deliberate on-ramp remains:** the rationale block holds the reason and the rejected alternative, which are precisely an ADR's two distinguishing fields, so a future decision to capture ADRs becomes a mechanical extraction rather than a re-authoring. The format is chosen for that reason and should not be simplified away as off-plan.

## Sources

| Source | Type | Why it matters |
|--------|------|----------------|
| [Evaluating AGENTS.md](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd) — Gloaguen, Mündler, Müller, Raychev, Vechev | Academic paper (ETH Zurich SRI Lab) | The instruction-followed / overview-unhelpful split; "rigorously but counterproductively"; the gap-filler asymmetry (paper-body details not independently re-verified). **Provenance checked 2026-08-04:** the arXiv ID `2602.11988` cited in earlier drafts **could not be confirmed on the primary source**, and secondary write-ups reporting +4% / −3% are likewise unconfirmed. Cite the publisher page, not the arXiv ID |
| [Packmind — Evaluating context for AI coding agents](https://packmind.com/evaluate-context-ai-coding-agent/) | Practitioner field review | Stale context obeyed with full compliance (the Jest/Vitest class of drift) |
| [Treude & Baltes — Context Rot in AI-Assisted Software Development](https://arxiv.org/html/2606.09090) | Academic paper (SMU / Heidelberg) | Names *context rot*; DOCER over 612 config files / 356 repos, 23.0% carrying stale code references, 64% confirmed genuine. Recommends reusing documentation-consistency tooling rather than inventing new mechanisms |
| [agents-lint](https://github.com/giacomo/agents-lint) | OSS tool | Existence proof that checked-in agent context rots |
| [Anthropic — Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Vendor guidance | The per-line admission test; bloat warning |
| [HumanLayer — Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) | Practitioner article | <300-line consensus; ~150–200 instruction ceiling (practitioner numbers, not measured) |
| [Augment Code — How to Build AGENTS.md](https://www.augmentcode.com/guides/how-to-build-agents-md) | Practitioner guide | Independent statement of the write-only-the-non-discoverable rule |
| [arXiv:2604.07192 — Compact Constraint Encoding](https://arxiv.org/abs/2604.07192) / [arXiv:2605.06445 — Constraint Decay](https://arxiv.org/abs/2605.06445) | Academic papers | Negative and counter-default constraints comply poorly; constraint pile-up degrades agents |
| [arXiv:2409.20550 — LLM Hallucinations in Practical Code Generation](https://arxiv.org/abs/2409.20550) / [PACMSE](https://dl.acm.org/doi/10.1145/3728894) | Academic paper | Hand-annotated hallucination taxonomy; Project Context Conflicts 24.56%, Dependency Conflicts 11.26%; repository-level context awareness as root cause; RAG mitigation only +0.87–3.05 Pass@1 on a stale model cohort |
| [arXiv:2602.11671 — Do Not Treat Code as Natural Language (Hydra / DAR)](https://arxiv.org/pdf/2602.11671) | Academic paper | Recall-over-precision for dependency retrieval, quoted verbatim from the paper body; class dependencies are what similarity retrieval misses worst |
| [ArchUnit](https://www.archunit.org/) · [import-linter](https://import-linter.readthedocs.io/) · [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) | OSS tools | Mature architecture-conformance enforcement — the commodity that made stored predicates redundant |
| [Factory.ai — Using linters to direct agents](https://factory.ai/news/using-linters-to-direct-agents) | Practitioner article | Prose establishes *why* a standard matters, linting creates the *guarantee* — and enforcement stays in the linter, mapped to lint rule IDs |
| [Docs as Tests](https://www.docsastests.com/) · Rust doc-tests | Methodology / language feature | Prior art for executable documentation, and a boundary marker: what gets tested is procedures and examples, never a conformance ratio on a directive |
| [ADR practice — techdebt.best](https://techdebt.best/architectural-decisions/) · [Azure Well-Architected](https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record) | Practitioner guides | Decision records are point-in-time and effectively never machine-verified; accepted remedies are a review cadence and a "last verified" date, with automated tests as a *separate* mechanism |
| [Nygard — Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) / [MADR](https://adr.github.io/madr/) | Practitioner article / standard | Canonical ADR forms — the structure showing ADRs span all three bands |
| [Chris Swan — Using ADRs with AI coding assistants](https://blog.thestateofme.com/2025/07/10/using-architecture-decision-records-adrs-with-ai-coding-assistants/) | Practitioner article | Best real source for the ADRs-as-agent-context thesis (unmeasured) |
| [aider — repository map](https://aider.chat/2023/10/22/repomap.html) | Practitioner docs | The live per-turn ranking that static map clones drop |
| [Serena issue #802](https://github.com/oraios/serena/issues/802) | Issue | Agents forget pull tools exist after compaction |
| [Srikanth R — The Hidden Power of Markdown](https://www.linkedin.com/pulse/hidden-power-markdown-structuring-md-files-ai-coding-assistants-r-kdgof) | Practitioner article | The examples-propagate claim behind family 5 (anecdotal, not measured) |
| [SpecKit](https://github.com/github/spec-kit) · [OpenSpec](https://github.com/Fission-AI/OpenSpec) · [Conductor](https://github.com/gemini-cli-extensions/conductor) | OSS frameworks | Artifact locations for SDD convention files, verified 2026-08-01 |
| A production project's docs + generated agent (user-supplied, anonymized) | Field artifacts | The derivable-at-a-cost middle band: a visible choice, unknown at decision time |
| A production project's code-agent audit (user-supplied, anonymized, 2026-08-02) | Field artifacts | Four agents, four blind spots; two were ambient-capability leaks invisible to vendor-SDK detection (family 1b); the unminable facet-exclusion rule behind [H17](#h17). LLM-authored report, illustrative before/after pairs — no measured A/B |

## Open questions

- **Family 6 (directional choices):** is git-recency inference ever safe enough to draft, or is legacy-vs-current permanently human-only? Wrong inversions are confidently harmful. No position taken; parked by default rather than decided against.
- **Conformance thresholds:** what N-of-M ratio justifies drafting a structural convention? No literature on the ratio. Overall size budgets have practitioner numbers but those are consensus, not measurement. Currently a labeled default (≥80% with exceptions listed), and [H6](#h6) argues it may be set too high — but nothing here takes a position on the number itself.
- **Does choice-mining output stand alone** in the plain-harness configuration — docs only, no agentkit agents? Untested, and no position.
- **Does the greenfield case break count-based detection?** A scaffolded project has sanctioned paths with zero instances, so every count-based detector returns nothing. `[intended]` is the marker for it ([H19](#h19)) but whether detection can surface a path nothing uses yet is unresolved.
- **What happens when two mined families disagree** — a structural convention at 11/13 whose two exceptions are the most recently added files? That's family 2 and family 6 pointing opposite ways on the same code, and nothing in the design arbitrates.
