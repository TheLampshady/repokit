# Troubleshooting

Common issues and solutions for MyWagtail Site.

---

## Quick Reference

| Symptom | Quick Fix |
|---------|-----------|
| Migrations fail | Check for pending migrations: `python manage.py showmigrations` |
| 500 error on page | Check logs: `python manage.py runserver` console |
| Images not loading | Rebuild renditions: `python manage.py wagtail_update_image_renditions` |
| Search not working | Rebuild index: `python manage.py update_index` |
| Static files missing | Collect static: `python manage.py collectstatic` |
| Admin login fails | Create new superuser: `python manage.py createsuperuser` |

---

## Development Issues

### Migrations Fail

**Symptom:** `django.db.utils.ProgrammingError` or migration conflicts

**Solutions:**

```bash
# Check migration status
python manage.py showmigrations

# If migrations conflict, reset (dev only!)
python manage.py migrate --fake [app] zero
python manage.py migrate [app]

# If StreamField changes cause issues
# Make sure use_json_field=True is set
```

### Page Returns 404

**Symptom:** Page exists in admin but returns 404

**Causes:**
1. Page not published
2. Page under unpublished parent
3. Site not configured

**Solutions:**

```python
# Check in Django shell
from wagtail.models import Page, Site

# Is page live?
page = Page.objects.get(slug='my-page')
print(page.live)  # Should be True

# Is site configured?
Site.objects.all()  # Should have root_page set
```

### StreamField Not Saving

**Symptom:** StreamField content disappears on save

**Cause:** Missing `use_json_field=True` (required in Wagtail 6+)

**Solution:**

```python
# In models.py
body = StreamField([
    ('paragraph', blocks.RichTextBlock()),
], use_json_field=True)  # Add this
```

---

## Image Issues

### Images Not Displaying

**Symptom:** Broken image links or 404s

**Solutions:**

```bash
# Rebuild renditions
python manage.py wagtail_update_image_renditions

# Check media URL in settings
# MEDIA_URL should be '/media/' or S3 URL

# Check storage backend
python -c "from django.conf import settings; print(settings.DEFAULT_FILE_STORAGE)"
```

### Image Upload Fails

**Symptom:** Error when uploading images

**Causes:**
1. File too large (check `DATA_UPLOAD_MAX_MEMORY_SIZE`)
2. Storage permissions
3. Invalid file type

**Solutions:**

```python
# In settings.py
DATA_UPLOAD_MAX_MEMORY_SIZE = 10485760  # 10MB

# Check allowed image types
WAGTAILIMAGES_EXTENSIONS = ['gif', 'jpg', 'jpeg', 'png', 'webp']
```

---

## Search Issues

### Search Returns No Results

**Symptom:** Search page shows no results even for existing content

**Solutions:**

```bash
# Rebuild search index
python manage.py update_index

# Check what's indexed
python manage.py update_index --verbosity=2
```

### Search Index Out of Date

**Symptom:** New pages not appearing in search

**Cause:** Auto-indexing disabled or failed

**Solution:**

```bash
# Update all indexes
python manage.py update_index

# Add to cron for production
# 0 2 * * * cd /app && python manage.py update_index
```

---

## Admin Issues

### Can't Create Page Type

**Symptom:** Page type not available in "Add child page"

**Cause:** Parent/child type constraints

**Solution:**

Check `parent_page_types` and `subpage_types`:

```python
class BlogPage(Page):
    parent_page_types = ['blog.BlogIndexPage']  # Can only be child of BlogIndexPage
    subpage_types = []  # No children allowed
```

### Admin Slow

**Symptom:** Wagtail admin loads slowly

**Causes:**
1. Too many pages in explorer
2. Complex StreamField rendering
3. Database queries

**Solutions:**

```python
# Limit explorer pagination
WAGTAILADMIN_RECENT_EDITS_LIMIT = 10

# Use select_related in page queries
def get_context(self, request):
    context = super().get_context(request)
    context['posts'] = BlogPage.objects.live().select_related('author')
    return context
```

---

## Template Issues

### Template Not Found

**Symptom:** `TemplateDoesNotExist` error

**Cause:** Template path doesn't match convention

**Solution:**

Wagtail looks for templates at:
```
templates/[app_label]/[model_name_snake_case].html
```

Example:
- Model: `blog.BlogPage`
- Template: `templates/blog/blog_page.html`

### Block Template Not Rendering

**Symptom:** Block shows raw data instead of rendered HTML

**Cause:** Missing block template

**Solution:**

Create template at path specified in block Meta:

```python
class CardBlock(StructBlock):
    title = CharBlock()

    class Meta:
        template = 'blocks/card_block.html'  # Create this file
```

---

## Production Issues

### Static Files 404

**Symptom:** CSS/JS not loading in production

**Solutions:**

```bash
# Collect static files
python manage.py collectstatic --noinput

# Check STATIC_URL and STATIC_ROOT in settings
# Verify Nginx/CDN is serving from correct path
```

### Media Files 404

**Symptom:** Uploaded images not loading in production

**Solutions:**

```bash
# Check S3 configuration
python -c "from django.conf import settings; print(settings.AWS_STORAGE_BUCKET_NAME)"

# Verify bucket permissions
aws s3 ls s3://your-bucket/media/
```

### High Memory Usage

**Symptom:** Container restarts, OOM errors

**Causes:**
1. Too many Gunicorn workers
2. Memory leaks in code
3. Large image processing

**Solutions:**

```bash
# Reduce Gunicorn workers
gunicorn --workers 2 --max-requests 1000 mywagtail.wsgi

# Add memory limit in Dockerfile
# Ensure image renditions are cached
```

---

## Getting Help

1. **Check Wagtail docs:** [docs.wagtail.org](https://docs.wagtail.org)
2. **Search issues:** [GitHub Issues](https://github.com/wagtail/wagtail/issues)
3. **Ask in Slack:** [Wagtail Slack](https://wagtail.org/slack/)
4. **Stack Overflow:** Tag `wagtail`

---

## Related Documentation

- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Environment setup
- [CLOUD.md](./CLOUD.md) - Deployment
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
