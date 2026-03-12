# repokit

A codebase maintenance toolkit for AI agents. Works with **Claude Code**, **Gemini CLI**, and **GitHub Copilot CLI**. Provides skills, agents, hooks, and policies that help development teams maintain documentation, modernize tooling, onboard developers, and track technical debt.

## Install

**Claude Code plugin:**
```bash
claude plugin marketplace add TheLampshady/repokit
claude plugin install repokit@repokit-marketplace
# NOTE: Restart Claude
```


**Gemini CLI extension:**
```bash
gemini extensions install https://github.com/TheLampshady/repokit
```

**GitHub Copilot CLI plugin:**
```bash
copilot plugin install https://github.com/TheLampshady/repokit
```


### Update

**Claude Code plugin:**
```bash
claude plugin marketplace update repokit-marketplace
```

**Gemini CLI extension:**
```bash
gemini extensions update repokit
```

**GitHub Copilot CLI plugin:**
```bash
copilot plugin update repokit
```

### Un-Install

**Claude Code plugin:**
```bash
claude plugin marketplace remove TheLampshady/repokit
claude plugin uninstall repokit@repokit-marketplace
```

**Gemini CLI extension:**
```bash
gemini extensions uninstall https://github.com/TheLampshady/repokit
```

**GitHub Copilot CLI plugin:**
```bash
copilot plugin uninstall https://github.com/TheLampshady/repokit
```

---

## Tools

### Skills (cross-platform: Claude + Gemini + Copilot)

| Skill | Command | Purpose | Status |
|-------|---------|---------|--------|
| **agentkit** | `/agentkit` | Generate project-level AI agents tailored to your codebase's custom code patterns. Supports Claude, Gemini, and Copilot. | WIP |
| **dockit** | `/dockit` | Generate, sync, check, and migrate project documentation. Scales by project size, auto-detects frameworks. | Ready |
| **modernizer** | `/modernizer` | Audit the codebase for outdated tooling, missing tests, and packaging gaps. Creates tickets in `spec/`. | In Review |
| **onboard** | `/onboard` | Create personalized onboarding plans for new team members based on role or feature focus. | Ready |
| **repokit** | `/repokit` | Show the full tool menu and get guided to the right tool. | In Review |

### Agents (auto-triggered)

| Agent | Triggers when... | Platform |
|-------|-----------------|----------|
| **sanity-checker** | You need to verify code quality, before committing, after fixing a bug | Claude |
| **auditor** | You ask to review the codebase for outdated code, stale practices, or automation gaps | Claude |

> **Gemini users:** See [Enabling Gemini Subagents](#gemini-subagents) to use agents on Gemini.

---

## Ticket System

All tools write work items to a shared backlog under `spec/`:

```
spec/
├── backlog.md       ← master checklist, items tagged by source
└── tickets/
    ├── 001-add-tests.md
    └── 002-stale-setup-docs.md
```

Tags in `backlog.md` show which tool created each item: `[modernizer]`, `[sanity-checker]`, `[manual]`. (The auditor does not write tickets directly — its findings flow through modernizer.)

---

## Keeping Docs in Sync

After making code changes, run dockit to check for documentation drift:

- `/repokit:dockit check` — detect stale docs (read-only, exit codes)
- `/repokit:dockit sync` — auto-update stale sections (non-destructive)

Run `check` before releases or PRs. Run `sync` when docs fall behind.

---

## Gemini Subagents

Repokit agent definitions are compatible with Gemini's experimental subagent system.

**1. Enable subagents** in `.gemini/settings.json` or `~/.gemini/settings.json`:

```json
{
  "experimental": {
    "enableAgents": true
  }
}
```

**2. Copy agent definitions:**

```bash
# Project-level (team-shared)
mkdir -p .gemini/agents
cp agents/*.md .gemini/agents/

# Or user-level (all your projects)
mkdir -p ~/.gemini/agents
cp agents/*.md ~/.gemini/agents/
```

**3. Restart Gemini CLI.**

> Subagents run in YOLO mode — they execute tool calls without per-step confirmation. Review `agents/*.md` before enabling.

---

## Component Diagram

```mermaid
graph TD
    subgraph repokit["The Repokit"]
        direction TB

        subgraph foundation["Foundation"]
            S_repokit["repokit<br/>Tool menu & navigation"]
            S_dockit["dockit<br/>Generate & sync project docs"]
        end

        subgraph accelerators["Accelerators"]
            S_modernizer["modernizer<br/>Audit tooling & create tickets"]
            S_agentkit["agentkit<br/>Generate project-level AI agents"]
            S_onboard["onboard<br/>Personalized plans for new devs"]
        end

        subgraph agents_box["Quality Gates"]
            A_auditor["auditor<br/>Find outdated code & practices"]
            A_sanity["sanity-checker<br/>Lint, format, typecheck & test"]
        end
    end

    subgraph client_repo["Client Repo"]
        direction TB
        SME["SME Agents<br/>Custom code experts<br/>generated per-project"]
        Spec[("spec/<br/>backlog.md · tickets/")]
    end

    CA["Code Assist<br/>Claude · Gemini · Copilot"]

    CA -->|"invokes"| foundation
    CA -->|"invokes"| accelerators
    CA -->|"delegates to"| SME
    CA -->|"triggers"| agents_box

    foundation -.->|"required by"| accelerators
    S_modernizer -.->|"invokes"| A_auditor

    S_agentkit -->|"generates"| SME
    S_modernizer -->|"writes tickets"| Spec

    classDef skill   fill:#3b82f6,stroke:#1d4ed8,color:#fff
    classDef agent   fill:#8b5cf6,stroke:#6d28d9,color:#fff
    classDef storage fill:#f59e0b,stroke:#b45309,color:#000
    classDef ai      fill:#7c3aed,stroke:#5b21b6,color:#fff
    classDef found   fill:#0ea5e9,stroke:#0284c7,color:#fff
    classDef sme     fill:#10b981,stroke:#059669,color:#fff
    classDef client  fill:#1e293b,stroke:#475569,color:#94a3b8

    class S_repokit,S_dockit found
    class S_modernizer,S_onboard,S_agentkit skill
    class A_sanity,A_auditor agent
    class Spec storage
    class CA ai
    class SME sme
```

> **Claude Code:** skills invoked as `/repokit:skill-name` · **Gemini CLI / Copilot CLI:** invoked as `/skill-name`, agents require [opt-in setup](#gemini-subagents)

### Scenario Flows

#### Documentation on Demand

*Repos of any size and age accumulate missing or nonexistent documentation — the codebase grows faster than anyone writes about it.*

```mermaid
graph LR
    Scenario["📁 Codebase\nwithout documentation"]
    Dev["👤 Developer"]
    CA["🤖 Code Assist"]
    Dockit["Docs Generator\ndockit init"]
    Output["📄 README · ARCHITECTURE\nENVIRONMENTS"]
    Result["✅ Docs created\nfrom the codebase\nin minutes"]

    Scenario --> Dev
    Dev -->|"'Set up docs\nfor this repo'"| CA
    CA -->|"invokes"| Dockit
    Dockit -->|"scans & generates"| Output
    Output --> Result

    classDef skill fill:#3b82f6,stroke:#1d4ed8,color:#fff
    classDef ai    fill:#7c3aed,stroke:#5b21b6,color:#fff
    class Dockit skill
    class CA ai
    style Scenario fill:#e2e8f0,stroke:#94a3b8,color:#1e293b
    style Dev      fill:#1e293b,stroke:#0f172a,color:#fff
    style Result   fill:#86efac,stroke:#16a34a,color:#000
```

> **Example:** An API service that's been running for two years has no README. A developer says "set up docs for this repo." The Code Assist invokes dockit, which scans the codebase and generates a README, ARCHITECTURE, and ENVIRONMENTS doc in under a minute.

#### Quality Gates Before Code Ships

*Code quality issues — lint errors, type failures, broken tests — are cheaper to catch locally than after a push triggers CI.*

```mermaid
graph LR
    Scenario["💻 Developer\nfinishes a feature"]
    Dev["👤 Developer"]
    CA["🤖 Code Assist"]
    Sanity["Sanity Checker\nauto-triggered agent"]
    Fix["🔧 Issues fixed\nlocally before commit"]
    Result["✅ Clean push\nCI passes first time"]

    Scenario --> Dev
    Dev -->|"'I just finished\nthe auth module'"| CA
    CA -->|"triggers"| Sanity
    Sanity -->|"fixes & reports"| Fix
    Fix --> Result

    classDef agent fill:#8b5cf6,stroke:#6d28d9,color:#fff
    classDef ai    fill:#7c3aed,stroke:#5b21b6,color:#fff
    class Sanity agent
    class CA ai
    style Scenario fill:#e2e8f0,stroke:#94a3b8,color:#1e293b
    style Dev      fill:#1e293b,stroke:#0f172a,color:#fff
    style Result   fill:#86efac,stroke:#16a34a,color:#000
```

> **Example:** A developer says "I just finished the auth module." The Code Assist recognizes this as a completion signal and triggers the sanity-checker, which finds a missing type annotation and a failing unit test — before a single `git push`.

#### What Do I Need to Update?

*A single question triggers an orchestrated review — the Code Assist runs modernizer, which internally invokes the auditor to find outdated code, stale practices, and automation gaps. Modernizer takes the auditor's findings, combines them with its own tooling analysis, and writes all tickets to a shared backlog.*

```mermaid
graph LR
    Scenario["💬 'What do I\nneed to update?'"]
    CA["🤖 Code Assist"]
    Modernizer["Stack Modernizer\nmodernizer"]
    Auditor["Auditor\nauditor"]
    Spec["📋 spec/backlog.md\nFindings tagged\nby source"]
    Result["✅ Full picture\nof work needed\nReady to prioritize"]

    Scenario --> CA
    CA -->|"runs"| Modernizer
    Modernizer -->|"invokes"| Auditor
    Auditor -->|"findings"| Modernizer
    Modernizer -->|"writes all tickets"| Spec
    Spec --> Result

    classDef skill   fill:#3b82f6,stroke:#1d4ed8,color:#fff
    classDef agent   fill:#8b5cf6,stroke:#6d28d9,color:#fff
    classDef storage fill:#f59e0b,stroke:#b45309,color:#000
    classDef ai      fill:#7c3aed,stroke:#5b21b6,color:#fff
    class Modernizer skill
    class Auditor agent
    class Spec storage
    class CA ai
    style Scenario fill:#e2e8f0,stroke:#94a3b8,color:#1e293b
    style Result   fill:#86efac,stroke:#16a34a,color:#000
```

> **Example:** A developer asks "what do I need to update before the release?" The Code Assist runs modernizer. Modernizer invokes the auditor, which finds two setup commands in the README that no longer exist and a missing CI config. Modernizer finds no type checking configured and an outdated package manager. All findings land in `spec/backlog.md`, tagged by source.

---

## Structure

```
repokit/
├── skills/                  ← cross-platform skills (Claude + Gemini + Copilot)
│   ├── agentkit/
│   ├── dockit/
│   ├── modernizer/
│   ├── onboard/
│   └── repokit/
├── .agents/skills → skills/  ← symlink for Gemini (git clone resolves it)
├── agents/                  ← distributed agents (sanity-checker, auditor)
├── .claude/agents/          ← internal dev tools (component-reviewer)
├── .claude-plugin/          ← Claude plugin + marketplace metadata
├── hooks/                   ← session lifecycle hooks
├── policies/                ← Gemini policy engine rules
├── spec/                    ← ticket system
│   ├── backlog.md
│   └── tickets/
├── CLAUDE.md                ← Claude context
├── GEMINI.md                ← Gemini context + subagent setup
└── gemini-extension.json    ← Gemini extension manifest
```

---

## Policies

The Gemini extension includes security policies (`policies/policies.toml`):

- Requires confirmation before `rm -rf` commands
- Blocks grep searches for sensitive files (`.env`, `id_rsa`, `passwd`)
- Validates file paths on write operations

---

## Report an Issue

Found a bug or unexpected behavior with a skill or agent? [Open an issue](https://github.com/TheLampshady/repokit/issues/new?template=ai-skills.yml).

Include which component (skill/agent), AI platform, and what you asked vs. what happened.

---
