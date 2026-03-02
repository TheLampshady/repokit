# Architecture

## Overview

MyWagtail Site is a content management system built on Wagtail 7.3 and Django 5.1. It follows a traditional server-rendered architecture with PostgreSQL for data storage and full-text search.

## System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Browser                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Nginx (Reverse Proxy)                     │
│                    - SSL termination                         │
│                    - Static file serving                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Gunicorn (WSGI)                           │
│                    - 4 workers                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Django + Wagtail                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                   │
│  │   home   │  │   blog   │  │   core   │                   │
│  └──────────┘  └──────────┘  └──────────┘                   │
└─────────────────────────────────────────────────────────────┘
           │                              │
           ▼                              ▼
┌──────────────────────┐    ┌──────────────────────┐
│     PostgreSQL       │    │      AWS S3          │
│  - Page data         │    │  - Media files       │
│  - Full-text search  │    │  - Image renditions  │
└──────────────────────┘    └──────────────────────┘
```

## Wagtail Architecture

### Page Tree Structure

```
Root (/)
└── HomePage (home)
    ├── BlogIndexPage (/blog/)
    │   ├── BlogPage (/blog/post-1/)
    │   ├── BlogPage (/blog/post-2/)
    │   └── ...
    ├── StandardPage (/about/)
    ├── StandardPage (/services/)
    └── ContactPage (/contact/)
```

### App Organization

| App | Purpose | Key Models |
|-----|---------|------------|
| home | Homepage and generic pages | HomePage, StandardPage, ContactPage |
| blog | Blog functionality | BlogIndexPage, BlogPage |
| core | Shared components | Blocks, Snippets, Settings |
| search | Search configuration | - |

### home

**Purpose**: Homepage and standard content pages

**Models**:

| Model | Type | Description |
|-------|------|-------------|
| HomePage | Page | Site landing page with hero section |
| StandardPage | Page | Generic content pages |
| ContactPage | FormPage | Contact form with Wagtail forms |

**Key Files**:

| File | Purpose |
|------|---------|
| `models.py` | Page models, fields |

**See**: [home/GEMINI.md](../home/GEMINI.md)

### blog

**Purpose**: Blog posts and listing

**Models**:

| Model | Type | Description |
|-------|------|-------------|
| BlogIndexPage | Page | Blog listing with pagination |
| BlogPage | Page | Individual blog posts |

**Key Files**:

| File | Purpose |
|------|---------|
| `models.py` | Page models, fields |

**See**: [blog/GEMINI.md](../blog/GEMINI.md)

### core

**Purpose**: Shared blocks, snippets, and settings

**Models**:

| Model | Type | Description |
|-------|------|-------------|
| Category | Snippet | Blog categories |
| Author | Snippet | Author profiles |
| CallToAction | Snippet | Reusable CTAs |
| SocialMediaSettings | Setting | Social links |
| SEOSettings | Setting | Default meta tags |

**Key Files**:

| File | Purpose |
|------|---------|
| `blocks/` | All reusable blocks |
| `snippets.py` | Snippet models |
| `settings.py` | Site settings |
| `wagtail_hooks.py` | Admin customizations |

**See**: [core/GEMINI.md](../core/GEMINI.md)

### Content Flow

```
Editor creates content
         │
         ▼
┌──────────────────┐
│  Wagtail Admin   │
│  - Draft page    │
│  - StreamField   │
└──────────────────┘
         │
         ▼ (Publish)
┌──────────────────┐
│    Database      │
│  - Page tree     │
│  - Revisions     │
└──────────────────┘
         │
         ▼ (Request)
┌──────────────────┐
│  Page View       │
│  - get_context() │
│  - Template      │
└──────────────────┘
         │
         ▼
┌──────────────────┐
│  Browser         │
│  - Rendered HTML │
└──────────────────┘
```

### Block Architecture

Blocks are organized hierarchically:

```
core/blocks/
├── base.py          # Base block classes
├── content.py       # Text, rich text, headings
├── media.py         # Images, videos, embeds
├── layout.py        # Columns, sections, cards
└── __init__.py      # Public exports
```

See [docs/BLOCKS.md](./BLOCKS.md) for full block reference.

### Search Architecture

**Backend**: PostgreSQL Full-Text Search

**Indexed Models**:

- `BlogPage` (title, body, excerpt)
- `StandardPage` (title, body)

**Custom Search Fields**:

```python
search_fields = Page.search_fields + [
    index.SearchField('body'),
    index.FilterField('date'),
]
```

## Data Flow

```
Request → URL Router → View → Template → Response
                         │
                         ▼
                    Page.get_context()
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
         Page Fields          StreamField
              │                     │
              ▼                     ▼
         Simple values        Block renderers
                                   │
                                   ▼
                            Block templates
```

## Database

**Type**: PostgreSQL 16

**ORM**: Django ORM

### Key Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| `home_homepage` | Homepage data | hero_title, hero_image, body |
| `blog_blogpage` | Blog posts | date, author_id, body |
| `core_category` | Blog categories | name, slug |
| `core_author` | Author profiles | name, bio, photo |

### Wagtail Core Tables

| Table | Purpose |
|-------|---------|
| `wagtailcore_page` | Base page tree (MPTT) |
| `wagtailcore_pagerevision` | Page version history |
| `wagtailcore_site` | Site configuration |
| `wagtailimages_image` | Image library |
| `wagtaildocs_document` | Document library |

### Relationships

```
wagtailcore_page (1) ────┬──── home_homepage (1)
                         ├──── blog_blogpage (many)
                         │           │
                         │           ├── core_author (FK)
                         │           └── core_category (M2M)
                         │
                         ├──── home_standardpage (many)
                         └──── home_contactpage (1)
```

## External Integrations

| Integration | Purpose | Auth Method | Docs |
|-------------|---------|-------------|------|
| AWS S3 | Media storage | IAM Role | [AWS S3](https://aws.amazon.com/s3/) |
| SendGrid | Email delivery | API Key | [SendGrid](https://sendgrid.com/docs/) |

## Design Decisions

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| CMS | Wagtail, Django CMS, Headless | Wagtail | Best editor UX, Django-native |
| Search | Elasticsearch, PostgreSQL FTS | PostgreSQL FTS | Simpler ops, sufficient for needs |
| Storage | Local, S3, GCS | S3 | Team familiarity, cost |
| Templates | Server-rendered, Headless | Server-rendered | Simpler architecture, better preview |

## Related Documentation

- [README.md](../README.md) - Project overview
- [MODELS.md](./MODELS.md) - Page models reference
- [BLOCKS.md](./BLOCKS.md) - Block library reference
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Environment configuration
- [CLOUD.md](./CLOUD.md) - Deployment architecture
