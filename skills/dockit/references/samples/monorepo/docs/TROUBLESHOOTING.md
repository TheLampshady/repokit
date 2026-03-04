# Troubleshooting

Common issues and solutions for the E-Commerce Platform.

---

## Quick Reference

| Symptom | Quick Fix |
|---------|-----------|
| `pnpm install` fails | Run `pnpm store prune` then retry |
| Port already in use | `lsof -i :PORT` and kill process |
| Database connection refused | Run `docker-compose up -d postgres` |
| Redis connection refused | Run `docker-compose up -d redis` |
| TypeScript errors after pull | Run `pnpm typecheck --force` |
| Tests fail on fresh clone | Run `pnpm db:migrate` first |

---

## Development Issues

### pnpm Install Fails

**Symptom:** `pnpm install` hangs or errors

**Solutions:**
```bash
# Clear pnpm cache
pnpm store prune

# Remove node_modules and retry
rm -rf node_modules **/node_modules
pnpm install

# Check Node version (requires 20+)
node --version
```

### Port Already in Use

**Symptom:** `Error: listen EADDRINUSE :::3000`

**Solution:**
```bash
# Find process using port
lsof -i :3000

# Kill it
kill -9 <PID>

# Or use different port
PORT=3001 pnpm --filter frontend dev
```

### Database Connection Refused

**Symptom:** `ECONNREFUSED 127.0.0.1:5432`

**Solutions:**
```bash
# Start PostgreSQL
docker-compose up -d postgres

# Check if running
docker-compose ps

# View logs
docker-compose logs postgres
```

### TypeScript Errors After Pull

**Symptom:** Type errors in files you didn't change

**Solutions:**
```bash
# Rebuild TypeScript project references
pnpm typecheck --force

# Clear TypeScript cache
rm -rf **/tsconfig.tsbuildinfo
pnpm typecheck
```

---

## Service-Specific Issues

### Frontend

| Issue | Cause | Solution |
|-------|-------|----------|
| Blank page | Build error | Check browser console, run `pnpm --filter frontend build` |
| API calls fail | Wrong backend URL | Check `VITE_API_URL` in `.env.local` |
| Styles missing | Tailwind not built | Run `pnpm --filter frontend dev` |

### Backend

| Issue | Cause | Solution |
|-------|-------|----------|
| 500 on all routes | DB not migrated | Run `pnpm --filter backend db:migrate` |
| Auth always fails | Missing Firebase creds | Check `FIREBASE_CREDENTIALS` in `.env` |
| Slow responses | Missing Redis | Start Redis: `docker-compose up -d redis` |

### Recommendations

| Issue | Cause | Solution |
|-------|-------|----------|
| Model not found | Model file missing | Run `pnpm --filter recommendations train` |
| Out of memory | Large batch size | Reduce `BATCH_SIZE` in `.env` |
| Slow predictions | No GPU | Expected in local dev |

---

## Docker Issues

### Containers Won't Start

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

### Database Data Lost

**Cause:** Docker volume was removed

**Solution:** Volumes persist data. Don't use `docker-compose down -v` unless intentional.

```bash
# List volumes
docker volume ls

# Data is in: ecom-platform_postgres_data
```

---

## CI/CD Issues

### Build Fails in CI

**Check:**
1. Do tests pass locally? `pnpm test`
2. Does lint pass? `pnpm lint`
3. Do types check? `pnpm typecheck`

**Common causes:**
- Missing test coverage
- Lint errors (CI is stricter)
- Environment variable not set in CI

### Deploy Fails

**Check Cloud Build logs:**
```bash
gcloud builds list --limit=5
gcloud builds log BUILD_ID
```

**Common causes:**
- Docker build fails (check Dockerfile)
- Missing secrets in Secret Manager
- Insufficient Cloud Run permissions

---

## Getting More Help

1. **Search existing issues** — [GitHub Issues](https://github.com/org/ecom-platform/issues)
2. **Ask in Slack** — #ecom-platform
3. **Check logs** — `docker-compose logs` or Cloud Logging
4. **Pair with someone** — Grab a teammate

---

## Related Documentation

- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Setup and configuration
- [CLOUD.md](./CLOUD.md) - Deployment and operations
- [CONTRIBUTING.md](./CONTRIBUTING.md) - Development workflow
