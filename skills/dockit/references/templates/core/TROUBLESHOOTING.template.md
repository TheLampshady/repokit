# Troubleshooting

## Quick Reference

| Symptom | Likely Cause | Quick Fix |
|---------|--------------|-----------|
[QUICK_FIXES_TABLE]

## Development Environment

### Installation Issues

#### Dependencies won't install

**Symptom**: `[INSTALL_CMD]` fails with errors

**Solutions**:
```bash
# Clear cache and retry
[CLEAR_CACHE_COMMANDS]

# Check version
[VERSION_CHECK_CMD]
```

#### Version mismatches

**Symptom**: Incompatible version errors

**Solution**: Ensure you're using:
[VERSION_REQUIREMENTS]

### Runtime Issues

#### Port already in use

**Symptom**: `Error: listen EADDRINUSE :::PORT` or `Error: That port is already in use`

**Solution**:
```bash
# Find process using port
lsof -i :[PORT]

# Kill the process
kill -9 [PID]
```

#### Service won't start

**Symptom**: [SERVICE_START_SYMPTOM]

**Solutions**:
1. Check environment variables are set
2. Verify dependencies are running
3. Check logs: `[LOG_CMD]`

### Database Issues

[IF_HAS_DATABASE]
#### Connection refused

**Symptom**: Cannot connect to database

**Solutions**:
1. Verify database is running: `[DB_STATUS_CMD]`
2. Check connection string in `.env`
3. Ensure port is not blocked

#### Migration failures

**Symptom**: Migrations fail to run

**Solutions**:
```bash
# Check migration status
[MIGRATION_STATUS_CMD]

# Reset and re-run migrations (dev only!)
[MIGRATION_RESET_CMD]
```
[ENDIF]

[IF_WAGTAIL]
## Wagtail-Specific Issues

### Page Admin Issues

#### "Page type not allowed here"

**Symptom**: Cannot create page under certain parent

**Cause**: `parent_page_types` or `subpage_types` constraint

**Solution**: Check model constraints:
```python
class BlogPage(Page):
    parent_page_types = ['home.HomePage', 'blog.BlogIndexPage']
    subpage_types = []  # No children allowed
```

#### StreamField data not saving

**Symptom**: StreamField content disappears after save

**Causes**:
1. Missing `use_json_field=True` (Wagtail 5+)
2. Block validation errors (check admin messages)
3. JavaScript errors in admin (check browser console)

**Solution**:
```python
body = StreamField(
    ContentBlock(),
    use_json_field=True,  # Required for Wagtail 5+
    blank=True,
)
```

#### Rich text content shows raw HTML

**Symptom**: HTML tags visible instead of formatted text

**Solution**: Use `|richtext` filter in template:
```django
{{ page.body|richtext }}
```

### Image/Media Issues

#### Images not showing

**Symptom**: Broken image links

**Check**:
1. `MEDIA_URL` and `MEDIA_ROOT` in settings
2. Media files exist on disk
3. URL patterns include media serving (dev):
   ```python
   urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
   ```

#### "Original image file not found"

**Symptom**: Error when accessing image renditions

**Solutions**:
1. Re-upload the original image
2. Clear renditions: `python manage.py wagtail_update_image_renditions`
3. Check storage backend configuration

### Search Issues

#### Search returns no results

**Symptom**: Search doesn't find content that exists

**Solutions**:
1. Rebuild search index:
   ```bash
   python manage.py update_index
   ```
2. Verify model has `search_fields`:
   ```python
   search_fields = Page.search_fields + [
       index.SearchField('body'),
   ]
   ```
3. Check search backend is running (Elasticsearch)

### Page Tree Issues

#### "Page not found" for published page

**Symptom**: Page is published but returns 404

**Check**:
1. Page is published (not draft)
2. Page's ancestors are all published
3. Site settings point to correct root page
4. URL path is correct (`/parent/child/` not `/child/`)

#### Cannot delete page

**Symptom**: Delete fails with integrity error

**Cause**: Other content references this page

**Solution**: Find and remove references first

### Migration Issues

#### StreamField migration fails

**Symptom**: `KeyError` or `LookupError` for blocks

**Cause**: Block class renamed or removed

**Solution**: Use data migration to transform old block data

#### "No installed app with label 'wagtailcore'"

**Symptom**: Migration references missing app

**Solution**: Ensure INSTALLED_APPS order has Wagtail apps before your apps
[ENDIF]

## Build Issues

### Build fails

**Symptom**: Build command exits with error

**Common causes**:
1. Type errors - run `[TYPECHECK_CMD]`
2. Missing dependencies - run `[INSTALL_CMD]`
3. Environment variables missing

### Tests fail

**Symptom**: Tests pass locally but fail in CI

**Check**:
1. Environment variables in CI config
2. Test database setup
3. Timing/async issues

## Deployment Issues

### Deployment fails

**Symptom**: Deployment pipeline fails

**Debug steps**:
1. Check CI logs: [CI_LOGS_LOCATION]
2. Verify secrets are configured
3. Check infrastructure state

### Static files missing after deploy

**Symptom**: CSS/JS not loading in production

**Solution**:
```bash
[COLLECTSTATIC_CMD]
```

### Application crashes after deploy

**Symptom**: Application starts but crashes

**Debug steps**:
1. Check application logs: `[APP_LOG_CMD]`
2. Verify environment variables
3. Check resource limits (memory, CPU)

## Integration Issues

### API returns 401/403

**Symptom**: Unauthorized errors from API

**Solutions**:
1. Check auth token is valid
2. Verify token has required scopes
3. Check CORS configuration

### External service unavailable

**Symptom**: Calls to [SERVICE] fail

**Solutions**:
1. Check service status page
2. Verify credentials are current
3. Check network/firewall rules

## Debug Commands

| Purpose | Command |
|---------|---------|
[DEBUG_COMMANDS_TABLE]

## Logs

| Log Type | Location | Command |
|----------|----------|---------|
[LOGS_TABLE]

## Getting Help

| Issue Type | Where to Go |
|------------|-------------|
| Quick questions | [CHAT_CHANNEL] |
| Bug reports | [ISSUE_TRACKER] |
[IF_WAGTAIL]
| Wagtail issues | [Wagtail GitHub](https://github.com/wagtail/wagtail/issues) |
[ENDIF]
| Production incidents | [INCIDENT_PROCESS] |
| Security issues | [SECURITY_CONTACT] |

## Known Limitations

| Limitation | Workaround | Tracking Issue |
|------------|------------|----------------|
[LIMITATIONS_TABLE]

## Related Documentation

- [README.md](../README.md) - Project overview
[IF_WAGTAIL]
- [MODELS.md](./MODELS.md) - Page models reference
- [BLOCKS.md](./BLOCKS.md) - Block library reference
[ENDIF]
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Environment setup
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development workflow
