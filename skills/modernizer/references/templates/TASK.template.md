# Task: [TASK_ID] - [TITLE]

> This task file is structured for both human review and agent consumption.

## Metadata

```yaml
id: [TASK_ID]
title: [TITLE]
priority: P1 | P2 | P3
category: testing | packaging | linting | documentation | structure
language: Python | JavaScript | TypeScript | Java | Kotlin | Go | Rust | Multi
executor: [AGENT_NAME] | [SKILL_NAME] | manual
depends_on: [] | [TASK_IDS]
status: pending | in_progress | completed  # completed tasks are deleted on /modernizer status
created: [DATE]
updated: [DATE]
```

## Current State

[Description of what currently exists. Be specific about files, configurations, and current behavior.]

**Evidence:**
```
[Relevant file paths, config snippets, or command output showing current state]
```

## Desired State

[Clear description of the end goal. What should exist when this task is complete?]

**Target:**
```
[Expected file structure, config, or behavior after completion]
```

## Acceptance Criteria

- [ ] [Specific, verifiable criterion]
- [ ] [Another criterion]
- [ ] [Criterion with measurable outcome]
- [ ] All existing tests pass
- [ ] No regressions introduced

## Implementation Notes

[Specific guidance for the executor. Include:]
- Key decisions already made
- Constraints to follow
- Patterns to match
- Files to modify

### Recommended Approach

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Files to Modify

| File | Action | Notes |
|------|--------|-------|
| [path/to/file] | create/modify/delete | [notes] |

## Verification

Run these commands to verify task completion:

```bash
[Verification command 1]
[Verification command 2]
```

**Expected output:**
```
[What success looks like]
```

## Rollback

If issues arise, rollback with:

```bash
[Rollback commands or git instructions]
```

---

## speckit Compatibility

This task can be converted to a speckit ticket:

```yaml
feature: [FEATURE_NAME]
type: chore | enhancement | bugfix
labels: [ai-readiness, tooling, testing, etc.]
```

## Agent Instructions

If you are an agent executing this task:

1. Read the **Current State** to understand context
2. Follow the **Recommended Approach**
3. Verify each **Acceptance Criterion**
4. Run **Verification** commands
5. Update **status** to `completed` when done
6. Report any blockers or deviations

---

## Completion Log

[AGENT/USER fills this in when completing]

**Completed by:** [agent-name | user]
**Completed on:** [DATE]
**Notes:** [Any relevant completion notes]
**Verification output:**
```
[Paste verification command output]
```
