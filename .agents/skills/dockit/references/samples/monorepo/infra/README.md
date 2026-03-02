# Infrastructure - GCP

Terraform configuration for the e-commerce platform on Google Cloud Platform.

## Overview

| Attribute | Value |
|-----------|-------|
| Tool | Terraform 1.6+ |
| Provider | Google Cloud Platform |
| Region(s) | us-central1 (primary), us-east1 (DR) |
| State Backend | GCS bucket |

## Structure

```text
infra/
├── modules/
│   ├── cloud-run/        # Cloud Run service module
│   ├── cloud-sql/        # Cloud SQL module
│   ├── redis/            # Memorystore Redis module
│   └── networking/       # VPC and networking
├── environments/
│   ├── staging/          # Staging environment
│   └── production/       # Production environment
├── main.tf               # Root module
├── variables.tf          # Input variables
├── outputs.tf            # Output values
└── backend.tf            # State backend config
```

## Prerequisites

- Terraform 1.6+
- Google Cloud SDK
- GCP project with billing enabled

### Required CLI Tools

| Tool | Version | Installation |
|------|---------|--------------|
| terraform | 1.6+ | `brew install terraform` |
| gcloud | latest | `brew install google-cloud-sdk` |

### Required Permissions

- `roles/editor` on the GCP project
- `roles/iam.serviceAccountUser` for service accounts

## Quick Commands

| Action | Command |
|--------|---------|
| Initialize | `terraform init` |
| Validate | `terraform validate` |
| Plan | `terraform plan -var-file=environments/staging/terraform.tfvars` |
| Apply | `terraform apply -var-file=environments/staging/terraform.tfvars` |
| Destroy | `terraform destroy -var-file=environments/staging/terraform.tfvars` |

## Resources Managed

| Resource | Purpose | Module/File |
|----------|---------|-------------|
| Cloud Run (x3) | Application services | `modules/cloud-run` |
| Cloud SQL | PostgreSQL database | `modules/cloud-sql` |
| Memorystore | Redis cache | `modules/redis` |
| VPC | Network isolation | `modules/networking` |
| Cloud Load Balancer | Traffic routing | `main.tf` |
| Cloud Armor | WAF/DDoS protection | `main.tf` |

## Variables

### Required

| Variable | Type | Description |
|----------|------|-------------|
| `project_id` | string | GCP project ID |
| `region` | string | Primary region |
| `environment` | string | staging or production |

### Optional

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `db_tier` | string | `db-f1-micro` | Cloud SQL machine type |
| `redis_memory_gb` | number | 1 | Redis memory size |
| `min_instances` | number | 1 | Min Cloud Run instances |

### Setting Variables

```bash
# Via environment
export TF_VAR_project_id="my-project"

# Via tfvars file
# environments/staging/terraform.tfvars
project_id  = "ecommerce-staging"
region      = "us-central1"
environment = "staging"
```

## Outputs

| Output | Description | Used By |
|--------|-------------|---------|
| `api_url` | Backend API URL | Frontend config |
| `db_connection_name` | Cloud SQL connection | Backend service |
| `redis_host` | Redis IP address | Backend service |
| `lb_ip` | Load balancer IP | DNS records |

## State Management

**Backend**: GCS bucket

**Location**: `gs://ecommerce-terraform-state/`

### Initialize State

```bash
terraform init -backend-config="bucket=ecommerce-terraform-state"
```

### State Operations

```bash
# List resources in state
terraform state list

# Import existing resource
terraform import google_cloud_run_service.api projects/PROJECT/locations/REGION/services/SERVICE

# Remove from state (without destroying)
terraform state rm google_cloud_run_service.api
```

## Environments/Workspaces

| Environment | Workspace/Config | Notes |
|-------------|------------------|-------|
| Staging | `environments/staging/` | Auto-deploy on merge to main |
| Production | `environments/production/` | Manual approval required |

### Switching Environments

```bash
# Use different tfvars
terraform plan -var-file=environments/production/terraform.tfvars
```

## Secrets

| Secret | Source | How to Update |
|--------|--------|---------------|
| `db_password` | Secret Manager | `gcloud secrets versions add db-password --data-file=-` |
| `stripe_key` | Secret Manager | `gcloud secrets versions add stripe-key --data-file=-` |

## Common Tasks

### Adding a New Service

1. Create service definition in `modules/cloud-run/`
2. Add service instance in `main.tf`
3. Configure networking and IAM
4. Run `terraform plan` to verify

### Importing Existing Resources

```bash
terraform import module.api.google_cloud_run_service.service \
  projects/ecommerce-prod/locations/us-central1/services/api
```

### Updating a Resource

1. Modify the relevant `.tf` file
2. Run `terraform plan -var-file=environments/staging/terraform.tfvars`
3. Review changes
4. Run `terraform apply -var-file=environments/staging/terraform.tfvars`

### Destroying Resources

```bash
# Destroy specific resource
terraform destroy -target=module.redis -var-file=environments/staging/terraform.tfvars

# Destroy all (DANGER)
terraform destroy -var-file=environments/staging/terraform.tfvars
```

## CI/CD Integration

Infrastructure changes are deployed via GitHub Actions:

1. PR opened → `terraform plan` runs, output posted as comment
2. PR approved + merged → `terraform apply` runs for staging
3. Release tag created → `terraform apply` runs for production

### Pipeline Stages

```
PR → Plan → Review → Merge → Apply (Staging) → Release → Apply (Prod)
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| State lock error | Check for running pipelines, force unlock if needed |
| Permission denied | Verify `gcloud auth` and IAM roles |
| Resource already exists | Import into state with `terraform import` |

## Cost Monitoring

Monthly costs tracked in GCP Billing dashboard. Budget alerts configured at 80% and 100% of monthly target.

## Related Documentation

- [Root README](../README.md) - Project overview
- [Cloud Documentation](../docs/CLOUD.md) - Cloud architecture
- [Environments](../docs/ENVIRONMENTS.md) - Environment configuration
