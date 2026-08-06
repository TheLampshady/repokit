# Phase 3 — Analysis

How agentkit turns discovery output into a proposed agent set. Invoked from [`SKILL.md`](../../SKILL.md#phase-3-analysis) § Phase 3.

Grouping decisions also depend on [`AGENT-SIZING.md`](./AGENT-SIZING.md), which owns the change-coupling principle, the split triggers, and the per-agent budgets. Nothing in this phase writes a file — its output is the plan the user reviews in Phase 4, shaped by [`REPORTING.md`](./REPORTING.md).

---

Foundation-led when FOUNDATIONS.md exists; custom-code-led otherwise.

### 3.1 Foundation Assessment (when FOUNDATIONS.md present)

For each foundation from step 1.0 of [DISCOVERY.md](./DISCOVERY.md), build:

```
Foundation: [name]
Slug: [kebab-case]
Path: [path]
Status: [active/intended/deprecated/etc.]
Health: [healthy/hotspot/unknown]
Owner: [team/person from FOUNDATIONS.md]
Consumers: [count] across [N] feature folders  — or "none yet (intended)"
Invariants: [count]
Sub-doc: [path or none]
Custom code in same tree: [list areas + file counts]
```

**`status: intended` changes how you scope, never whether you generate.** The catalog is declaring a sanctioned path the code hasn't adopted yet, so its `Consumers` column is empty by design. Two rules follow:

- **Never skip an `intended` foundation for having no consumers.** Zero adoption is what the status means. Skipping it leaves the team's most recent architectural decision with no agent that knows about it — the delegation blindspot, arriving at the worst possible moment.
- **Scope it by where consumers are *meant* to go**, not by the empty column: the foundation's own directory, the layer it exists to serve, directories a scaffold generates into, and — for a wrapper — the directories where the wrapped SDK is reachable. Include destination directories that are currently empty; being present the first time someone writes there is the entire job. `foundation-agent.template.md` carries the full sourcing note.

Then apply the **Grouping Principle: Change-coupling beats domain-tidiness** from `AGENT-SIZING.md`. Default to merging:

1. Start by assuming **one agent owns all foundations**.
2. For each foundation, run "the test" from AGENT-SIZING:
   > *"If a feature came in that needed to touch this foundation and another, would I be OK with the human (or LLM) consulting two agents and merging their advice — every time, for the life of this project?"*
3. Only split off a foundation when a **split trigger** fires — different owner team, hotspot mismatch, orthogonal invariants, different consumer base, or size-budget breach. The table in AGENT-SIZING § "Split triggers" is the whole authority; if none fires, group it.
4. Check the resulting set for **routability** — write each agent's one-line description and confirm no two would match the same request. A collision means you split on the wrong boundary. See AGENT-SIZING § "Check routability before proposing the set."

The default is **fewer agents**. Two agents that both touch a feature when it lands will conflict on triggering and drift apart on maintenance; one agent with broader ownership keeps the picture coherent. But the count itself is an output — never a target and never capped. Whatever the triggers and budgets produce is the right number, and a monorepo with eight uncoupled services legitimately yields eight agents.

Custom-code findings (3.2) fold into the foundation agents — don't add separate agents unless the custom code is unrelated to any foundation.

### 3.2 Custom Code Assessment (always runs)

For each custom code area from step 1.4 of [DISCOVERY.md](./DISCOVERY.md), build an assessment:

### Assessment Format

```
Area: [e.g., "Custom Wagtail StreamField Blocks"]
Extends: [framework feature/class being extended]
Framework: [name] @ [version]
Files: [count] ([list key files])
Complexity: low | medium | high
Custom logic: [brief description of what the team added]
Native alternative: [yes/no — if yes, explain what native feature could replace this]
Agent value: [why an agent helps here — what would AI get wrong without it]
```

### Native Alternative Detection

For each finding, check whether the framework handles this natively. Use the research from step 1.2 of [DISCOVERY.md](./DISCOVERY.md).

**Flag as "native/skip" when:**
- The framework provides this exact functionality out of the box
- The custom code adds nothing beyond configuration
- A newer version of the framework (that the project could upgrade to) provides this natively

**Flag as "borderline — ask user" when:**
- The custom code is small (<20 lines) and extends a native feature minimally
- A newer framework version provides a similar (but not identical) native feature
- The custom code exists but may be legacy/unused

**Flag as "agent-worthy" when:**
- Significant custom logic that AI assistants would get wrong
- Custom base classes that other project code depends on
- Patterns that look like framework defaults but behave differently (the most dangerous for AI)
- Growing areas with many files following the same custom pattern

### 3.3 Grouping into Agents

Apply the scaling logic from `AGENT-SIZING.md`:

**Foundation-led path (FOUNDATIONS.md present):**
1. Apply the Mapping Heuristic — produce the foundation→agent assignments
2. For each custom-code area (3.2), find the foundation it belongs to (same directory tree, extends a foundation, or same domain) and **fold it in**
3. Custom-code areas with no foundation home become separate domain-expert agents (no foundation ownership) — only if they pass the agent-worthy bar
4. Run the routability check across the whole proposed set; merge any pair whose descriptions collide

**Custom-code-only path (no FOUNDATIONS.md):**
1. Sort findings by file count (descending)
2. Group related findings (same framework area, same domain)
3. Apply project size limits
4. Merge small groups into larger ones
5. Name each proposed agent descriptively
