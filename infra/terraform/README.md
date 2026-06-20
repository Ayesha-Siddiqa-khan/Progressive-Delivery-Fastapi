# Terraform Infrastructure

This folder creates the AWS infrastructure needed by the progressive delivery project.

It provisions:

- VPC with public and private subnets.
- EKS cluster with a managed node group.
- ECR repository for the FastAPI Docker image.
- GitHub Actions OIDC provider and deployment IAM role.
- Optional private RDS PostgreSQL instance.

No real credentials or database passwords are hardcoded.

## Files

```text
versions.tf
providers.tf
locals.tf
variables.tf
network.tf
eks.tf
ecr.tf
github-oidc.tf
rds.tf
outputs.tf
terraform.tfvars.example
```

## Prerequisites

- Terraform CLI.
- AWS CLI configured for an admin or infrastructure role.
- An AWS account with permission to create VPC, EKS, ECR, IAM, and optional RDS resources.

## Quick Start

Copy the example variables file:

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit:

```text
terraform.tfvars
```

At minimum, change:

```hcl
github_repository = "YOUR_GITHUB_USERNAME/progressive-delivery-fastapi"
```

If the AWS EKS Console shows this warning:

```text
Your current IAM principal doesn't have access to Kubernetes objects on this cluster.
```

add the IAM user or IAM role you use in the AWS Console:

```hcl
cluster_admin_principal_arns = [
  "arn:aws:iam::257536659737:user/YOUR_IAM_USER"
]
```

Do not add the AWS root principal. Create or use a real IAM user/role for console and kubectl access.

Initialize Terraform:

```bash
terraform init
```

Preview changes:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

## Outputs to Copy to GitHub Actions Variables

After apply, run:

```bash
terraform output github_actions_variables
```

Create these GitHub Actions repository variables from the output:

```text
AWS_REGION
AWS_ACCOUNT_ID
AWS_ROLE_TO_ASSUME
EKS_CLUSTER_NAME
ECR_REPOSITORY
```

Create these additional GitHub Actions repository variables manually:

```text
STAGING_HOST
PRODUCTION_HOST
```

Create these GitHub Actions repository secrets manually:

```text
DATABASE_URL_STAGING
DATABASE_URL_PRODUCTION
```

## Optional RDS

By default:

```hcl
create_rds = false
```

If you want Terraform to create RDS:

```hcl
create_rds = true
```

The RDS password is managed by AWS Secrets Manager through `manage_master_user_password`.

After apply:

```bash
terraform output rds_endpoint
terraform output rds_master_secret_arn
terraform output database_url_template
```

Use the secret value from AWS Secrets Manager to create `DATABASE_URL_STAGING` and `DATABASE_URL_PRODUCTION`.

## Cost Warning

This stack can create paid AWS resources:

- NAT Gateway.
- EKS cluster.
- EC2 worker nodes.
- EBS volumes.
- Optional RDS.

Destroy demo infrastructure when finished:

```bash
terraform destroy
```

## Official References

- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- AWS VPC module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
- AWS EKS module: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
- GitHub OIDC for AWS: https://docs.github.com/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
