# Page Models

Reference for all Wagtail Page models in this project.

## Page Hierarchy

```
[PAGE_HIERARCHY_ASCII]
```

## Models by App

[REPEAT_FOR_EACH_APP]
### [APP_NAME]

[REPEAT_FOR_PAGE_MODELS]
#### [MODEL_NAME]

**Purpose**: [MODEL_PURPOSE]

**Constraints**:
- Parent: [PARENT_PAGE_TYPES]
- Children: [SUBPAGE_TYPES]

**Fields**:

| Field | Type | Description |
|-------|------|-------------|
[FIELDS_TABLE]

**StreamField** (`body`):
[STREAMFIELD_BLOCKS_LIST]

**Panels**: [PANELS_SUMMARY]

**Template**: `[TEMPLATE_PATH]`

---

[END_REPEAT]
[END_REPEAT]

## Model Relationships

```
[MODEL_RELATIONSHIPS_DIAGRAM]
```

## Common Patterns

### Creating a new page programmatically

```python
from [APP].models import [PageModel]

parent = HomePage.objects.first()
new_page = [PageModel](
    title="Example",
    slug="example",
    # ... fields
)
parent.add_child(instance=new_page)
new_page.save_revision().publish()
```

### Querying pages

```python
# All published pages of type
[PageModel].objects.live()

# With specific parent
[PageModel].objects.child_of(parent_page).live()

# Filtered
[PageModel].objects.live().filter(field=value)
```

## Related Documentation

- [BLOCKS.md](./BLOCKS.md) - Block library reference
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [README.md](../README.md) - Project overview
