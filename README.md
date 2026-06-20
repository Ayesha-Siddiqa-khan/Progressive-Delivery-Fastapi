# Progressive Delivery FastAPI on AWS EKS

This repository contains a beginner-friendly CI/CD and Kubernetes deployment setup for a FastAPI progressive delivery project on AWS EKS.

The application is expected to run on port `8000`. The deployment layer uses GitHub Actions, AWS ECR, AWS EKS, Helm, Argo Rollouts, Prometheus, Grafana, and either NGINX Ingress or AWS ALB Ingress.

No Terraform, Vault, real credentials, real account IDs, or real domains are stored in this repository.

## Project Structure

```text
progressive-delivery-fastapi/
|-- .github/workflows/
|   |-- ci.yml
|   |-- deploy-staging.yml
|   |-- promote-production.yml
|   `-- rollback.yml
|-- helm/progressive-app/
|   |-- Chart.yaml
|   |-- values.yaml
|   |-- values-staging.yaml
|   |-- values-production.yaml
|   `-- templates/
|       |-- namespace.yaml
|       |-- serviceaccount.yaml
|       |-- configmap.yaml
|       |-- secret-example.yaml
|       |-- service.yaml
|       |-- ingress.yaml
|       |-- rollout-canary.yaml
|       |-- rollout-bluegreen.yaml
|       |-- analysis-template.yaml
|       |-- servicemonitor.yaml
|       `-- notes.txt
|-- k8s/
|   |-- argo-rollouts/install-notes.md
|   |-- prometheus/servicemonitor.yaml
|   |-- prometheus/prometheus-queries.md
|   |-- grafana/progressive-delivery-dashboard.json
|   `-- examples/
|       |-- good-v1-values.yaml
|       |-- good-v2-values.yaml
|       |-- bad-v2-error-values.yaml
|       `-- bad-v2-latency-values.yaml
|-- scripts/
|   |-- deploy-staging.sh
|   |-- deploy-production.sh
|   |-- smoke-test.sh
|   |-- simulate-traffic.sh
|   |-- rollout-status.sh
|   |-- promote-rollout.sh
|   |-- abort-rollout.sh
|   `-- rollback.sh
|-- infra/terraform/
|   |-- versions.tf
|   |-- providers.tf
|   |-- locals.tf
|   |-- variables.tf
|   |-- network.tf
|   |-- eks.tf
|   |-- ecr.tf
|   |-- github-oidc.tf
|   |-- rds.tf
|   |-- outputs.tf
|   `-- terraform.tfvars.example
`-- docs/
    |-- cicd-on-aws.md
    |-- kubernetes-yaml-explanation.md
    |-- github-secrets.md
    |-- manual-production-approval.md
    `-- rollback-runbook.md
```

## Terraform AWS Infrastructure

Terraform is now included in:

```text
infra/terraform
```

It creates:

- VPC with public and private subnets.
- EKS cluster and managed node group.
- ECR repository for the FastAPI image.
- GitHub Actions OIDC IAM role.
- Optional private RDS PostgreSQL instance.

Start here:

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit:

```text
terraform.tfvars
```

At minimum, replace:

```hcl
github_repository = "YOUR_GITHUB_USERNAME/progressive-delivery-fastapi"
```

Then run:

```bash
terraform init
terraform plan
terraform apply
```

After apply, get the values for GitHub Actions repository variables:

```bash
terraform output github_actions_variables
```

Cost warning: this can create paid AWS resources such as NAT Gateway, EKS, EC2 worker nodes, EBS volumes, and optional RDS.

## AWS EKS CI/CD and Kubernetes Deployment

### Required GitHub Variables and Secrets

Create these repository variables before running deployment workflows:

```text
AWS_REGION
AWS_ACCOUNT_ID
AWS_ROLE_TO_ASSUME
EKS_CLUSTER_NAME
ECR_REPOSITORY
STAGING_HOST
PRODUCTION_HOST
```

Create these repository secrets because they contain database passwords:

```text
DATABASE_URL_STAGING
DATABASE_URL_PRODUCTION
```

`AWS_ROLE_TO_ASSUME` is not a password. It is an IAM role ARN, so it can be stored as a GitHub Actions variable. The workflows use `vars.*` for normal config and `secrets.*` only for database URLs.

### How Staging Deployment Works

The workflow at `.github/workflows/deploy-staging.yml` runs on push to `main` and can also be triggered manually.

It does the following:

1. Assumes the AWS OIDC role.
2. Logs in to Amazon ECR.
3. Builds the Docker image.
4. Tags the image with the Git SHA.
5. Pushes the image to ECR.
6. Updates kubeconfig for EKS.
7. Creates or updates the `DATABASE_URL` Kubernetes secret.
8. Deploys the Helm chart to `progressive-delivery-staging`.
9. Waits for Argo Rollouts status.
10. Runs smoke tests.
11. Writes a deployment summary to GitHub Actions.

Image format:

```text
AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY:GITHUB_SHA
```

### How Production Approval Works

The workflow at `.github/workflows/promote-production.yml` is manual and accepts:

```text
image_tag
```

It uses the GitHub Environment named:

```text
production
```

Configure required reviewers in GitHub so production waits for manual approval before deployment.

### Deploy a Good v1 Release

```bash
helm upgrade --install progressive-app ./helm/progressive-app \
  --namespace progressive-delivery-staging \
  --create-namespace \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-staging.yaml \
  -f k8s/examples/good-v1-values.yaml \
  --set namespace.name=progressive-delivery-staging \
  --set image.repository="AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY" \
  --set image.tag="v1" \
  --set ingress.host="staging.progressive-app.example.com"
```

### Deploy a Good v2 Release

```bash
helm upgrade --install progressive-app ./helm/progressive-app \
  --namespace progressive-delivery-staging \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-staging.yaml \
  -f k8s/examples/good-v2-values.yaml \
  --set namespace.name=progressive-delivery-staging \
  --set image.repository="AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY" \
  --set image.tag="v2" \
  --set ingress.host="staging.progressive-app.example.com"
```

### Deploy a Bad v2 Release

Error release:

```bash
helm upgrade --install progressive-app ./helm/progressive-app \
  --namespace progressive-delivery-staging \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-staging.yaml \
  -f k8s/examples/bad-v2-error-values.yaml \
  --set namespace.name=progressive-delivery-staging \
  --set image.repository="AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY" \
  --set image.tag="bad-v2-error" \
  --set ingress.host="staging.progressive-app.example.com"
```

Latency release:

```bash
helm upgrade --install progressive-app ./helm/progressive-app \
  --namespace progressive-delivery-staging \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-staging.yaml \
  -f k8s/examples/bad-v2-latency-values.yaml \
  --set namespace.name=progressive-delivery-staging \
  --set image.repository="AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY" \
  --set image.tag="bad-v2-latency" \
  --set ingress.host="staging.progressive-app.example.com"
```

### How Automatic Rollback Is Triggered

Argo Rollouts runs Prometheus analysis during the canary rollout.

The rollout fails if:

- Error rate is greater than `0.05`.
- p95 latency is greater than `0.5` seconds.

The AnalysisTemplate is:

```text
helm/progressive-app/templates/analysis-template.yaml
```

Prometheus queries are documented in:

```text
k8s/prometheus/prometheus-queries.md
```

### Run Smoke Tests

```bash
./scripts/smoke-test.sh https://staging.progressive-app.example.com
```

### Simulate Traffic

```bash
./scripts/simulate-traffic.sh https://staging.progressive-app.example.com 100
```

### Check Rollout Status

```bash
kubectl argo rollouts get rollout progressive-app -n progressive-delivery-staging --watch
```

or:

```bash
./scripts/rollout-status.sh progressive-delivery-staging progressive-app
```

### Promote Manually

```bash
kubectl argo rollouts promote progressive-app -n progressive-delivery-staging
```

or:

```bash
./scripts/promote-rollout.sh progressive-delivery-staging progressive-app
```

### Abort Manually

```bash
kubectl argo rollouts abort progressive-app -n progressive-delivery-staging
```

or:

```bash
./scripts/abort-rollout.sh progressive-delivery-staging progressive-app
```

### Roll Back

Command line:

```bash
CONFIRM_ROLLBACK=yes ./scripts/rollback.sh progressive-delivery-staging progressive-app
```

GitHub Actions:

1. Open GitHub Actions.
2. Select `Rollback`.
3. Run the workflow.
4. Choose `staging` or `production`.
5. Enter the namespace and release name.

## Helm Values

Default chart values live in:

```text
helm/progressive-app/values.yaml
```

Environment overrides:

```text
helm/progressive-app/values-staging.yaml
helm/progressive-app/values-production.yaml
```

Choose canary:

```yaml
rollout:
  strategy: canary
```

Choose blue-green:

```yaml
rollout:
  strategy: bluegreen
```

Switch to AWS ALB Ingress:

```yaml
ingress:
  className: alb
  alb:
    enabled: true
```

## Database Secret

The real database URL is created by GitHub Actions:

```bash
kubectl create secret generic progressive-app-db \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --dry-run=client -o yaml | kubectl apply -f -
```

The placeholder example is:

```text
helm/progressive-app/templates/secret-example.yaml
```

## Useful Documentation

- [CI/CD on AWS](docs/cicd-on-aws.md)
- [Kubernetes YAML Explanation](docs/kubernetes-yaml-explanation.md)
- [GitHub Variables and Secrets](docs/github-secrets.md)
- [Manual Production Approval](docs/manual-production-approval.md)
- [Rollback Runbook](docs/rollback-runbook.md)

## Validation Commands

Render the Helm chart:

```bash
helm template progressive-app ./helm/progressive-app \
  --namespace progressive-delivery-staging \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-staging.yaml
```

Run local checks if the FastAPI app is present:

```bash
pip install -r requirements.txt
ruff check .
pytest
docker build -f docker/Dockerfile -t progressive-delivery-fastapi:ci .
```

## Placeholders to Replace

Replace these before real cloud deployment:

```text
AWS_ACCOUNT_ID
AWS_REGION
AWS_ROLE_TO_ASSUME
EKS_CLUSTER_NAME
ECR_REPOSITORY
staging.progressive-app.example.com
progressive-app.example.com
DATABASE_URL_STAGING
DATABASE_URL_PRODUCTION
```

AWS EKS, ECR, RDS, DNS, ingress controller, Prometheus, Grafana, Argo Rollouts, GitHub variables, and GitHub secrets must be configured before real cloud deployment.
