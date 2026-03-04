# [PROJECT_NAME]

> [PROJECT_DESCRIPTION]

[PROJECT_CONTEXT]
<!-- 1-3 sentences explaining what this project does, who it's for, and what makes it useful. Example: "This project provides a cloud-native backend service designed for rapid development with local Firebase emulators and seamless GCP deployment." -->

[IF_HAS_BADGES]
[BADGES]
[ENDIF]

---

## Quick Start

[QUICK_START_CONTEXT]
<!-- 1-2 sentences explaining what the user will accomplish and any benefits (e.g., "Get the project running locally in three steps. The setup uses emulators so you can develop without cloud costs.") -->

### 1. Install

[INSTALL_CONTEXT]
<!-- Explain what this step does: what gets installed, configured, or set up. Example: "Installs Python dependencies via uv, configures git hooks for code quality, and sets up the commit message template." -->

```bash
[INSTALL_COMMANDS]
```

### 2. Configure

[CONFIGURE_CONTEXT]
<!-- Explain what configuration is needed and why. Example: "Create your local environment file and pull secrets from GCP. The .env file controls local behavior like emulator usage and project targeting." -->

```bash
cp .env.sample .env
# Edit .env with your settings
```

> **Need help?** See [Environment Setup](./docs/ENVIRONMENTS.md) for detailed configuration.

### 3. Run

[RUN_CONTEXT]
<!-- Explain what services start and any dependencies. Example: "Start two terminal sessions - one for emulators and one for the server. The emulators must be running before the API server starts." -->

```bash
[RUN_COMMAND]
```

[IF_HAS_LOCAL_URLS]
**Local URLs**:
[LOCAL_URLS_LIST]
<!-- Include brief description of each URL. Example: "- **API**: http://localhost:8000 — FastAPI backend with auto-generated docs at /docs" -->
[ENDIF]

[IF_HAS_ADMIN_URL]
**Admin**: [ADMIN_URL]
[ENDIF]

---

## Common Commands

[COMMANDS_CONTEXT]
<!-- Brief explanation of command organization. Example: "Daily development commands. All commands use make targets defined in the root Makefile." -->

| Command | Description |
|---------|-------------|
[COMMANDS_TABLE]
<!-- Each row should have a clear, informative description. Not just "Run tests" but "Run pytest with network blocked by default" -->

[IF_DJANGO]
### Django Management

[DJANGO_COMMANDS_CONTEXT]
<!-- Example: "Database and admin commands for Django/Wagtail projects." -->

```bash
# Database
[MIGRATE_COMMAND]

# Create admin user
[CREATESUPERUSER_COMMAND]

# Collect static files
[COLLECTSTATIC_COMMAND]
```
[ENDIF]

[IF_WAGTAIL]
### Wagtail Management

[WAGTAIL_COMMANDS_CONTEXT]

```bash
# Database migrations
[MIGRATE_COMMAND]

# Create admin user
[CREATESUPERUSER_COMMAND]

# Update search index
[UPDATE_INDEX_COMMAND]

# Collect static files
[COLLECTSTATIC_COMMAND]
```
[ENDIF]

---

## Tech Stack

[TECH_STACK_CONTEXT]
<!-- Brief explanation of the technology choices. Example: "The project uses a modern Python backend with Google Cloud services for auth, data persistence, and AI capabilities." -->

| Layer | Technology | Purpose |
|-------|------------|---------|
[TECH_STACK_TABLE]
<!-- Include Purpose column explaining WHY each technology is used, not just what it is -->

---

## Project Structure

[STRUCTURE_CONTEXT]
<!-- Brief explanation. Example: "Each folder serves a specific purpose in the development and deployment workflow." -->

| Folder | Purpose |
|--------|---------|
[STRUCTURE_TABLE]
<!-- Include meaningful descriptions. Not just "Backend code" but "Main application — FastAPI backend, API routes, GCP client integrations, and tests" -->

---

## Documentation

[DOCS_CONTEXT]
<!-- Guide the reader. Example: "Detailed guides for different aspects of the project. Start with Architecture for system understanding, Environments for setup, and Troubleshooting when things go wrong." -->

| Document | What You'll Learn |
|----------|-------------------|
| **[Architecture](./docs/ARCHITECTURE.md)** | [ARCH_DESCRIPTION] |
| **[Environments](./docs/ENVIRONMENTS.md)** | [ENV_DESCRIPTION] |
| **[Cloud](./docs/CLOUD.md)** | [CLOUD_DESCRIPTION] |
| **[Troubleshooting](./docs/TROUBLESHOOTING.md)** | [TROUBLESHOOT_DESCRIPTION] |
[IF_HAS_CONTRIBUTING]
| **[Contributing](./docs/CONTRIBUTING.md)** | [CONTRIBUTING_DESCRIPTION] |
[ENDIF]

---

## Testing

[TESTING_CONTEXT]
<!-- Explain testing approach and any special configuration. Example: "Tests use pytest with pytest-asyncio for async support. Network access is blocked by default via pytest-socket to ensure tests don't make external calls." -->

```bash
[TEST_COMMAND]
```

[IF_HAS_TEST_OPTIONS]
**Filter tests by marker:**

| Command | Description |
|---------|-------------|
[TEST_OPTIONS_TABLE]
[ENDIF]

[IF_HAS_TEST_NETWORK_INFO]
**Enable network for specific tests** (in test code):

```python
@pytest.mark.enable_socket
def test_external_api():
    ...
```
[ENDIF]

---

## Deployment

[DEPLOYMENT_CONTEXT]
<!-- Explain the deployment target and process. Example: "Deploy to Google App Engine. The build step copies frontend assets, then deploys the service." -->

```bash
[DEPLOY_COMMAND]
```

[IF_HAS_DEPLOY_STEPS]
**What happens:**
[DEPLOY_STEPS_LIST]
<!-- Numbered list explaining each step. Example: "1. `make build` — Copies sample_dist/ to service/static/" -->
[ENDIF]

> See [Cloud Guide](./docs/CLOUD.md) for full instructions.

[IF_HAS_LICENSE]
---

## License

[LICENSE_TYPE]
[ENDIF]
