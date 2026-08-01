# Destructive Operations

**Activation: Always On**

Confirm with the user before running any command that deletes or overwrites work that isn't trivially recoverable.

## Always confirm first

| Operation | Why |
|-----------|-----|
| `rm -rf` anything | No undo, and glob mistakes are silent |
| Deleting `.backlog/` or files inside it | That's the project's ticket system — often the only record of pending work |
| Deleting `.claude/agents/`, `.agents/agents/`, or `.github/agents/` | Generated project agents; regenerating loses hand-edits |
| Deleting `docs/` or files inside it | The context layer other tools depend on |
| `git push` | Outward-facing and hard to walk back |
| `git reset --hard`, `git checkout --` over uncommitted work | Discards changes with no reflog entry |

State what will be deleted and how many files, then wait. "Confirm you intend to do this" is not a formality — read the target first (`ls` it) so the count in your question is real.

## Never do without an explicit request

- Force-push to a shared branch
- Rewrite published history (`rebase`, `commit --amend` on pushed commits)
- Delete a branch that isn't merged

## Overwriting is deleting

Writing a file that already exists destroys its contents. Before overwriting, read the file. If it has content you didn't author, append or edit rather than replacing — and if replacing is genuinely right, say what you're discarding.
