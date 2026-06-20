# CI/CD on AWS

This project uses GitHub Actions to move a FastAPI app from source code to AWS EKS.

The AWS infrastructure can be created from:

```text
infra/terraform
```

That Terraform layer creates EKS, ECR, GitHub OIDC IAM role, VPC networking, and optional RDS.

## CI workflow

File:

```text
.github/workflows/ci.yml
```

Jobs:

- `test` installs Python dependencies and runs pytest.
- `lint` installs Python dependencies and runs Ruff.
- `docker-build` builds the Docker image locally.

CI does not push images and does not deploy to AWS.

## Staging deployment workflow

File:

```text
.github/workflows/deploy-staging.yml
```

The staging workflow:

1. Runs on push to `main` or manual trigger.
2. Authenticates to AWS with GitHub OIDC role assumption.
3. Logs in to Amazon ECR.
4. Builds the Docker image.
5. Tags the image with the Git SHA.
6. Pushes the image to ECR.
7. Updates kubeconfig for EKS.
8. Creates or updates the `DATABASE_URL` Kubernetes secret safely.
9. Deploys the Helm chart to `progressive-delivery-staging`.
10. Waits for Argo Rollouts status.
11. Runs smoke tests.
12. Writes a deployment summary to the GitHub Actions step summary.

Image format:

```text
AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY:GITHUB_SHA
```

## Production promotion workflow

File:

```text
.github/workflows/promote-production.yml
```

The production workflow:

1. Runs manually with an `image_tag` input.
2. Uses the GitHub Environment named `production`.
3. Waits for required reviewers if you configure them in GitHub.
4. Authenticates to AWS.
5. Updates kubeconfig for EKS.
6. Creates or updates the production database secret.
7. Deploys the Helm chart to `progressive-delivery-production`.
8. Waits for Argo Rollouts status.
9. Runs smoke tests.
10. Generates release notes from Git tags or recent commits.

## Rollback workflow

File:

```text
.github/workflows/rollback.yml
```

The rollback workflow:

1. Runs manually.
2. Accepts `environment`, `namespace`, and `release_name`.
3. Shows rollout history.
4. Aborts an active rollout if needed.
5. Runs Argo Rollouts undo.
6. Falls back to Helm rollback if Argo undo fails.
7. Shows final rollout status.

## OIDC authentication

The preferred AWS authentication method is GitHub OIDC. The `AWS_ROLE_TO_ASSUME` variable should point to an IAM role created by your Terraform infrastructure. That role should trust GitHub's OIDC provider and allow ECR, EKS, and Kubernetes deployment actions required by this project.

Fallback option: if your account does not support OIDC yet, you can modify the `Configure AWS credentials` step to use `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. OIDC is preferred because it avoids long-lived AWS keys in GitHub.
