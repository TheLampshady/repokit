# Context Files Are Hand-Maintained

**Activation: Always On**

`GEMINI.md`, `AGENTS.md`, `CLAUDE.md`, and `.github/copilot-instructions.md` are loaded on every request. They carry team conventions someone wrote deliberately, and a bad edit degrades every future session in the project.

## Rules

1. **Confirm before writing to one.** Show the exact text you intend to add and name the file. Wait for a yes.
2. **Append, never overwrite.** Add a new section at the end, or immediately after an obviously related one. Leave the rest of the file byte-identical.
3. **Never reformat.** Don't reflow prose, reorder sections, normalize heading levels, or "clean up" tables in a file you were asked to add one line to.
4. **Don't create a second one.** If `GEMINI.md` exists, don't add `AGENTS.md` — Antigravity parses either, and two files means two places to drift. Extend the one that's there.

## Keep them short

These files cost tokens on every single request. Content belongs here only if it's needed *always*. Anything conditional belongs in a rule under `.agents/rules/` with `Glob` or `Model Decision` activation, or in a skill that loads on demand.

Specifically, don't list available skills, agents, or plugins in a context file — those are already discovered automatically. Enumerating them is paid context with no behavioral payoff.

## The one thing worth adding

A pointer to the project's foundation registry, if `docs/FOUNDATIONS.md` exists:

```markdown
## Foundations

Shared, foundational code is catalogued in [docs/FOUNDATIONS.md](docs/FOUNDATIONS.md),
with the invariants each foundation guarantees. Read it before changing anything under
those paths.
```

That's a few tokens that stop agents from re-deriving the architecture on every task. `/repokit status` checks whether it's present; `/repokit init` offers to add it.
