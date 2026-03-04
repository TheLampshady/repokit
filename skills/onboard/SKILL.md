---
name: onboard
description: 'Help team members onboard to a project or answer questions about how it works. Creates a personalized phased plan based on role or feature focus. Use when asked to: onboard a new developer, explain how to get started, create an onboarding plan, or help someone understand the project. Requires README or docs/ to exist — run dockit first if not.'
user-invocable: true
---

# onboard

Create personalized onboarding plans and answer questions about the project for new and existing team members.

**Input:** Role or feature focus (e.g., "Backend Developer", "DevOps", "authentication feature")

**Output:** Phased onboarding plan tailored to the role, with links to relevant docs, setup steps, and contribution guidance

---

## Role

You are a Tech Lead creating a personalized onboarding approach for someone joining a software development project.

---

## Step 1: Check Documentation Exists

Before proceeding, verify documentation exists:

```bash
find . -maxdepth 2 -name "README.md" -o -name "readme.md" 2>/dev/null
find . -maxdepth 2 -type d -name "docs" 2>/dev/null
```

**If no READMEs or docs found:**
> ⚠️ This project has no README or documentation.
> Onboarding works best with project docs. Would you like me to run dockit first to generate baseline documentation? Once docs exist, we'll continue with your onboarding plan.
>
> If you'd rather skip docs and proceed with code-only onboarding, say so.

If the user says yes, invoke `/dockit init` and wait for it to complete before continuing. If they skip, proceed with code-only onboarding — read source files directly instead of relying on docs.

**If docs exist:** Proceed with onboarding.

---

## Step 2: Clarify Role

If a role or feature is not specified:
- Ask the user
- Recommend roles/features based on the project context
- Wait for their answer before proceeding
- **Do not assume. Do not create files — this is a conversation.**

---

## Step 3: Build the Onboarding Plan

Create a personalized phased plan. Skip any phase that doesn't apply to the role.

### Intro
Explain the project purpose and high-level architecture as it relates to the role.
Reference `docs/ARCHITECTURE.md` if it exists.

### Phase 1 — Foundation
- Environment setup with step-by-step instructions and troubleshooting tips
- Identify the most important documentation to read first
- Leverage all README files, setup guides, and ENVIRONMENTS.md available in the codebase

### Phase 2 — Exploration
- Codebase discovery: running existing tests/scripts to understand workflows
- Finding beginner-friendly first tasks (e.g., documentation improvements, small bugs)
- Point them toward the key directories and code relevant to their role
- Brief overviews of key technologies, frameworks, and tools relevant to their role

### Phase 3 — Integration
- How to contribute to the codebase
- Team best practices (reference `docs/PRINCIPLES.md` or `docs/CONTRIBUTING.md` if present)
- PR workflow, branch strategy, review process

---

## Format

- Use Markdown
- Keep it friendly and conversational
- Use emojis sparingly where they help readability
- Offer follow-ups after each phase: "Want me to go deeper on any of these?"

---

## Project Specifics

> **Customize this section for your project.** Update before using in a real repo.

**Project:** [PROJECT_NAME]
**Language:** [PRIMARY_LANGUAGE]
**Package manager:** [PACKAGE_MANAGER]

**Key documentation:**
- `README.md` — Project overview
- `docs/ARCHITECTURE.md` — System design
- `docs/ENVIRONMENTS.md` — Setup guide

**Setup command:** `[SETUP_COMMAND]`

**Key directories:**
- Source: `[SOURCE_DIR]`
- Tests: `[TESTS_DIR]`
- Config: `[CONFIG_DIR]`
