#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-progressive-delivery-production}"
RELEASE_NAME="${RELEASE_NAME:-progressive-app}"
IMAGE_REPOSITORY="${IMAGE_REPOSITORY:-placeholder}"
IMAGE_TAG="${IMAGE_TAG:?Set IMAGE_TAG to the tested image tag before deploying production.}"
PRODUCTION_HOST="${PRODUCTION_HOST:-progressive-app.example.com}"

echo "Deploying ${RELEASE_NAME} to production namespace ${NAMESPACE}"
echo "Image: ${IMAGE_REPOSITORY}:${IMAGE_TAG}"
echo "Host: ${PRODUCTION_HOST}"

if [ -n "${DATABASE_URL:-}" ]; then
  echo "Creating or updating database secret without printing the secret value"
  kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
  kubectl create secret generic progressive-app-db \
    --namespace "${NAMESPACE}" \
    --from-literal=DATABASE_URL="${DATABASE_URL}" \
    --dry-run=client -o yaml | kubectl apply -f -
else
  echo "DATABASE_URL is not set. Configure it before a real production deployment."
fi

helm upgrade --install "${RELEASE_NAME}" ./helm/progressive-app \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  -f helm/progressive-app/values.yaml \
  -f helm/progressive-app/values-production.yaml \
  --set namespace.name="${NAMESPACE}" \
  --set image.repository="${IMAGE_REPOSITORY}" \
  --set image.tag="${IMAGE_TAG}" \
  --set ingress.host="${PRODUCTION_HOST}"

echo "Waiting for rollout status"
kubectl argo rollouts status "rollout/${RELEASE_NAME}" -n "${NAMESPACE}" --timeout 15m
