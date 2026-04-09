---
name: tik
description: "Create structured tickets from requests. Use this skill when the user asks to: create a ticket, write a ticket, make a ticket, draft a task, write up a feature request, create a story, write a bug report, or turn a request into a ticket. Also triggers when the user says things like 'ticket this', 'can you write that up', 'make a card for this', 'I need a ticket for X'. This is the default ticket creation skill — use it for any ticket request that does NOT involve a Figma link or Stitch exports. If the user provides a Figma URL or mentions Figma, use figtik instead. If the user references Stitch exports or a stitch/ directory, use stitchtik instead."
user-invocable: true
---

# tik

Turn simple requests into structured, well-written tickets. The output should be useful to everyone on the team — product leads understand the Overview, engineers work from Goals and Tech Details, and QA validates against Acceptance Criteria.

## When to Use

This is the default ticket creation skill. The user might say anything from "I need a ticket for adding dark mode" to a detailed paragraph about a bug they found. Your job is to expand their request into a complete ticket.

If the user provides a Figma link or wants a ticket based on a Figma design, hand off to `/figtik` instead. If they reference Stitch exports or a `stitch/` directory, hand off to `/stitchtik`. If they want a codebase audit, redirect to `/modernizer`.

## Process

### 1. Understand the Request

Read the user's request carefully. Identify:
- **What** they want built, fixed, or changed
- **Why** it matters (business context, user impact, urgency)
- **Any technical constraints** they mentioned (specific services, APIs, frameworks)
- **Any links or files** they referenced

### 2. Research Before Asking

Before asking the user anything, check the codebase and docs for answers:
- Read relevant source files, configs, READMEs, and existing docs
- Check `specs/` for related tickets or prior work
- Look at the project structure to understand what exists and what conventions are in place

This reduces back-and-forth and produces better tickets because they reflect the actual state of the project.

### 3. Clarify Only What You Can't Resolve

If questions remain after researching the codebase, ask the user — but do it well:
- **Offer a recommendation with each question.** Don't just ask "which database?" — say "I'd recommend PostgreSQL here because the project already uses it for X, but Redis could work if read latency is the priority. Which direction?"
- **Batch questions together** — 2-3 max per round.
- **It's OK to leave some things open.** This ticket will likely be passed to speckit for spec generation, where deeper technical research happens. Questions like "which caching strategy?" or "should we use a new service or extend the existing one?" can be flagged as open in the Tech Details section rather than blocking ticket creation. Mark these clearly so speckit knows to resolve them during the spec process.

### 4. Write the Ticket to `specs/tickets/`

Always save tickets to `specs/tickets/<slug>.md`:
- Generate a **unique, descriptive kebab-case slug** from the ticket's subject — e.g., `inventory-search-filter`, `dark-mode-support`, `checkout-flow-retry-logic`. No numbers or prefixes needed, just a clear name that won't collide with existing tickets.
- Check `specs/tickets/` for existing files to avoid duplicate slugs. If a collision exists, make the slug more specific.
- If `specs/backlog.md` exists, append a line: `- [ ] <Title> [tik] → tickets/<slug>.md`
- Create `specs/tickets/` if it doesn't exist yet.

After writing the ticket, give the user a **brief summary** in the conversation:
- The ticket title and file path
- 1-2 sentences on what the ticket covers
- Any open questions or `[TBD]` items that speckit will need to resolve

### 5. Write the Ticket

Read the canonical ticket template at `./references/ticket-template.md` (bundled with this skill). Use that template as-is — tik uses the base format with no additional sub-sections.

Every ticket gets Overview, Goals, and Acceptance Criteria. Tech Details, References, and Other are included only when relevant — don't pad the ticket with empty sections. Use `[TBD]` placeholders for details that aren't known yet — speckit will research and resolve these during the spec process.

---

## Writing Guidelines

**Overview** — Write for the person who won't read the rest of the ticket. They should understand what's being built and why it matters in under 10 seconds. Avoid jargon. The Note callout is for business-critical information only — don't use it for routine details.

**Goals** — Be specific enough that a developer can start working without asking follow-up questions. Bad: "Add search functionality." Good: "Add a search bar to the inventory page that filters items by name, SKU, and category as the user types." If the user's request was vague, make reasonable assumptions and state them explicitly.

**Tech Details** — Only include when there's something non-obvious. If the user mentioned a specific service ("use Redis for caching") or if the work clearly requires a particular technology, document it here. When you find relevant context in the codebase (existing patterns, services already in use, configs), reference it — this grounds the ticket in reality rather than assumptions. Open questions are often the most valuable part of this section. Not every question needs an answer before the ticket is written — flag questions that should be resolved during the spec process (technology research, architecture decisions, performance analysis) under "Open Questions (for spec process)" so speckit knows to pick them up. If there's nothing technical to note, omit the section entirely.

**References** — Include any links, file paths, or documentation the user mentioned. If you know of relevant docs in the project (like a design system file or API spec), include those too. Don't manufacture references that don't exist.

**Acceptance Criteria** — These are for QA. Each criterion should be independently testable. Start with the happy path, then cover edge cases. The Given/When/Then format keeps them unambiguous:
- **Given** establishes the starting state (logged in as admin, on the settings page, with 3 items in cart)
- **When** is the single action being tested (click submit, enter invalid email, resize to mobile)
- **Then** is what should happen (form submits, error message appears, layout switches to single column)
- **and Then** chains additional outcomes from the same action — use this instead of writing separate criteria when multiple things should happen together

**Other** — Use sparingly. Good candidates: priority level, estimated complexity (S/M/L), dependencies on other tickets, rollout considerations (feature flag, A/B test), or links to related work.

## Tone

Write tickets in a professional but approachable tone. Be direct. Don't pad with filler. The ticket should feel like it was written by someone who understands the work and respects the reader's time.
