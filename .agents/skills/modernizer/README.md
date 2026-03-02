# modernizer

Analyze codebases for AI-readiness and generate actionable plans. This skill is the **planning brain** - it knows best practices across languages, discovers available executors, and creates structured task files that agents and skills can consume.

## Philosophy

- **modernizer plans, others execute** - Focuses on analysis and recommendations
- **Language agnostic** - Supports Python, JS/TS, Java, Go, Rust, and more
- **Plans are machine-readable** - Output structured tasks for agents
- **Technology expert** - Knows latest best practices per language (2025)
- **Discovery-driven** - Finds available agents/skills and recommends which to use

## Installation

Copy the entire `modernizer/` folder to your project's `.claude/skills/` directory:

```bash
cp -r modernizer/ /path/to/your/project/.claude/skills/
```

## Usage

```
/modernizer          # Analyze codebase, generate plans
/modernizer status   # Check status, clean up completed tasks
```

### Analyze Mode (default)
Analyzes the codebase and generates:
- **Conversation**: Detailed recommendations tailored to your preferences
- **CHECKLIST.md**: Scorecard for tracking progress
- **tasks/*.md**: Individual task files for agents/speckit

### Status Mode
Shows task progress and cleans up:
- Reports completed vs remaining tasks
- **Deletes completed task files** from `spec/tickets/`
- Updates CHECKLIST.md
- Shows next priority task

## Output Structure

```
docs/
└── aiprep/
    ├── CHECKLIST.md           # Scorecard with scores and task overview
    └── tasks/                 # Individual task files for agents
        ├── 001-testing-setup.md
        ├── 002-package-modernization.md
        └── ...
```

Detailed recommendations are given directly in conversation. Language references are in `references/languages/*.md`.

## Supported Languages

| Language | Package Manager | Linter/Format | Testing |
|----------|-----------------|---------------|---------|
| Python | uv | ruff + ty | pytest |
| JS/TS (Frontend) | pnpm | ESLint / Biome | Vitest |
| JS/TS (Backend) | pnpm (Node) | ESLint / Biome | Vitest |
| Java/Kotlin | Gradle 8+ | Spotless | JUnit 5 |
| Go | go mod | golangci-lint | go test |
| Rust | cargo | clippy + rustfmt | built-in |

Each language has detailed recommendations in `references/languages/*.md` with:
- **Established vs Modern** options for each tool category
- **Licensing information** for compliance checks
- **Bun vs Node.js guidance** for JS/TS backends
- CLI framework recommendations
- Project structure examples

## What It Checks

| Category | Checks | Language-Specific |
|----------|--------|-------------------|
| **Documentation** | README, AI instructions, architecture | Universal |
| **Package Management** | Manager, lockfile, deps | Per-language best practice |
| **Testing** | Framework, coverage, isolation | Per-language tooling |
| **Code Quality** | Linting, formatting, types | Per-language tooling |
| **Code Patterns** | Hints, style, organization | Idiomatic per language |
| **CLI Frameworks** | CLI library choice (if applicable) | Typer, oclif, Cobra, clap, picocli |

## Task File Format

Each task is structured for both human review and agent consumption:

```markdown
# Task: 001 - Testing Setup

## Metadata
- **Priority**: P1
- **Category**: testing
- **Executor**: test-scaffolder (agent)
- **Status**: pending

## Current State
[What exists now]

## Desired State
[What should exist]

## Acceptance Criteria
- [ ] pytest configured
- [ ] Network isolation enabled
- [ ] Tests pass

## Verification
```bash
uv run pytest -v
```
```

## Workflow

### Analyze (`/modernizer`)

```
/modernizer
    │
    ├── 1. Discovery
    │   ├── Detect language(s)
    │   ├── Find AI instruction files
    │   ├── Discover available agents/skills
    │   └── Detect project structure
    │
    ├── 1.5. User Preferences (interactive)
    │   ├── Modern vs Established tools?
    │   ├── Licensing requirements?
    │   └── JS/TS: Frontend or Backend?
    │
    ├── 2. Analysis (using language references)
    │   └── Score: docs, packages, tests, quality, patterns
    │
    ├── 3. Plan Generation
    │   ├── spec/CHECKLIST.md
    │   └── spec/tickets/*.md
    │
    └── 4. Discussion
        ├── Present summary
        ├── Ask clarifying questions
        └── Offer to run available executors
```

### Status (`/modernizer status`)

```
/modernizer status
    │
    ├── Read task files in spec/tickets/
    ├── Delete completed tasks (status: completed)
    ├── Update CHECKLIST.md
    └── Report: completed, remaining, next priority
```

## Integration with Executors

modernizer discovers available agents and skills:

```
Available Executors:
- Agent: test-scaffolder → Testing setup tasks
- Agent: sanity-checker → Code quality verification
- Skill: dockit → Documentation generation
- Skill: speckit → Task/ticket management
```

Then matches tasks to executors and offers to run them:

```
Testing task detected:
  → test-scaffolder agent available
    "Run test-scaffolder for task 001?"
```

## speckit Integration

Task files are structured for speckit compatibility:

```bash
# Convert tasks to speckit tickets
/speckit.taskstoissues spec/tickets/
```

## Technology Recommendations (2025)

See `references/languages/*.md` for detailed options with licensing and established/modern alternatives.

### Quick Reference (Production Defaults)

| Language | Package | Lint/Format | Test | CLI |
|----------|---------|-------------|------|-----|
| Python | uv | ruff | pytest | Typer |
| JS/TS Frontend | pnpm | Biome | Vitest | - |
| JS/TS Backend | pnpm + Node | Biome | Vitest | oclif |
| Java/Kotlin | Gradle 8+ | Spotless | JUnit 5 | picocli |
| Go | go mod | golangci-lint | go test | Cobra |
| Rust | cargo | clippy | built-in | clap |

> **Note:** Bun is recommended for CLI tools and scripts (fast startup), but Node.js remains the safer choice for production backend services due to better npm compatibility and stability.

### Language Reference Files

| Language | File | Key Tools |
|----------|------|-----------|
| Python | `python.md` | uv, ruff, ty, pytest, Typer |
| JS/TS Frontend | `javascript-frontend.md` | Vite, React, shadcn/ui, Vitest, Playwright |
| JS/TS Backend | `javascript-node.md` | Bun, Fastify, Elysia, oclif |
| Go | `go.md` | golangci-lint, Cobra, Gin, Viper |
| Rust | `rust.md` | clap, Axum, Tokio, criterion |
| Java/Kotlin | `java-kotlin.md` | Gradle, Spotless, Spring Boot, picocli |

## What This Skill Does NOT Do

- **Does not execute changes** - Only plans
- **Does not write code** - Delegates to agents
- **Does not assume tools exist** - Discovers what's available
- **Does not hardcode executors** - Matches tasks dynamically

## Support

**Author**: Zach Goldstein - Solutions Architect

**Issues**: [Submit an issue](https://github.com/HugeInternal/zgoldstein_dev/issues/new?template=ai-skills.yml)
