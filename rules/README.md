# Antigravity Rules

Markdown rules loaded by [Antigravity](https://antigravity.google/docs/rules-workflows) as part of the repokit plugin.

| Rule | Activation | Covers |
|------|-----------|--------|
| [destructive-operations.md](destructive-operations.md) | Always On | Confirm before `rm -rf`, deleting agent dirs / `docs/`, `git push`, hard resets |
| [secrets.md](secrets.md) | Always On | Don't read or write credential files; read keys not values |
| [context-files.md](context-files.md) | Always On | Append-only edits to `GEMINI.md` / `AGENTS.md` / `CLAUDE.md`; keep them short |

## Constraints

- **12,000 characters per file** — Antigravity's limit. All three are well under it.
- Rules are **guidance the model may follow**, not enforcement. See the caveat below.

## Relationship to `policies/policies.toml`

These rules are the Antigravity counterpart to `policies/policies.toml`, but they are **not equivalent in strength**:

| | `policies/policies.toml` (Gemini CLI) | `rules/*.md` (Antigravity) |
|---|---|---|
| Mechanism | Policy engine — matches tool calls by pattern | Instructions injected into context |
| Can hard-block | Yes — `decision = "deny"` refuses the call | No |
| Bypassable by the model | No | Yes, in principle |

So `secrets.md` asking the agent not to read `.env` is weaker than `policies.toml` denying `grep_search` against `\.env`. Treat these rules as the best available control on Antigravity, not as a security boundary. For real enforcement, use Antigravity's own permission prompts and `commandExecutionPolicy` on generated subagents.

Both files are kept: `policies.toml` still applies for Code Assist Standard/Enterprise users on Gemini CLI, which stopped serving other tiers on 2026-06-18.
