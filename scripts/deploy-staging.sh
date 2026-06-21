#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-progressive-delivery-staging}"
RELEASE_NAME="${RELEASE_NAME:-progressive-app}"
IMAGE_REPOSITORY="${IMAGE_REPOSITORY:-placeholder}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Deploying ${RELEASE_NAME} to staging namespace ${NAMESPACE}"
echo "Image: ${IMAGE_REPOSITORY}:${IMAGE_TAG}"

if [ -n "${DATABASE_URL:-}" ]; then
  echo "Creating or updating database secret without printing the secret value"
  kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret generic progressive-app-db \
    --namespace "${NAMESPACE}" \
    --from-literal=DATABASE_URL="${DATABASE_URL}" \
    --dry-run=client -o yaml | kubectl apply -f -
else
  echo "DATABASE_URL is not set. The chart will reference progressive-app-db, but the app can still start if the secret is optional."
fi

helm upgrade --install "${RELEASE_NAME}" ./helm/progressive-app \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-staging.yaml \
  --set namespace.name="${NAMESPACE}" \
  --set image.repository="${IMAGE_REPOSITORY}" \
  --set image.tag="${IMAGE_TAG}"

echo "Waiting for deployment rollout status"
kubectl rollout status "deployment/${RELEASE_NAME}" -n "${NAMESPACE}" --timeout 10m
