# Static Blog on AWS — S3 + CloudFront

Static website hosted on AWS, deployed via Terraform and GitHub Actions.
Demonstrates the difference between an intentionally **vulnerable** setup
and a **hardened** one, using a branch-based promotion workflow.

## Branches

| Branch    | Purpose                                    | Deploys? |
|-----------|---------------------------------------------|:---:|
| `dev`     | Sandbox, intentionally vulnerable infra      | No |
| `staging` | Hardened infra, pre-production validation    | Yes |
| `main`    | Hardened infra, production (manual approval) | Yes |

**Promotion path:** `dev → staging → main`. A required check blocks any PR
into `main` that doesn't come from `staging`.

## Vulnerable vs. hardened

| | `dev` | `staging` / `main` |
|---|---|---|
| S3 bucket | Public | Fully private |
| Delivery | S3 website endpoint (HTTP) | CloudFront + OAC (HTTPS) |
| Encryption / versioning | None | AES256 + versioning |

Hardened infra is a reusable Terraform module (`modules/static-site`),
parameterized by `bucket_name` so each environment is isolated.

## State

One S3 bucket for state, separate keys per environment
(`staging/terraform.tfstate`, `prod/terraform.tfstate`) — fully independent.

## Pipeline (`deploy.yml`)

Push to `staging`/`main` triggers: **Trivy** (secrets) → **Grype** (CVEs) →
**terraform plan** → **Checkov** (misconfig) → **terraform apply** →
upload site → invalidate CloudFront cache. Any failed scan stops the
pipeline before touching AWS.

## Approvals & protection

- `staging`: deploys automatically.
- `main`: requires manual approval (GitHub Environment) before deploy.
- Both block force pushes/deletions and require PRs.

## Teardown

`destroy.yml` is manual — pick an environment, it empties the bucket and
runs `terraform destroy` against that environment's state only.
