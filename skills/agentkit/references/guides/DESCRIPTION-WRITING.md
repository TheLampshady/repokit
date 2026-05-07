# Writing Agent Descriptions for Auto-Triggering

The description field is the most critical part of an agent definition. It determines when the host AI (Claude, Gemini, Copilot) decides to delegate to this agent — and just as important, when it decides **not** to.

## The Scope Boundary Rule

A project agent owns a specific part of the codebase. **The description must keep the host AI from triggering the agent on work outside that part.** An agent that triggers too eagerly is worse than one that doesn't trigger enough — it pollutes unrelated work with project-specific context the user didn't ask for, and creates triggering conflicts with other agents.

Every description has to do two jobs:

1. **Define the positive scope** — what the agent owns: foundations, working directories, file patterns, expertise area.
2. **Define the negative scope** — what looks similar but should *not* trigger this agent: generic library help, third-party SDK questions, code in other parts of the project, work that overlaps superficially with the agent's domain.

A description with only positive scope over-triggers. A description with only negative scope under-triggers. You need both.

## Anatomy of a Good Description

A description should answer four questions:

1. **What does this agent know?** — area of expertise, owned foundations, working directories
2. **When SHOULD it be used?** — concrete trigger scenarios tied to the codebase, not the topic
3. **When should it NOT be used?** — adjacent topics, generic questions, other parts of the codebase
4. **What does triggering look like?** — example scenarios (positive and at least one negative)

## Platform-Specific Format

### Claude

Claude uses `<example>` XML blocks. Include **at least one negative example** showing a query that sounds related but should NOT trigger this agent — Claude uses these to learn the boundary.

```
"Owner of the auth foundation in the myproject codebase. Use this agent when
modifying or extending code in `core/auth/`, `core/permissions/`, or any code
that imports from these foundations — including custom session middleware,
permission checks, and FOUNDATIONS.md updates for `core.auth` or
`core.permissions`.

Do NOT use this agent for:
- Generic OAuth/auth library questions unrelated to this project
- Third-party SDK help (e.g., Auth0, Okta integration)
- Work in other parts of the codebase that don't import auth foundations

Examples:

<example>
Context: User is modifying the project's auth foundation directly.
user: \"I need to add a refresh-token rotation policy to core.auth\"
assistant: \"This touches the auth foundation. Launching the auth agent.\"
<Task tool call to launch auth agent>
</example>

<example>
Context: User is adding code that depends on the auth foundation.
user: \"How do I add a permission check to the new orders endpoint?\"
assistant: \"This will use core.permissions. Launching the auth agent.\"
<Task tool call to launch auth agent>
</example>

<example>
Context: User is asking a generic auth question — not the project's foundation.
user: \"How do JWTs work?\"
assistant: \"This is a general question, not specific to the project's auth
foundation. Answering directly without delegating to the auth agent.\"
</example>"
```

The negative example is doing real work. Without it, Claude tends to over-trigger on topical keywords like "JWT," "auth," "login."

### Gemini

Gemini uses plain text. Include an explicit "Do not use for:" clause.

```
'Owner of the auth foundation in the myproject codebase. Use when modifying or
extending code in core/auth/, core/permissions/, or any code that imports from
these foundations. Use also when updating FOUNDATIONS.md entries for core.auth
or core.permissions.

For example: adding a refresh-token rotation policy to core.auth, adding a
permission check to a new endpoint that uses core.permissions, or updating the
auth foundation''s invariants after a security review.

Do NOT use for: generic OAuth or JWT questions unrelated to this project, third-
party SDK integration help, or work in other parts of the codebase that do not
import auth foundations.'
```

### Copilot

Copilot uses concise plain text. Same pattern, tighter:

```
'Owner of the auth foundation in myproject. Use when modifying core/auth/,
core/permissions/, or code that imports from these foundations, or when
updating FOUNDATIONS.md for core.auth / core.permissions. Do not use for
generic OAuth/JWT questions, third-party SDK help, or work in other parts of
the codebase.'
```

## How to Compose Each Field

### Positive scope phrases

Use **concrete codebase references**, not topic words. The host AI matches on specificity.

| Generic (bad) | Specific (good) |
|---------------|-----------------|
| "Use for auth" | "Use when modifying `core/auth/` or `core/permissions/`" |
| "Use for data layer work" | "Use when modifying `core/database/` or files importing `core.database`" |
| "Use for notifications" | "Use when modifying code in `core/notifications/`, the notifications dispatcher, or `FOUNDATIONS.md`'s `core.notifications` entry" |

If the agent owns FOUNDATIONS.md rows, name them. If it owns directories, list them. If it owns import-edges (consumers of the foundation), say so.

### Negative scope phrases

The most useful negatives are the **near-misses**. Things that share keywords or topic with the agent but actually need a different response:

- "Do not use for: generic [topic] questions unrelated to this project"
- "Do not use for: third-party [vendor] SDK help"
- "Do not use for: work in other parts of the codebase that don't import [foundation]"
- "Do not use for: [adjacent area] work — that's owned by the [other-agent] agent"

If two agents share a domain (e.g., a `data-layer` foundation agent and a `custom-querysets` SME agent), each one's description should explicitly point at the other for the boundary case.

## Common Mistakes

### Too broad (over-triggers)

Bad: *"Use for all Django operations"*
Bad: *"Knows about authentication"*
Good: *"Use when modifying this project's custom model managers, audit mixins, and soft-delete patterns in `core/models/`. Do not use for generic Django ORM questions."*

### Too narrow (under-triggers)

Bad: *"Use only when editing CustomHeroBlock in blocks/hero.py"*
Good: *"Use when working with any custom StreamField block in `blocks/`, adding new blocks, or modifying block rendering logic."*

### Topic-matching instead of code-matching

Bad: *"Use when the user mentions auth, login, sessions, or permissions"* — triggers on every casual auth mention
Good: *"Use when the user is modifying or extending code in `core/auth/` or files that import from it"* — triggers only on real work in the agent's territory

### Missing negative scope

A description with only positive triggers will trigger on adjacent topics it shouldn't own. Always include at least one negative clause. The Claude format makes this a negative `<example>`; Gemini/Copilot do it as a "Do NOT use for:" clause.

### No examples (Claude)

The host AI needs concrete scenarios to match against. Include at least 2 positive examples and 1 negative example. The negative example is what teaches Claude the boundary.

## Testing Descriptions

After generating an agent, test its triggering by asking the host AI three kinds of queries:

| Query type | Expected behavior |
|------------|-------------------|
| Direct work in owned territory | Agent triggers |
| Work that imports the agent's foundation | Agent triggers |
| Generic question on the same topic, not project-specific | Agent does NOT trigger; host answers directly |
| Work in a different part of the codebase | Agent does NOT trigger |

If the agent triggers when it shouldn't, the description is too broad — strengthen the negative scope. If it doesn't trigger when it should, the positive scope is too narrow or too generic — make it more concretely about *this* codebase's directories and foundations.

## Foundation-Owner Agent Description Template

For agents that own FOUNDATIONS.md rows, use this skeleton:

```
Owner of [foundation list] in [project name]. Use when:
- modifying code in [working directories]
- modifying code that imports from [foundations]
- updating FOUNDATIONS.md entries for [foundations]
- [add foundation-specific triggers, e.g., "rotating tokens," "publishing notifications"]

Do NOT use for:
- generic [topic] questions unrelated to this project
- third-party SDK help
- work in other parts of the codebase that do not import [foundations]
- [adjacent areas owned by other agents]

[Platform-appropriate examples follow]
```

Fill in the placeholders from the agent's `Owned Foundations` section.
