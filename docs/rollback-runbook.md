# Rollback Runbook

Use this runbook when a deployment is unhealthy or when you need to demonstrate rollback for your portfolio.

## Automatic rollback with Argo Rollouts

Argo Rollouts runs Prometheus analysis during the canary rollout. If the analysis fails, the rollout stops and the stable ReplicaSet continues serving traffic.

This project checks:

- Error rate greater than 5 percent.
- p95 latency greater than 500ms.

## Metric-based rollback

The FastAPI app exposes metrics at:

```text
/metrics
```

Prometheus scrapes the app. Argo Rollouts queries Prometheus through the `AnalysisTemplate`.

If the query result violates the success condition, the rollout fails.

## Inspect rollout status

```bash
kubectl argo rollouts get rollout progressive-app -n progressive-delivery-staging --watch
```

## Inspect rollout history

```bash
kubectl argo rollouts history rollout progressive-app -n progressive-delivery-staging
```

## Abort a bad rollout

```bash
kubectl argo rollouts abort progressive-app -n progressive-delivery-staging
```

## Promote a paused healthy rollout

```bash
kubectl argo rollouts promote progressive-app -n progressive-delivery-staging
```

## Describe rollout details

```bash
kubectl describe rollout progressive-app -n progressive-delivery-staging
```

## Roll back from the command line

```bash
CONFIRM_ROLLBACK=yes ./scripts/rollback.sh progressive-delivery-staging progressive-app
```

Roll back to a specific revision:

```bash
CONFIRM_ROLLBACK=yes ./scripts/rollback.sh progressive-delivery-staging progressive-app 3
```

## Roll back with GitHub Actions

1. Open GitHub Actions.
2. Select `Rollback`.
3. Click `Run workflow`.
4. Choose `staging` or `production`.
5. Enter the namespace.
6. Enter `progressive-app` as the release name.
7. Run the workflow.

## Debug failed analysis

List AnalysisRuns:

```bash
kubectl get analysisrun -n progressive-delivery-staging
```

Describe the failed AnalysisRun:

```bash
kubectl describe analysisrun ANALYSIS_RUN_NAME -n progressive-delivery-staging
```

Check Prometheus manually using the queries in:

```text
k8s/prometheus/prometheus-queries.md
```
