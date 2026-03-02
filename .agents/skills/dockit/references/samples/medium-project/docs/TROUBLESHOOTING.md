# Troubleshooting

Common issues and solutions organized by category.

---

## Quick Reference

| Symptom | Likely Cause | Quick Fix |
|---------|--------------|-----------|
| Database connection refused | PostgreSQL not running | `make db-start` |
| Auth token invalid | Wrong Firebase project | Check `FIREBASE_PROJECT_ID` in .env |
| Migrations fail | Database out of sync | `make db-reset` (dev only) |
| WebSocket disconnects | Redis not running | `make db-start` |
| Import errors | Dependencies missing | `make setup` |
| Tests fail with DB errors | Test DB not created | `make test-setup` |

---

## Development Environment

### Database Connection Refused

**Symptom:** `Connection refused` or `could not connect to server`

**Solutions:**

1. Start database containers:
   ```bash
   make db-start
   ```

2. Check containers are running:
   ```bash
   docker ps
   ```

3. Verify connection string in `.env`:
   ```
   DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/tasks
   ```

### Migration Failures

**Symptom:** `alembic` errors or table doesn't exist

**Solutions:**

1. Check migration status:
   ```bash
   make migrate-status
   ```

2. Reset database (dev only):
   ```bash
   make db-reset
   make migrate
   ```

3. Create migration for model changes:
   ```bash
   make migrate-create
   ```

### Redis Connection Issues

**Symptom:** WebSocket errors or cache failures

**Solutions:**

1. Verify Redis is running:
   ```bash
   docker ps | grep redis
   ```

2. Test connection:
   ```bash
   redis-cli -h localhost -p 6379 ping
   ```

---

## Authentication

### Invalid Token Errors

**Symptom:** `401 Unauthorized` with valid Firebase token

**Check:**

1. Firebase project ID matches:
   ```bash
   echo $FIREBASE_PROJECT_ID
   ```

2. Token is not expired (Firebase tokens expire after 1 hour)

3. Token is being sent correctly:
   ```bash
   curl -H "Authorization: Bearer TOKEN" http://localhost:8000/api/me
   ```

### Permission Denied

**Symptom:** `403 Forbidden` on workspace operations

**Cause:** User doesn't have required role in workspace

**Debug:**
```bash
# Check user's workspace membership
curl http://localhost:8000/api/workspaces/WORKSPACE_ID/members \
  -H "Authorization: Bearer TOKEN"
```

---

## Testing

### Tests Fail with Database Errors

**Symptom:** `relation does not exist` in tests

**Solutions:**

1. Ensure test database exists:
   ```bash
   make test-setup
   ```

2. Run migrations on test database:
   ```bash
   DATABASE_URL=...test make migrate
   ```

### Async Test Warnings

**Symptom:** `RuntimeWarning: coroutine was never awaited`

**Solution:** Ensure test functions are marked as async:
```python
@pytest.mark.asyncio
async def test_something():
    result = await some_async_function()
```

---

## Deployment

### Deploy Fails

**Symptom:** Cloud Build or Cloud Run errors

**Debug steps:**

1. Check build logs:
   ```bash
   gcloud builds list --limit=5
   gcloud builds log BUILD_ID
   ```

2. Check service status:
   ```bash
   gcloud run services describe task-manager
   ```

3. Check for secret access issues:
   ```bash
   gcloud run services describe task-manager --format="yaml" | grep -A5 secrets
   ```

### Application Crashes After Deploy

**Symptom:** Service starts but returns 500 errors

**Debug:**

1. Check logs:
   ```bash
   gcloud logging read "resource.type=cloud_run_revision" --limit=100
   ```

2. Verify environment variables are set:
   ```bash
   gcloud run services describe task-manager --format="yaml" | grep -A20 env
   ```

3. Test database connectivity from Cloud Run (check VPC connector)

---

## Performance

### Slow API Responses

**Symptom:** Requests taking >1 second

**Check:**

1. Database queries (N+1 problems):
   ```python
   # Enable SQL logging
   LOG_LEVEL=DEBUG make run
   ```

2. Missing indexes:
   ```sql
   EXPLAIN ANALYZE SELECT * FROM tasks WHERE workspace_id = 'uuid';
   ```

3. Connection pool exhaustion:
   - Increase `MAX_CONNECTIONS` in .env

---

## Debug Commands

| Purpose | Command |
|---------|---------|
| View logs | `make logs` |
| Check DB status | `docker ps` |
| Test DB connection | `make db-shell` |
| Test Redis | `redis-cli ping` |
| Run single test | `pytest -k "test_name" -v` |

---

## Getting Help

| Issue Type | Where to Go |
|------------|-------------|
| Bug reports | GitHub Issues |
| Questions | #task-manager Slack channel |
| Urgent production issues | Page on-call via PagerDuty |

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Environment setup
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development workflow
