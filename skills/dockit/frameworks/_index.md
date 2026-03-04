# Framework Detection

Detect framework in this order. First match wins.

## Detection Rules

| Framework | Detection | Module | Extra Docs |
|-----------|-----------|--------|------------|
| Wagtail | `wagtail` in dependencies | `wagtail.md` | MODELS.md, BLOCKS.md |
| Django | `django` in deps (no wagtail) | `django.md` | *(future)* |
| FastAPI | `fastapi` in dependencies | `fastapi.md` | *(future)* |
| React | `react` in package.json | `react.md` | *(future)* |
| **Default** | No match | `_default.md` | None |

## Detection Logic

```python
# Priority order - first match wins
if "wagtail" in dependencies:
    load("frameworks/wagtail.md")
elif "django" in dependencies:
    load("frameworks/django.md")  # future
elif "fastapi" in dependencies:
    load("frameworks/fastapi.md")  # future
elif "react" in package_json:
    load("frameworks/react.md")  # future
else:
    load("frameworks/_default.md")
```

## Dependency Sources

Check these files for dependencies:
- `pyproject.toml` - `[project.dependencies]` or `[tool.poetry.dependencies]`
- `requirements.txt` - Direct list
- `package.json` - `dependencies` and `devDependencies`
- `go.mod` - `require` block
- `Cargo.toml` - `[dependencies]`

## Module Interface

Each framework module must define:

1. **Analysis** - Framework-specific detection steps
2. **Extra Docs** - Additional docs to generate
3. **Git Patterns** - Files to watch for sync
4. **Questions** - Framework-specific questions (max 2-3)
5. **Templates** - Path to framework templates

See `_default.md` for the base module structure.
