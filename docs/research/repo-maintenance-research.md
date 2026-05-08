# Repo Maintenance — Research

**Date:** 2026-05-08
**Original request:** Review the dockit skill, look up best practices for repo maintenance / documentation, and write a reference doc backing what we built.
**Goal:** Capture the practitioner consensus that dockit's design implements, plus the angle dockit explicitly takes on documentation as a context layer for AI agents — so future contributors and external readers can see *why* the skill is shaped the way it is.

---

## Summary

The center of gravity for documentation work has shifted. For most of the last decade, the practitioner consensus around repo maintenance was: store docs alongside code ("docs-as-code"), separate doc *types* by purpose (Diátaxis), keep architectural decisions as an append-only log (ADRs), and treat drift as a CI problem. That body of practice is still load-bearing — dockit inherits all of it — but a second audience now consumes the same files. Coding agents (Claude Code, Cursor, Copilot, Codex) load `README.md`, `CLAUDE.md`, `AGENTS.md`, and `docs/**/*.md` into their working context every time they touch the repo, and the quality-of-context they get directly affects task success.

That second audience changes a few priorities. Recent research from ETH Zurich found that LLM-generated context summaries layered on top of existing docs *hurt* coding-agent task success by ~3% while increasing token cost by 20%+ — the summaries duplicated what agents could discover on their own. The lesson isn't "skip docs"; it's that each layer of documentation must add something the layer below cannot reveal. Dockit is built around that principle: it generates the *primary* documentation (decisions, invariants, foundations, conventions) — the kind of content agents and humans both need that isn't recoverable by reading the code. Tombstones, redundant summaries, and stale sections are the failure mode; sync and audit modes actively prevent them.

## Key findings

- **Co-locate docs with code, treat them as part of the change.** Embed doc updates into the same PR as the code change; require updates as a merge condition; surface stale docs in CI ([Docsie — Documentation Drift](https://www.docsie.io/blog/glossary/documentation-drift/)). This is the well-established docs-as-code consensus and the foundation everything else rests on.

- **Diátaxis: separate four documentation types.** Tutorials (learning), how-to guides (problem-solving), reference (facts), and explanation (understanding) serve four different needs. Mixing them is the root of "a vast number of problems in documentation" ([Diátaxis](https://diataxis.fr/start-here/)). Practitioner adoption is wide — Canonical/Ubuntu, Sequin, Cloudflare, others.

- **Use Architecture Decision Records as an append-only log.** ADRs are short, single-page records of one decision: context, decision, status, consequences. They are *not* edited after acceptance — supersession links to a new record ([Cognitect / Michael Nygard](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions); [Martin Fowler](https://martinfowler.com/bliki/ArchitectureDecisionRecord.html)). This makes them *complementary* to "docs describe what is" — descriptive docs and decision logs serve different jobs.

- **Drift detection has two modes: staleness and content verification.** Staleness checks ask "when was this doc last touched relative to the code it describes?" — a timestamp comparison. Content verification reads the doc and checks every claim (file paths, function names, env vars, commands) against the codebase. They catch different failures: a doc can be a week old and accurate, or hours old and broken ([Understanding Data — Doc Drift Detection in CI](https://understandingdata.com/posts/doc-drift-detection-ci/)).

- **Single Source of Truth eliminates version drift.** When the same content lives in multiple places, divergence is inevitable — warnings get updated in one manual but not another, discovered just before a deadline ([Paligo — SSOT](https://paligo.net/blog/content-reuse/what-is-single-source-of-truth-ssot/)). Each fact should have one authoritative location; everything else links to it.

- **Progressive disclosure: start small, scale only when complexity demands it.** A single README is appropriate for small projects (<200 lines, single service); transition to an index + linked references when content exceeds what a reader can hold in working memory ([NN/g — Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/); [Ardalis — Progressive Disclosure for AI Agents](https://ardalis.com/optimizing-ai-agents-with-progressive-disclosure/)). The same principle applies to AI agents: top-level files orient, deeper files load on demand.

- **Foundational code is identifiable by fan-in, not by directory name.** Afferent coupling (number of modules depending on a module) is the canonical metric for stability and "core-ness" ([entrofi — Software Coupling Metrics](https://www.entrofi.net/coupling-metrics-afferent-and-efferent-coupling/); [Wikipedia — Efferent coupling / Robert Martin](https://en.wikipedia.org/wiki/Efferent_coupling)). High-fan-in modules are the ones whose changes cascade. They deserve named, documented invariants — *whether or not they live in `core/`*.

- **AGENTS.md is emerging as the standard "instructions for agents" file.** Used by 60,000+ open-source projects, it complements rather than replaces README. README targets human contributors with quick-starts and project description; AGENTS.md provides the operational rules an agent needs (build commands, security boundaries, conventions) that would clutter the README ([agents.md](https://agents.md/); [Augment Code — How to Build AGENTS.md](https://www.augmentcode.com/guides/how-to-build-agents-md)).

- **LLM-generated context summaries can hurt agent performance.** A 2026 ETH Zurich study evaluated 138 real-world GitHub issues across multiple coding agents. Auto-generated AGENTS.md files reduced task success by ~3% relative to *no* context file; hand-written files gained only ~4%; both increased token cost by 20%+. The cause: redundancy with existing repo docs ([SRI Lab — Evaluating AGENTS.md](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd); [Botmonster summary](https://botmonster.com/posts/evaluating-agents-md-repository-context-files-helpful/)). The actionable rule: include only information that *changes the correct approach* and that the agent *cannot discover* by reading the repo.

- **`llms.txt` is a proposed standard for an AI-readable site map.** A markdown file at the project root that lists key documentation links, meant for LLM inference-time use rather than crawler indexing ([llmstxt.org](https://llmstxt.org/); [Mintlify — llms.txt](https://www.mintlify.com/docs/ai/llmstxt)). Adoption: ~844k domains as of early 2026, including Anthropic, Mintlify, Cursor, GitBook. Useful when docs are public and external agents may consume them.

- **Stable section names are a tooling contract.** When downstream tools (linters, parsers, CI checks, AI agents that look for `## Foundations`) depend on canonical headings, renaming a heading silently breaks them ([Fern — Docs Linting Guide](https://buildwithfern.com/post/docs-linting-guide); [Netlify — Docs Linting in CI/CD](https://www.netlify.com/blog/a-key-to-high-quality-documentation-docs-linting-in-ci-cd/)). Consumers don't fail loudly; they just stop finding the section.

## How this applies to your request

The findings above describe what the field has converged on. This section translates each one into the specific design choice dockit makes — and where dockit deliberately takes a position the broader practitioner discussion hasn't converged on yet.

### Where dockit follows consensus

- **Co-located docs, modal sync** — dockit lives in the repo, ships sync/check/audit modes that mirror co-evolving-doc practice. The `sync` mode embeds doc updates into the post-change loop; `check` is a CI-friendly read-only staleness gate; `audit` is the content-verification mode (cross-references every claim against the codebase). This maps directly to the staleness-vs-verification distinction.

- **Single source of truth per fact.** ENVIRONMENTS.md owns env vars; ARCHITECTURE.md owns system design; FOUNDATIONS.md owns shared/foundational code. The DOC-MAP routes content to one destination, README links rather than duplicates. SSOT, applied at the doc-section level.

- **Progressive disclosure via three size tiers.** Small (≤20 files) → README + 2 docs. Medium (20–50 files, framework + DB) → README + 5 docs + FOUNDATIONS. Large (>50 files) → adds CONTRIBUTING + sub-docs under `architecture/foundations/`. This is the same "start small, expand on demand" pattern the NN/g and progressive-disclosure literature recommends, parameterized by detectable project shape.

- **Foundations by fan-in, not by directory.** The detection guide scores every source file by `log(fan_in) × log(distinct_features) × stability_factor`. Convention dirs (`core/`, `shared/`, `lib/`) get a 1.2× boost but are not required. This is afferent-coupling analysis, with cross-feature usage as the key disambiguator (a file imported 40 times in one feature is *feature-internal*; 5 times across 5 features is *foundational*). The "hidden foundations / pretenders" categories come straight from this — code in `core/` that nothing imports is a pretender; code in `utils/` that everything imports is a hidden foundation.

- **Stable section names as a contract.** WRITING-GUIDE.md explicitly calls these out: `## Foundations` in FOUNDATIONS.md, `## Quick Start` in README.md, env-var tables under known headings. Adding sections is safe; renaming or moving them is a breaking change requiring coordinated updates to consumers (agentkit, feedback-loop, onboard, dockit's own sync). This is the docs-as-tooling-contract pattern from the docs-linting community.

- **Different rules for restructuring vs syncing.** Init/migrate never destroy information — content moves between files but is never lost. Sync removes doc sections when the underlying code is gone. Removals are reported in the chat completion summary, not memorialized in the docs. This separates *content preservation during reorganization* from *staleness removal during routine sync* — which the literature mostly conflates.

### Where dockit takes a position

These choices aren't wrong by consensus; they're places where dockit picks a side because the field hasn't fully converged.

- **No tombstones for removed code.** Most changelog and release-notes guidance (e.g., [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)) tells you to memorialize removals. Dockit's WRITING-GUIDE inverts this for descriptive docs: *git history and changelogs serve that purpose; descriptive docs reflect what currently exists.* The reasoning is that tombstones are noise — they describe what *isn't* there, which clutters the file for the next reader. The "why we removed X" case is covered by whichever decision-log mechanism the project uses (Spec-Kit's constitution, an `adr/` directory, release notes); the changelog handles "X was removed in v2"; descriptive docs just stop mentioning X. Dockit explicitly does not generate a decision log — that's Spec-Kit's territory or the team's choice — and the no-tombstones rule depends on that other mechanism existing. The split is correct as long as the team keeps *some* form of decision history.

- **One set of writing rules for both audiences.** WRITING-GUIDE.md states explicitly: "These practices serve both human readers and downstream AI tools … the two audiences need almost the same things — terse explanations, explicit cross-links, exact strings, purpose-bearing tables — so there's one set of rules below, not two." This is a deliberate choice against the AGENTS.md-style audience split. The reasoning: maintaining two parallel documents (one for humans, one for agents) creates the same version-drift problem SSOT was meant to solve, and the cross-section of "what humans need" and "what agents need" is wide enough that the unified approach pays off.

  *Where this needs nuance:* AGENTS.md / CLAUDE.md isn't a *parallel* doc — it's an *operational* doc covering things humans don't typically need in writing (exact build flags, security boundaries, "don't run rm without confirmation"). Dockit's choice is correct for *descriptive* docs (README/ARCHITECTURE/FOUNDATIONS); a separate operational file is complementary, not contradictory. Dockit doesn't generate that file either — `/init` in Claude Code owns it. That scope discipline also resolves the `llms.txt` question: the operational layer (CLAUDE.md / AGENTS.md, written by `/init`) and the AI-readable index layer (`llms.txt`) overlap heavily for repokit's use case (internal-only doc consumers), so generating both would be duplication. Dockit owns the human-facing-and-also-AI-readable descriptive layer; everything else is upstream tooling's job.

### Calibration: the ETH AGENTS.md study

The most surprising finding in this research is that LLM-generated context summaries hurt agent task success. A casual reading suggests "more docs = bad for agents," which would undercut everything dockit does. The careful reading is different.

The study tested *summary files layered on top of an existing repo*. The agents already had access to README, code, and standard docs; the AGENTS.md added a *summary* of those, and the summary turned out to duplicate what agents could already discover by reading. The 3% drop and 20% cost increase came from the redundancy — agents spent tokens re-reading information they had multiple times, and got stuck following over-specific instructions when the original context was richer.

The study does *not* conclude:
- ❌ "Skip documentation"
- ❌ "Agents perform best with no context"
- ❌ "Generated docs are inherently harmful"

The study *does* support:
- ✅ Each documentation layer must add what the layer below cannot reveal
- ✅ Auto-generated summaries of existing content are a trap
- ✅ Hand-curated, minimal, *non-redundant* context still beats no context (though the win is small)

Mapping this to dockit:

| Doc | What it adds that code alone can't reveal | Failure mode |
|-----|--------------------------------------------|--------------|
| README.md | Project intent, quick start ordering, philosophy | Becomes a summary of file structure |
| ARCHITECTURE.md | *Why* decisions were made, data flow, components | Becomes a list of files in `src/` |
| FOUNDATIONS.md | Cross-feature fan-in patterns, invariants, refactor triggers | Becomes "what's in `core/`" |
| PRINCIPLES.md | Conventions and patterns not enforceable in code | Becomes restatement of the linter config |
| ENVIRONMENTS.md | Setup steps, env-var purpose, team-specific auth | Becomes `.env.example` re-pasted as a table |

The discriminator is **derivable vs non-derivable from code**:
- **Derivable** (skip — agents and readers can grep): file paths, function signatures, imports, test layout, env var names alone
- **Non-derivable** (worth documenting): *why* a decision was made; cross-file invariants; foundations identified by fan-in; intentional vs incidental patterns; deployment topology; team conventions

Dockit's audit mode and "no tombstones" rule are direct defenses against the failure modes in the right column. Audit catches docs that have drifted into restating things the code now contradicts (the redundant-and-wrong case). The no-tombstones rule keeps removed-feature noise from accumulating. Stable section names let downstream consumers (and agents) jump to the section they need rather than re-reading everything.

### Practical recommendations: avoiding the redundancy trap in `init`

These are the levers that keep `init` from producing the kind of summary content the ETH study penalized. Ordered by strength of defense.

- **"Earn its tokens" rule per section.** Every generated section must answer a *non-derivable* question — something a reader could not figure out by reading the repo for 60 seconds. If the answer is derivable, the section gets a `[TODO: explain why]` marker for the human, not synthesized prose. Better an empty placeholder than fluff.
- **Default to fewer sections.** Don't generate every template section regardless of source material. A project with no documented design decisions should not get a fake `## Decisions` section with placeholder bullets — skip it and surface "consider adding" in the completion summary.
- **Templates as prompts, not shells.** Frame each template section as a *question* generation must answer with real content ("Why this stack?" not "Tech Stack"). If no answer is in the codebase, leave the question for the human and move on.
- **Add a `redundancy` pass to `audit`.** Read each generated section, attempt to derive its content from the repo, flag sections where doc and derivation overlap above a threshold. A self-applied version of the ETH study's test.
- **Bias generation effort toward FOUNDATIONS over ARCHITECTURE.** ARCHITECTURE.md is the highest-risk doc for redundancy (easy to drift into "files in `src/`"). FOUNDATIONS.md is the highest-value doc for non-derivability — fan-in × cross-feature × stability is information no single-file read recovers. When in doubt, invest there.

The lightest version of this is one rule added to WRITING-GUIDE: *every section must answer a question that requires reading multiple files or talking to a human to answer*.

### Subagent context loss: the active-work compromise

Default subagents spawn fresh, don't see CLAUDE.md or AGENTS.md, re-do work that already happened, and produce parallel content that duplicates what dockit owns. This is the immediate pain point — and it's the *opposite* failure from the ETH study. The ETH study warns about *redundant* context; the subagent problem is *missing* context.

Both are real, but they trade off. Fully de-duplicating the agent's input (DRY for both humans and machines) is the long-term direction — break out FOUNDATIONS-style references that subagents and humans both consume by pointer rather than copy. The current priority is pragmatic: **small + present beats DRY + missing**. If a subagent doesn't have the context, it fabricates or duplicates; if it has the context but the context is partially redundant, the cost is tokens, not correctness.

Compromises that work today:

- **Brief subagents with explicit doc references in the system prompt.** When agentkit creates a subagent, the prompt says: "Before writing anything, read `docs/FOUNDATIONS.md` and `docs/ARCHITECTURE.md`. Treat their contents as canonical — do not duplicate or re-explain." Shifts the burden from "should know" to "is told."
- **Make subagent outputs additive, not parallel.** A subagent that writes docs *extends* a named section or `[TODO]`s one — it doesn't write standalone parallel content. Detect post-hoc duplication; fold or discard.
- **Read-only-context pattern for review/audit roles.** Set the rule: "You cannot write project docs. Surface drift as a finding for the human." Eliminates duplication at the source.
- **Narrow scope per subagent.** Wider scope → more drift into re-explaining the project. Scope per-foundation or per-pattern, not per-domain.
- **Verify at handoff.** Parent diffs subagent output against existing docs. If overlap exceeds threshold, merge or reject.

Future direction (open question below): factor canonical content (foundations, invariants, conventions) into reference fragments that both human docs and subagent prompts consume by pointer. That keeps it DRY without leaving subagents context-starved.

### How agents *actually* get context (the layered model)

The study makes this explicit even though the paper doesn't lay it out as a stack. The practical model:

| Layer | What it adds | What it costs | Owned by |
|-------|--------------|---------------|----------|
| Repo itself (code, names, structure) | Ground truth, current state | Free — agents read on demand | Engineers |
| **Primary docs (README, ARCHITECTURE, FOUNDATIONS, etc.)** | Intent, decisions, invariants, foundations, conventions | Tokens proportional to doc size | **Dockit** |
| `AGENTS.md` / `CLAUDE.md` | Operational rules: build commands, security boundaries, "don't run X" | Small (kept minimal by discipline) | `/init`, contributors |
| `llms.txt` (optional) | Entry-point map for external agents | Trivial | Consumer's preference |
| Per-task context loaded at runtime | Specifics of *this* task | Whatever the user pastes | The user |

Dockit owns the second layer. The first layer is the codebase itself. The third and fourth layers are out of scope — `/init` writes CLAUDE.md, the project owner writes AGENTS.md, neither is dockit's job. Per-task context is, definitionally, never a project artifact.

The ETH study's finding — that auto-generated summaries hurt — is specifically a warning about the *third* layer being a summary of the *second*. Dockit's role is generating the second layer well, *so that* the third layer can stay small and focused on what the second layer can't say.

## Sources

| Source | Type | Why it matters |
|--------|------|----------------|
| [Diátaxis — Start here](https://diataxis.fr/start-here/) | Framework reference | Canonical four-types-of-docs framework; widely adopted |
| [Cognitect — Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | Practitioner article | Original ADR proposal (Michael Nygard) |
| [Martin Fowler — Architecture Decision Record](https://martinfowler.com/bliki/ArchitectureDecisionRecord.html) | Practitioner blog | ADR endorsement and append-only-log discipline |
| [Docsie — Documentation Drift](https://www.docsie.io/blog/glossary/documentation-drift/) | Reference article | Definition and prevention strategies for drift |
| [Understanding Data — Doc Drift Detection in CI](https://understandingdata.com/posts/doc-drift-detection-ci/) | Practitioner blog | Practical CI techniques; staleness-vs-verification distinction |
| [Paligo — Single Source of Truth](https://paligo.net/blog/content-reuse/what-is-single-source-of-truth-ssot/) | Industry article | SSOT principle for documentation systems |
| [NN/g — Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/) | UX research | Foundational principle for layered information design |
| [Ardalis — Progressive Disclosure for AI Agents](https://ardalis.com/optimizing-ai-agents-with-progressive-disclosure/) | Practitioner blog | Progressive disclosure applied to AI agent context |
| [entrofi — Software Coupling Metrics](https://www.entrofi.net/coupling-metrics-afferent-and-efferent-coupling/) | Reference article | Afferent coupling / fan-in as foundational-code metric |
| [Wikipedia — Efferent coupling (Robert Martin)](https://en.wikipedia.org/wiki/Efferent_coupling) | Reference | Origin of stability metric `I = Ce/(Ca+Ce)` |
| [agents.md](https://agents.md/) | Standard | AGENTS.md format, scope, README relationship |
| [Augment Code — How to Build AGENTS.md](https://www.augmentcode.com/guides/how-to-build-agents-md) | Practitioner guide | What to include vs exclude — the "non-derivable" rule |
| [SRI Lab — Evaluating AGENTS.md](https://www.sri.inf.ethz.ch/publications/gloaguen2026agentsmd) | Academic paper | The 138-issue study; surprising negative result on auto-generated context |
| [Botmonster — AGENTS.md study summary](https://botmonster.com/posts/evaluating-agents-md-repository-context-files-helpful/) | Practitioner summary | Accessible breakdown of the ETH paper's findings |
| [llmstxt.org](https://llmstxt.org/) | Standard proposal | The llms.txt specification |
| [Mintlify — llms.txt](https://www.mintlify.com/docs/ai/llmstxt) | Vendor doc | Practical adoption guidance for llms.txt |
| [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) | Standard | Canonical changelog format; the "where tombstones belong" answer |
| [Fern — Docs Linting Guide](https://buildwithfern.com/post/docs-linting-guide) | Practitioner guide | Stable headings as tooling contract |
| [Netlify — Docs Linting in CI/CD](https://www.netlify.com/blog/a-key-to-high-quality-documentation-docs-linting-in-ci-cd/) | Practitioner blog | CI-side enforcement of doc quality |
| [Qodo — Code Documentation Best Practices 2026](https://www.qodo.ai/blog/code-documentation-best-practices-2026/) | Industry article | Recent consensus on AI-era documentation practices |

## Resolved (deliberately not doing)

These came up in research as plausible additions to dockit. After thinking through the layered context model and what's already in the toolchain, they're scoped out — covered by upstream tools.

- **`llms.txt` generation.** The operational layer (CLAUDE.md / AGENTS.md, owned by Claude Code's `/init`) and the AI-index layer (`llms.txt`) have heavy content overlap for repokit's use case (internal-only doc consumers, no external agent traffic). Generating both would duplicate. Re-evaluate if/when repokit grows external doc consumers.

- **ADR generation.** Architectural decisions live in Spec-Kit's constitution and spec files. ADRs would be a parallel mechanism with the same content. The "no tombstones" rule in dockit relies on *some* decision-log mechanism existing — Spec-Kit fills that role.

## Open questions

Active gaps. Worth revisiting.

- **Subagent context loss is the priority engineering problem.** Default subagents don't see CLAUDE.md/AGENTS.md, re-explain the project from scratch, and write parallel content. The current compromise (small + present > DRY + missing) is a working position, not a final answer. The future direction is to factor canonical content — foundations, invariants, conventions — into reference fragments that both human docs and subagent prompts consume by pointer rather than copy. That's a non-trivial design problem (how do fragments stay in sync? what's the file format? how do prompts cite them?) and it's the highest-leverage improvement on the docket.

- **Tighten `init` against the ETH-study failure mode.** Add the "earn its tokens" rule to WRITING-GUIDE; let `init` skip empty-source-material sections rather than generate placeholder content; consider a `redundancy` sub-mode of `audit` that flags sections derivable from the repo. Owner: in-flight work outside this doc.

- **Should the foundations score formalize the Robert-Martin instability metric (`I = Ce/(Ca+Ce)`)?** The current `log(fan_in) × log(distinct_features) × stability_factor` formula is reasonable but ad-hoc. The instability metric is grounded in decades of practice and produces a clean 0–1 number. Worth a side-by-side validation on a real project to see if the rankings disagree meaningfully.

- **Drift detection in long-prose sections.** Audit mode verifies discrete claims (paths, identifiers, env vars, commands). It does not verify multi-paragraph prose against code behavior — there's no good way to do that without a model in the loop. A paragraph in ARCHITECTURE.md describing "how the auth flow works" can drift while every grep-able reference in it stays valid. Possibly an LLM-pass mode separate from `audit`.

- **The ETH study used Python repos; results may differ for other ecosystems.** The 138-issue benchmark was Python-heavy. For repos where structure is *less* discoverable from filenames (dynamically-loaded plugins, code-generated services, monorepos with custom build graphs), "what agents can discover on their own" shifts. Dockit's framework detection partially addresses this; worth keeping an eye on as the literature broadens.
