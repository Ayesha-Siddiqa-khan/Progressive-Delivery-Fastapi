# Kubernetes YAML Explanation

This project uses Helm templates so the same chart can deploy to staging and production.

## Namespace

File:

```text
helm/progressive-app/templates/namespace.yaml
```

Creates the target namespace from `namespace.name`.

## ServiceAccount

File:

```text
helm/progressive-app/templates/serviceaccount.yaml
```

Creates a Kubernetes ServiceAccount for the app pods.

## ConfigMap

File:

```text
helm/progressive-app/templates/configmap.yaml
```

Stores non-secret app configuration:

- `APP_VERSION`
- `RELEASE_MODE`

## Secret

File:

```text
helm/progressive-app/templates/secret-example.yaml
```

Shows the shape of the database secret with a placeholder value only. The real secret is created by GitHub Actions:

```bash
kubectl create secret generic progressive-app-db \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Service

File:

```text
helm/progressive-app/templates/service.yaml
```

Creates the active Service named `progressive-app`. In blue-green mode it also creates a preview Service named `progressive-app-preview`.

## Ingress

File:

```text
helm/progressive-app/templates/ingress.yaml
```

Exposes the app through NGINX Ingress or AWS ALB Ingress. Switch with:

```yaml
ingress:
  className: alb
  alb:
    enabled: true
```

## Rollout

Files:

```text
helm/progressive-app/templates/rollout-canary.yaml
helm/progressive-app/templates/rollout-bluegreen.yaml
```

The chart creates an Argo Rollout instead of a Kubernetes Deployment. Choose the strategy with:

```yaml
rollout:
  strategy: canary
```

or:

```yaml
rollout:
  strategy: bluegreen
```

## AnalysisTemplate

File:

```text
helm/progressive-app/templates/analysis-template.yaml
```

Defines Prometheus checks for:

- Error rate.
- p95 latency.

If metrics are unhealthy, Argo Rollouts fails the rollout.

## ServiceMonitor

File:

```text
helm/progressive-app/templates/servicemonitor.yaml
```

Lets Prometheus scrape:

```text
/metrics
```

from the app Service on the `http` port every 15 seconds.
