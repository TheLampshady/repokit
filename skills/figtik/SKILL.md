---
name: figtik
description: "Turn Figma designs into structured implementation tickets. Use this skill when the user mentions Figma (a URL, file key, or the word 'figma') AND wants to create a ticket, break down the design into work items, or get an explanation of how to implement the design. Also triggers when the user wants to UPDATE an existing ticket with additional scope — Figma links, motion specs, interaction details, or any feature addition (e.g., 'add fadeout to the name-page ticket'). Key trigger phrases: 'create a ticket from this figma', 'ticket this figma', 'how would I implement this figma', 'break this design into tasks', 'make a ticket from this design', 'add motion to this ticket', 'update the ticket with this figma', 'add X to the Y ticket'. This skill should NOT trigger if the user just wants to inspect Figma data, export assets, or look at styles without creating a ticket — and should NOT trigger for general ticket requests without a Figma link (use tik instead)."
---

# figtik

This skill fetches Figma design data via the API, analyzes it against the existing codebase, walks you through a focused interview, and produces structured implementation tickets in `specs/tickets/`. Tickets are designed to be readable by humans (dev, design, QA) and consumable by speckit for spec generation.

## Modes

This skill operates in two modes:

- **Create** — new ticket from a Figma link (the default)
- **Update** — add scope to an existing ticket. This includes layering additional Figma data (motion specs, interaction details, responsive variants) OR adding non-Figma features (animations, API requirements, copy changes, etc.)

### Mode Detection

- **Create**: user provides a Figma link without referencing an existing ticket
- **Update**: user references an existing ticket by name OR says "update" / "add to" alongside a ticket reference. Target recent tickets in `specs/tickets/` — if ambiguous, list recent tickets and ask which one.

When updating, if a Figma link is provided, fetch and merge the new data. If no Figma link, just update the ticket content based on the user's description.

---

## Step 1: Parse the Figma Input

The user might provide:
- A full Figma URL: `https://www.figma.com/design/<file_key>/<name>?node-id=<node_id>`
- A file key + node ID separately: `BPMuear9Uqzb3fppxdPF8q` and `1452:1521`
- Just a URL and you need to extract the parts

Extract `file_key` and `node_id` from the input. Node IDs in URLs use `-` as separator (e.g., `1452-1521`) but the API uses `:` (e.g., `1452:1521`) — convert as needed.

If the user doesn't provide a node ID, ask which frame/screen they want to ticket. You can fetch the top-level file structure to help them pick.

**Update mode with Figma link:** Parse the new link the same way. You'll merge this data into the existing ticket folder.

**Update mode without Figma link:** Skip this step entirely — go straight to reading the existing ticket and updating it.

## Step 2: Fetch Figma Data + Project Discovery (parallel)

> **Run Steps 2a and 2b concurrently.** They are independent — Figma data fetch does not depend on project discovery, and vice versa. Proceed to Step 3 (Codebase Comparison) once both are complete.

### Step 2a: Fetch Figma Data

Run the fetch script from the skill's bundled scripts directory.

**Create mode:** Generate a kebab-case ticket name from the Figma node name and work type (e.g., `form-screen-redesign`, `hero-section-animation`). Create the folder and fetch into it:

```bash
mkdir -p specs/tickets/<ticket-name>
bash <skill-path>/scripts/figma_fetch.sh <file_key> <node_id> specs/tickets/<ticket-name>
```

**Update mode (with Figma link):** Fetch into the existing ticket folder. New data sits alongside the original since node IDs differ:

```bash
bash <skill-path>/scripts/figma_fetch.sh <file_key> <node_id> specs/tickets/<existing-ticket>
```

The script requires the `FIGMA_API_KEY` environment variable. If missing, tell the user:

> Add `export FIGMA_API_KEY="your-token"` to your `~/.bash_profile` (or `~/.zshrc`), then restart your terminal. Generate a token at https://www.figma.com/developers/api#access-tokens

Then parse the raw response:

```bash
bash <skill-path>/scripts/parse_figma.sh specs/tickets/<ticket-name>/figma_raw.json specs/tickets/<ticket-name>
```

This produces `figma.json` and `summary.txt`. The script also downloads rendered PNGs (@2x) and SVG exports into `images/`.

Read `summary.txt`, then **view the downloaded PNG(s)** in `images/` using the Read tool. The visual context — layout proportions, spacing relationships, composition — is essential and cannot be captured by JSON alone.

### Step 2b: Project Discovery

While Figma data is being fetched, scan the project to understand what already exists. This step runs once per project (cache your findings for the session).

#### Design System Detection

Check these locations for an existing design system:

1. **Tailwind config** — `tailwind.config.*`, `theme` section for colors, spacing, fonts
2. **CSS custom properties** — `:root` declarations in global CSS files
3. **Token files** — `tokens.json`, `tokens/`, `design-tokens/`, `theme/` directories
4. **Component library** — `components/`, `ui/`, `shared/` directories for existing component patterns
5. **Documentation** — `docs/`, `README.md`, any design system docs
6. **Existing design constitution** — check `specs/design-system.md` (this skill may have created one previously)

#### Design System Constitution

If the project has no `specs/design-system.md`, create one modeled after the speckit constitution format. If one already exists, update it with any new tokens or patterns discovered from this Figma design.

See **Appendix: Design System Constitution Template** at the bottom of this file for the full template.

The constitution serves two purposes: it helps this skill map Figma values to existing code on future runs, and it gives speckit a reference for what design patterns to leverage during implementation.

## Step 3: Codebase Comparison

> **Requires:** Both Step 2a (Figma data) and Step 2b (Project Discovery) must be complete before starting this step.

Analyze the Figma design against the existing codebase. Start with a surface-level comparison, then offer to go deeper.

### Surface Level (always do this)

1. **Component inventory** — for each major element in the Figma design, determine:

   | Figma Element | Status | Codebase Match | What Changes |
   |---|---|---|---|
   | Hero section | Exists — update | `components/Hero.tsx` | New background color, updated CTA text |
   | Pricing card | No change | `components/PricingCard.tsx` | — |
   | Feature grid | New — build | — | 3-column auto-layout, no existing match |

   Present this table to the user. It makes scope immediately clear and tells speckit what to reuse.

2. **Scope summary** — present what you think is changing:
   > "Here's what I see:
   >
   > **Leverage existing** (update in place):
   > - [component] — [what's changing]
   >
   > **Build new:**
   > - [component] — [why it's new]
   >
   > **No change needed:**
   > - [component]
   >
   > Does that match your intent?"

3. **Ripple effects** — flag changes that could affect other screens:
   > "Heads up — some changes could ripple:
   > - [e.g., 'New color tokens would apply globally']
   > - [e.g., 'The card component is shared across 3 other pages']
   >
   > Should the ticket scope include those, or just this screen?"

### Deep Dive (offer, don't force)

After presenting the surface analysis, offer:
> "Want me to go deeper? I can diff the exact CSS/style values between the Figma design and the current codebase — pixel-level spacing, color deviations, font mismatches."

If yes, produce a detailed diff comparing every Figma value to the nearest existing token and flag mismatches.

Only proceed to the interview once the user confirms the scope.

## Step 4: Interview the User

Ask focused questions to fill gaps that the Figma data and codebase comparison can't answer. Skip questions you can already answer from the data.

### Required Questions

1. **Scope confirmation** — from Step 3 (already asked)
2. **Priority components** — "I see these main elements: [list]. Should I ticket them all, or are some higher priority?"

### State Coverage

For each interactive component, present a state matrix and ask the user to confirm or fill gaps:

> "Here are the states I can infer. Checkmarks mean the Figma shows it; question marks are my guess:
>
> | Component | Default | Hover | Focus | Active | Disabled | Error | Loading | Empty |
> |---|---|---|---|---|---|---|---|---|
> | Submit button | Yes | ? | ? | ? | ? | — | ? | — |
> | Email input | Yes | — | ? | — | — | ? | ? | ? |
>
> Which states matter for this ticket?"

### Motion & Animation

Don't ask whether this is "design" or "motion" work — analyze it yourself:

1. **Check existing motion patterns** in the project (CSS transitions, animation utilities, Framer Motion, etc.)
2. **Analyze the Figma data** for interactive elements that imply motion
3. **Recommend specific animations** with concrete values:
   - "Pill selection: 150ms ease-out background-color transition (project uses `transition-colors`)"
   - "Submit button: scale(0.97) on press, 100ms"

4. **Ask the user to choose**:
   > "Based on the design and existing patterns:
   >
   > 1. [specific recommendation with timing/easing]
   > 2. [specific recommendation]
   >
   > **A)** Include in the ticket — **B)** No motion — **C)** Tweaks: ___"

### Conditional Questions

Only when relevant:

- **Text nodes present**: "Is the copy final, or placeholder?"
- **Images/assets present**: "Should I export assets from Figma, or are they available?"
- **No responsive frames**: "Platform priority? (mobile-first, desktop-first, both?)"
- **Unclear data dependencies**: "Does this screen need API data that doesn't exist yet?"

Keep it conversational — 2-3 questions at a time max.

## Step 5: Generate the Ticket

### Create Mode

Create the ticket in `specs/tickets/<ticket-name>/`.

### Update Mode

Read the existing `ticket.md`, then merge new information:
- Add new goals under a clear sub-heading (e.g., `### Motion & Animation`)
- Add new acceptance criteria for the new scope
- Add new references (Figma links, files)
- Add a changelog entry noting what was added and when
- Preserve all existing content — only add or modify, never remove previous scope

---

### ticket.md Template

Read the canonical ticket template at `./references/ticket-template.md` (bundled with this skill). figtik extends the base template with the following additions:

#### Goals — Figma-specific sub-sections

In addition to the standard goal bullets, include these sub-sections under Goals when the Figma data supports them:

* **Component Inventory**
  - **Leverage existing:** `path/to/Component` — [what changes]
  - **Build new:** [Component name] — [what it is, why it's new]

* **State & Interaction**
  - [Component]: default [desc], hover [desc], focus [desc], disabled [desc]

* **Motion & Animation** *(may be added/enriched via Update mode)*
  - [Element]: [animation with timing, easing, property]

* **Platform Priority**: [Mobile-first / Desktop-first / Both] — [details]

#### References — Figma-specific entries

In addition to any standard references, always include:
- **Figma (layout)**: the Figma URL with file key and node ID
- **Design system**: `specs/design-system.md` (if it exists)
- **Assets**: `specs/tickets/<ticket-name>/images/`
- **Figma data**: `specs/tickets/<ticket-name>/figma.json`

#### Acceptance Criteria — Figma-specific coverage

In addition to the standard happy path and edge cases, cover:
- Default/initial state rendering
- Each interactive state from the Goals section
- Responsive behavior if in scope
- Motion/animation timing and behavior if applicable

#### Changelog (update mode only)

Add this section at the end of the ticket when in Update mode:

```markdown
## Changelog

- [date] — Initial ticket created from [Figma node name]
- [date] — Added [scope description] from [source — Figma link or user request]
```

### Supporting Files

Produced by the fetch/parse scripts and stored in the ticket folder:

- `figma.json` — cleaned node data
- `summary.txt` — human-readable summary
- `figma_images.json` — image URLs (if fetch succeeded)
- `figma_svg.json` — SVG URLs (if fetch succeeded)
- `images/` — downloaded PNGs and SVGs

**Always view the PNG** before writing the ticket.

If the user provides extra screenshots or reference files, save them in the ticket folder.

## Conventions

- Ticket folder names use kebab-case: `form-redesign`, `hero-animation`
- Extract real values from Figma — never approximate colors or font sizes
- Goals should be specific enough to act on without re-reading designs
- Always reference the Figma URL in the ticket
- Component inventory must clearly distinguish "leverage existing" from "build new" so speckit prioritizes reuse
- When in Update mode, preserve all existing content — add or modify, never remove
- Keep the design system constitution (`specs/design-system.md`) up to date across tickets

---

## Appendix: Design System Constitution Template

Create this at `specs/design-system.md` when a project's design system is first discovered. Model after the speckit project constitution — versioned, principled, and kept in sync.

```markdown
# Design System Constitution

<!--
SYNC IMPACT REPORT
==================
Version change: X.X.X → X.X.X
Bump rationale: [reason]
-->

## I. Color Tokens

Mapping between design values and code tokens.

| Role | Figma Value | Code Token | CSS Variable / Class |
|------|-------------|------------|---------------------|
| Primary text | #1a1a1a | `text-gray-900` | `--color-text-primary` |
| Background | #ffffff | `bg-white` | `--color-bg-default` |

### Deviations to Verify
- [e.g., "Figma uses #f5f5f5 but code has --color-bg-subtle at #f7f7f7 — intentional?"]

## II. Typography Scale

| Role | Figma Font | Size/Weight/Height | Code Token |
|------|-----------|-------------------|------------|
| Heading 1 | Inter Bold | 32px/700/40px | `text-3xl font-bold` |

## III. Spacing Scale

| Figma Value | Code Token | Usage |
|-------------|------------|-------|
| 4px | `spacing-1` / `p-1` | Tight inner padding |
| 8px | `spacing-2` / `p-2` | Default inner padding |

## IV. Component Library

Existing coded components and their Figma counterparts.

| Figma Component | Code Path | Notes |
|-----------------|-----------|-------|
| Button/Primary | `components/ui/Button.tsx` | Supports variants: primary, secondary, ghost |

## V. Motion Patterns

Existing animation patterns in the codebase.

| Pattern | Implementation | Usage |
|---------|---------------|-------|
| Color transition | `transition-colors duration-150` | Interactive state changes |
| Fade in | `animate-fadeIn` | Page/section entrance |

## Governance

**Version**: 1.0.0 | **Created**: [date] | **Last Updated**: [date]

- MAJOR: Token removal or breaking rename
- MINOR: New tokens or components added
- PATCH: Value corrections or clarifications
```
