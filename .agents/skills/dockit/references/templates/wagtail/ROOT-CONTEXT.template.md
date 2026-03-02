# [PROJECT_NAME]

[ONE_LINE_DESCRIPTION]

## Stack

- **CMS**: Wagtail [WAGTAIL_VERSION] on Django [DJANGO_VERSION]
- **Database**: [DATABASE_TYPE]
- **Search**: [SEARCH_BACKEND]
- **Storage**: [STORAGE_BACKEND]
[IF_HEADLESS]
- **API**: Wagtail API v2 (headless)
[ENDIF]

## Quick Reference

| Command | Action |
|---------|--------|
| `[INSTALL_CMD]` | Install dependencies |
| `[MIGRATE_CMD]` | Run migrations |
| `[RUN_CMD]` | Start dev server |
| `[TEST_CMD]` | Run tests |

## Documentation

@docs/MODELS.md
@docs/BLOCKS.md
@docs/ARCHITECTURE.md
@docs/PRINCIPLES.md

## Apps

[REPEAT_FOR_EACH_APP]
- `[APP_NAME]/` - [APP_PURPOSE_ONE_LINE]
[END_REPEAT]

## Conventions

- Page models inherit from `wagtail.models.Page`
- Blocks defined in `[app]/blocks.py` or `core/blocks/`
- Templates follow `templates/[app]/[model_name].html`
- StreamField uses `use_json_field=True`

[IF_HAS_SNIPPETS]
## Snippets

Reusable content in `core/snippets/`:
[REPEAT_FOR_SNIPPETS]
- `[SNIPPET_NAME]` - [SNIPPET_PURPOSE]
[END_REPEAT]
[ENDIF]

[IF_HAS_SETTINGS]
## Site Settings

Global settings via Wagtail Settings:
[REPEAT_FOR_SETTINGS]
- `[SETTING_NAME]` - [SETTING_PURPOSE]
[END_REPEAT]
[ENDIF]
