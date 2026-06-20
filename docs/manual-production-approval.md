# Manual Production Approval

The production workflow uses the GitHub Environment named:

```text
production
```

GitHub Environments can require a human reviewer before a deployment job runs.

## How to configure it

1. Open the GitHub repository.
2. Go to `Settings`.
3. Open `Environments`.
4. Create an environment named `production`.
5. Add required reviewers.
6. Add production-only secrets if you want environment-scoped secrets.

## Why it matters

Manual approval is common in real production pipelines because it creates a clear control point before customer-facing changes.

This project combines manual approval with automated rollout safety:

- A human approves production promotion.
- Argo Rollouts still checks metrics during deployment.
- Prometheus analysis can stop a bad release.
