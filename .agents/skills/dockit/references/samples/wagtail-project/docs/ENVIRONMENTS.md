# Environments

Environment setup and configuration for MyWagtail Site.

---

## Local Development

### Prerequisites

| Requirement | Version | Check |
|-------------|---------|-------|
| Python | 3.12+ | `python --version` |
| PostgreSQL | 16+ | `psql --version` |
| Node.js | 20+ | `node --version` |

### Setup

```bash
# 1. Clone repository
git clone https://github.com/example/mywagtail.git
cd mywagtail

# 2. Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# 3. Install dependencies
pip install -e ".[dev]"

# 4. Create database
createdb mywagtail

# 5. Configure environment
cp .env.example .env
# Edit .env with your settings

# 6. Run migrations
python manage.py migrate

# 7. Create admin user
python manage.py createsuperuser

# 8. Start server
python manage.py runserver
```

**URLs:**
- **Site:** http://localhost:8000
- **Admin:** http://localhost:8000/admin/

---

## Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET_KEY` | Django secret key | `your-secret-key-here` |
| `DATABASE_URL` | PostgreSQL connection | `postgres://user:pass@localhost/mywagtail` |
| `ALLOWED_HOSTS` | Comma-separated hosts | `localhost,127.0.0.1` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUG` | Enable debug mode | `False` |
| `AWS_STORAGE_BUCKET_NAME` | S3 bucket for media | - |
| `AWS_ACCESS_KEY_ID` | AWS access key | - |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | - |
| `SENDGRID_API_KEY` | Email delivery | - |

### Example .env

```bash
# Django
SECRET_KEY=your-secret-key-change-in-production
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DATABASE_URL=postgres://localhost/mywagtail

# Storage (optional - uses local storage if not set)
# AWS_STORAGE_BUCKET_NAME=mywagtail-media
# AWS_ACCESS_KEY_ID=...
# AWS_SECRET_ACCESS_KEY=...

# Email (optional - uses console backend if not set)
# SENDGRID_API_KEY=...
```

---

## Environments

### Development

| Setting | Value |
|---------|-------|
| `DEBUG` | `True` |
| Database | Local PostgreSQL |
| Storage | Local filesystem |
| Email | Console output |

### Staging

| Setting | Value |
|---------|-------|
| URL | `staging.mywagtail.dev` |
| `DEBUG` | `False` |
| Database | Cloud SQL |
| Storage | AWS S3 |
| Email | SendGrid |

### Production

| Setting | Value |
|---------|-------|
| URL | `www.mywagtail.com` |
| `DEBUG` | `False` |
| Database | Cloud SQL (HA) |
| Storage | AWS S3 + CloudFront |
| Email | SendGrid |

---

## Database

### Local Setup

```bash
# Create database
createdb mywagtail

# Or with specific user
createdb -U postgres mywagtail
```

### Migrations

```bash
# Apply migrations
python manage.py migrate

# Create new migration
python manage.py makemigrations

# Show migration status
python manage.py showmigrations
```

### Reset (Dev Only)

```bash
dropdb mywagtail
createdb mywagtail
python manage.py migrate
python manage.py createsuperuser
```

---

## Search Index

Wagtail uses PostgreSQL full-text search.

```bash
# Rebuild search index
python manage.py update_index

# Update specific app
python manage.py update_index blog
```

---

## Static & Media Files

### Development

Static and media files served by Django runserver.

### Production

```bash
# Collect static files
python manage.py collectstatic --noinput
```

Static files served by Nginx/CDN. Media files stored in S3.

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [CLOUD.md](./CLOUD.md) - Infrastructure and deployment
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues
