# Writing Guide

How to write documentation that explains, not just instructs.

## Audience

These practices serve both human readers and downstream AI tools (agentkit, feedback-loop, onboard, and external agents that load the project's docs as context). The two audiences need almost the same things — terse explanations, explicit cross-links, exact strings, purpose-bearing tables — so there's one set of rules below, not two. Where they genuinely diverge (tone, phased onboarding), the right move is to layer rather than fork: keep the docs flat and complete, and let downstream tools (like onboard) build personalized views on top.

## The Core Principle

**Documentation should explain, not just instruct.** Every section needs context.

---

## The Rule of Three

For each section, answer:

1. **What** - What does this do/contain?
2. **Why** - Why does it matter? Why would someone use this?
3. **When** - When should they use it? Any prerequisites or conditions?

---

## Section Lead-ins

Every major section (##) should have a 1-3 sentence introduction before diving into commands, tables, or code. This orients the reader.

### Bad Example

```markdown
## Testing
```bash
make test
```
```

### Good Example

```markdown
## Testing
Tests use pytest with pytest-asyncio for async support. Network access is blocked by default via pytest-socket to ensure tests don't make external calls.

```bash
make test
```
```

---

## Table Descriptions

Tables should have descriptive columns that explain purpose, not just list names.

### Bad Example

| Command | Description |
|---------|-------------|
| `make test` | Run tests |

### Good Example

| Command | Description |
|---------|-------------|
| `make test` | Run pytest with network blocked by default |

---

## README Principles

### Explanatory, Not Just Instructional

Every section should explain:
- **What** it does (the command/action)
- **Why** it matters (context for the reader)
- **When** to use it (situational guidance)

### Bad Example (too sparse)

```markdown
## Quick Start
### 1. Install
```bash
make setup
```
```

### Good Example

```markdown
## Quick Start
Get the project running locally in three steps. The setup uses Firebase emulators so you can develop without cloud costs.

### 1. Install
Installs Python dependencies via uv, configures git hooks for code quality, and sets up the commit message template.
```bash
make setup
```
```

---

## Visual and Scannable

Use markdown effectively:
- **Horizontal rules** (`---`) to separate sections
- **Tables** for commands and options (include Purpose/Description column)
- **Code blocks** with syntax highlighting
- **Blockquotes** for tips and links to detailed docs
- **Bold** for emphasis, not walls of text

---

## Quick Start Focus

Get the user running in 3 steps:
1. Install
2. Configure
3. Run

Each step should have a 1-2 sentence explanation of what happens and why.

---

## Contextual, Not Noisy

Include brief context, but link to details:

| What to Include | Where to Link |
|-----------------|---------------|
| Brief intro explaining what the project does (1-2 sentences) | - |
| Each section gets a lead sentence explaining its purpose | - |
| Detailed env vars | → ENVIRONMENTS.md (but explain what .env controls) |
| Full architecture | → ARCHITECTURE.md (but explain the stack briefly) |
| Troubleshooting | → TROUBLESHOOTING.md (but mention where to go) |

---

## Command Context

Include essential commands with context:

- Install, run, test commands
- Framework management commands (Django: migrate, createsuperuser, etc.)
- Custom management commands if they exist
- **Add a "What happens" explanation for non-obvious commands**
- Link to docs for details

---

## Informative Tables

Tables should be informative:

| Table Type | Include |
|------------|---------|
| Command tables | Description column explaining each command |
| Tech stack tables | Purpose column explaining why each tech is used |
| Documentation tables | "What You'll Learn" descriptions |

---

## Apply to All Docs

This principle applies to ALL generated documentation:

| Doc | What to Explain |
|-----|-----------------|
| **README.md** | Context for each section |
| **ARCHITECTURE.md** | Why design decisions were made |
| **ENVIRONMENTS.md** | What each variable controls |
| **CLOUD.md** | What happens during deployment |
| **TROUBLESHOOTING.md** | Causes, not just fixes |

---

## Stable Section Names

Downstream consumers — `agentkit`, `feedback-loop`, `onboard`, and dockit's own `sync` mode — depend on predictable structure across generated docs. They look for `## Foundations` in FOUNDATIONS.md, `## Quick Start` in README.md, env var tables under known headings. When a template author renames `## Architecture` to `## System Design`, the consumers don't break loudly — they silently miss the section, and project agents lose their context.

Treat canonical section names in the core templates as a contract.

**Safe changes:**
- Add new sections — additive changes don't break consumers
- Rephrase the body under a heading — only the heading is the contract
- Add subsections (`### Local Setup` under `## Environment Variables`)

**Breaking changes (avoid or coordinate):**
- Renaming top-level headings in core templates
- Moving a stable section to a different file (`FOUNDATIONS.md` content belongs in `FOUNDATIONS.md`, even if the project is small)
- Splitting a stable section across multiple files

If a rename is genuinely needed, update the consumer tools at the same time so docs and consumers stay in sync. Don't ship a renamed heading and hope nothing downstream notices.

---

## Content Preservation

Docs describe the **current** state of the code. Preservation rules differ by mode:

- **Restructuring (init / migrate):** never lose information — relocate it.
- **Syncing (sync):** when the code is gone, the doc section goes too. Removals are reported in chat, not memorialized in the docs.

### Merge Strategy (init / migrate)

When destination file exists:
1. Parse existing content into sections
2. Identify sections from template
3. **MERGE**: Add new sections, preserve existing custom sections
4. Mark conflicts for user review
5. Report what was added vs preserved

### Removal Strategy (sync)

When sync detects a removed feature, module, command, or env var:
1. Locate the corresponding doc section(s)
2. **Code-derived sections** (command tables, env var lists, API endpoints, generated diagrams): delete without prompting
3. **Prose-heavy sections** (multi-paragraph narrative, design notes, custom workflows): ask the user before deleting — they may contain intentional context worth keeping
4. **Never** leave tombstones — no "*deprecated*", "*removed in v2*", or "*no longer supported*" markers. Git history and changelogs serve that purpose.
5. Report each removal in the chat completion summary so the user can confirm

### Content Routing

| Content Type | Destination | README keeps |
|--------------|-------------|--------------|
| System setup, prerequisites, env vars | ENVIRONMENTS.md | Link only |
| Architecture, services, data flow | ARCHITECTURE.md | Brief overview |
| Coding standards, conventions | PRINCIPLES.md | Link only |
| Deployment, infra, CI/CD | CLOUD.md | Deploy command only |
| Common issues, debugging | TROUBLESHOOTING.md | Link only |
| Dev workflow, PR process | CONTRIBUTING.md | Link only |

---

## Migration Notes

`docs/MIGRATION-NOTES.md` is a **one-time hand-off doc** created during init/migrate when content gets relocated across files. It exists so the team can find content that moved during a restructure.

It is **not** a removal log. Sync must not append to it. Routine "X was removed" entries belong in chat output and git history, not in the docs.

```markdown
# Migration Notes

Content redistributed on [DATE]:

| Original Location | Content | New Location |
|-------------------|---------|--------------|
| README.md | System requirements | ENVIRONMENTS.md |
| README.md | Architecture diagram | ARCHITECTURE.md |
| README.md | Env var documentation | ENVIRONMENTS.md |

## Preserved Content

The following custom content was preserved in destination files:
- ENVIRONMENTS.md: "Local Development Setup" section
- ARCHITECTURE.md: Custom diagrams
```

Once the team has reviewed the migration, this file can be deleted — its job is done.
