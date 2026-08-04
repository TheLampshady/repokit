# dockit

Generate and maintain project documentation optimized for humans and AI agents.

## Usage

```
/dockit
```

That's it. Auto-detects the right action:
- No docs? → generates them
- Git changes? → syncs stale sections
- Docs current? → tells you

### Explicit modes (optional)

```
/dockit init         # Force full generation
/dockit migrate      # Restructure legacy docs
/dockit sync         # Force sync
/dockit sync --deep  # Whole-repo pass: broken refs, undocumented code
```

Every mode is human-run by design — there's no gate mode and nothing to wire into CI. For a read-only "has anything drifted?", use `/repokit status`.

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

| File | Purpose                                       | Sizes |
|------|-----------------------------------------------|-------|
| `README.md` | Human overview, setup, quick start            | All |
| `docs/PRINCIPLES.md` | Tech decisions, patterns, conventions          | Medium+ |
| `docs/ARCHITECTURE.md` | Services, packages, data flow                 | All |
| `docs/FOUNDATIONS.md` | Catalog of shared/foundational code — detected by fan-in × cross-feature × stability scoring (see [FOUNDATIONS-DETECTION.md](./references/guides/FOUNDATIONS-DETECTION.md)) | Medium+ |
| `docs/ENVIRONMENTS.md` | Local, staging, production configs            | All |
| `docs/CLOUD.md` | Infrastructure, deployment                    | Medium+ |
| `docs/TROUBLESHOOTING.md` | Common issues and solutions                   | Medium+ |
| `docs/CONTRIBUTING.md` | Development workflow by role                  | Large |

**Framework-specific** (from `templates/[framework]/`):
- Defined in each framework module

## Integration

### With CLAUDE.md / GEMINI.md

- **CLAUDE.md**: dockit does NOT generate - cross-links only
- **GEMINI.md**: dockit generates with `@imports` for hierarchical loading

### With CI/CD and pre-commit hooks

**Don't.** dockit has no gate mode and nothing here belongs in an automated pipeline.

`sync` deletes doc sections whose code is gone, and its only safeguard is the change report it prints for a human to review — automated, that report lands in a log nobody opens and content disappears unnoticed. And a pass/fail mode isn't offered as the automatable alternative, because an exit code produced by a language model isn't a gate you can rely on; CI would treat a silent fail-open as a pass.

Run `/repokit:dockit sync` yourself after a change, and `/repokit status` when you want a read-only look at whether anything has drifted.

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
