# repokit

**Keep your project's context in sync, then put it to work.** `dockit` keeps docs aligned with the code; `agentkit` consumes that synced context to build project-level agents.

Skills auto-activate from their descriptions — mention `dockit`, `agentkit`, or `repokit` by name to force one.

> This file is read as workspace context by **Antigravity** (`GEMINI.md` or `AGENTS.md` at the workspace root) and by Gemini CLI (via `contextFileName`). Antigravity replaced Gemini CLI on 2026-06-18.

## Generated Subagents

`/agentkit` writes Antigravity subagents to **`.agents/agents/<name>.md`** — not the retired `.gemini/agents/`. Run `/agents` to confirm they're discovered. Generated agents carry an enforced `tools` allowlist, `mainAgent: false`, and `commandExecutionPolicy: sandbox`.
