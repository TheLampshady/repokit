# Block Library

Reference for all Wagtail blocks in this project.

## Block Index

| Block | Type | Location | Used In |
|-------|------|----------|---------|
| `HeadingBlock` | StructBlock | core/blocks/content.py | All pages |
| `ParagraphBlock` | RichTextBlock | core/blocks/content.py | All pages |
| `ImageBlock` | StructBlock | core/blocks/media.py | All pages |
| `CodeBlock` | StructBlock | core/blocks/content.py | BlogPage |
| `QuoteBlock` | StructBlock | core/blocks/content.py | BlogPage |
| `CardBlock` | StructBlock | core/blocks/layout.py | HomePage |
| `CardGridBlock` | ListBlock | core/blocks/layout.py | HomePage |
| `CTABlock` | StructBlock | core/blocks/layout.py | HomePage |
| `ContentStreamBlock` | StreamBlock | core/blocks/__init__.py | StandardPage |
| `BlogStreamBlock` | StreamBlock | core/blocks/__init__.py | BlogPage |

## Core Blocks

Shared blocks in `core/blocks/`:

### HeadingBlock

**Type**: StructBlock

**Purpose**: Section headings with size options

**Child Blocks**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `text` | CharBlock | Yes | Heading text |
| `size` | ChoiceBlock | Yes | h2, h3, or h4 |

**Usage**:

```python
from core.blocks import HeadingBlock

body = StreamField([
    ('heading', HeadingBlock()),
])
```

**Template**: `templates/blocks/heading_block.html`

---

### ParagraphBlock

**Type**: RichTextBlock (extended)

**Purpose**: Rich text paragraphs

**Features**: bold, italic, links, lists, embedded images

**Usage**:

```python
from core.blocks import ParagraphBlock

body = StreamField([
    ('paragraph', ParagraphBlock()),
])
```

---

### ImageBlock

**Type**: StructBlock

**Purpose**: Images with optional caption and alignment

**Child Blocks**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `image` | ImageChooserBlock | Yes | The image |
| `caption` | CharBlock | No | Image caption |
| `alignment` | ChoiceBlock | No | left, center, right, full |

**Template**: `templates/blocks/image_block.html`

---

### CodeBlock

**Type**: StructBlock

**Purpose**: Code snippets with syntax highlighting

**Child Blocks**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `language` | ChoiceBlock | Yes | python, javascript, bash, etc. |
| `code` | TextBlock | Yes | Code content |

**Template**: `templates/blocks/code_block.html`

---

### QuoteBlock

**Type**: StructBlock

**Purpose**: Pull quotes and testimonials

**Child Blocks**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `quote` | TextBlock | Yes | Quote text |
| `attribution` | CharBlock | No | Quote source |

**Template**: `templates/blocks/quote_block.html`

---

### CardBlock

**Type**: StructBlock

**Purpose**: Content cards for grids

**Child Blocks**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `title` | CharBlock | Yes | Card title |
| `description` | RichTextBlock | Yes | Card content |
| `image` | ImageChooserBlock | No | Card image |
| `link` | URLBlock | No | Card link URL |

**Template**: `templates/blocks/card_block.html`

---

### CardGridBlock

**Type**: ListBlock(CardBlock)

**Purpose**: Grid of cards (3-column layout)

**Usage**:

```python
from core.blocks import CardGridBlock

body = StreamField([
    ('card_grid', CardGridBlock()),
])
```

**Template**: `templates/blocks/card_grid_block.html`

---

### CTABlock

**Type**: StructBlock

**Purpose**: Call-to-action sections

**Child Blocks**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `title` | CharBlock | Yes | CTA headline |
| `text` | RichTextBlock | No | Supporting text |
| `button_text` | CharBlock | Yes | Button label |
| `button_link` | URLBlock | Yes | Button URL |
| `style` | ChoiceBlock | No | primary, secondary |

**Template**: `templates/blocks/cta_block.html`

---

## StreamBlock Compositions

Common StreamBlock configurations:

### ContentStreamBlock

Used in: StandardPage, HomePage body

**Allowed blocks**:

- `heading` (HeadingBlock)
- `paragraph` (ParagraphBlock)
- `image` (ImageBlock)
- `card_grid` (CardGridBlock)
- `cta` (CTABlock)

### BlogStreamBlock

Used in: BlogPage body

**Allowed blocks**:

- `heading` (HeadingBlock)
- `paragraph` (ParagraphBlock)
- `image` (ImageBlock)
- `code` (CodeBlock)
- `quote` (QuoteBlock)

## Block Patterns

### Creating a new StructBlock

```python
from wagtail.blocks import StructBlock, CharBlock, RichTextBlock
from wagtail.images.blocks import ImageChooserBlock

class CardBlock(StructBlock):
    title = CharBlock(max_length=255)
    description = RichTextBlock()
    image = ImageChooserBlock(required=False)

    class Meta:
        icon = 'doc-full'
        label = 'Card'
        template = 'blocks/card.html'
```

### Creating a new StreamBlock

```python
from wagtail.blocks import StreamBlock

class ContentStreamBlock(StreamBlock):
    heading = HeadingBlock()
    paragraph = ParagraphBlock()
    image = ImageBlock()
    card = CardBlock()

    class Meta:
        icon = 'edit'
```

### Nesting blocks

```python
class SectionBlock(StructBlock):
    title = CharBlock()
    content = StreamBlock([
        ('text', RichTextBlock()),
        ('image', ImageChooserBlock()),
    ])
```

## Related Documentation

- [MODELS.md](./MODELS.md) - Page models reference
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [README.md](../README.md) - Project overview
