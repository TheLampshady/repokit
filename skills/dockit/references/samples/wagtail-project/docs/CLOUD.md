# Cloud Infrastructure

Infrastructure and deployment for MyWagtail Site.

---

## Overview

| Attribute | Value |
|-----------|-------|
| Provider | AWS |
| Region | us-east-1 |
| IaC | Terraform |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      CloudFront CDN                          │
│                    - Static assets                           │
│                    - Cache HTML pages                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Application Load Balancer                   │
│                    - SSL termination                         │
│                    - Health checks                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ECS Fargate                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Gunicorn   │  │   Gunicorn   │  │   Gunicorn   │       │
│  │   Container  │  │   Container  │  │   Container  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
           │                              │
           ▼                              ▼
┌──────────────────────┐    ┌──────────────────────┐
│       RDS            │    │        S3            │
│     PostgreSQL       │    │    Media storage     │
└──────────────────────┘    └──────────────────────┘
```

---

## Services Used

| Service | Purpose | Notes |
|---------|---------|-------|
| ECS Fargate | Application hosting | Auto-scaling containers |
| RDS PostgreSQL | Database | Multi-AZ for production |
| S3 | Media storage | Images, documents |
| CloudFront | CDN | Static assets + page cache |
| ACM | SSL certificates | Auto-renewal |
| ECR | Container registry | Private images |
| Secrets Manager | Secrets | Django SECRET_KEY, DB password |

---

## Deployment

### How to Deploy

```bash
# Deploy to staging
./deploy.sh staging

# Deploy to production
./deploy.sh production
```

### What Happens

1. Docker image built locally
2. Image pushed to ECR
3. ECS service updated
4. Rolling deployment (zero downtime)
5. Migrations run via one-off task
6. Static files collected to S3

### Deploy Script

```bash
#!/bin/bash
set -e

ENV=$1
IMAGE_TAG=$(git rev-parse --short HEAD)

# Build and push
docker build -t mywagtail:$IMAGE_TAG .
docker tag mywagtail:$IMAGE_TAG $ECR_REPO:$IMAGE_TAG
docker push $ECR_REPO:$IMAGE_TAG

# Update ECS service
aws ecs update-service \
  --cluster mywagtail-$ENV \
  --service web \
  --force-new-deployment

# Run migrations
aws ecs run-task \
  --cluster mywagtail-$ENV \
  --task-definition migrate \
  --launch-type FARGATE

echo "Deployed $IMAGE_TAG to $ENV"
```

### Rollback

```bash
# List recent deployments
aws ecs describe-services --cluster mywagtail-prod --services web

# Rollback to previous task definition
aws ecs update-service \
  --cluster mywagtail-prod \
  --service web \
  --task-definition mywagtail-web:PREVIOUS_VERSION
```

---

## Monitoring

### Logs

```bash
# View recent logs
aws logs tail /ecs/mywagtail-prod --follow

# Filter errors
aws logs filter-log-events \
  --log-group-name /ecs/mywagtail-prod \
  --filter-pattern "ERROR"
```

### Metrics

CloudWatch dashboards track:
- Request count and latency
- Error rates (4xx, 5xx)
- Container CPU/memory
- Database connections

### Alerts

| Alert | Condition | Notification |
|-------|-----------|--------------|
| High error rate | >1% 5xx for 5 min | Slack #alerts |
| High latency | p95 > 2s | Slack #alerts |
| Database CPU | >80% for 10 min | PagerDuty |

---

## Operations

### Health Checks

| Check | Endpoint | Expected |
|-------|----------|----------|
| Application | `/health/` | 200 OK |
| Database | Checked via app | Connected |

### Scaling

ECS auto-scales based on CPU:
- Scale up: CPU > 70% for 3 min
- Scale down: CPU < 30% for 10 min
- Min: 2 tasks, Max: 10 tasks

Manual scaling:
```bash
aws ecs update-service \
  --cluster mywagtail-prod \
  --service web \
  --desired-count 5
```

### Maintenance

```bash
# Clear Wagtail cache
python manage.py clear_cache

# Rebuild search index
python manage.py update_index

# Collect static files
python manage.py collectstatic --noinput
```

---

## Cost

| Service | Est. Monthly | Notes |
|---------|--------------|-------|
| ECS Fargate | $100-200 | 2-4 tasks |
| RDS | $50 | db.t3.small |
| S3 + CloudFront | $20 | Storage + bandwidth |
| **Total** | ~$200 | Varies with traffic |

---

## Related Documentation

- [README.md](../README.md) - Project overview
- [ENVIRONMENTS.md](./ENVIRONMENTS.md) - Environment setup
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues
