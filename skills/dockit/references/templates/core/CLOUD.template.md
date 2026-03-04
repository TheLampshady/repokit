# Cloud Infrastructure

## Overview

| Attribute | Value |
|-----------|-------|
| Provider | [CLOUD_PROVIDER] |
| Project/Account | [PROJECT_ID] |
| Region(s) | [REGIONS] |
| IaC Tool | [IAC_TOOL] |

## Architecture Diagram

```
[CLOUD_ARCHITECTURE_DIAGRAM]
```

## Services Used

| Service | Purpose | Config Location |
|---------|---------|-----------------|
[CLOUD_SERVICES_TABLE]

## Infrastructure as Code

**Tool**: [IAC_TOOL]

**Location**: `[IAC_LOCATION]`

### Commands

| Action | Command |
|--------|---------|
| Initialize | `[IAC_INIT_CMD]` |
| Plan | `[IAC_PLAN_CMD]` |
| Apply | `[IAC_APPLY_CMD]` |
| Destroy | `[IAC_DESTROY_CMD]` |

### Modules/Resources

| Resource | Purpose | File |
|----------|---------|------|
[IAC_RESOURCES_TABLE]

## Deployment

### CI/CD Pipeline

**Platform**: [CICD_PLATFORM]

**Config**: `[CICD_CONFIG_PATH]`

```
[PIPELINE_DIAGRAM]
```

### Deployment Steps

[DEPLOYMENT_STEPS]

### Manual Deployment

```bash
[MANUAL_DEPLOY_COMMANDS]
```

### Rollback

```bash
[ROLLBACK_COMMANDS]
```

## Networking

| Resource | CIDR/Range | Purpose |
|----------|------------|---------|
[NETWORKING_TABLE]

### DNS

| Domain | Points To | TTL |
|--------|-----------|-----|
[DNS_TABLE]

## Security

### IAM Roles

| Role | Purpose | Assigned To |
|------|---------|-------------|
[IAM_ROLES_TABLE]

### Service Accounts

| Account | Purpose | Permissions |
|---------|---------|-------------|
[SERVICE_ACCOUNTS_TABLE]

### Firewall Rules

| Rule | Source | Destination | Ports |
|------|--------|-------------|-------|
[FIREWALL_TABLE]

## Monitoring & Logging

### Monitoring

| Tool | Purpose | Dashboard URL |
|------|---------|---------------|
[MONITORING_TABLE]

### Logging

| Log Type | Location | Retention |
|----------|----------|-----------|
[LOGGING_TABLE]

### Alerts

| Alert | Condition | Notification |
|-------|-----------|--------------|
[ALERTS_TABLE]

## Cost

**Monthly Estimate**: [COST_ESTIMATE]

| Service | Est. Cost | Cost Driver |
|---------|-----------|-------------|
[COST_TABLE]

### Cost Optimization

[COST_OPTIMIZATION_TIPS]

## Disaster Recovery

| Metric | Target |
|--------|--------|
| RTO (Recovery Time Objective) | [RTO] |
| RPO (Recovery Point Objective) | [RPO] |

### Backup Strategy

[BACKUP_STRATEGY]

### Recovery Procedure

[RECOVERY_STEPS]

## Access & Permissions

### Getting Access

[ACCESS_INSTRUCTIONS]

### Required Permissions by Role

| Role | Permissions Needed |
|------|-------------------|
[ROLE_PERMISSIONS_TABLE]

## Operations

[OPERATIONS_CONTEXT]
<!-- Brief intro: "Procedures for common operational tasks. For incident response, see the Runbook section below." -->

### Health Checks

| Service | Health Endpoint | Expected Response |
|---------|-----------------|-------------------|
[HEALTH_CHECKS_TABLE]

### Scaling

[SCALING_CONTEXT]
<!-- How to scale the application up/down -->

```bash
[SCALING_COMMANDS]
```

### Restart Services

```bash
[RESTART_COMMANDS]
```

[IF_LARGE_PROJECT]
> See [cloud/RUNBOOK.md](./cloud/RUNBOOK.md) for full incident response procedures.
[ENDIF]

[IF_MEDIUM_PROJECT]
### Incident Response (Quick Reference)

| Severity | Response Time | Escalation |
|----------|---------------|------------|
| Critical | 15 min | [CRITICAL_ESCALATION] |
| High | 1 hour | [HIGH_ESCALATION] |
| Medium | 4 hours | [MEDIUM_ESCALATION] |

**Common Issues:**

| Symptom | Quick Check | Resolution |
|---------|-------------|------------|
[OPERATIONS_ISSUES_TABLE]
[ENDIF]

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Environment configuration
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Application architecture
[IF_HAS_INFRA_README]
- [infra/README.md](../infra/README.md) - IaC documentation
[ENDIF]
[IF_LARGE_PROJECT]
- [cloud/RUNBOOK.md](./cloud/RUNBOOK.md) - Incident response and operations
[ENDIF]
