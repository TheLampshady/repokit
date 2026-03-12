# agentkit

Generate project-level AI subagents tailored to your codebase's custom code patterns.

## What It Does

Analyzes your codebase to find where your team has extended, customized, or built on top of frameworks — then generates agents that help AI assistants understand and follow those patterns instead of reinventing them.

## How It Works

1. **Discovers** your dependencies, frameworks, and their versions
2. **Researches** what each framework provides natively (using docs + web search)
3. **Scans** for custom/extended code — subclasses, middleware, hooks, blocks, components, etc.
4. **Distinguishes** custom logic from boilerplate — flags native alternatives
5. **Proposes** agents scaled to your project size, with descriptions optimized for auto-triggering
6. **Generates** agent files for Claude, Gemini, and/or Copilot

## Usage

```
/agentkit              # Analyze and generate for all platforms
/agentkit claude       # Generate Claude agents only
/agentkit gemini       # Generate Gemini agents only
/agentkit copilot      # Generate Copilot agents only
```

## Output

Agent files are created in project-level directories:

| Platform | Location | Extension |
|----------|----------|-----------|
| Claude | `.claude/agents/` | `.md` |
| Gemini | `.gemini/agents/` | `.md` |
| Copilot | `.github/agents/` | `.agent.md` |

Plus instruction snippets for your CLAUDE.md / GEMINI.md / copilot-instructions.

## Updating repokit

To get the latest version of agentkit (and all repokit tools):

| Platform | Command |
|----------|---------|
| Claude | `/plugin marketplace update repokit-marketplace` |
| Gemini | `gemini extensions update repokit` |
| Copilot | `copilot plugin update repokit` |

## Agent Scaling

| Project Size | Files | Agents |
|-------------|-------|--------|
| Small | 1–20 | 1–2 |
| Medium | 21–50 | 2–4 |
| Large | 51+ | 3–7 |

## What Makes a Good Agent

Agents are created for **custom code** — not framework features:
- Custom base classes other code inherits from
- Extensions that look like defaults but behave differently
- Growing directories with many files following team patterns
- Middleware, hooks, blocks, components with project-specific logic

Agents are NOT created for:
- Standard framework usage with no customization
- Single configuration overrides
- Boilerplate that adds nothing to framework defaults
