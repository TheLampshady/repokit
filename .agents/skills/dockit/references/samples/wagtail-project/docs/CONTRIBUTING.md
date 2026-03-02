# Contributing

Development workflow and guidelines for MyWagtail Site.

---

## Getting Started

1. Set up your development environment per [ENVIRONMENTS.md](./ENVIRONMENTS.md)
2. Create a feature branch from `main`
3. Make your changes
4. Submit a pull request

---

## Development Workflow

### 1. Create Branch

```bash
git checkout main
git pull origin main
git checkout -b feat/your-feature
```

Branch naming:
- `feat/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code refactoring

### 2. Make Changes

Follow these guidelines:
- One feature per branch
- Keep commits focused
- Update tests for new functionality
- Update docs if needed

### 3. Run Checks

```bash
# Run tests
pytest

# Run linting
ruff check .

# Run type checking
mypy .

# Format code
ruff format .
```

### 4. Commit

Use conventional commits:

```bash
git commit -m "feat(blog): add category filtering"
git commit -m "fix(home): resolve hero image sizing"
git commit -m "docs: update deployment guide"
```

### 5. Push and Create PR

```bash
git push -u origin feat/your-feature
```

Then create a PR on GitHub.

---

## Code Guidelines

### Python

- Follow PEP 8 (enforced by Ruff)
- Type hints for function signatures
- Docstrings for public methods

```python
def get_featured_posts(self, limit: int = 5) -> list[BlogPage]:
    """Return the most recent featured blog posts.

    Args:
        limit: Maximum number of posts to return.

    Returns:
        List of published BlogPage instances marked as featured.
    """
    return BlogPage.objects.live().filter(featured=True)[:limit]
```

### Wagtail Models

- Use `use_json_field=True` for all StreamFields
- Set `parent_page_types` and `subpage_types` explicitly
- Group fields with MultiFieldPanel
- Add help_text for editor clarity

```python
class BlogPage(Page):
    date = models.DateField(help_text="Publication date")

    body = StreamField([
        ('paragraph', blocks.RichTextBlock()),
    ], use_json_field=True)

    parent_page_types = ['blog.BlogIndexPage']
    subpage_types = []

    content_panels = Page.content_panels + [
        MultiFieldPanel([
            FieldPanel('date'),
        ], heading="Metadata"),
        FieldPanel('body'),
    ]
```

### Templates

- Extend base templates
- Use Wagtail's `{% include_block %}` for StreamField
- Keep logic in views/models, not templates

```html
{% extends "base.html" %}
{% load wagtailcore_tags %}

{% block content %}
    <h1>{{ page.title }}</h1>

    {% for block in page.body %}
        {% include_block block %}
    {% endfor %}
{% endblock %}
```

### Blocks

- Create blocks in `core/blocks/`
- Use descriptive names
- Set icon and label in Meta

```python
class CardBlock(StructBlock):
    title = CharBlock(required=True)
    image = ImageChooserBlock(required=False)
    link = URLBlock(required=False)

    class Meta:
        icon = 'doc-full'
        label = 'Card'
        template = 'blocks/card_block.html'
```

---

## Testing

### Running Tests

```bash
# All tests
pytest

# Specific app
pytest blog/

# Specific test
pytest blog/tests/test_models.py::test_blog_page_creation

# With coverage
pytest --cov=. --cov-report=html
```

### Writing Tests

```python
import pytest
from wagtail.test.utils import WagtailPageTestCase
from blog.models import BlogPage, BlogIndexPage

class TestBlogPage(WagtailPageTestCase):
    def test_can_create_blog_page(self):
        """Blog pages can be created under BlogIndexPage."""
        self.assertCanCreateAt(BlogIndexPage, BlogPage)

    def test_blog_page_parent_types(self):
        """Blog pages can only exist under BlogIndexPage."""
        self.assertAllowedParentPageTypes(
            BlogPage,
            {BlogIndexPage}
        )

@pytest.mark.django_db
def test_blog_page_context():
    """Blog index provides paginated posts in context."""
    # ... test implementation
```

### Test Requirements

- All new page models need tests
- All new blocks need tests
- Critical user flows need integration tests

---

## Pull Request Process

### Requirements

- [ ] Tests pass
- [ ] Lint passes
- [ ] Code is formatted
- [ ] Docs updated (if needed)
- [ ] Migrations included (if needed)

### Review

1. Automated checks run
2. Code review by maintainer
3. Manual testing for UI changes
4. Approval required before merge

### Merging

- Squash and merge to `main`
- Delete branch after merge
- Staging deploys automatically

---

## Migrations

### Creating Migrations

```bash
# After model changes
python manage.py makemigrations

# Name migrations descriptively
python manage.py makemigrations --name add_featured_field_to_blog
```

### Migration Guidelines

- Include migrations in your PR
- Test migrations locally before pushing
- For data migrations, use `RunPython` with reverse function
- Never edit existing migrations in production

---

## Release Process

1. Merge PRs to `main`
2. Create release tag: `git tag v1.2.3`
3. Push tag: `git push origin v1.2.3`
4. CI deploys to production

---

## Getting Help

- **Questions:** Ask in #dev Slack channel
- **Bugs:** Create GitHub issue
- **Wagtail help:** [Wagtail Slack](https://wagtail.org/slack/)

---

## Related Documentation

- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Development setup
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
- [PRINCIPLES.md](./PRINCIPLES.md) - Patterns and conventions
