# Home App

Homepage and standard page functionality.

## Page Models

### HomePage

Site root and landing page.

- **Parent types**: Root only
- **Child types**: BlogIndexPage, StandardPage, ContactPage
- **Template**: `templates/home/home_page.html`

**StreamField blocks**: heading, paragraph, image, card_grid, cta_block

### StandardPage

Generic content pages (About, Services, etc.)

- **Parent types**: HomePage
- **Child types**: None
- **Template**: `templates/home/standard_page.html`

**StreamField blocks**: Uses ContentStreamBlock (all standard blocks)

### ContactPage

Contact form with Wagtail form builder.

- **Parent types**: HomePage
- **Child types**: None
- **Template**: `templates/home/contact_page.html`

## Blocks

Uses blocks from `core/blocks/`

## Templates

Located in `templates/home/`:
- `home_page.html` - Landing page with hero section
- `standard_page.html` - Generic content layout
- `contact_page.html` - Form with success message

## Key Files

| File | Purpose |
|------|---------|
| `models.py` | HomePage, StandardPage, ContactPage models |
