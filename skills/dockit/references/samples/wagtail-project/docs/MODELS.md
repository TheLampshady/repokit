# Page Models

Reference for all Wagtail Page models in this project.

## Page Hierarchy

```
Root
└── HomePage (home)
    ├── BlogIndexPage (blog)
    │   └── BlogPage (blog) [multiple]
    ├── StandardPage (home) [multiple]
    └── ContactPage (home)
```

## Models by App

### home

#### HomePage

**Purpose**: Site root page, landing page content

**Constraints**:
- Parent: Root only
- Children: BlogIndexPage, StandardPage, ContactPage

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `hero_title` | CharField | Hero section title |
| `hero_subtitle` | TextField | Hero section subtitle |
| `hero_image` | ForeignKey(Image) | Hero background image |
| `body` | StreamField | Main content area |

**StreamField** (`body`):
- `heading` - Section headings
- `paragraph` - Rich text paragraphs
- `image` - Full-width images
- `card_grid` - Grid of cards
- `cta_block` - Call to action sections

**Panels**: hero fields in MultiFieldPanel, body in FieldPanel

**Template**: `templates/home/home_page.html`

---

#### StandardPage

**Purpose**: Generic content pages (About, Services, etc.)

**Constraints**:
- Parent: HomePage
- Children: None

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `subtitle` | CharField | Page subtitle |
| `body` | StreamField | Main content |

**StreamField** (`body`): Uses `ContentStreamBlock` (all standard blocks)

**Template**: `templates/home/standard_page.html`

---

#### ContactPage

**Purpose**: Contact form page

**Constraints**:
- Parent: HomePage
- Children: None

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `intro` | RichTextField | Introduction text |
| `form_fields` | FormField | Wagtail form builder fields |
| `thank_you_text` | RichTextField | Success message |

**Template**: `templates/home/contact_page.html`

---

### blog

#### BlogIndexPage

**Purpose**: Blog listing page, shows all published posts

**Constraints**:
- Parent: HomePage
- Children: BlogPage only

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `intro` | RichTextField | Introduction text |

**Template**: `templates/blog/blog_index_page.html`

**Context Methods**:
- `get_context()` - Adds paginated `posts` to context

---

#### BlogPage

**Purpose**: Individual blog post

**Constraints**:
- Parent: BlogIndexPage
- Children: None

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
| `date` | DateField | Publication date |
| `author` | ForeignKey(Author) | Post author (snippet) |
| `categories` | ParentalManyToMany | Blog categories |
| `featured_image` | ForeignKey(Image) | Post featured image |
| `excerpt` | TextField | Short summary |
| `body` | StreamField | Post content |

**StreamField** (`body`):
- `heading` - Section headings
- `paragraph` - Rich text
- `image` - Images with captions
- `code` - Code blocks with syntax highlighting
- `quote` - Pull quotes

**Panels**: date/author in MultiFieldPanel, categories in FieldPanel, body in StreamFieldPanel

**Template**: `templates/blog/blog_page.html`

---

## Model Relationships

```
HomePage (1) ─────────────────┬─── BlogIndexPage (1)
                              │         │
                              │         └─── BlogPage (many)
                              │                   │
                              │                   ├── Author (FK)
                              │                   └── Category (M2M)
                              │
                              ├─── StandardPage (many)
                              │
                              └─── ContactPage (1)
```

## Common Patterns

### Creating a new page programmatically

```python
from blog.models import BlogPage
from wagtail.models import Page

parent = BlogIndexPage.objects.first()
new_page = BlogPage(
    title="My New Post",
    slug="my-new-post",
    date=date.today(),
    excerpt="A short summary",
)
parent.add_child(instance=new_page)
new_page.save_revision().publish()
```

### Querying pages

```python
# All published blog posts
BlogPage.objects.live()

# Posts by category
BlogPage.objects.live().filter(categories__name="News")

# Recent posts
BlogPage.objects.live().order_by('-date')[:5]
```

## Related Documentation

- [BLOCKS.md](./BLOCKS.md) - Block library reference
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [README.md](../README.md) - Project overview
