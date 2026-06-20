# Next Steps

Use this checklist after the project files are created.

## 1. Push the Project to GitHub

```bash
git init
git add .
git commit -m "Build EKS progressive delivery CI/CD project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/progressive-delivery-fastapi.git
git push -u origin main
```

## 2. Run Local Validation

```bash
pip install -r requirements.txt
ruff check .
pytest
helm lint ./helm/progressive-app
helm template progressive-app ./helm/progressive-app \
  --namespace progressive-delivery-staging \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-staging.yaml
```

Start Docker Desktop, then run:

```bash
docker build -f docker/Dockerfile -t progressive-delivery-fastapi:local .
```

## 3. Create GitHub Secrets

Create these in GitHub:

```text
AWS_REGION
AWS_ACCOUNT_ID
AWS_ROLE_TO_ASSUME
EKS_CLUSTER_NAME
ECR_REPOSITORY
STAGING_HOST
PRODUCTION_HOST
DATABASE_URL_STAGING
DATABASE_URL_PRODUCTION
```

GitHub path:

```text
Repository -> Settings -> Secrets and variables -> Actions
```

## 4. Confirm AWS Resources Exist

Your Terraform or AWS setup should already provide:

```text
EKS cluster
ECR repository
GitHub OIDC IAM role
Ingress controller: NGINX or AWS ALB
Argo Rollouts
Prometheus
Grafana
Optional RDS PostgreSQL database
```

## 5. Deploy to Staging

Push to `main`, or manually run:

```bash
gh workflow run deploy-staging.yml
```

Watch the rollout:

```bash
kubectl argo rollouts get rollout progressive-app -n progressive-delivery-staging --watch
```

## 6. Run Smoke Test and Traffic

```bash
./scripts/smoke-test.sh https://staging.progressive-app.example.com
./scripts/simulate-traffic.sh https://staging.progressive-app.example.com 100
```

## 7. Simulate a Bad Release

Deploy a bad error release:

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

Generate traffic:

```bash
./scripts/simulate-traffic.sh https://staging.progressive-app.example.com 100
```

Watch automatic rollback:

```bash
kubectl argo rollouts get rollout progressive-app -n progressive-delivery-staging --watch
kubectl get analysisrun -n progressive-delivery-staging
```

## 8. Promote to Production

After staging succeeds, run:

```bash
gh workflow run promote-production.yml -f image_tag=GIT_SHA_OR_IMAGE_TAG
```

Production deployment uses the GitHub Environment named:

```text
production
```

Configure required reviewers before using it for a real production demo.

## 9. Capture Portfolio Evidence

Capture screenshots or GIFs of:

```text
GitHub Actions CI passing
GitHub Actions staging deployment
Argo Rollouts canary stages
Prometheus error-rate query
Prometheus p95 latency query
Grafana dashboard
Automatic rollback event
Production approval screen
Smoke test output
```

## 10. Placeholders to Replace

Replace these before real cloud deployment:

```text
YOUR_USERNAME
AWS_ACCOUNT_ID
AWS_REGION
AWS_ROLE_TO_ASSUME
EKS_CLUSTER_NAME
ECR_REPOSITORY
staging.progressive-app.example.com
progressive-app.example.com
DATABASE_URL_STAGING
DATABASE_URL_PRODUCTION
GIT_SHA_OR_IMAGE_TAG
```
