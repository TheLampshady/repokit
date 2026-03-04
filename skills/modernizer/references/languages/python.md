# Python Recommendations

> Reference for aicodeprep analysis. See main SKILL.md for usage.

## Package Management

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **uv** | Modern | MIT | 10-100x faster than pip, lockfile, Astral team |
| pip + venv | Established | PSF | Standard library, universal compatibility |
| Poetry | Established | MIT | Good for libraries, slower than uv |
| PDM | Modern | MIT | PEP 582 support, fast |

**Recommendation:**
- Modern preference → **uv**
- Established preference → **pip + venv** (no extra deps)
- Library publishing → **Poetry** or **uv**

## Linting & Formatting

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **ruff** | Modern | MIT | All-in-one, 10-100x faster, replaces flake8+black+isort |
| flake8 | Established | MIT | Mature, plugin ecosystem |
| black | Established | MIT | Opinionated formatter |
| isort | Established | MIT | Import sorting |
| pylint | Established | GPL-2.0 | Comprehensive but slow |

**Recommendation:**
- Modern preference → **ruff** (single tool)
- Established preference → **flake8 + black + isort**
- Note: pylint is GPL - check licensing requirements

## Type Checking

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **ty** | Modern | MIT | Astral team, fast, same ecosystem as uv/ruff |
| mypy | Established | MIT | Industry standard, most mature |
| pyright | Modern | MIT | Microsoft, fast, used in Pylance |
| pyre | Modern | MIT | Facebook, good for large codebases |

**Recommendation:**
- Modern preference → **ty** (ecosystem consistency with uv/ruff)
- Established preference → **mypy** (most documentation, widest adoption)
- VS Code users → **pyright** (powers Pylance)

## Testing

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **pytest** | Standard | MIT | De facto standard, 1300+ plugins |
| unittest | Established | PSF | Standard library, no deps |
| nose2 | Legacy | BSD | Successor to nose, less active |

**Plugins:**
| Plugin | Purpose | License |
|--------|---------|---------|
| pytest-socket | Network isolation | MIT |
| pytest-asyncio | Async test support | MIT |
| pytest-cov | Coverage reporting | MIT |
| pytest-xdist | Parallel execution | MIT |

**Recommendation:**
- Always → **pytest** (unless zero-deps required)
- Zero-deps → **unittest**

## CLI Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **Typer** | Modern | MIT | Type hints, auto-completion, FastAPI-style |
| Click | Established | BSD-3 | Mature, Typer's foundation |
| argparse | Established | PSF | Standard library |
| fire | Modern | Apache-2.0 | Google, auto-generates CLI from functions |

**Recommendation:**
- Modern preference → **Typer**
- Established preference → **Click**
- Zero-deps → **argparse**

## Web Frameworks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **FastAPI** | Modern | MIT | Async, type hints, auto-docs |
| Flask | Established | BSD-3 | Simple, flexible, huge ecosystem |
| Django | Established | BSD-3 | Batteries included, ORM |
| Starlette | Modern | BSD-3 | FastAPI's foundation, ASGI |
| Litestar | Modern | MIT | FastAPI alternative, more features |

**Recommendation:**
- Modern API → **FastAPI**
- Traditional web app → **Django**
- Microservices → **Flask** or **FastAPI**

## Pre-commit & Hooks

| Option | Type | License | Notes |
|--------|------|---------|-------|
| **pre-commit** | Standard | MIT | Language-agnostic, widely adopted |
| husky (via npm) | Alternative | MIT | If already using Node |

**Recommendation:** **pre-commit** (Python-native, works everywhere)

## Project Structure

```
project/
├── pyproject.toml      # Modern: all config here
├── .venv/ or venv/     # Virtual environment
├── src/project/        # Source (src layout) OR
├── project/            # Source (flat layout)
├── tests/
│   ├── conftest.py
│   └── test_*.py
└── .pre-commit-config.yaml
```

## pyproject.toml Patterns

**Web App (no build-system needed):**
```toml
[project]
name = "myapp"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [...]

[dependency-groups]  # PEP 735 - modern
dev = ["ruff", "ty", "pre-commit"]
test = ["pytest", "pytest-socket", "pytest-cov"]
```

**Library (needs build-system):**
```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "mylib"
...
```
