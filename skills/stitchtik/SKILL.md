---
name: stitchtik
description: "Turn Google Stitch design exports into structured implementation tickets. Triggers when the user mentions Stitch, a stitch/ directory, or references a path inside a stitch/ folder — even without saying 'stitch' or 'ticket' explicitly. Key triggers: any mention of 'stitch', referencing a stitch/ path or subfolder, asking about UI mockups when stitch exports exist, 'what needs to change for this design', 'can you ticket the organize page'. Default action is ticket creation. Should NOT trigger for Figma designs (use figtik) or general ticket requests with no stitch context (use tik)."
user-invocable: true
---

# stitchtik

Analyze Google Stitch UI exports against the existing codebase and produce structured implementation tickets in `specs/tickets/`. Stitch exports contain screen mockups, optional generated HTML, and optional design system specs. The skill compares these against what already exists to determine the right ticket scope — avoiding tickets for work that's already done and grouping cross-cutting changes into single tickets.

## Stitch Export Format

A Stitch export is a directory containing:
- **`screen.png`** (required) — The UI mockup screenshot. This is the primary design artifact.
- **`code.html`** (optional) — Generated HTML/CSS. Useful as structural reference but unaware of the project's tech stack. Treat as reference only — never copy directly.
- **`DESIGN.md`** (optional) — Design system spec with color tokens, typography, spacing, component guidelines. When present, applies across all exports.

Export directories follow naming conventions:
- `posts_home` + `posts_home_mobile_v2` — same page, responsive variants
- `admin_settings` + `admin_settings_mobile_v2` — same page, responsive variants
- Suffixes like `_v2`, `_v4_polished` — iterations (use the latest)

## Step 0: Resolve the Input

The user may not hand you an exact path. Figure out what they mean:

1. **Explicit path given** (e.g., "stitch/init/post_detail_mobile_v2") — use it directly.
2. **Keyword match** (e.g., "look at the organize page" or "the admin settings mockup") — search for a matching subfolder in any `stitch/` directory in the project. Match loosely: "organize" matches `organize_mobile_v4_polished`, `organize_grey_containers`, etc. If multiple matches, list them and ask which one.
3. **Just "stitch"** with no specifics (e.g., "check the stitch exports") — list all export directories and ask the user which ones to work on.
4. **A folder inside stitch/** referenced without the word "stitch" (e.g., "look at posts_home_mobile_v2") — if a `stitch/` directory exists and contains a matching subfolder, use it. The user doesn't need to say "stitch" when the path makes the context obvious.

**The default action is ticket creation.** If the user says "look at the organize mockup" without saying "make a ticket", still proceed through the full skill workflow (compare, interview, generate ticket). The user invokes this skill because they want tickets — don't ask "do you want a ticket?" unless genuinely ambiguous.

## Step 1: Load Stitch Exports + Project Discovery (parallel)

### 1a: Read the Exports

The user points you to a directory with one or more exports. For each:

1. **View `screen.png`** with the Read tool — visual context is essential and cannot be skipped
2. **Read `code.html`** if present — scan for layout structure, component hierarchy, CSS values
3. **Read `DESIGN.md`** if present — extract design tokens and component guidelines

Build a mental inventory: what pages, sections, components, interactions, and data each screen shows.

**Group related exports** before analyzing:
- Same base name + `_mobile` suffix → responsive variants of one page (analyze together, ticket strategy depends on platform detection in Step 1b)
- Same base name + version suffix → design iterations (use the latest version)
- Different base names → different pages/features

### 1b: Scan the Existing Codebase

Understand what's already built:

- **Pages** — routes, page components, what each renders
- **Components** — shared components, UI library, layout primitives
- **Design system** — Tailwind config, CSS variables, existing tokens
- **Data flow** — API endpoints, models, what data the UI consumes
- **Existing design docs** — check `specs/design-system.md` if it exists
- **Platform coverage** — determine what platforms the codebase currently supports (see below)

#### Platform Detection

Check for existing responsive/multi-platform infrastructure to classify the project:

1. **Responsive infrastructure** — media queries, breakpoint configs (Tailwind `screens`, CSS `@media`), responsive utility classes, container queries
2. **Mobile-specific components** — bottom navigation, mobile drawers/sheets, touch gesture handlers, mobile layout wrappers
3. **Mobile routes or viewports** — separate mobile routes (`/m/`, responsive meta tags), mobile-specific page variants
4. **Platform-specific code splitting** — dynamic imports by viewport, separate mobile bundles, platform detection utilities

Classify into one of three states:
- **Both platforms exist** — responsive infrastructure is in place, components adapt to breakpoints
- **One platform only** — only desktop or only mobile exists in the codebase (no breakpoints, no responsive components, or only one viewport targeted)
- **Partial** — some responsive infrastructure exists but key pieces are missing (e.g., breakpoints defined but no mobile navigation, or media queries exist but only for a few pages)

## Step 2: Codebase Comparison

For each Stitch screen, compare against the existing codebase and classify every visible element:

| Category | Meaning | Ticket Strategy |
|----------|---------|----------------|
| **No change** | Existing code matches the mockup | Skip — don't ticket what's done |
| **Update existing** | Component exists but mockup shows differences | Ticket scoped to the delta |
| **New page** | An entire page/view that doesn't exist | One ticket per new page |
| **New component** | A new component needed by one or more pages | One ticket per component |
| **Cross-cutting** | A shared component (header, nav, layout) that changes across multiple screens | One ticket for the component, noting all affected pages |

### Resolve Library & Asset Conflicts

When the mockup uses different libraries, icons, fonts, or patterns than the project already has, don't ask the user to choose. Instead:

1. **Default to what the project already uses.** If the project uses Lucide React but the mockup shows Material Symbols, note the discrepancy in the report and map to Lucide equivalents in the ticket.
2. **Flag it clearly** in the comparison report so the user sees it, but treat it as resolved unless they say otherwise.
3. **Only escalate** if there's no reasonable equivalent in the existing project (e.g., the mockup relies on an animation library the project doesn't have).

This avoids blocking ticket creation on library decisions. The project's existing choices are the right default — the mockup is a reference, not a spec.

### Present the Analysis

Show the user a clear summary with your ticket plan already decided. Don't ask "which should I ticket?" — decide based on the comparison and present your plan for confirmation:

> "I compared the Stitch exports against your codebase. Here's what I found and my ticket plan:
>
> **Already implemented (no ticket needed):**
> - [component/page] — matches mockup
>
> **Tickets I'll create** (ordered by dependency):
> 1. **[Design system tokens]** — [what's new/changed] *(prerequisite for all below)*
> 2. **[Shared component]** — [cross-cutting change affecting N pages]
> 3. **[Page-level ticket]** — [what's changing]
>
> **Discrepancies resolved:**
> - Mockup uses [X], project uses [Y] — tickets will use [Y]
>
> I'll generate these unless you want to adjust."

The comparison is the most valuable part of this skill. Be thorough — the user is relying on you to catch what's already done vs. what actually needs work.

### Ticket Ordering (Atomic Design)

Order tickets using the atomic design principle — smallest building blocks first, compositions last. This ensures each ticket can be implemented without waiting for unrelated work:

1. **Design system tokens** — colors, typography, spacing changes
2. **Atoms** — icons, buttons, badges, form inputs
3. **Molecules** — search bars, card components, nav items
4. **Organisms** — headers, navigation bars, sidebars, shared layouts
5. **Pages** — full page-level tickets that compose the above

Within the same level, order by how many other tickets depend on it (most dependents first). Note dependencies explicitly in each ticket so speckit can parallelize where possible.

### Platform-Aware Ticketing

When Stitch exports include both desktop and mobile variants (e.g., `posts_home` + `posts_home_mobile_v2`), use the platform detection from Step 1b to decide the ticketing strategy automatically:

#### Scenario A: Both platforms exist (responsive codebase)

The project already has responsive infrastructure — breakpoints, media queries, mobile-aware components. Desktop + mobile variants of the same page become **ONE ticket** with a Responsive Requirements section. Both `screen.png` files go in the same ticket directory. This is breakpoint/layout work, not a new feature.

#### Scenario B: New platform (desktop-only adding mobile, or vice versa)

The project only targets one platform today. The Stitch exports introduce the other platform for the first time. Split into:

1. **Platform infrastructure tickets** (early in atomic ordering):
   - Responsive foundation — breakpoint config, viewport meta, responsive utilities
   - Mobile/desktop navigation — bottom tab bar, sidebar, hamburger menu (whichever is new)
   - Layout system — mobile layout wrapper, responsive container, platform-specific shell
   - Touch/interaction patterns — swipe handlers, mobile gestures (if adding mobile)

2. **Per-page tickets** still bundle both variants — each page ticket includes desktop + mobile `screen.png` and a Responsive Requirements section. But these tickets **depend on** the infrastructure tickets above and are ordered after them.

Present the infrastructure tickets as prerequisites in the ticket plan:
> "Your codebase is desktop-only — the Stitch exports introduce mobile for the first time. I'll create infrastructure tickets first:
> 1. **Responsive foundation** (breakpoints, viewport, utilities)
> 2. **Mobile navigation** (bottom tab bar)
> Then per-page tickets that depend on those:
> 3. **Posts home** (desktop update + mobile variant) — depends on 1, 2
> 4. **Admin settings** (desktop update + mobile variant) — depends on 1, 2"

#### Scenario C: Partial platform support

Some responsive infrastructure exists but key pieces are missing (e.g., breakpoints defined but no mobile navigation). Create tickets **only for the missing infrastructure** — don't re-ticket what's already built. Per-page tickets bundle both variants as in Scenario A, but depend on the gap-filling infrastructure tickets.

## Step 3: Interview

After presenting the comparison and ticket plan, ask only questions where the mockup and codebase genuinely leave ambiguity. The skill should be opinionated — make decisions, present them, and let the user correct rather than asking open-ended questions.

### Ask When Relevant
- "The mockup shows [interaction pattern] that doesn't exist yet — here's how I'd spec it: [recommendation]. Sound right?"
- "I see [data] in the mockup that doesn't match existing API responses. I'll add a backend task to the ticket — unless this data already exists somewhere I'm not seeing?"
- "There are [N] ways to interpret [ambiguous element]. I'm going with [X] because [reason]. Let me know if you meant something different."

### Don't Ask
- Which items to ticket (you already decided)
- Priority order (you already ordered by atomic dependency)
- Library/icon/font choices (default to existing project)
- Things clearly visible in the screenshot
- Implementation details inferable from codebase patterns
- Things that can be flagged as open questions for speckit to resolve

Keep it to 2-3 questions max. If nothing is genuinely ambiguous, skip the interview and go straight to generating tickets.

## Step 4: Generate the Ticket

### Ticket Location

Create in `specs/tickets/<ticket-name>/`:
- Use a **descriptive kebab-case slug** — e.g., `design-system-tokens`, `bottom-nav-bar`, `post-detail-redesign`. No numeric prefixes.
- Implementation order is expressed through **position in the backlog** and **dependency references** inside each ticket — not in filenames.
- Copy the relevant `screen.png` files into the ticket directory so the ticket is self-contained
- If `code.html` exists, copy it too (clearly labeled as reference)

### Ticket Structure

Follow the canonical ticket template in `./references/ticket-template.md`. Add these Stitch-specific sub-sections under Goals:

* **Component Inventory**
  - **Leverage existing:** `path/to/Component` — [what changes]
  - **Build new:** [Component name] — [what it is, why no existing match]
  - **No change:** [Component] — already matches mockup

* **Design References**
  - Stitch mockup: `specs/tickets/<name>/screen.png`
  - HTML reference: `specs/tickets/<name>/code.html` (reference only — not project tech stack)
  - Design system: link to `specs/design-system.md` or DESIGN.md notes

* **Responsive Requirements** (when desktop + mobile exports both exist)
  - Desktop: [layout description] — see `desktop-screen.png`
  - Mobile: [layout description] — see `mobile-screen.png`
  - Breakpoint behavior: [how layout adapts]

### Acceptance Criteria

Cover:
- Visual match to the Stitch mockup for each component
- Interactive states if discussed during interview
- Responsive behavior if multiple variants were provided
- Data rendering with real vs. empty states

### Backlog

If `specs/backlog.md` exists, append one line per ticket. **Position in the backlog IS the implementation order** — add tickets in dependency order (design tokens first, shared components next, pages last):

```
- [ ] Design system tokens [stitchtik] → tickets/design-system-tokens/ticket.md
- [ ] Bottom nav bar [stitchtik] → tickets/bottom-nav-bar/ticket.md
- [ ] Post detail redesign [stitchtik] → tickets/post-detail-redesign/ticket.md
```

If `specs/backlog.md` doesn't exist, create it with the entries.

## Stitch Prompt Generator (separate action)

This is NOT part of the ticket creation flow. Only generate Stitch prompts when the user explicitly asks for one — e.g., "generate a stitch prompt for the organize page", "I need a prompt for Stitch", "make me a stitch prompt for an empty state". Never offer or suggest this after ticket creation.

When the user asks for a Stitch prompt, generate one they can copy-paste directly into Google Stitch. Read the existing codebase to seed the prompt with the project's actual design tokens, so Stitch output stays consistent.

### Stitch Prompt Format

Structure as numbered sections. One structural change per prompt — if multiple changes are needed, produce separate prompts labeled "Prompt 1 of 3", etc.

```
1. [One-line purpose]: [what this screen does]

2. DESIGN SYSTEM (REQUIRED):
   - Platform: [mobile/web/tablet]
   - Theme: [description of visual style]
   - Colors: [Name (#hex) for [role]], [Name (#hex) for [role]]
   - Typography: [font families, sizes]
   - Spacing: [grid system, e.g., "8-pt grid, radius 12"]

3. PAGE STRUCTURE:
   - [Section 1]: [detailed description with component specifics]
   - [Section 2]: [description]
   - [Section 3]: [description]

4. SPECIFIC REQUIREMENTS:
   - [Concrete detail, e.g., "primary CTA button with fully rounded corners"]
   - [Another detail]
```

### Prompt Tips

- Seed with the project's actual design tokens — font families, color hex values, border radii, spacing scale
- Use specific UI terminology: "navigation bar", "call-to-action button", "card grid"
- Reference the existing DESIGN.md if one exists in the Stitch exports
- Present in a copyable code block so the user can paste directly into Stitch

## Conventions

- Always view `screen.png` before writing — visual context is non-negotiable
- Extract real values from code.html/DESIGN.md when available — don't approximate
- code.html is reference only — note this in tickets to prevent direct copying
- **Prefer existing project choices over mockup choices.** If the mockup uses different icons, fonts, colors, or libraries than the project already has, default to the project's existing tools and note the mapping. The mockup is a design reference, not a technology spec.
- Component inventory must distinguish "leverage existing" from "build new" so speckit prioritizes reuse
- **Decide, don't ask.** Make ticket scope and priority decisions yourself using atomic design ordering. Present your decisions for confirmation — don't ask open-ended "what do you want?"
- Shared component changes get ONE ticket noting all affected pages, not per-page tickets
- Desktop + mobile variants: auto-detect platform state (see Platform-Aware Ticketing in Step 2) — responsive codebase → one ticket; new platform → infrastructure tickets first, then bundled page tickets
- Flag backend API gaps when mockup shows data that doesn't match existing endpoints
- Keep ticket scope focused — if the comparison reveals 5 unrelated changes, that's 5 tickets, not 1
- **Stitch is the beginning, not the end.** Stitch outputs are mid-fidelity prototypes. Tickets should capture the design intent while accounting for what the codebase actually needs — don't over-spec pixel values from a prototype.
