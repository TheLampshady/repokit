# Block Library

Reference for all Wagtail blocks in this project.

## Block Index

| Block | Type | Location | Used In |
|-------|------|----------|---------|
[BLOCKS_INDEX_TABLE]

## Core Blocks

Shared blocks in `core/blocks/`:

[REPEAT_FOR_CORE_BLOCKS]
### [BLOCK_NAME]

**Type**: [BLOCK_TYPE] (StructBlock/StreamBlock/ListBlock)

**Purpose**: [BLOCK_PURPOSE]

**Child Blocks**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
[CHILD_BLOCKS_TABLE]

**Usage**:
```python
from core.blocks import [BLOCK_NAME]

body = StreamField([
    ('[block_key]', [BLOCK_NAME]()),
])
```

[IF_HAS_TEMPLATE]
**Template**: `templates/blocks/[TEMPLATE_NAME]`
[ENDIF]

---

[END_REPEAT]

## App-Specific Blocks

[REPEAT_FOR_EACH_APP_WITH_BLOCKS]
### [APP_NAME]

Located in `[APP_NAME]/blocks.py`:

[REPEAT_FOR_APP_BLOCKS]
#### [BLOCK_NAME]

**Purpose**: [BLOCK_PURPOSE]

**Fields**: [FIELDS_SUMMARY]

---

[END_REPEAT]
[END_REPEAT]

## StreamBlock Compositions

Common StreamBlock configurations:

[REPEAT_FOR_STREAMBLOCKS]
### [STREAMBLOCK_NAME]

Used in: [USED_IN_MODELS]

**Allowed blocks**:
[ALLOWED_BLOCKS_LIST]

[END_REPEAT]

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
    heading = CharBlock(form_classname="title")
    paragraph = RichTextBlock()
    image = ImageChooserBlock()
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
