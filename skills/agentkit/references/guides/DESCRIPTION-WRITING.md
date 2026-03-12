# Writing Agent Descriptions for Auto-Triggering

The description field is the most critical part of an agent definition. It determines when the host AI (Claude, Gemini, Copilot) decides to delegate to this agent.

## Anatomy of a Good Description

A description should answer three questions:
1. **What does this agent know?** (area of expertise)
2. **When should it be used?** (trigger conditions)
3. **What does that look like?** (example scenarios)

## Platform-Specific Format

### Claude
Claude uses `<example>` XML blocks for reliable triggering:

```
"Custom blocks expert for the myproject project. Understands the team's custom
StreamField blocks, their rendering logic, and when to use each block type.
Use when working with Wagtail blocks, StreamField content, or page templates.

Examples:

<example>
Context: User is adding a new content section to a page.
user: \"I need to add a hero section to the homepage\"
assistant: \"I'll use the custom-blocks agent to find the right block type.\"
<Task tool call to launch custom-blocks agent>
</example>

<example>
Context: User is modifying an existing block.
user: \"The CTA block needs a new color option\"
assistant: \"Launching the custom-blocks agent to understand the existing CTA block pattern.\"
<Task tool call to launch custom-blocks agent>
</example>"
```

### Gemini
Gemini uses plain text with inline scenarios:

```
'Custom blocks expert for the myproject project. Understands the team''s custom
StreamField blocks, their rendering logic, and when to use each block type.
Use when working with Wagtail blocks, StreamField content, or page templates.
For example: when adding new content sections to pages, when modifying existing
block types, or when choosing which block to use for a design requirement.'
```

### Copilot
Copilot uses plain text, similar to Gemini:

```
'Custom blocks expert for the myproject project. Understands the team''s custom
StreamField blocks, their rendering logic, and when to use each block type.
Use when working with Wagtail blocks, StreamField content, or page templates.
For example: adding hero sections, modifying CTA blocks, choosing block types.'
```

## Common Mistakes

### Too broad
Bad: "Use for all Django operations"
Good: "Use when working with this project's custom model managers, audit mixins, and soft-delete patterns in `core/models/`"

### Too narrow
Bad: "Use only when editing CustomHeroBlock in blocks/hero.py"
Good: "Use when working with any custom StreamField block, adding new blocks, or modifying block rendering"

### Missing trigger phrases
Bad: "Knows about the project's middleware"
Good: "Use when adding or modifying request middleware, authentication handling, rate limiting, or error response formatting"

### No examples
The host AI needs concrete scenarios to match against. Always include at least 2 examples showing realistic user messages.

## Testing Descriptions

After generating an agent, test its triggering by asking the host AI:
- A message that SHOULD trigger it — does it delegate?
- A message that should NOT trigger it — does it correctly skip?

If triggering is unreliable, make the description more specific about when to use (not what it knows).
