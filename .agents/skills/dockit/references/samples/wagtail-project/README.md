# MyWagtail Site

A content management system for Example Corp built with Wagtail CMS.

## Quick Links

| Resource | Link |
|----------|------|
| Documentation | [docs/](./docs/) |
| Project Principles | [docs/PRINCIPLES.md](./docs/PRINCIPLES.md) |
| Page Models | [docs/MODELS.md](./docs/MODELS.md) |
| Block Library | [docs/BLOCKS.md](./docs/BLOCKS.md) |
| AI Context | [GEMINI.md](./GEMINI.md) |

## Project Structure

```text
mywagtail/
├── home/              # Homepage app
├── blog/              # Blog functionality
├── core/              # Shared blocks and snippets
│   ├── blocks/        # Reusable StreamField blocks
│   └── snippets/      # Reusable content snippets
├── search/            # Search configuration
├── templates/         # Project templates
├── static/            # Static assets
└── mywagtail/         # Django settings
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| CMS | Wagtail 7.3 |
| Framework | Django 5.1 |
| Database | PostgreSQL 16 |
| Search | PostgreSQL FTS |
| Storage | AWS S3 |

## Getting Started

### Prerequisites

- Python 3.12+
- PostgreSQL 16+
- Node.js 20+ (for frontend tooling)

### Installation

```bash
# Clone and setup
git clone https://github.com/example/mywagtail.git
cd mywagtail

# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -e ".[dev]"

# Setup database
createdb mywagtail
python manage.py migrate
python manage.py createsuperuser
```

### Running Locally

```bash
python manage.py runserver
```

Admin: http://localhost:8000/admin/

## Testing

```bash
# All tests
pytest

# Specific app
pytest blog/tests/

# With coverage
pytest --cov=.
```

## Deployment

See [docs/CLOUD.md](./docs/CLOUD.md) for full deployment guide.

```bash
# Build static files
python manage.py collectstatic --noinput

# Run migrations
python manage.py migrate --noinput
```

## Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](./docs/ARCHITECTURE.md) | System design, apps, data flow |
| [MODELS.md](./docs/MODELS.md) | Page model reference |
| [BLOCKS.md](./docs/BLOCKS.md) | Block library reference |
| [ENVIRONMENTS.md](./docs/ENVIRONMENTS.md) | Environment configs |
| [CLOUD.md](./docs/CLOUD.md) | Infrastructure and deployment |
| [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) | Common issues and solutions |
| [CONTRIBUTING.md](./docs/CONTRIBUTING.md) | Development workflow |

## Contributing

See [docs/CONTRIBUTING.md](./docs/CONTRIBUTING.md) for development workflow.

## License

Proprietary - Example Corp
