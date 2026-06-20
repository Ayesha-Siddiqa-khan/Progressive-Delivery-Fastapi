# Prometheus Queries

These queries assume Prometheus adds `namespace` and `service` labels from the Kubernetes ServiceMonitor. If your Prometheus setup uses different labels, adjust the selectors in the Helm `AnalysisTemplate`.

## Request rate

```promql
sum(rate(http_requests_total{namespace="progressive-delivery-staging", service="progressive-app"}[2m]))
```

## Error rate

```promql
sum(rate(http_errors_total{namespace="progressive-delivery-staging", service="progressive-app"}[2m]))
/
clamp_min(sum(rate(http_requests_total{namespace="progressive-delivery-staging", service="progressive-app"}[2m])), 1)
```

## P95 latency

```promql
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket{namespace="progressive-delivery-staging", service="progressive-app"}[2m])) by (le)
)
```

## Current app version if labels are available

```promql
sum by (app_version) (rate(http_requests_total{namespace="progressive-delivery-staging", service="progressive-app"}[2m]))
```

## Rollout health placeholder

If you scrape Argo Rollouts controller metrics, add controller-specific health queries here. The exact metric names depend on your Argo Rollouts and Prometheus installation.
