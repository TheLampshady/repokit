# Infrastructure - [INFRA_NAME]

[INFRA_DESCRIPTION]

## Overview

| Attribute | Value |
|-----------|-------|
| Tool | [IAC_TOOL] |
| Provider | [CLOUD_PROVIDER] |
| Region(s) | [REGIONS] |
| State Backend | [STATE_BACKEND] |

## Structure

```text
[INFRA_FOLDER_STRUCTURE]
```

## Prerequisites

[PREREQUISITES_LIST]

### Required CLI Tools

| Tool | Version | Installation |
|------|---------|--------------|
[CLI_TOOLS_TABLE]

### Required Permissions

[REQUIRED_PERMISSIONS]

## Quick Commands

| Action | Command |
|--------|---------|
| Initialize | `[INIT_CMD]` |
| Validate | `[VALIDATE_CMD]` |
| Plan | `[PLAN_CMD]` |
| Apply | `[APPLY_CMD]` |
| Destroy | `[DESTROY_CMD]` |

## Resources Managed

| Resource | Purpose | Module/File |
|----------|---------|-------------|
[RESOURCES_TABLE]

## Variables

### Required

| Variable | Type | Description |
|----------|------|-------------|
[REQUIRED_VARS_TABLE]

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
[OPTIONAL_VARS_TABLE]

### Setting Variables

```bash
# Via environment
export TF_VAR_[variable_name]="value"

# Via tfvars file
[TFVARS_EXAMPLE]
```

## Outputs

| Output | Description | Used By |
|--------|-------------|---------|
[OUTPUTS_TABLE]

## State Management

**Backend**: [STATE_BACKEND]

**Location**: [STATE_LOCATION]

### Initialize State

```bash
[STATE_INIT_CMD]
```

### State Operations

```bash
# List resources in state
[STATE_LIST_CMD]

# Import existing resource
[STATE_IMPORT_CMD]

# Remove from state (without destroying)
[STATE_RM_CMD]
```

## Environments/Workspaces

| Environment | Workspace/Config | Notes |
|-------------|------------------|-------|
[WORKSPACES_TABLE]

### Switching Environments

```bash
[SWITCH_WORKSPACE_CMD]
```

## Secrets

| Secret | Source | How to Update |
|--------|--------|---------------|
[SECRETS_TABLE]

## Common Tasks

### Adding a New Resource

1. [STEP_1]
2. [STEP_2]
3. [STEP_3]

### Importing Existing Resources

```bash
[IMPORT_EXAMPLE]
```

### Updating a Resource

1. Modify the relevant `.tf` file
2. Run `[PLAN_CMD]`
3. Review changes
4. Run `[APPLY_CMD]`

### Destroying Resources

```bash
# Destroy specific resource
[DESTROY_TARGET_CMD]

# Destroy all (DANGER)
[DESTROY_ALL_CMD]
```

## CI/CD Integration

[CICD_INTEGRATION_DESCRIPTION]

### Pipeline Stages

```
[PIPELINE_DIAGRAM]
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
[INFRA_TROUBLESHOOTING_TABLE]

## Cost Monitoring

[COST_MONITORING_DESCRIPTION]

## Related Documentation

- [Root README](../README.md) - Project overview
- [Cloud Documentation](../docs/CLOUD.md) - Cloud architecture
- [Environments](../docs/ENVIRONMENTS.md) - Environment configuration
