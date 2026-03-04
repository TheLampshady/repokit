# [APP_NAME] App

[APP_DESCRIPTION]

## Page Models

[REPEAT_FOR_PAGE_MODELS]
### [MODEL_NAME]

[MODEL_PURPOSE]

- **Parent types**: [PARENT_PAGE_TYPES]
- **Child types**: [SUBPAGE_TYPES]
- **Template**: `templates/[APP_NAME]/[TEMPLATE_NAME]`

**StreamField blocks**: [STREAMFIELD_BLOCKS_SUMMARY]

[END_REPEAT]

[IF_NO_PAGE_MODELS]
This app does not define Page models.
[ENDIF]

## Blocks

[IF_HAS_BLOCKS]
[REPEAT_FOR_BLOCKS]
- `[BLOCK_NAME]` - [BLOCK_PURPOSE]
[END_REPEAT]
[ENDIF]

[IF_NO_BLOCKS]
Uses blocks from `core/blocks/`
[ENDIF]

[IF_HAS_SNIPPETS]
## Snippets

[REPEAT_FOR_SNIPPETS]
- `[SNIPPET_NAME]` - [SNIPPET_PURPOSE]
[END_REPEAT]
[ENDIF]

## Templates

Located in `templates/[APP_NAME]/`:
[REPEAT_FOR_TEMPLATES]
- `[TEMPLATE_NAME]` - [TEMPLATE_PURPOSE]
[END_REPEAT]

## Key Files

| File | Purpose |
|------|---------|
| `models.py` | Page models and fields |
[IF_HAS_BLOCKS_FILE]
| `blocks.py` | App-specific blocks |
[ENDIF]
[IF_HAS_WAGTAIL_HOOKS]
| `wagtail_hooks.py` | Admin customizations |
[ENDIF]
