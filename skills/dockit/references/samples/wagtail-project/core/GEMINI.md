# Core App

Shared blocks, snippets, and site settings.

## Page Models

This app does not define Page models.

## Blocks

Defined in `core/blocks/`:

### Content Blocks (`content.py`)
- `HeadingBlock` - Section headings (h2, h3, h4)
- `ParagraphBlock` - Rich text paragraphs
- `CodeBlock` - Syntax-highlighted code
- `QuoteBlock` - Pull quotes with attribution

### Media Blocks (`media.py`)
- `ImageBlock` - Images with caption and alignment

### Layout Blocks (`layout.py`)
- `CardBlock` - Content cards
- `CardGridBlock` - Grid of cards (ListBlock)
- `CTABlock` - Call-to-action sections

### StreamBlock Compositions (`__init__.py`)
- `ContentStreamBlock` - General content (heading, paragraph, image, card_grid, cta)
- `BlogStreamBlock` - Blog content (heading, paragraph, image, code, quote)

## Snippets

Defined in `core/snippets.py`:

- `Category` - Blog categories (name, slug)
- `Author` - Author profiles (name, bio, photo)
- `CallToAction` - Reusable CTA content

## Site Settings

Defined in `core/settings.py`:

- `SocialMediaSettings` - Twitter, Facebook, LinkedIn URLs
- `SEOSettings` - Default meta description, OG image

## Key Files

| File | Purpose |
|------|---------|
| `blocks/` | All reusable blocks |
| `snippets.py` | Category, Author, CallToAction |
| `settings.py` | SocialMediaSettings, SEOSettings |
| `wagtail_hooks.py` | Admin customizations |
