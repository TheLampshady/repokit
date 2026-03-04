# Blog App

Blog posts and blog index functionality.

## Page Models

### BlogIndexPage

Blog listing page with pagination.

- **Parent types**: HomePage
- **Child types**: BlogPage only
- **Template**: `templates/blog/blog_index_page.html`

**Custom context**: `get_context()` adds paginated `posts`

### BlogPage

Individual blog post with rich content.

- **Parent types**: BlogIndexPage
- **Child types**: None
- **Template**: `templates/blog/blog_page.html`

**StreamField blocks**: heading, paragraph, image, code, quote

**Related models**:
- `Author` (ForeignKey to snippet)
- `Category` (ManyToMany to snippet)

## Blocks

Uses `BlogStreamBlock` which includes:
- HeadingBlock
- ParagraphBlock
- ImageBlock
- CodeBlock (with syntax highlighting)
- QuoteBlock

## Templates

Located in `templates/blog/`:
- `blog_index_page.html` - Post listing with filters
- `blog_page.html` - Single post layout
- `includes/post_card.html` - Post preview card

## Key Files

| File | Purpose |
|------|---------|
| `models.py` | BlogIndexPage, BlogPage models |
