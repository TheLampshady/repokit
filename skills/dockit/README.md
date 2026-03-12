# dockit

Generate and maintain project documentation optimized for humans and AI agents.

## Usage

```
/dockit
```

That's it. Auto-detects the right action:
- No docs? → generates them
- Git changes? → syncs stale sections
- CI environment? → runs check mode
- Docs current? → tells you

### Explicit modes (optional)

```
/dockit init      # Force full generation
/dockit migrate   # Restructure legacy docs
/dockit sync      # Force sync
/dockit check     # Force CI mode
```

## Architecture

```
dockit/
├── SKILL.md                    # Core logic (~100 lines)
├── frameworks/
│   ├── _index.md               # Detection rules
│   ├── _default.md             # Fallback behavior
│   └── wagtail.md              # Wagtail module
├── references/
│   ├── templates/
│   │   ├── core/               # Always used
│   │   └── wagtail/            # Wagtail-specific
│   └── samples/
│       ├── small-project/
│       ├── monorepo/
│       └── wagtail-project/
```

## How It Works

1. **Detect framework** - Check dependencies against `frameworks/_index.md`
2. **Load module** - Load matching module or `_default.md`
3. **Run analysis** - Execute module-specific analysis
4. **Generate docs** - Core templates + framework templates

## Supported Frameworks

| Framework | Status | Extra Docs |
|-----------|--------|------------|
| Wagtail | ✅ | MODELS.md, BLOCKS.md, per-app GEMINI.md |
| Django | 🔜 | - |
| FastAPI | 🔜 | ENDPOINTS.md |
| React | 🔜 | COMPONENTS.md |
| Default | ✅ | Core docs only |

## Adding a Framework

1. Add detection rule to `frameworks/_index.md`
2. Create `frameworks/[name].md` (copy `_default.md` as template)
3. Create `references/templates/[name]/` with framework-specific templates
4. Add sample to `references/samples/[name]-project/`

## Generated Documents

**Always generated** (from `templates/core/`):

| File | Purpose |
|------|---------|
| `README.md` | Human overview, setup, quick start |
| `docs/PRINCIPLES.md` | Tech decisions, conventions |
| `docs/ARCHITECTURE.md` | Services, packages, data flow |
| `docs/ENVIRONMENTS.md` | Local, staging, production configs |
| `docs/CLOUD.md` | Infrastructure, deployment |
| `docs/TROUBLESHOOTING.md` | Common issues and solutions |
| `docs/CONTRIBUTING.md` | Development workflow by role |

**Framework-specific** (from `templates/[framework]/`):
- Defined in each framework module

## Integration

### With CLAUDE.md / GEMINI.md

- **CLAUDE.md**: dockit does NOT generate - cross-links only
- **GEMINI.md**: dockit generates with `@imports` for hierarchical loading

### With CI/CD

```yaml
# GitHub Actions
- name: Check documentation
  run: claude "/dockit check"
```

### With Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: dockit-check
      name: Check documentation freshness
      entry: claude "/dockit check"
      language: system
      pass_filenames: false
```

## Philosophy

1. **Modular** - Add frameworks without bloating core
2. **Analyze first** - Auto-detect before asking questions
3. **Git-aware** - Smart sync using git history
4. **Default fallback** - Works on any project

## Requirements

- **Git repository** - For smart sync/check (falls back to full scan otherwise)

## Support

**Author**: Zach Goldstein - Solutions Architect

**Issues**: [Report a bug](https://github.com/TheLampshady/repokit/issues/new?template=ai-skills.yml)
