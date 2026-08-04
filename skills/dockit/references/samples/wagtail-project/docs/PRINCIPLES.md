# Principles

Decisions this project has made that an agent or a new contributor would not guess.

> **Convention** — how it's done here. Follow by default; deviating is fine if you say why.
> **Rule** — deviating is a defect. Don't.

<!-- Compared against .specify/memory/constitution.md v1.0.0 on 2026-02-26 — no discrepancies. dockit never writes to that file, and it never overwrites this one. -->

---

## Conventions

**Define blocks in `core/blocks/`.** A `blocks.StructBlock` / `StreamBlock` / `ListBlock` declared in a per-app `blocks.py` drifts in styling and duplicates variants editors can't tell apart — move the class into `core/blocks/` and import it.

<details><summary>Why</summary>

Blocks defined per-app drifted in styling and duplicated three card variants that editors
couldn't tell apart.
Rejected: a shared base class per app — it standardises the code without standardising the
editor experience, which is the part that mattered.
</details>

**Every `StreamField` passes `use_json_field=True`.** A `StreamField(` without it stores the value as text, so the field can't be queried or indexed — add the argument when declaring the field.

[TODO: why?]

**Declare reusable `StreamBlock` classes.** An inline block list inside a `StreamField(...)` definition can't be reused or migrated as a unit — declare a named `class XBlock(blocks.StreamBlock)` in `core/blocks/` and reference it.

[TODO: why?]

**Keep block nesting to two levels.** A third `StreamBlock(` nested inside two others makes the editor UI unusable at typical browser widths — flatten it, or promote the inner block to a top-level choice.

<details><summary>Why</summary>

Three-level nesting makes the editor UI unusable at typical browser widths — the innermost
add-block control ends up off-screen.
Rejected: custom admin CSS to reclaim the width; it fixed the symptom on desktop only.
</details>

---

## Rules

**Pages render in under 2 seconds** at the 95th percentile on the production tier.

<details><summary>Why</summary>

Adopted from the project constitution. Content is the product; the 2024 rebuild lost
measurable organic traffic at the previous 4-second baseline.
</details>

**Templates and blocks meet WCAG 2.1 AA.**

<details><summary>Why</summary>

Adopted from the project constitution. Contractual requirement, not a preference.
</details>

**Admin UX changes are validated with a content editor before merge.** Editors are first-class users of this codebase, not an afterthought.

<details><summary>Why</summary>

Adopted from the project constitution.
Rejected: developer review only — the two prior StreamField redesigns both shipped changes
editors immediately worked around.
</details>

---

## Extending the codebase

| Adding a... | Do this |
|-------------|---------|
| Page type | Subclass `Page` in `<app>/models.py`, add `content_panels`, create `templates/<app>/<slug>.html`, then `make migrations` |
| Block | Add the class to `core/blocks/`, register it in the relevant `StreamBlock`, add `templates/blocks/<name>.html` |
| Snippet | Add the model to `<app>/models.py` with `@register_snippet`, singular noun name |
| Template partial | Add to `templates/includes/` — shared partials never live in an app template directory |

---

## Tech decisions

| Decision | Choice | Why |
|----------|--------|-----|
| CMS framework | Wagtail, over Django CMS and Contentful | Django-native, so it reuses existing Python infrastructure; StreamField gives editors composition without developer involvement; LTS releases match the support window |
| Database | PostgreSQL, over SQLite and MySQL | Built-in full-text search removes an Elasticsearch dependency; JSON fields back StreamField directly |
| Rendering | Server-rendered Django templates, not headless | Editors preview exactly what visitors see; no hydration cost on a content-first site |
| Block architecture | Centralised in `core/blocks/` | See the convention above |

---

## Change log

| Date | Change | Author |
|------|--------|--------|
| 2026-02-26 | Initial principles established | Team |

---

## Related documentation

- [README.md](../README.md) — project overview
- [ARCHITECTURE.md](./ARCHITECTURE.md) — system design
- [BLOCKS.md](./BLOCKS.md) — the block catalogue
- [CONTRIBUTING.md](./CONTRIBUTING.md) — development workflow, test commands, setup
