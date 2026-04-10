---
name: modernizer
description: 'Analyze and modernize codebases. Audits for AI-readiness, outdated tooling, and missing quality infrastructure. Generates actionable tickets in specs/tickets/ and a progress checklist in specs/CHECKLIST.md. Use when asked to: modernize the codebase, audit code quality, check if tools are up to date, improve the dev setup, find what testing/linting/packaging improvements are needed. Modes: analyze, status.'
user-invocable: true
---

# modernizer

Analyze codebases for AI-readiness and generate actionable plans for agents and skills to execute.
This skill is the **planning brain** - it knows best practices across languages, discovers available
executors, and creates structured task plans that other agents can consume.

## Philosophy

- **modernizer plans, others execute** - This skill focuses on analysis and recommendations
- **Language agnostic** - Supports Python, JavaScript/TypeScript, Java, Go, Rust, and more
- **Plans are machine-readable** - Output structured tasks that agents can parse
- **Technology expert** - Knows latest best practices per language (2025)
- **Discovery-driven** - Finds available agents/skills and recommends which to use

## Modes

| Mode | Command | Description |
|------|---------|-------------|
| `analyze` | `/modernizer` or `/modernizer analyze` | Audit codebase, generate plans in `specs/` |
| `status` | `/modernizer status` | Show task status, clean up completed tasks |

### Status Mode

When `/modernizer status` is invoked:

1. **Read all task files** in `specs/tickets/`
2. **Check status** of each task (from metadata yaml block)
3. **Cross-reference with code state** — For each pending task, check if the acceptance criteria are now met in the actual codebase:
   - "No tests exist" → check if test files now exist
   - "No linter config" → check if linter config files now exist
   - "Missing CI pipeline" → check if `.github/workflows/` now exists
   - If speckit is available (`.specify/` exists), check for completed speckit tickets that match modernizer tasks
   - Mark verified-complete tasks as `status: completed`
4. **Delete completed tasks** - Remove any task file where `status: completed`
5. **Update CHECKLIST.md** - Refresh the task table to reflect remaining tasks
6. **Report summary**:
   - Tasks completed (and removed): X (auto-detected: Y)
   - Tasks remaining: Z
   - Next priority task

```
Example output:

## Task Status

**Cleaned up:** 3 completed tasks removed
- ~~testing-setup.md~~ (completed)
- ~~linting-setup.md~~ (completed)
- ~~pre-commit.md~~ (completed)

**Remaining:** 2 tasks
| Task | Priority | Status |
|------|----------|--------|
| type-checking | P2 | pending |
| documentation | P3 | pending |

**Next up:** 004 - Add type checking (P2)
```

## Output Location

All outputs go to `specs/`:

```
specs/
├── backlog.md                 # Master checklist, one line per item, tagged [modernizer]
└── tickets/                   # Individual task files for agents
    ├── testing-setup.md
    ├── package-modernization.md
    └── ...
```

**Note:** Detailed recommendations are given directly in conversation. Language-specific references are in `references/languages/*.md`.

---

## Execution Flow

### Phase 1: Discovery

#### 1. Detect Primary Language(s)

**CRITICAL: Detect language FIRST to apply correct best practices.**

| Indicator Files | Language | Ecosystem |
|-----------------|----------|-----------|
| `pyproject.toml`, `requirements.txt`, `setup.py`, `*.py` | Python | pip/uv, pytest |
| `package.json`, `*.js`, `*.ts`, `*.tsx` | JavaScript/TypeScript | npm/pnpm, jest/vitest |
| `pom.xml`, `build.gradle`, `build.gradle.kts`, `*.java` | Java/Kotlin | Maven/Gradle, JUnit |
| `go.mod`, `go.sum`, `*.go` | Go | go mod, go test |
| `Cargo.toml`, `*.rs` | Rust | cargo |
| `mix.exs`, `*.ex`, `*.exs` | Elixir | mix |
| `Gemfile`, `*.rb` | Ruby | bundler, rspec |
| `composer.json`, `*.php` | PHP | composer, phpunit |
| `*.cs`, `*.csproj`, `*.sln` | C#/.NET | dotnet, xunit/nunit |

For monorepos, detect ALL languages present and note the primary one.

**Determine the ROLE of each language:**
- Check directory names: `api/`, `backend/`, `server/` → backend language
- Check directory names: `frontend/`, `front-end/`, `web/`, `ui/`, `client/` → frontend language
- Check framework indicators: FastAPI, Django, Flask, Express, Gin → backend
- Check framework indicators: React, Vue, Angular, Svelte → frontend
- If Python/Go/Java/Rust exists alongside JS/TS, the JS/TS is almost always frontend

#### 2. Check for AI Instruction Files

| Platform | Files to Check |
|----------|----------------|
| Claude | `CLAUDE.md`, `.claude/`, `AGENTS.md` |
| Gemini | `GEMINI.md`, `.gemini/` |
| Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules/`, `.cursorrules` |
| Generic | `AI_INSTRUCTIONS.md`, `AGENTS.md` |

#### 3. Discover Available Agents and Skills

```bash
# Find available agents (distributed with plugin, or local)
ls agents/*.md .claude/agents/*.md 2>/dev/null

# Find available skills (plugin skills at root, or local)
ls skills/*/SKILL.md .claude/skills/*/SKILL.md 2>/dev/null

# Check for speckit
ls .specify/ 2>/dev/null
```

Build a registry of what's available and match to detected language.

#### 4. Check for Existing Documentation

```bash
find . -maxdepth 2 -name "README.md" -o -name "readme.md" 2>/dev/null
find . -maxdepth 2 -type d -name "docs" 2>/dev/null
```

**If no README or docs/ found:**
> ⚠️ No documentation found. Consider running `/dockit` first — understanding the project's architecture and setup will improve the quality of modernizer's recommendations.
> Proceed anyway, but note that tooling recommendations may lack project context.

**If docs exist:** Read `README.md` and any files in `docs/` before proceeding. Use them to understand the project's architecture, stack, and existing setup decisions — this context improves recommendation quality.

#### 5. Detect Project Structure

- Monorepo vs single service vs library
- Framework(s) detected
- Existing test setup
- CI/CD configuration
- Build system

---

### Phase 1.5: User Preferences

**Before analysis, ask the user about their preferences to tailor recommendations:**

#### Questions to Ask

1. **Tooling Style Preference**
   - "Do you prefer **modern/cutting-edge** tools (faster, newer, may have fewer resources) or **established** tools (battle-tested, more documentation)?"
   - Options: `Modern` | `Established` | `No preference`

2. **Licensing Preference**
   - "Do you have licensing requirements for tools?"
   - Options: `Permissive only (MIT, Apache, BSD)` | `Any open source (including GPL)` | `No preference`

3. **JavaScript/TypeScript Context** (only if JS/TS detected AND no other backend language exists)
   - "Is this primarily a **frontend** project, **backend/Node** project, or **both**?"
   - Options: `Frontend` | `Backend (Node/Bun)` | `Full-stack (both)`

   **IMPORTANT: Skip this question if another backend language is detected.**
   - If Python, Go, Java, Rust, etc. is detected alongside JS/TS → assume JS/TS is **Frontend only**
   - Only ask this question when JS/TS is the ONLY language detected
   - Example: Python backend + React frontend = DO NOT ask, auto-classify JS/TS as Frontend

#### Using Preferences

- Reference the appropriate language file based on detected language
- Filter recommendations by user's modern/established preference
- Flag tools with non-permissive licenses if user selected "Permissive only"
- For JS/TS, use `javascript-frontend.md` or `javascript-node.md` based on context
- **For monorepos with non-JS backend**: Always use `javascript-frontend.md` for the JS/TS portion

---

### Phase 2: Analysis

Audit the codebase across these dimensions, **applying language-specific criteria**:

#### 1. Package Management (Score /10)

Check for: lockfile present, modern package manager in use, no legacy config files (setup.py, requirements.txt without pyproject.toml, yarn v1, GOPATH).

See language reference files for specific legacy→modern mappings.

#### 2. Testing Structure (Score /10)

Check for: test files exist, framework appropriate for language, coverage configured, mocking library present for the stack.

See language reference files for framework-specific checklists.

#### 3. Code Quality & Hooks (Score /10)

Check for: linter configured, formatter configured, type checker configured, pre-commit hooks set up.

See language reference files for recommended tools per language.

#### 4. Code Patterns (Score /10)
- [ ] Type annotations/hints used (where applicable)
- [ ] Consistent style
- [ ] Clear function signatures
- [ ] Manageable file sizes
- [ ] Idiomatic patterns for language

#### 5. Documentation Health (lightweight inline check)

Do a quick doc health check — this does not require the auditor agent.

| Check | How |
|-------|-----|
| Docs exist? | Look for `README.md`, `docs/` directory |
| Docs stale? | Compare last doc commit vs last code commit (`git log -1 --format=%ct -- docs/ README.md` vs `git log -1 --format=%ct -- src/ lib/ app/`) |
| Obvious gaps? | No ARCHITECTURE doc for a multi-service project, no ENVIRONMENTS doc when `.env*` files exist, no CONTRIBUTING doc when multiple contributors |

If no docs were found in Phase 1, skip this step — note "no docs" as a finding and recommend `/repokit:dockit`.

Write any doc-related tickets tagged `[modernizer]` in `specs/tickets/`, same as all other modernizer tickets.

> For a deeper documentation audit (staleness details, automation gaps, troubleshooting coverage), suggest the user ask for a doc health review — the **auditor agent** auto-triggers for that and provides a comprehensive findings report.

---

### Phase 3: Plan Generation

Generate structured output in `specs/`:

#### CHECKLIST.md (`specs/CHECKLIST.md`)

Overall scores, task overview, and quick checklist (see template). This is the persistent artifact for tracking progress.

#### Backlog (`specs/backlog.md`)

Before creating any ticket, check `specs/backlog.md` for duplicates. For each new ticket, append a line. **Position in the backlog IS the priority order** — add tickets in priority order (P1 first, then P2, etc.):

```
- [ ] Testing setup [modernizer] → tickets/testing-setup.md
- [ ] Package modernization [modernizer] → tickets/package-modernization.md
```

#### Task Files (`specs/tickets/`)

Each task uses the canonical ticket template at `./references/templates/ticket-template.md` (bundled with this skill). Modernizer extends the base template with agent-execution sub-sections under Goals.

**Overview** — Describe the modernization task in plain language. What's out of date, what improves when it's done.

**Goals** — Include the standard goal bullets plus these modernizer-specific sub-sections:

* **Current State** — What currently exists (files, configs, behavior). Include evidence snippets.
* **Desired State** — What should exist when complete. Include target config/structure.
* **Execution**
  - **Priority**: P1 | P2 | P3
  - **Category**: testing | packaging | linting | documentation | structure
  - **Language**: Python | JavaScript | TypeScript | Java | Go | Rust | Multi
  - **Executor**: [AGENT_NAME] | [SKILL_NAME] | manual
  - **Depends On**: [TASK_IDS] or none
  - **Status**: pending | in_progress | completed
* **Implementation Notes** — Language-specific guidance, key decisions, constraints, patterns to match.
  - **Files to Modify**: table with File | Action | Notes
  - **Recommended Approach**: numbered steps
* **Verification** — Commands to verify completion + expected output.
* **Rollback** — Commands or git instructions to revert if issues arise.

**Acceptance Criteria** — Use the standard Given/When/Then format. Always include:
- Specific verifiable criteria for the modernization change
- All existing tests pass
- No regressions introduced

**Tech Details** — Use for speckit compatibility info:
- Feature: [FEATURE_NAME]
- Type: chore | enhancement | bugfix
- Labels: [ai-readiness, tooling, testing, etc.]

---

### Phase 4: Discussion

After generating plans:

1. Present the checklist summary
2. Note detected language(s)
3. Ask clarifying questions:
   - "Which tasks should be prioritized?"
   - "Any recommendations you want to skip?"
   - "Should I create speckit tickets for these?"
4. Offer to run available executors (matched to language)

---

## Language Reference Files

Detailed recommendations are in language-specific reference files. Each file contains:
- **Established vs Modern options** for each tool category
- **Licensing information** for each tool
- **CLI framework recommendations**
- **Project structure examples**
- **Configuration examples**

### Reference Files

| Language | Reference File | Notes |
|----------|----------------|-------|
| Python | `references/languages/python.md` | uv, ruff, ty, pytest, Typer |
| JavaScript/TypeScript (Frontend) | `references/languages/javascript-frontend.md` | Vite, React, Vitest, Playwright |
| JavaScript/TypeScript (Backend) | `references/languages/javascript-node.md` | Bun, Node, pnpm, oclif |
| Go | `references/languages/go.md` | go mod, golangci-lint, Cobra |
| Rust | `references/languages/rust.md` | cargo, clippy, clap |
| Java/Kotlin | `references/languages/java-kotlin.md` | Gradle, Spotless, picocli |

### How to Use References

1. Detect primary language(s) in Phase 1
2. Get user preferences in Phase 1.5
3. Load appropriate reference file(s)
4. Filter by user's preference (modern/established, licensing)
5. Apply recommendations in analysis

### Quick Reference (Production Defaults)

| Language | Package | Lint | Format | Test | CLI |
|----------|---------|------|--------|------|-----|
| Python | uv | ruff | ruff | pytest | Typer |
| JS/TS Frontend | pnpm | ESLint/Biome | Prettier/Biome | Vitest | - |
| JS/TS Backend | pnpm + Node | ESLint/Biome | Prettier/Biome | Vitest | oclif |
| Go | go mod | golangci-lint | gofmt | go test | Cobra |
| Rust | cargo | clippy | rustfmt | built-in | clap |
| Java/Kotlin | Gradle 8+ | Spotless | Spotless | JUnit 5 | picocli |

> **Bun note:** Recommended for CLI tools/scripts (fast startup). For production backends, Node.js is safer due to npm compatibility and stability. See `javascript-node.md` for detailed guidance.

---

## Integration with speckit

If speckit is available (`.specify/` exists), offer to:

1. Convert tasks to speckit tickets
2. Use speckit's task workflow
3. Link to speckit constitution/principles

Task files are already structured to be speckit-compatible.

---

## Example Sessions

### Example 1: Monorepo with non-JS backend (Python + React)

```
User: /modernizer

AI: Analyzing codebase for AI-readiness...

## Discovery

**Detected Languages:**
- Backend: Python (api_capture/, FastAPI detected)
- Frontend: TypeScript (front-end/, React + Vite detected)

**Project Type:** Monorepo (Python backend + React frontend)

**AI Files:** CLAUDE.md found

**Note:** Since Python backend detected, JS/TS is classified as **Frontend only**.
Skipping "frontend vs backend" question - using `javascript-frontend.md` reference.

[Continues with analysis of both Python and TypeScript portions separately...]
```

### Example 2: JS/TS only project

```
User: /modernizer

AI: Analyzing codebase for AI-readiness...

## Discovery

**Detected Languages:**
- Primary: TypeScript (package.json, src/*.ts)

**Project Type:** Single language

**AI Files:** None found

**Question:** Is this primarily a **frontend** project, **backend/Node** project, or **both**?

[Waits for user response before proceeding...]
```

### Example 3: Go backend + TypeScript frontend

```
User: /modernizer

AI: Analyzing codebase for AI-readiness...

## Discovery

**Detected Languages:**
- Backend: Go (go.mod found, cmd/server/)
- Frontend: TypeScript (frontend/, React detected)

**Project Type:** Monorepo (Go backend + React frontend)

**Note:** Go backend detected, auto-classifying TypeScript as Frontend.

## Analysis Results

### Overall Score: 5/10

| Category | Score | Key Issue |
|----------|-------|-----------|
| Documentation | 7/10 | Missing architecture docs |
| Package Management | 8/10 | Go mod configured correctly |
| Testing | 3/10 | No tests exist |
| Code Quality | 4/10 | No golangci-lint |
| Code Patterns | 7/10 | Good Go idioms |

## Generated Plans

Created in `specs/`:
- CHECKLIST.md (scorecard + task overview)
- tickets/testing-setup.md (P1, Go, manual - no agent available)
- tickets/golangci-lint.md (P1, Go, manual)
- tickets/frontend-testing.md (P2, TypeScript, manual)

## Questions

1. No Go test scaffolder agent available - want me to create tasks for manual implementation?
2. Should I prioritize backend (Go) or frontend (TypeScript) testing?
3. Want me to create speckit tickets for these tasks?
```

---

## What This Skill Does NOT Do

- **Does not execute changes** - Only plans
- **Does not write code** - Delegates to agents
- **Does not assume tools exist** - Discovers what's available
- **Does not hardcode executors** - Matches tasks to available agents/skills
- **Does not assume language** - Detects and adapts

## Audience

- Tech leads evaluating AI-readiness
- Developers preparing repos for AI workflows
- Teams modernizing legacy codebases
- Multi-language projects and monorepos
