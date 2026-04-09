# Canonical Ticket Template

Adapted from repokit's canonical template. This is the base structure — stitchtik adds
Stitch-specific sub-sections under Goals (Component Inventory, Design References,
Responsive Requirements).

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

* **Component Inventory**
  - **Leverage existing:** `path/to/Component` — [what changes]
  - **Build new:** [Component name] — [what it is, why no existing match]
  - **No change:** [Component] — already matches mockup

* **Design References**
  - Stitch mockup: `specs/tickets/<name>/screen.png`
  - HTML reference: `specs/tickets/<name>/code.html` (reference only)
  - Design system: `specs/design-system.md` or DESIGN.md notes

* **Responsive Requirements** (when desktop + mobile variants exist)
  - Desktop: [layout description] — see `desktop-screen.png`
  - Mobile: [layout description] — see `mobile-screen.png`
  - Breakpoint behavior: [how layout adapts]

* **<Additional goal areas as needed>**
  - <Specific task or requirement>

## Tech Details

<Technical notes that engineers need. Include when:
- A specific service, API, or technology is required
- There are architectural constraints
- There are open technical questions>

**Open Questions (for spec process):**
- <Unresolved technical decisions for speckit to research>
- <Use `[TBD]` inline for specific unknowns>

## References

- Stitch mockup(s): `specs/tickets/<name>/screen.png`
- Stitch HTML reference: `specs/tickets/<name>/code.html` (visual reference only — not project tech stack)
- <Existing component files that need modification>
- <Design system doc if exists>

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

<Priority, dependencies, related tickets, rollout notes. Omit if nothing to add.>
```

## Section Guidelines

**Overview** — Write for the person who won't read the rest. They should understand what's
being built and why in under 10 seconds.

**Goals** — Specific enough that a developer or agent can start without asking follow-up
questions. The Component Inventory is critical — it tells speckit what to reuse vs. build.

**Tech Details** — Only when non-obvious. Flag unknowns with `[TBD]` for speckit.

**References** — Real paths only. Always include the Stitch screen.png. Note that code.html
is reference-only.

**Acceptance Criteria** — Given/When/Then. Each independently testable. Visual match first,
then interactions, then edge cases.
