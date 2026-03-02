# MyWagtail Site

Content management system for Example Corp.

## Stack

- **CMS**: Wagtail 7.3 on Django 5.1
- **Database**: PostgreSQL 16
- **Search**: PostgreSQL Full-Text Search
- **Storage**: AWS S3 for media

## Quick Reference

| Command | Action |
|---------|--------|
| `pip install -e ".[dev]"` | Install dependencies |
| `python manage.py migrate` | Run migrations |
| `python manage.py runserver` | Start dev server |
| `pytest` | Run tests |

## Documentation

@docs/MODELS.md
@docs/BLOCKS.md
@docs/ARCHITECTURE.md
@docs/PRINCIPLES.md

## Apps

- `home/` - Homepage and site root
- `blog/` - Blog posts and categories
- `core/` - Shared blocks, snippets, settings

## Conventions

- Page models inherit from `wagtail.models.Page`
- Blocks defined in `core/blocks/`
- Templates follow `templates/[app]/[model_name].html`
- StreamField uses `use_json_field=True`

## Snippets

Reusable content in `core/snippets/`:
- `Category` - Blog categories
- `Author` - Author profiles
- `CallToAction` - Reusable CTAs

## Site Settings

Global settings via Wagtail Settings:
- `SocialMediaSettings` - Social links
- `SEOSettings` - Default meta tags
