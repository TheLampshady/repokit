# Phase 5 — Generation

How agentkit writes the agent files, once the user has approved the Phase 4 plan. Invoked from [`SKILL.md`](../../SKILL.md#phase-5-generation) § Phase 5.

Platform frontmatter differs in ways that fail *silently* — a wrong field name yields an agent that loads as inert markdown rather than erroring. [`platforms.md`](../platforms.md) is the authority on those field names and which are enforced.

---

For each approved agent, generate agent files for each selected platform.

### 5.1 Load Platform Specs

Read `../platforms.md` to get the exact frontmatter format and platform quirks for each target. Pay attention to the **foundation-owner frontmatter** section — frontmatter differs based on whether the agent owns foundations.

### 5.2 Pick the Right Template

| Agent type | Template |
|------------|----------|
| Owns ≥1 foundation from FOUNDATIONS.md | `../templates/foundation-agent.template.md` |
| Domain-expert with no foundation ownership | `../templates/agent.template.md` |

Foundation-owner agents get extra sections: `Owned Foundations`, `Invariants (hot memory)`, `Maintenance` (with cross-doc check + invariant change protocol). See `FOUNDATION-MAINTENANCE.md` for what each section must contain.

### 5.3 Generate Agent Files

For each agent, follow this sequence — frontmatter first, body second, validate, then write. Skipping any step (especially the frontmatter step) produces an inert agent file that no platform can discover.

#### Step 1 — Build the frontmatter (REQUIRED on every platform)

Every agent file starts with frontmatter. Two fields are non-negotiable:

| Field | Purpose | Without it |
|-------|---------|-----------|
| `name` | Identifier — what the agent is called for routing/triggering | Some platforms reject the file; on others the filename is used silently |
| `description` | When to trigger and what the agent does — primary mechanism for auto-invocation | The agent never auto-triggers; it only exists if name-called |

**Compose `name`:** kebab-case from the agent's domain (e.g., `auth`, `data-layer`, `messaging`). Match the filename you'll write to.

**Compose `description` — scope-bounded.** This is the field that decides when the host AI delegates to this agent. The description has to do **two jobs**:

1. **Define positive scope** — what the agent owns: foundations by name, working directories with paths, file patterns. Use concrete codebase references, not topic words. *"Use when modifying `core/auth/`"* triggers correctly; *"Use for auth"* triggers on every casual auth mention.
2. **Define negative scope** — what looks similar but should NOT trigger this agent: generic library questions, third-party SDK help, work in other parts of the codebase, adjacent areas owned by other agents.

A description with only positive scope **over-triggers** (the agent fires on topical keywords like "JWT" or "database" even when the work isn't in its territory). A description with only negative scope under-triggers. Both are required.

**Per-platform pattern:**
- **Claude** — include at least one negative `<example>` showing a query that sounds related but should NOT trigger this agent. Claude uses these to learn the boundary.
- **Antigravity / Copilot** — include an explicit "Do NOT use for:" clause naming the near-misses.

**Foundation-owner skeleton:**

```
Owner of [foundation list] in [project name]. Use when:
- modifying code in [working directories]
- modifying code that imports from [foundations]
- updating FOUNDATIONS.md entries for [foundations]
- [foundation-specific triggers]

Do NOT use for:
- generic [topic] questions unrelated to this project
- third-party SDK help
- work in other parts of the codebase that do not import [foundations]
- [adjacent areas owned by other agents]
```

Keep the full description under 1024 characters. Full pattern guide with examples per platform: [`DESCRIPTION-WRITING.md`](./DESCRIPTION-WRITING.md).

**Add platform-specific fields:** read `../platforms.md` and add them. For foundation-owner agents:

- **Claude** — `tools: Read, Edit, Write, Glob, Grep, Bash` plus `permissionMode: acceptEdits` (Claude enforces both — without them the agent can't edit `docs/`)
- **Copilot** — include `editFile`, `createFile`, `terminal` in `tools` (Copilot enforces the allowlist)
- **Antigravity** — `tools: [view_file, grep_search, replace_file_content, run_command]` plus `mainAgent: false` and `commandExecutionPolicy: sandbox`. Antigravity **does** enforce the allowlist (a reversal from Gemini CLI), and the default is `[]` — omit it and the agent can't do anything. Use Antigravity tool names, not Claude's; misspelled names can hang the subagent.

#### Step 2 — Build the body (once, shared across platforms)

**Always include (both templates):**

1. **Architecture Context** — pull the relevant excerpt from `ARCHITECTURE.md` or `README.md`. Keep to 5-10 lines. If no docs exist, summarize from code.

2. **Working Directories** — list the directories this agent operates in. For an `intended` foundation the catalog's `Consumers` column is empty by definition, so sourcing the table from it yields an agent that triggers on nothing. Scope it by where consumers are *meant* to go — the foundation's own directory, the layer it exists to serve, scaffold destinations, and for a wrapper the directories where the wrapped SDK is reachable — including directories that are currently empty. `../templates/foundation-agent.template.md` carries the full sourcing note and the no-precedent block that goes with it.

3. **Framework Context** — framework name and version. What's native vs what's custom in this area.

4. **Conventions** — extract from actual code patterns: naming, file organization, error handling, tests.

4b. **Exemplar (address, not content)** — one worked file per foundation, named by path and symbol, with a read-it-before-writing instruction. Sits *above* Custom Patterns, because worked code outranks prose about code. Which file, how to anchor it, and why it's an address rather than a paste: [§ Exemplar selection](#exemplar-selection).

5. **Custom Patterns (hot memory)** — for the 2-3 most critical patterns, **read the source files** and embed real code snippets. Prose for the rest. Embedded code is capped at what has no address: the canonical call site and a named anti-pattern that exists as real code. If a pattern lives in a file the agent could be told to read, give the path.

6. **Key Files** — table with "read when" guidance.

7. **When to Trigger** — scenarios with examples.

8. **Common Mistakes** — what AI gets wrong without this agent.

9. **Research** — project docs first, framework docs via context7 second, check for native alternatives third.

10. **Completion Handoff** — instructs the agent to state what it changed and what remains unverified when its scope is done, so the parent can sequence around dependent agents and knows what still needs checking. Verbatim phrasing comes from the template — don't paraphrase.

**Additional sections for foundation-owner agents (from foundation-agent.template.md):**

11. **Owned Foundations** — table of foundations this agent owns (name, path, status, sub-doc).

12. **Invariants (hot memory)** — copied verbatim from FOUNDATIONS.md per foundation, **including each one's `tier`** (Convention or Rule) and its **named anti-pattern and repair**. The anti-pattern is the operational half — an agent can't recognise a violation it can't name — so never trim it as detail. An agent that defends a Convention as though it were a Rule blocks legitimate work.

13. **Canonical usage (hot memory)** — the real call site from FOUNDATIONS.md per foundation, with its `path:line` comment. Not a signature list.

13b. **Extending and boundaries (hot memory)** — `Extend by` and `Doesn't cover` from the entry. The second tells the agent when building something new is correct rather than a violation; without it the agent forces every task through the foundation.

14. **Maintenance** — Change Checklist (verbatim from FOUNDATIONS.md), When to Update Docs table, Invariant Change Protocol, Cross-Doc Consistency Check.

15. **agentkit-managed marker** — HTML comment near the top of the body: `<!-- agentkit-managed -->`. Marks the agent as agentkit-generated so sync mode knows it's safe to update without prompting; hand-authored agents (no marker) are always treated as off-limits unless the user opts in.

**What the body must not contain:** an assertion of expertise. Open with scope and authority — *"You own X's Y foundation(s)"*, not *"You are the owner and subject-matter expert for…"*. Role framing in a system prompt measured as inert against a no-persona control, so it buys nothing and spends characters an exemplar address or a real invariant needs. Behavioral instructions that read like framing are not framing and stay: *"work through the existing foundation rather than inventing a new approach"* tells the agent what to do.

#### Exemplar selection

One worked file per foundation (or per custom area, for a non-foundation agent). Computed here at generation time from inputs agentkit already reads — nothing new to store, and no schema change to FOUNDATIONS.md.

1. **Candidate set** — the foundation entry's `Consumers` table (`Feature / Module` column), under its `#### Reference` heading. That table is Reference tier — *not* extracted into the agent — and nothing about this rule changes that: generation reads it to compute one address, and the address is what the agent carries. For a non-foundation agent, use the files in its working directories. For an `intended` foundation the table is empty by definition: emit no exemplar, and say so.
2. **Resolve to paths** — entries are feature or module names (`billing.invoices`), not necessarily paths. Convert to a directory the way the `Working Directories` table does; if one won't resolve, fall back to grepping for imports of the foundation and use the importing files directly. Skip a consumer you can't resolve rather than guessing at it.
3. **Drop disputed shapes** — exclude candidates inside a `hotspot` foundation's tree. High churn means the abstraction is under active dispute, and a shape the team is arguing about is the wrong thing for new code to copy. Filter before picking, so the pick can't land on one.
4. **Pick the newest** — the most recently *added* file among what's left:
   ```bash
   git log --diff-filter=A --format='%ad %H' --date=short --name-only -- <resolved-paths>
   ```
   The newest consumer is the last time someone did this task and got it through review, so it reflects current practice rather than the oldest surviving pattern.
5. **Anchor on a symbol, not a line range** — record the path plus the declaration the agent should look at: `` `app/notifications/order_confirmed.py` → `class OrderConfirmedNotification` ``. Line numbers move every time anything above them is edited, so a range goes wrong while the code is still perfectly good; a symbol goes wrong when the symbol is renamed or deleted, which is the drift worth catching. Both are greppable, so both are checkable — only one of them is stable.
6. **Record the add date alongside it** — `` — newest consumer, added 2026-05 ``. It's the only staleness signal a reader gets, so it isn't optional.
7. **When selection yields nothing** — every candidate was dropped, or the set was empty. Omit the row and say so in the Phase 6 report: *"no exemplar for `<foundation>` — all consumers sit in a hotspot tree."* An absent row is honest; a row pointing at a disputed pattern is worse than no row.

#### Why an address and not the code

This is the reasoning behind the exemplar, the embedded-code cap, and `SYNC.md` § Exemplar drift. It lives here so those three don't each carry their own copy of it — they state the rule and point back.

- **Cost.** A path plus a symbol runs ~80 characters against a 10,000-character body. The file itself runs ~1,500. Fifteen invariants fit in the difference.
- **Drift.** Pasting the file puts a second copy of the code inside a doc, where it goes stale silently the next time someone edits the original. That is the failure dockit exists to remove, and generating it on purpose would be indefensible.
- **Checkability.** An address that stops resolving is a checkable claim — sync greps for the symbol and reports what it can't find. A stale paste asserts nothing checkable, so nothing ever catches it.
- **The one real cost.** The agent spends a tool call reading the file, and might skip it. That's the tradeoff being made deliberately: a read that might not happen, against a copy that will certainly rot.

**`context7` doesn't substitute for this, and don't write a disclaimer into the agent saying so.** context7 serves third-party framework APIs — a genuinely different question from how this team builds one, and the exemplar exists only in this repository. The agent's `Research` section already routes framework questions to context7 and local ones to the exemplar; that ordering is the instruction, and prose explaining the distinction is body weight the agent doesn't act on.

#### Step 3 — Pre-write validation (do not skip)

Before writing the file, confirm every requirement is satisfied:

| Check | Required value |
|-------|----------------|
| Frontmatter starts with `---` and ends with `---` | yes |
| Frontmatter contains `name:` | yes, kebab-case, matches filename |
| Frontmatter contains `description:` | yes, includes positive scope (paths/foundations), negative scope ("Do NOT use for" or negative `<example>` on Claude), and "Use when..." triggers; under 1024 chars |
| Frontmatter contains platform-specific required fields | per `platforms.md`: **Claude** foundation-owners need `tools` + `permissionMode: acceptEdits` (both enforced); **Copilot** foundation-owners need `editFile`/`createFile`/`terminal` in `tools` (enforced); **Antigravity** needs an explicit `tools` list in Antigravity tool names (enforced; default `[]`) plus `mainAgent: false` and `commandExecutionPolicy: sandbox` |
| Body has `<!-- agentkit-managed -->` near the top | yes (agentkit-generated agents only) |
| Body has Owned Foundations + Maintenance sections | yes (foundation-owner agents only) |
| Body has Completion Handoff section with the verbatim "ready for verification" phrasing | yes (both templates) |
| Body names an exemplar by path and symbol, or the report says why it doesn't | yes (both templates) |
| Body is self-sufficient (below) | yes (both templates) |

**Self-sufficiency check.** A subagent runs in its own context window. Read the body once more and ask whether it still works for an agent that has:

- **no conversation history** — nothing the user said, nothing the parent decided
- **none of the files the parent already read** — including `docs/FOUNDATIONS.md` itself
- **no output style** — formatting preferences don't reach it
- **no auto memory** — the main conversation's accumulated notes don't load

Anything the agent *needs* that lives in one of those four is missing, not inherited. This is why the invariants are copied verbatim instead of referenced: a pointer to a doc the agent must remember to read is weaker than the line itself.

The one thing that *does* cross the boundary on Claude is the `CLAUDE.md` hierarchy — user, project, `CLAUDE.local.md`, unscoped `.claude/rules/`, managed policy — plus a git-status snapshot. Don't rely on it: it's platform-specific, and a rule that must hold belongs in the body. Never assume `AGENTS.md` reaches the agent; Claude Code reads `CLAUDE.md`, not `AGENTS.md`, unless the project imports one from the other.

**If any check fails, fix it before writing.** Do not write a file without `name` and `description` — that produces a file no platform discovers. It's worse than not generating the agent at all, because the user thinks they have an agent and don't.

#### Size check — split if too large

After building the body, check its size. An effective agent needs enough context to be useful but not so much that it becomes bloated or hits platform limits.

**Target size per agent:**

| Metric | Target | Split Signal |
|--------|--------|-------------|
| Body length | 3,000–8,000 characters | >10,000 characters |
| Embedded code snippets | 2–3 critical patterns | >5 snippets |
| Custom patterns covered | 3–10 per agent | >12 patterns |
| Working directories | 1–4 directories | >6 directories |

**What yields when the budget binds** — in order, cheapest loss first:

1. **Prose** — conventions restated in sentences, pattern descriptions, anything explaining code rather than showing it.
2. **Architecture Context** — trim toward the low end of 5–10 lines.
3. **A third or fourth embedded snippet** — replace with a path.

**What never yields:** the exemplar addresses, the invariants with their tiers and named anti-patterns, and the canonical call sites. Cutting an invariant to fit prose is backwards. The bet on exemplars ranking above prose is a working position rather than a measured one — see `docs/research/subagent-value-research.md` H4 — but at ~80 characters an address is cheap enough that being wrong about it costs almost nothing.

**If an agent exceeds the split signal:**

1. Look for a natural domain boundary to divide on (e.g., "custom blocks" and "custom page types" instead of one "wagtail-customs" agent)
2. Split into two focused agents, each with their own hot memory
3. Re-check that each resulting agent still covers 3+ files (don't create tiny agents)
4. Update the plan and confirm with the user before generating

**Splitting is better than trimming.** Two focused agents with rich context outperform one bloated agent with thin coverage. The goal is: each agent has enough embedded knowledge to be useful *without reading any files*, but stays focused enough to trigger reliably.

**Granularity guard — do NOT create:**
- One agent per class or file (too specific, triggers overlap)
- One agent per base class (unless 10+ files inherit from it)
- Agents for isolated utilities with no shared pattern

The right level is **one agent per domain area**: a group of related custom code that shares conventions, directories, and framework extension points.

#### Per-platform frontmatter quirks (reference)

Frontmatter is built in Step 1, but the platform-specific fields differ. All three platforms now enforce their `tools` allowlist — Antigravity's enforcement is new, so don't carry over old Gemini CLI habits. Recap of what `platforms.md` covers:

**Default agents (no foundation ownership):**
- Claude: `<example>` blocks inside the description string; no `permissionMode` needed; `tools` optional
- Antigravity: `tools: [view_file, grep_search]`, `mainAgent: false`, `model: inherit`, `commandExecutionPolicy: sandbox`; read-only scope note in body
- Copilot: keep total file size under 30,000 chars; tools allowlist IS enforced

**Foundation-owner agents:**
- Claude: `tools: Read, Edit, Write, Glob, Grep, Bash` plus `permissionMode: acceptEdits` (both enforced)
- Antigravity: add `replace_file_content` and `run_command` to `tools`, `model: pro`, keep `commandExecutionPolicy: sandbox`; foundation-owner scope note in body (authorized to edit `docs/`, forbidden outside it). No `permissionMode` equivalent exists — doc edits will prompt, and that's expected
- Copilot: include `editFile`, `createFile`, `terminal` in tools (enforced)

#### Step 4 — Write to output location

| Platform | Path |
|----------|------|
| Claude | `.claude/agents/<agent-name>.md` |
| Antigravity | `.agents/agents/<agent-name>.md` |
| Copilot | `.github/agents/<agent-name>.agent.md` |

Create directories if missing. Check Copilot size limit (30,000 chars) — if exceeded, split or trim.

### 5.4 Update Instruction Files

After generating agent files, enrich the project's AI instruction files with an agent routing section. This builds on the base instruction file created by each platform's `/init` command.

#### Detection

Check which instruction files exist:

| Platform | Instruction File | Created By |
|----------|-----------------|------------|
| Claude | `CLAUDE.md` | `/init` in Claude Code |
| Antigravity | `GEMINI.md` or `AGENTS.md` (workspace root) | `/init` in Antigravity CLI |
| Copilot | `.github/copilot-instructions.md` | `/init` in Copilot CLI |

#### If instruction file exists

Ask the user: "I see you have a `CLAUDE.md`. Want me to add the agent routing section?"

If yes, **append** (do not overwrite existing content) an agent routing section:

```markdown
