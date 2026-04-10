# Stitchtik Ticket Template

Adapted from repokit's canonical template. Stitchtik adds a Design section with
embedded mockup images, and a Component Inventory under Goals. This template is
independent — it is NOT synced from `src/ticket-template.md` via `make sync`.

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

## Design

<Embed Stitch mockup images so the reader sees the design before reading the work breakdown.
Use markdown image syntax. Include all variants (desktop, mobile) that were analyzed.>

![Desktop](desktop-screen.png)
![Mobile](mobile-screen.png)

**Breakpoint behavior:** <One line on how the layout adapts between desktop and mobile.
Only include when both variants exist.>

**HTML reference:** `code.html` — structural reference only, not project tech stack.
<Only include this line when code.html exists in the Stitch export.>

## Component Inventory

- **Leverage existing:** `path/to/Component` — [what changes]
- **Build new:** [Component name] — [what it is, why no existing match]
- **No change:** [Component] — already matches mockup

<This section tells speckit what to reuse vs. build. Be specific — include file paths
for existing components.>

## Goals

<Bulleted list detailing what needs to be done. Use sub-bullets for specifics. Group
related items under bold sub-headings when the ticket covers multiple areas of work.
Include desktop/mobile differences inline per component — don't repeat them in a
separate section.>

* **<Component or area of work>**
  - <Specific task or requirement>
  - Desktop: <desktop-specific detail>
  - Mobile: <mobile-specific detail>

* **<Another component or area>**
  - <Detail>

## Tech Details

<Technical notes that engineers need. Include when:
- A specific service, API, or technology is required
- There are architectural constraints
- There are open technical questions>

**Open Questions (for spec process):**
- <Unresolved technical decisions for speckit to research>
- <Use `[TBD]` inline for specific unknowns>

## References

- Design system: `specs/design-system.md` <or DESIGN.md notes>
- <Existing component files that need modification>
- <Other docs, links, or resources>

<Code paths and docs only. Mockup images are embedded in the Design section above —
do NOT repeat image paths here.>

## Acceptance Criteria

* **Given:** <Current state or precondition>
  **When:** <The action taken>
  **Then:** <Expected outcome>
  **and Then:** <Another expected outcome>

* **Given:** <Another scenario>
  **When:** <Action>
  **Then:** <Outcome>

<Cover: visual match to mockup, interactive states, responsive behavior, empty/error states.>

## Other

<Priority, dependencies, related tickets, rollout notes. Omit if nothing to add.
Reference dependencies by slug name, not numbers.>
```

## Section Guidelines

**Overview** — Write for the person who won't read the rest. They should understand what's
being built and why in under 10 seconds.

**Design** — The most important section visually. Embedded images let the reader see exactly
what's being built before reading the details. Include breakpoint behavior as a single line
when both desktop and mobile variants exist. Mention code.html only when it exists.

**Component Inventory** — Tells speckit what to reuse vs. build. Always include file paths
for existing components. This section is separate from Goals because it's a lookup table,
not a work breakdown.

**Goals** — Specific enough that a developer or agent can start without asking follow-up
questions. Desktop/mobile differences go inline per component — don't create a separate
responsive section that duplicates the goals.

**Tech Details** — Only when non-obvious. Flag unknowns with `[TBD]` for speckit.

**References** — Code paths and docs only. No image paths — those are embedded in Design.

**Acceptance Criteria** — Given/When/Then. Each independently testable. Visual match first,
then interactions, then edge cases.
