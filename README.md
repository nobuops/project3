# Blog V1 — Public S3 (Vulnerable)

Static blog hosted on S3 with intentionally insecure configuration to demonstrate Checkov and Trivy findings.

## Architecture

```
Internet → S3 Static Website (HTTP, public-read)
```

## Files

| File | Description |
|---|---|
| `versions.tf` | AWS provider + remote state on S3 |
| `state.tf` | Bucket to store the tfstate |
| `main.tf` | Blog bucket (public) |
| `outputs.tf` | Website URL and bucket name |

## Intentional bad practices

| Resource | Bad practice | Risk |
|---|---|---|
| `aws_s3_bucket_acl` | `public-read` ACL | Anyone on the internet can list and read bucket contents |
| `aws_s3_bucket_public_access_block` | All options set to `false` | No guardrail preventing public exposure |
| `aws_s3_bucket_policy` | `Principal: "*"` | Any unauthenticated request can retrieve objects |

These misconfigurations will cause the pipeline to fail at the Checkov scan step intentionally.

## CI/CD

| Workflow | Trigger | Description |
|---|---|---|
| `deploy.yml` | Push to `main` | Trivy → Checkov → Apply → s3 sync |
| `destroy.yml` | Manual | Empties the bucket and destroys the infra |

### Required GitHub secrets

| Secret | Value |
|---|---|
| `AWS_ROLE_ARN` | ARN of the IAM Role with S3 permissions |

## Repository structure

```
.
├── main.tf
├── versions.tf
├── state.tf
├── outputs.tf
├── website/
│   ├── index.html
│   └── error.html
└── .github/
    └── workflows/
        ├── deploy.yml
        └── destroy.yml
```
