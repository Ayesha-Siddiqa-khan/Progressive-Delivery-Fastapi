# GitHub Secrets

Create these secrets in your GitHub repository before running the deployment workflows.

| Secret | Meaning | Source |
| --- | --- | --- |
| `AWS_REGION` | AWS region where ECR and EKS exist, such as `us-east-1`. | Terraform output or AWS Console |
| `AWS_ACCOUNT_ID` | Your AWS account ID. | AWS Console or `aws sts get-caller-identity` |
| `AWS_ROLE_TO_ASSUME` | IAM role ARN used by GitHub Actions OIDC. | Terraform-created IAM OIDC role |
| `EKS_CLUSTER_NAME` | EKS cluster name. | Terraform output or AWS Console |
| `ECR_REPOSITORY` | ECR repository name for the Docker image. | Terraform output or ECR Console |
| `STAGING_HOST` | Staging domain or placeholder host. | DNS or ingress plan |
| `PRODUCTION_HOST` | Production domain or placeholder host. | DNS or ingress plan |
| `DATABASE_URL_STAGING` | PostgreSQL connection string for staging. | RDS output or secret manager you manage outside this repo |
| `DATABASE_URL_PRODUCTION` | PostgreSQL connection string for production. | RDS output or secret manager you manage outside this repo |

## OIDC role

`AWS_ROLE_TO_ASSUME` should ideally come from Terraform. The role should trust GitHub's OIDC provider and allow this repository to assume it.

The workflow uses:

```yaml
permissions:
  id-token: write
  contents: read
```

and:

```yaml
uses: aws-actions/configure-aws-credentials@v4
with:
  role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
  aws-region: ${{ secrets.AWS_REGION }}
```

## Database secret safety

The workflows create the Kubernetes secret with:

```bash
kubectl create secret generic progressive-app-db \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --dry-run=client -o yaml | kubectl apply -f -
```

The value is not printed in logs.
