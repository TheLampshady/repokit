# [TITLE]

> This task file uses the canonical ticket template (see `references/ticket-template.md`)
> with modernizer-specific sub-sections under Goals for agent execution.

## Overview

[1-3 sentences describing the modernization task for non-technical readers. What's out of
date, what improves when it's done.]

> **Note:** [Only if there's a business-critical consideration — e.g., security vulnerability,
compliance deadline, blocking other teams. Omit if not applicable.]

## Goals

* **Current State**

  [Description of what currently exists. Be specific about files, configurations, and current behavior.]

  **Evidence:**
  ```
  [Relevant file paths, config snippets, or command output showing current state]
  ```

* **Desired State**

  [Clear description of the end goal. What should exist when this task is complete?]

  **Target:**
  ```
  [Expected file structure, config, or behavior after completion]
  ```

* **Execution**
  - **Priority**: P1 | P2 | P3
  - **Category**: testing | packaging | linting | documentation | structure
  - **Language**: Python | JavaScript | TypeScript | Java | Kotlin | Go | Rust | Multi
  - **Executor**: [AGENT_NAME] | [SKILL_NAME] | manual
  - **Depends On**: [] | [TASK_IDS]
  - **Status**: pending | in_progress | completed

* **Implementation Notes**

  [Specific guidance for the executor:]
  - Key decisions already made
  - Constraints to follow
  - Patterns to match

  **Files to Modify:**

  | File | Action | Notes |
  |------|--------|-------|
  | [path/to/file] | create/modify/delete | [notes] |

  **Recommended Approach:**

  1. [Step 1]
  2. [Step 2]
  3. [Step 3]

* **Verification**

  Run these commands to verify task completion:

  ```bash
  [Verification command 1]
  [Verification command 2]
  ```

  **Expected output:**
  ```
  [What success looks like]
  ```

* **Rollback**

  If issues arise, rollback with:

  ```bash
  [Rollback commands or git instructions]
  ```

## Tech Details

```yaml
feature: [FEATURE_NAME]
type: chore | enhancement | bugfix
labels: [ai-readiness, tooling, testing, etc.]
```

**Open Questions (for spec process):**
- [Any unresolved technical decisions — flag for speckit if applicable]

## References

- [Relevant documentation, config files, or external links]

## Acceptance Criteria

* **Given:** [Current state or precondition]
  **When:** [The modernization change is applied]
  **Then:** [Expected outcome]
  **and Then:** [Additional verifiable outcome]

* **Given:** [Existing tests and functionality]
  **When:** [The change is complete]
  **Then:** All existing tests pass
  **and Then:** No regressions introduced

## Other

**Completion Log** *(filled in when completing)*

- **Completed by:** [agent-name | user]
- **Completed on:** [DATE]
- **Notes:** [Any relevant completion notes]
- **Verification output:**
  ```
  [Paste verification command output]
  ```
