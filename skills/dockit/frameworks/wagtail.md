# Wagtail Framework Module

For Wagtail CMS projects (Django-based content management).

**Targets**: Wagtail 7.x (current stable: 7.3)

## Essential Commands

For README, always include these Django/Wagtail management commands:

```bash
# Database
python manage.py migrate              # Apply migrations
python manage.py makemigrations       # Create migrations

# Admin
python manage.py createsuperuser      # Create admin user

# Search
python manage.py update_index         # Rebuild search index

# Static/Media
python manage.py collectstatic        # Collect static files

# Development
python manage.py runserver            # Start dev server
python manage.py shell                # Django shell
```

If project uses custom management commands (check `*/management/commands/`), include those too.

## Analysis

### Detect Wagtail Stack

1. **Versions** - From pyproject.toml/requirements.txt:
   - Wagtail version
   - Django version

2. **Database** - From settings or env:
   - PostgreSQL, SQLite, MySQL

3. **Search backend**:
   - PostgreSQL FTS (default)
   - Elasticsearch
   - None

4. **Storage**:
   - Local filesystem
   - S3/GCS

5. **Optional packages**:
   - wagtail-localize (translations)
   - wagtail-grapple (GraphQL)
   - wagtail-ai (AI features)

### Map Django Apps

Find apps with Wagtail imports:

```python
# Apps importing from wagtail.models
from wagtail.models import Page
```

Categorize:
- **Page apps** - Apps with `Page` subclasses
- **Snippet apps** - Apps with `@register_snippet`
- **Settings apps** - Apps with `@register_setting`
- **Block apps** - Apps with reusable blocks

### Extract Page Models

For each `Page` subclass:

```python
class BlogPage(Page):
    body = StreamField(...)
    parent_page_types = ['home.HomePage']
    subpage_types = []
```

Extract:
- Class name + purpose (from docstring/name)
- Parent/child constraints
- StreamField definitions
- Panel configuration
- Template path

### Extract Blocks

For each block class:

```python
class CardBlock(StructBlock):
    title = CharBlock()
    image = ImageChooserBlock()
```

Extract:
- Class name + type (StructBlock, StreamBlock, ListBlock)
- Child blocks
- Meta options (icon, label, template)

### Extract Snippets & Settings

```python
@register_snippet
class Category(models.Model): ...

@register_setting
class SocialSettings(BaseSiteSetting): ...
```

### Detect API (Headless)

Look for:
- `wagtail.api` in urls.py
- `PagesAPIViewSet` usage
- Separate api/ app

## Extra Docs

Generate from `templates/wagtail/`:

| Doc | Purpose |
|-----|---------|
| `docs/MODELS.md` | Page models reference |
| `docs/BLOCKS.md` | Block library reference |
| `[app]/GEMINI.md` | Per-app AI context |

## Git Patterns

| Changed Files | Docs to Update |
|---------------|----------------|
| `*/models.py` (with Page) | MODELS.md, app GEMINI.md |
| `*/blocks.py` | BLOCKS.md, app GEMINI.md |
| `*/wagtail_hooks.py` | ARCHITECTURE.md |
| `templates/` | App GEMINI.md |
| `*/snippets.py` | ARCHITECTURE.md |
| Core patterns | *(see _default.md)* |

## Questions

Only ask if cannot detect:

1. **Headless vs Templates**
   - "Is this headless (API-only) or traditional templates?"
   - Default: templates (if templates/ folder exists)

2. **Multi-site**
   - "Multi-site setup with different domains?"
   - Default: no (single Site in settings)

## Templates

Use `templates/wagtail/`:
- `ROOT-CONTEXT.template.md` → `./GEMINI.md`
- `APP-CONTEXT.template.md` → `./[app]/GEMINI.md`
- `MODELS.template.md` → `./docs/MODELS.md`
- `BLOCKS.template.md` → `./docs/BLOCKS.md`

## AI Context (Root GEMINI.md)

```markdown
# [PROJECT_NAME]

[ONE_LINE_DESCRIPTION]

## Stack
- **CMS**: Wagtail [VERSION] on Django [VERSION]
- **Database**: [DATABASE]
- **Search**: [SEARCH_BACKEND]

## Commands

| Command | Action |
|---------|--------|
| `pip install -e ".[dev]"` | Install |
| `python manage.py migrate` | Migrate |
| `python manage.py runserver` | Run |
| `pytest` | Test |

## Docs
@docs/MODELS.md
@docs/BLOCKS.md
@docs/ARCHITECTURE.md

## Apps
- `home/` - Homepage and site root
- `blog/` - Blog functionality
- `core/` - Shared blocks and snippets

## Conventions
- Page models inherit from `wagtail.models.Page`
- Blocks in `core/blocks/` or `[app]/blocks.py`
- Templates: `templates/[app]/[model].html`
- StreamField: always `use_json_field=True`
```

## AI Context (Per-App GEMINI.md)

```markdown
# [APP_NAME] App

[APP_DESCRIPTION]

## Page Models
- `[ModelName]` - [purpose], parents: [types], children: [types]

## Blocks
- Uses blocks from `core/blocks/`

## Templates
Located in `templates/[app]/`

## Key Files

| File | Purpose |
|------|---------|
| `models.py` | Page models |
| `blocks.py` | App blocks (if exists) |
```

## Troubleshooting Additions

Add to TROUBLESHOOTING.md `[IF_WAGTAIL]` sections:

- Page admin issues (type constraints, StreamField saving)
- Image/media issues (renditions, storage)
- Search issues (index rebuild)
- Page tree issues (404s, deletion)
- Migration issues (StreamField changes)

## Architecture Additions

Add to ARCHITECTURE.md `[IF_WAGTAIL]` sections:

- Page tree structure diagram
- App organization table
- Block architecture
- Search architecture (if configured)
- API architecture (if headless)
- Wagtail core tables
