# Principles

<!-- Synced from .specify/memory/constitution.md v1.0.0 on 2026-02-26 -->

## Non-Negotiables

1. **Content editors are first-class users** - Admin UX must be intuitive
2. **Performance matters** - Pages must load in under 2 seconds
3. **Accessibility is required** - WCAG 2.1 AA compliance minimum

## Tech Decisions

### CMS Framework: Wagtail

**Decision**: Use Wagtail CMS over alternatives (Django CMS, Contentful)

**Rationale**:

- Django-native, integrates with existing Python infrastructure
- Excellent editor experience with StreamField
- Strong community and long-term support (LTS releases)

### Database: PostgreSQL

**Decision**: PostgreSQL over SQLite/MySQL

**Rationale**:

- Full-text search built-in (avoid Elasticsearch dependency)
- JSON field support for StreamField
- Production-ready with managed options on all clouds

### Block Architecture: Centralized

**Decision**: All blocks in `core/blocks/`, not per-app

**Rationale**:

- Single source of truth for block definitions
- Consistent styling across pages
- Easier to maintain and update

### Template Strategy: Server-rendered

**Decision**: Traditional Django templates, not headless

**Rationale**:

- Simpler architecture for content-focused site
- Better SEO without hydration complexity
- Editors can preview exactly what visitors see

## Conventions

### Code Style

- Follow Django and Wagtail coding standards
- Type hints on all function signatures
- Docstrings with Args/Returns sections

### Model Naming

- Page models: `[Name]Page` (e.g., `BlogPage`, `StandardPage`)
- Block classes: `[Name]Block` (e.g., `CardBlock`, `CTABlock`)
- Snippet classes: Singular nouns (e.g., `Category`, `Author`)

### Template Organization

```
templates/
├── base.html           # Site base template
├── blocks/             # Block-specific templates
├── home/               # Home app templates
├── blog/               # Blog app templates
└── includes/           # Shared partials
```

### StreamField Conventions

- Always use `use_json_field=True`
- Define StreamBlocks for reuse, not inline
- Limit nesting depth to 2 levels

### Testing Requirements

- Unit tests for custom model methods
- Integration tests for page creation
- Template tests for block rendering

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-02-26 | Initial principles established | Team |
