---
inclusion: auto
name: terraform-conventions
description: Terraform coding conventions, backend configuration, tagging, and deployment workflow. Use when writing or reviewing Terraform code.
---

# Terraform Conventions

## Project Structure

### Terraform-only projects

```
project-name/
├── infrastructure/          # Reusable Terraform module (environment-agnostic)
│   ├── variables.tf         # Module inputs
│   ├── outputs.tf           # Module outputs
│   ├── locals.tf            # Local values and computed expressions
│   ├── aws_s3.tf            # Resources grouped by AWS service
│   ├── aws_lambda.tf
│   ├── aws_iam.tf
│   └── ...
├── environments/
│   └── dev/
│       ├── config.tf              # Provider, backend S3, terraform version
│       ├── main.tf                # Module instantiation, variables, outputs
│       ├── backend.hcl            # Real backend values (gitignored)
│       ├── backend.hcl.example    # Template with placeholders (committed)
│       ├── terraform.tfvars       # Real variable values (gitignored)
│       └── terraform.tfvars.example  # Template with placeholders (committed)
├── .gitignore
├── LICENSE
└── README.md
```

### Fullstack projects (Terraform + Frontend)

```
project-name/
├── backend/
│   ├── infrastructure/      # Same structure as terraform-only
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── locals.tf
│   │   └── aws_*.tf
│   └── environments/
│       └── dev/
│           ├── config.tf
│           ├── main.tf
│           ├── backend.hcl(.example)
│           └── terraform.tfvars(.example)
├── frontend/                # Frontend application code
├── .gitignore
├── LICENSE
└── README.md
```

**How it works**:
- `infrastructure/` is a generic, parameterized Terraform module
- `environments/dev/main.tf` instantiates the module with concrete values
- State is stored remotely in S3 via `backend.hcl`
- `terraform plan/apply` is executed from within `environments/<env>/`
- File naming: `aws_<service>.tf` per AWS service (e.g., `aws_lambda.tf`, `aws_s3.tf`)

## Backend Configuration

The `config.tf` declares an empty `backend "s3" {}`. Actual values are in `backend.hcl` (gitignored), loaded via `terraform init -backend-config=backend.hcl`.

```hcl
# config.tf
terraform {
  backend "s3" {}
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags { tags = local.default_tags }
}
```

```hcl
# backend.hcl (gitignored) — real values
bucket  = "tutorial-terraform-tfstate"
key     = "project-name/dev/terraform.tfstate"
region  = "us-east-1"
profile = "Curso-Root"
```

```hcl
# backend.hcl.example (committed) — placeholders
bucket  = "your-terraform-state-bucket"
key     = "project-name/dev/terraform.tfstate"
region  = "us-east-1"
profile = "your-aws-profile"
```

## terraform.tfvars Pattern

Same separation: `.tfvars` is gitignored with real values, `.tfvars.example` is committed with placeholders.

## Code Style

- Section headers with `# ====...====` blocks
- One file per AWS service: `aws_<service>.tf`
- Resource naming: `${var.project_prefix}-<suffix>`
- Use `for_each` over `locals` maps for similar resources
- `create_before_destroy = true` for zero-downtime replacements
- `sha256(jsonencode(...))` for deployment triggers

## Required Variables (module level)

- `project_prefix` — resource naming prefix
- `aws_region` — AWS region
- `project_id` — cost allocation tag

## Tagging Strategy

Applied via provider `default_tags`:

| Tag | Value |
|-----|-------|
| `project_id` | project identifier |
| `managed_by` | `terraform` (fixed) |
| `environment` | env name (dev, prod) |

## Security

- Never commit `backend.hcl`, `terraform.tfvars`, `.env`
- Only `.example` files with placeholders are committed
- Mark sensitive vars with `sensitive = true`
- Use `profile` for authentication — never hardcode access keys

## Creating New Projects

Always use the scaffolding script before writing any code. Never create project structure manually.

```bash
./create-terraform-project.sh <ProjectName>              # terraform-only
./create-terraform-project.sh <ProjectName> --fullstack  # with frontend
```

This copies the template from `.copy_to_terraform_projects/` including real backend values (`backend.hcl`, `terraform.tfvars`) and replaces `PROJECT_NAME` placeholders automatically. After running the script, the project is ready for `terraform init`.

## Workflow

```bash
cd environments/<name>
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform apply tfplan
```
