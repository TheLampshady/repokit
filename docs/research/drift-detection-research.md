# Drift Detection for Agent Context — Research

**Date:** 2026-08-01
**Original request:** Research drift detection — mechanics and tooling examples — for agent context files (AGENTS.md, CLAUDE.md, GEMINI.md, Cursor rules), the docs repokit generates, and subagent/skill definitions.
**Goal:** Specify how repokit's sync/check/audit loop should detect context drift: which detection mechanics are proven, what tooling already exists, and where the open niches are.
**Constraints:** Anything recommended must be open source and free. Evidence bar: practitioner consensus, upgraded by benchmarks and skeptical reports wherever they exist.
**Provenance:** This document stands alone — it references no other document in this repository. External claims cite primary sources inline. Positions marked **(repokit hypothesis)** originated in project working discussions, not the literature; they are hypotheses repokit intends to validate by experiment, and evidence cited near them is supporting context, not proof.

---

## Executive summary

**What to do:** build repokit's sync loop as three detection layers — a deterministic five-check core on every sync (paths resolve, commands exist, claims match config, cross-file agreement, both directions), diff-scoped LLM claim-verification per change, and nag-don't-block process enforcement — and claim the two niches nobody occupies: verifying agent *descriptions* against the code they describe, and measuring drift rates at all.

- **The problem is real and measured:** drift is overwhelmingly silent omission (only 13–20% of code changes touch adjacent docs — [Fluri et al. 2009](https://link.springer.com/article/10.1007/s11219-009-9075-x)), and agents obey stale claims with full compliance ([ETH Zurich](https://arxiv.org/abs/2602.11988); [Packmind](https://packmind.com/evaluate-context-ai-coding-agent/)) — a wrong claim is an obeyed error, not noise.
- **Deterministic checks are proven mechanics, unproven impact:** six near-identical MIT linters converged on the same five checks; cheap and sub-second, but zero adoption/impact evidence. Treat the checks as the standard, not any one tool.
- **LLM auditing works in principle, unmeasured in practice:** two converged shapes (diff-scoped ~$0.50–2/run; claim-extraction-then-verification), backed by the verification-easier-than-generation asymmetry — but no published false-positive/negative rates anywhere (absence claim).
- **Process mechanisms rot without an owner:** freshness dates rubber-stamp and gates get bypassed; the fixes with evidence are owner-attributed stamps ([SWE at Google](https://abseil.io/resources/swe-book/html/ch10.html)) and warnings instead of blocks.
- **The maturity target exists:** OpenAI's Harness team runs background cleanup agents at 1M-line scale with a ~100-line AGENTS.md table of contents ([Lopopolo, Feb 2026](https://openai.com/index/harness-engineering/)) — self-reported, but the only account of drift maintenance as routine practice.
- **The open ground is repokit's:** description-vs-code sync and drift-rate telemetry have no public prior art (absence claims) — first-mover territory for agentkit and sync instrumentation.

## Key findings

### The failure mode, quantified

- **Drift is silent omission, not bad edits.** When comments do change, they co-change with code >90% of the time — but only 13–20% of code changes trigger any comment update at all ([Fluri/Würsch/Gall, Software Quality Journal 2009](https://link.springer.com/article/10.1007/s11219-009-9075-x) — old but canonical; corroborated at scale by [Wen et al., ICPC 2019](https://dl.acm.org/doi/abs/10.1109/ICPC.2019.00019), 1,500 Java systems). Follow-on work finds code-comment inconsistency measurably correlates with bug introduction ([arXiv 2409.10781](https://arxiv.org/pdf/2409.10781)).
- **Agents make stale context strictly worse than stale docs.** Context-file instructions are followed "rigorously but counterproductively" even when wrong ([ETH Zurich, arXiv 2602.11988](https://arxiv.org/abs/2602.11988)); field audits show agents obeying outdated claims with full compliance — Jest-vs-Vitest, stale Node versions, Postgres→MySQL migration leftovers ([Packmind](https://packmind.com/evaluate-context-ai-coding-agent/), Feb 2026 — vendor blog, anecdotal base of "dozens of real CLAUDE.md files").
- **Nobody measures drift rates.** No quantitative before/after or drift-velocity study exists anywhere in the agent-context space (absence confirmed by searching across all three research passes). The evidence base is converging anecdotes plus the old SE research above.

### Layer 1 — Deterministic linters for agent context files

A young, crowded niche of free MIT-licensed CLIs, all deterministic-first, none with independent adoption or impact evidence (all claims below are author-documented mechanics, fetched directly):

| Tool | Paths exist | Commands exist | Claims vs config | Cross-file consistency | Freshness | LLM layer |
|---|---|---|---|---|---|---|
| [agents-lint](https://github.com/giacomo/agents-lint) | ✓ | ✓ (package.json) | ✓ (framework patterns, e.g. `ReactDOM.render()` flagged as outdated) | ✓ (AGENTS.md vs CLAUDE.md path asymmetry, npm-vs-yarn conflicts) | proxy (old year refs) | — |
| [AgentLint](https://github.com/0xmariowu/AgentLint) | ✓ | ✓ | partial | ✓ | ✓ | opt-in (7 of 58 checks; incl. mining session logs for ignored rules) |
| [agentlinter](https://github.com/seojoonkim/agentlinter) | ✓ | ✓ (both directions — also flags *undocumented* scripts) | — | ✓ | partial | — |
| [cclint](https://github.com/felixgeelhaar/cclint) | ✓ (`@import` resolution) | — | — | monorepo duplicate content | — | explain-only |
| [context-drift](https://github.com/geekiyer/context-drift) | ✓ | ✓ | ✓ (dependency versions) | ✓ | — | ✓ (MCP prose-claim check via host model) |

- **The mechanics catalog is stable across tools:** (a) referenced paths resolve, (b) named commands/scripts exist, (c) claims match config, (d) cross-file agreement, (e) freshness signals — all sub-second, zero-network, no API key. The differentiators are thin; the niche is six implementations of the same five checks.
- **The unique mechanics worth noting:** AgentLint's session-log mining (evidence a rule is being *ignored*, not just stale) and agentlinter's reverse check (scripts that exist but are undocumented — drift by omission, the statistically dominant kind).
- **Zero evidence any of them improves agent outcomes.** The one tool publishing numbers ([ctxlint](https://dev.to/vamshidhar_reddy_392c2302/i-built-a-linter-that-proves-74-of-your-agentsmd-is-wasting-your-ai-agents-time-46an): "74% waste, 91% precision") is self-reported theoretical token math, not behavior impact — low confidence.

### Layer 2 — LLM-judged auditing

- **Two converged mechanics.** (1) *Diff-scoped checks*: analyze recent changes, find affected docs, LLM flags factual contradictions — [driftcheck](https://github.com/deichrenner/driftcheck) (MIT, pre-push hook, works with local models via Ollama) and the Claude-Code-in-GitHub-Actions pattern at ~$0.50–2.00 per run, ~$10–40/day on a 20-PR/day repo ([Dosu, Mar 2026](https://dosu.dev/blog/how-to-catch-documentation-drift-claude-code-github-actions) — vendor blog with honest caveats: "catches what's explicit, misses what's implied"). (2) *Claim-extraction-then-verification*: extract 5–10 verifiable claims per doc, verify each against code, emit a claim/result table (the docs-auditor skill pattern, [LobeHub listing](https://lobehub.com/ja/skills/nimblebraininc-skills-docs-auditor)).
- **The full-repo LLM auditor exists and is open source.** [Packmind context-evaluator](https://github.com/PackmindHub/context-evaluator) (MIT) drives your already-installed agent CLI (Claude Code, Cursor, Copilot, Codex) through ~17 named evaluators — Command Completeness, Contradictory Instructions, Context Gaps, Outdated Documentation — and scores the repo. Cost rides on your existing subscription. It is the OSS funnel for a commercial product; its evidence base is anecdotal.
- **The principle is sound; the measurements don't exist.** Verification being easier than generation is well-established ([Wei, asymmetry of verification](https://www.jasonwei.net/blog/asymmetry-of-verification-and-verifiers-law)), and *self*-verification is known-weak — improving generation doesn't improve self-checking ([arXiv 2602.07594](https://arxiv.org/abs/2602.07594)), which argues for cross-agent verification designs. But **no published study measures false-positive/false-negative rates of LLM doc audits against labeled ground truth** (absence claim — confirmed by targeted searching) — every "conservative, low false positives" claim in this space is asserted, not proven.
- **Documented failure modes of continuous-audit loops:** hallucinated fixes passing review ("laundered misinformation"), PR volume exceeding value on small doc surfaces, and oscillation between equivalent rewordings ("drift-loop churn") ([AgentPatterns — continuous documentation](https://www.agentpatterns.ai/workflows/continuous-documentation/), reviewed Jul 2026; publisher unverified). The pattern "works best when drift is frequent enough that detection — not correction — is the bottleneck."
- **The strongest operational account:** OpenAI's Harness team (~1M lines, ~1,500 PRs, 3 engineers) runs "background cleanup agents: periodic agents scan for stale documentation, constraint violations, and pattern deviations, opening small refactoring PRs," mostly auto-merged; "repository knowledge is treated as a product: versioned, maintained, kept fresh by agents." Their AGENTS.md is held to ~100 lines as a table-of-contents with progressive disclosure ([Lopopolo, "Harness engineering," Feb 2026](https://openai.com/index/harness-engineering/)). First-party, single team, no counterfactual — but the only published account of drift maintenance as routine, working practice.

### Layer 3 — Docs-as-code prior art (what transfers, what rots)

- **Deterministic coupling works and is the cheapest trick in the book.** [embedme](https://github.com/zakhenry/embedme) (MIT): code blocks declare a source path, the tool injects the real code, `--verify` fails CI when doc and source diverge. Swimm industrialized the same idea with a weighted signal "histogram" that auto-patches trivial drift and punts complex changes to humans ([Swimm auto-sync](https://swimm.io/blog/how-does-swimm-s-auto-sync-feature-work), 2021). The principle both encode: **make the source the single source of truth and check the copy mechanically** — never sync prose by hand.
- **Executable docs verify commands the way tests verify code.** [Runme](https://docs.runme.dev/getting-started/cli/) (Apache-2.0) executes the shell blocks in Markdown in CI ("keep docs from bitrot"); doctest/rustdoc remain the highest-reliability form — but all of these verify *code/command snippets*, not prose claims.
- **Freshness metadata rots unless a named owner is attached.** Google's g3doc practice — `freshness: { owner: 'username', reviewed: 'date' }` with automated nagging — reports that attaching an *owner* to the date is what drove adoption ([SWE at Google, ch.10](https://abseil.io/resources/swe-book/html/ch10.html)); Microsoft's `ms.date` tracks edit-date, not verified-date — exactly the rubber-stamp failure. Reminder-only tools (docdecay et al.) keep appearing and fading.
- **PR gates should nag, not block.** The standard danger.js recipe warns (not fails) when `src/**` changed but `docs/**` didn't ([danger.js](https://danger.systems/js/guides/the_dangerfile.html)); hard gates get institutionalized bypasses fast (`[changelog skip]` tags, ruleset bypass lists). Ecosystem consensus by revealed preference: warning > blocking.
- **Cautionary market signal:** Swimm — the best-funded doc-sync company — could not sustain snippet-sync as a standalone product and pivoted to feeding verified context to AI agents ([Swimm 2.0](https://swimm.io/blog/swimm-2-0-the-understanding-platform-for-ai-modernization), 2025–26). The demand moved to exactly the "docs as agent context" framing; snippet-level sync alone was not the durable value.

### Subagent and skill definitions

- **Descriptions measurably drive routing, and the official tooling tests them against *queries*.** Anthropic's skill-creator v2 ([anthropics/skills](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md), open source) generates ~20 should/shouldn't-trigger queries with near-misses, runs an automated optimization loop with train/test split, and selects descriptions by held-out trigger rate; Anthropic reports improvement on 5 of 6 internal skills, and one independent practitioner measured 81 → 97.5 across four evals ([O'Brien, Mar 2026](https://dev.to/debs_obrien/i-used-skill-creator-v2-to-improve-one-of-my-agent-skills-in-vs-code-fhd)).
- **Definitions-as-build-outputs is the working sync model.** [wshobson/agents](https://github.com/wshobson/agents) (38.4k stars, MIT) keeps a single source-of-truth and transpiles to Claude Code, Codex, Cursor, Gemini CLI, and Copilot formats via `make generate`, with `make validate` (structure) and `make garden` (drift/dead-link detection). Hand-editing generated artifacts is the anti-pattern.
- **Nobody verifies descriptions against code.** No tool or documented practice checks whether an agent/skill description still matches the codebase it describes (absence confirmed by targeted searching). Skill-audit tools check structure and security, not code-sync. Direct evidence that stale descriptions cause mis-routing also doesn't exist — only the well-evidenced adjacent chain (descriptions are the sole routing signal; trigger rates are sensitive to wording).
- **Don't conflate:** academic work on *goal drift* in coding agents (runtime behavior drifting mid-task) is a different problem from context/definition staleness.

### What vendors ship

Generation, not detection. Anthropic ships `/init` plus manual guidance ("treat CLAUDE.md like code... prune it regularly" — [best practices](https://code.claude.com/docs/en/best-practices)); OpenAI's Codex guidance is reactive ("when Codex makes the same mistake twice... update AGENTS.md"); Cursor ships nothing, and community guidance warns stale rule globs silently stop firing after folder renames ([Atlan](https://blog.atlan.com/engineering/cursor-rules/)). The drift-detection layer is entirely third-party.

## How this applies to repokit

### The layered sync architecture **(repokit hypothesis — the design this research supports)**

Repokit's context-in-sync premise sits on the best-evidenced gap in the field: drift is the dominant, measured failure mode; detection tooling is young, fragmented, and evidence-free; and the deterministic mechanics are proven, cheap, and unclaimed as an integrated loop. The proposed structure — a hypothesis to build and validate, not established practice:

1. **Deterministic core, every sync (free, sub-second).** The five-check catalog the linter niche converged on: referenced paths resolve; named commands exist in Makefile/package.json/pyproject; claims match config (dependency versions, tool names); cross-file agreement (AGENTS.md vs CLAUDE.md vs GEMINI.md); both directions — including agentlinter's reverse check for *undocumented* capabilities, since silent omission is the statistically dominant drift ([Fluri et al.](https://link.springer.com/article/10.1007/s11219-009-9075-x)). Rather than depending on any single early-stage linter, treat the mechanics as the standard: they are all reimplementations of the same five checks.
2. **Evidence recounts for mined conventions (deterministic, every sync).** Where repokit emits a convention with a conformance label ("11/13 handlers conform"), re-run the count on sync; decay (11/13 → 6/13) or a dead exemplar path flags the rule **(repokit hypothesis — this mechanic has no public prior art; it is the agent-context analogue of embedme's `--verify`)**.
3. **LLM claim-verification, diff-scoped (per sync/PR, costed).** The converged shape: scope to changed files, extract claims, verify against code, cross-agent rather than self-verifying ([arXiv 2602.07594](https://arxiv.org/abs/2602.07594)). Budget expectation from the field: ~$0.50–2 per run ([Dosu](https://dosu.dev/blog/how-to-catch-documentation-drift-claude-code-github-actions)). Tuned conservative — and honestly labeled as unproven, since no FP/FN benchmarks exist anywhere.
4. **Agent-description sync — repokit's empty-niche opportunity.** agentkit descriptions/instructions verified against the foundations and code they describe has *no public prior art*. The adjacent proven pieces: definitions-as-generated-artifacts (wshobson's model — regenerate, don't hand-fix) and query-based trigger evals (skill-creator v2) for the routing side. Combining code-sync verification with trigger-eval verification would be novel territory **(repokit hypothesis)**.
5. **Process layer: nag, don't block, and name an owner.** The feedback-loop agent enforcing same-PR context updates should warn rather than fail (the danger.js lesson — hard gates breed bypass labels), and any freshness stamp repokit writes should carry an owner, the one mitigation with documented adoption impact ([SWE at Google](https://abseil.io/resources/swe-book/html/ch10.html)).

### Secondary implications

- **Instrument the loop — repokit could produce the field's first drift-rate data** **(repokit hypothesis)**. Nobody measures how fast agent context rots or how many claims a sync pass corrects. Sync-mode telemetry (claims checked, claims failed, category, age) would be genuinely novel evidence, not just product surface.
- **The OpenAI Harness pattern is the maturity target:** periodic background cleanup at a cadence where most fixes auto-merge, with the always-loaded file held to ~100 lines as a table of contents ([Lopopolo](https://openai.com/index/harness-engineering/)). Repokit's sync mode is the plugin-shaped version of that practice.
- **Expect and design for the audit-loop failure modes:** hallucinated fixes surviving review, churn on small doc surfaces, reword oscillation ([AgentPatterns](https://www.agentpatterns.ai/workflows/continuous-documentation/)). Confirm-or-delete drafts and diff-scoped runs are the mitigations the field has converged on.

## Hypotheses to implement

The actionable roll-up of everything marked **(repokit hypothesis)** — each with the concrete change or experiment that would test it:

1. **Layered sync architecture** — implement the deterministic five-check core in repokit sync; test by seeding a repo with known drift (dead paths, renamed scripts, config mismatches) and measuring catch rate.
2. **Evidence recounts for mined conventions** — re-run conformance counts (`11/13 → ?`) on every sync; test by refactoring a conforming file and confirming the decayed count flags the rule.
3. **Description-vs-code sync (agentkit)** — verify agent descriptions against the foundations/code they describe on sync; test by aging a description past a real code change and confirming detection, then pair with a skill-creator-style trigger eval to measure whether the refresh changes routing.
4. **Drift-rate telemetry** — instrument sync to log claims checked/failed by category and age; success is the first real drift-rate dataset, publishable on its own.
5. **Diff-scoped LLM claim-verification** — add as a costed sync layer (~$0.50–2/run expectation); test against a small labeled set of true/false doc claims to produce the FP/FN numbers the field lacks.

## Sources

| Source | Type | Why it matters |
|--------|------|----------------|
| [Fluri/Würsch/Gall 2009](https://link.springer.com/article/10.1007/s11219-009-9075-x) | Peer-reviewed (old, canonical) | Only 13–20% of code changes trigger comment updates — drift is silent omission |
| [Wen et al., ICPC 2019](https://dl.acm.org/doi/abs/10.1109/ICPC.2019.00019) | Peer-reviewed | Code-comment inconsistency taxonomy at 1,500-system scale |
| [GitHub Open Source Survey 2017](https://opensourcesurvey.org/2017/) | Large-N survey (old) | 93% report incomplete/outdated docs; 60% never contribute to docs |
| [arXiv 2602.11988 — Evaluating AGENTS.md](https://arxiv.org/abs/2602.11988) | Controlled study | Agents follow stale instructions rigorously — obeyed errors, not noise |
| [Packmind — evaluating context](https://packmind.com/evaluate-context-ai-coding-agent/) + [context-evaluator](https://github.com/PackmindHub/context-evaluator) | Vendor blog + MIT tool | Field drift examples; the lone LLM-judged full-repo auditor |
| [agents-lint](https://github.com/giacomo/agents-lint), [AgentLint](https://github.com/0xmariowu/AgentLint), [agentlinter](https://github.com/seojoonkim/agentlinter), [cclint](https://github.com/felixgeelhaar/cclint), [context-drift](https://github.com/geekiyer/context-drift) | OSS tools (MIT) | The deterministic linter niche and its converged five-check catalog |
| [driftcheck](https://github.com/deichrenner/driftcheck) | OSS tool (MIT) | Diff-scoped LLM drift check as a pre-push hook; local-model capable |
| [Dosu — drift with Claude Code Actions](https://dosu.dev/blog/how-to-catch-documentation-drift-claude-code-github-actions) | Vendor blog | Per-PR audit cost data (~$0.50–2/run); honest reliability caveats |
| [Lopopolo — Harness engineering (OpenAI)](https://openai.com/index/harness-engineering/) | Vendor engineering post (Feb 2026) | Primary source for background cleanup agents at 1M-line scale; ~100-line AGENTS.md as ToC |
| [AgentPatterns — continuous documentation](https://www.agentpatterns.ai/workflows/continuous-documentation/) | Pattern catalog (publisher unverified) | Audit-loop failure modes: laundered misinformation, churn, oscillation |
| [Wei — asymmetry of verification](https://www.jasonwei.net/blog/asymmetry-of-verification-and-verifiers-law) + [arXiv 2602.07594](https://arxiv.org/abs/2602.07594) | Researcher blog + preprint | Verification easier than generation; self-verification weak — use cross-agent designs |
| [Swimm auto-sync](https://swimm.io/blog/how-does-swimm-s-auto-sync-feature-work) + [Swimm 2.0 pivot](https://swimm.io/blog/swimm-2-0-the-understanding-platform-for-ai-modernization) | Vendor blogs | The industrial snippet-sync mechanics; the market signal of the pivot |
| [embedme](https://github.com/zakhenry/embedme) | OSS tool (MIT) | `--verify`: the cheapest deterministic doc-code coupling check |
| [Runme](https://docs.runme.dev/getting-started/cli/) | OSS tool (Apache-2.0) | Executable Markdown command blocks in CI |
| [SWE at Google, ch.10](https://abseil.io/resources/swe-book/html/ch10.html) | Book (2020, foundational) | Owner-attributed freshness metadata — the one process fix with adoption evidence |
| [danger.js](https://danger.systems/js/guides/the_dangerfile.html) | OSS docs | Docs-touched PR gates as warnings; why hard gates fail |
| [anthropics/skills — skill-creator](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) + [O'Brien writeup](https://dev.to/debs_obrien/i-used-skill-creator-v2-to-improve-one-of-my-agent-skills-in-vs-code-fhd) | Official repo + practitioner | Query-based description-trigger evals; measured routing sensitivity |
| [wshobson/agents](https://github.com/wshobson/agents) | OSS repo (MIT, 38k stars) | Definitions as build outputs; `make garden` drift checks |
| [Anthropic best practices](https://code.claude.com/docs/en/best-practices) | Vendor guidance | Vendors ship generation + manual pruning advice, no detection |
| [Atlan — Cursor rules](https://blog.atlan.com/engineering/cursor-rules/) | Practitioner blog | Stale rule globs silently stop firing; same-PR removal practice |
| Working discussions, Zach, 2026-07-31 → 2026-08-01 | Conversation | Everything marked **(repokit hypothesis)**: the layered sync architecture, evidence recounts, description-vs-code sync, drift telemetry — to be validated by experiment in repokit |

## Open questions

- **No FP/FN benchmarks for LLM doc audits exist.** Every conservatism claim is asserted. If repokit ships LLM claim-verification, it should label results as unproven-precision and consider building a small labeled eval — which would itself be first-of-kind.
- **No drift-rate measurements exist.** The 13–20% co-change figure is 2009-era code comments, not 2026 agent context files. Repokit's sync telemetry could produce the first real numbers **(repokit hypothesis)**.
- **Does deterministic linting improve agent outcomes at all?** Zero evidence either way — the entire linter niche is unvalidated. The mechanics are cheap enough that the bet is low-risk, but honesty requires calling it a bet.
- **What cadence does LLM auditing earn?** Per-PR (~$0.50–2) vs nightly vs weekly is currently decided by budget folklore. The AgentPatterns rule of thumb — continuous auditing pays only when drift outpaces correction — has no numbers behind it.
- **Does description drift actually cause mis-routing?** The chain is plausible (descriptions are the routing signal; routing is wording-sensitive) but the direct effect is unmeasured. A trigger-eval before/after on aged vs refreshed agentkit descriptions would test it directly **(repokit hypothesis)**.
- **Where is the auto-fix line?** Swimm auto-patched only trivial drift and punted the rest; OpenAI auto-merges most cleanup PRs. Whether repokit's sync should fix, draft, or only flag — per check type — is a design decision this research informs but doesn't settle.
