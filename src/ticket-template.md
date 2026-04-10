# Canonical Ticket Template

This is the single source of truth. Edit here, then run `make sync` to copy into each skill.
Skills may add sub-sections under Goals or additional top-level sections, but the base
structure stays the same.

## Base Template

```markdown
# <Ticket Title>

## Overview

<1-3 sentences explaining what this work is and what we get from it, written for
non-technical readers — leads, product, stakeholders. Focus on the outcome, not the
implementation.>

> **Note:** <Only include if there's something important for business decisions — timeline
risk, dependency on another team, cost implications, breaking change, etc. Omit this block
entirely if there's nothing notable.>

## Goals

<Bulleted list detailing what needs to be done. Use sub-bullets for specifics. Group
related items under bold sub-headings when the ticket covers multiple areas of work.>

* **<Goal area>**
  - <Specific task or requirement>
  - <Another detail>

* **<Another goal area>**
  - <Detail>

## Tech Details

<Technical notes that engineers need to know. Include this section when:
- A specific service, API, or technology is required or assumed
- There are architectural constraints or decisions to be aware of
- There are migration or backward-compatibility considerations
- There are open technical questions that need answers before or during implementation>

**Open Questions (for spec process):**
- <Unresolved technical decisions that speckit should research and resolve during spec
  generation — e.g., technology selection, architecture approach, performance strategy>
- <Use `[TBD]` inline for specific unknowns — e.g., "Cache layer: [TBD — evaluate Redis
  vs Memcached for session storage]">

## References

<Links, files, docs, or other resources that help with the ticket.>

- <Link or file reference>
- <Another reference>

## Acceptance Criteria

<A list of Given/When/Then scenarios for QA to verify the work is complete. Each scenario
describes a starting state, an action, and expected outcomes. Chain multiple outcomes with
"and Then" when they belong to the same scenario.>

* **Given:** <The current state or precondition>
  **When:** <The action taken>
  **Then:** <Expected outcome>
  **and Then:** <Another expected outcome from the same action>

* **Given:** <Another scenario's starting state>
  **When:** <Action>
  **Then:** <Outcome>

<Cover the happy path first, then edge cases, error states, and boundary conditions.>

## Other

<Anything that doesn't fit above — priority, estimated effort, dependencies, related
tickets, design considerations, rollout strategy, feature flags, etc. Omit this section
if there's nothing to add.>

## <Additional Sections as Needed>

<Some tickets naturally call for sections beyond the standard set. Add them when the
content doesn't fit cleanly into the sections above. Examples:
- **Migration Plan** — when the work involves data migration or breaking changes
- **Rollout Strategy** — when the feature needs phased deployment or feature flags
- **Security Considerations** — when auth, permissions, or sensitive data are involved
- **Performance Requirements** — when there are specific latency, throughput, or scale targets
- **Design Notes** — when there are UX decisions or wireframe references
- **Dependencies** — when the work is blocked by or blocks other tickets

Use your judgment. If a topic deserves its own heading to be clear, give it one.>
```

## Section Guidelines

**Overview** — Write for the person who won't read the rest of the ticket. They should
understand what's being built and why it matters in under 10 seconds. Avoid jargon. The
Note callout is for business-critical information only.

**Goals** — Be specific enough that a developer (or agent) can start working without
asking follow-up questions. Skills extend this section with domain-specific sub-sections:

| Skill | Adds under Goals |
|-------|-----------------|
| tik | (none — uses base format) |
| figtik | Component Inventory, State & Interaction, Motion & Animation, Platform Priority |
| stitchtik | Design (embedded images + breakpoint), Component Inventory (own section, not under Goals) |
| modernizer | Current State, Desired State, Execution (metadata, executor, verification, rollback) |

**Tech Details** — Only include when there's something non-obvious. Use `[TBD]` for
unknowns that speckit will resolve. Omit entirely if nothing to note.

**References** — Real links and file paths only. Don't manufacture references that don't exist.

**Acceptance Criteria** — Given/When/Then format. Each criterion independently testable.
Happy path first, then edge cases.

**Other** — Use sparingly. Priority, complexity, dependencies, rollout considerations.
