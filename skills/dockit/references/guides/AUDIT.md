# Audit Mode

Cross-reference every claim in project documentation against the actual codebase. Reports what's broken, what's missing, and what's outdated — without changing any files.

**When to use:** After refactors, dependency upgrades, renames, or any time you suspect docs have drifted from reality. Unlike `check` (which detects staleness via git timestamps), `audit` reads the content and verifies each reference actually exists.

---

## Execution

### Step 1: Collect all doc files

Gather every markdown file that constitutes project documentation:
- `README.md` (root and any service-level READMEs)
- `docs/**/*.md`
- `CLAUDE.md`, `GEMINI.md`, `CONTRIBUTING.md`, `CHANGELOG.md`
- Any `.md` files referenced by the above via links

Skip files inside `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`, and `specs/tickets/`.

### Step 2: Extract references

Scan each doc file and extract every verifiable claim. The categories below cover what to look for — not every doc will have all of them.

#### File paths

Any path-like string in docs, whether in code blocks, inline code, or plain text:
- Backticked paths: `` `src/auth/middleware.ts` ``
- Code block references: `import { foo } from './utils'`
- Prose references: "see the config in `config/database.yml`"
- Directory references: "`src/components/` contains..."

**How to verify:** Check if the file or directory exists at the referenced path (relative to repo root). For glob-like references (`src/**/*.test.ts`), verify at least one match exists.

#### Internal doc links

Markdown links between documentation files:
- `[Architecture](docs/ARCHITECTURE.md)`
- `[see setup](../ENVIRONMENTS.md#local-setup)`
- Relative links in any format

**How to verify:** Resolve the link relative to the file it appears in. Check the target file exists. For anchor links (`#section-name`), verify a heading with that slug exists in the target file.

#### Function, class, and variable names

Code identifiers referenced in docs as things that exist in the codebase:
- `` `authenticate()` ``
- `` `UserService` class ``
- "the `MAX_RETRIES` constant"

**How to verify:** Grep the codebase for the identifier. Match against function definitions, class declarations, const/let/var assignments, and exports. A reference is broken if zero matches are found in source files.

Be pragmatic — common language terms in backticks (like `` `true` ``, `` `null` ``, `` `string` ``) are not codebase references. Only verify identifiers that clearly refer to project-specific code.

#### Commands and scripts

Shell commands documented as runnable:
- `npm run build`, `make test`, `python manage.py migrate`
- Commands in "Getting Started" or "Development" sections

**How to verify:**
- `npm run <script>` → check `scripts` in `package.json`
- `make <target>` → check `Makefile` for target definition
- `python manage.py <cmd>` → check for Django management command (built-in commands like `migrate`, `runserver` are always valid)
- `npx <pkg>`, `pip install`, `cargo build` → skip (external tools, always valid)
- Custom scripts (`./scripts/deploy.sh`) → check file exists and is executable

#### Environment variables

Variables referenced as required or configurable:
- `DATABASE_URL`, `$API_KEY`, `SECRET_KEY`
- Any `ALL_CAPS_WITH_UNDERSCORES` pattern in env-related doc sections

**How to verify:** Check at least one of:
- `.env.example`, `.env.sample`, `.env.template`
- `docker-compose.yml` environment blocks
- Source code (`os.environ`, `process.env`, `env()` calls)
- CI workflow `env:` blocks

A variable is "unverified" (not necessarily broken) if it appears in docs but nowhere in code or config.

#### Dependencies and packages

Named dependencies in docs ("requires Redis 7+", "uses PostgreSQL"):
- Package names with version constraints
- External service dependencies

**How to verify:** Check `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `docker-compose.yml` for the dependency. Version claims should match the constraint in the manifest.

---

### Step 3: Verify each reference

For each extracted reference, attempt verification using the rules above. Classify the result:

| Status | Meaning |
|--------|---------|
| `verified` | Reference exists in the codebase exactly as documented |
| `broken` | Reference does not exist — file missing, function removed, link dead |
| `moved` | A likely match exists at a different path or name (fuzzy match) |
| `unverified` | Cannot be automatically verified (external URLs, ambiguous references) |

**Fuzzy matching for `moved`:** When a file path or function name doesn't match exactly, search for the basename or a similar identifier. If `docs/setup.md` references `src/utils/auth.ts` but the file is now at `src/lib/auth.ts`, report it as `moved` with the likely new location.

### Step 4: Generate report

Present findings grouped by doc file, ordered by severity (broken first, then moved, then unverified). Skip verified references — they're noise in the report.

#### Report format

```markdown
## Audit Report

**Scanned:** N doc files | **References found:** N
**Broken:** N | **Moved:** N | **Unverified:** N | **Verified:** N

---

### README.md

| Line | Reference | Status | Details |
|------|-----------|--------|---------|
| 12 | `src/old-auth/handler.ts` | broken | File not found |
| 34 | `npm run deploy` | broken | No `deploy` script in package.json |
| 45 | `src/auth/handler.ts` | moved | Now at `src/lib/auth/handler.ts` |
| 67 | `STRIPE_KEY` | unverified | Not found in .env.example or code |

### docs/ARCHITECTURE.md

| Line | Reference | Status | Details |
|------|-----------|--------|---------|
| 8 | `[Environments](ENVIRONMENTS.md)` | verified | — |
| 23 | `DatabasePool` class | broken | No class definition found |

---

### Summary

**Broken references to fix:**
1. README.md:12 — `src/old-auth/handler.ts` was likely removed or renamed
2. README.md:34 — `deploy` script missing from package.json
3. docs/ARCHITECTURE.md:23 — `DatabasePool` class not found in codebase

**Likely moves (verify and update path):**
1. README.md:45 — `src/auth/handler.ts` → `src/lib/auth/handler.ts`

**Unverified (check manually):**
1. README.md:67 — `STRIPE_KEY` not found in config files
```

Adapt the report to the project's actual findings — if there are no moved references, skip that section. If everything is verified, say so and stop.

---

## Scope Control

Audit focuses on **verifiable claims** — things that can be checked by reading the filesystem. It does not:
- Judge whether explanations are accurate or well-written (that's human review)
- Check external URLs (that requires network access and is a different problem)
- Verify that documented behavior matches runtime behavior (that's testing)
- Suggest new documentation (that's `init` or `sync`)

If the user asks to also check external links, note that this is outside audit's scope but offer to do it as a separate pass.
