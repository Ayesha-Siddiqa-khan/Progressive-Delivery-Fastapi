# Argo Rollouts Installation Notes

This project expects Argo Rollouts to be installed before you deploy the Helm chart.

Install the controller:

```bash
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl rollout status deployment/argo-rollouts -n argo-rollouts --timeout=180s
```

Install the kubectl plugin on Linux:

```bash
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x kubectl-argo-rollouts-linux-amd64
sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

Verify:

```bash
kubectl argo rollouts version
```

Useful commands:

```bash
kubectl argo rollouts get rollout progressive-app -n progressive-delivery-staging --watch
kubectl argo rollouts promote progressive-app -n progressive-delivery-staging
kubectl argo rollouts abort progressive-app -n progressive-delivery-staging
kubectl argo rollouts undo progressive-app -n progressive-delivery-staging
```
