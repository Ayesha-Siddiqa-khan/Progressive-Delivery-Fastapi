#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-progressive-delivery-staging}"
ROLLOUT="${2:-progressive-app}"
REVISION="${3:-}"

echo "Showing rollout history for ${ROLLOUT} in namespace ${NAMESPACE}"
kubectl argo rollouts history rollout "${ROLLOUT}" -n "${NAMESPACE}" || true

if [ "${CONFIRM_ROLLBACK:-no}" != "yes" ]; then
  echo "Safety check: set CONFIRM_ROLLBACK=yes to perform the rollback."
  echo "Example: CONFIRM_ROLLBACK=yes ./scripts/rollback.sh ${NAMESPACE} ${ROLLOUT}"
  exit 1
fi

echo "Aborting any active rollout before rollback"
kubectl argo rollouts abort "${ROLLOUT}" -n "${NAMESPACE}" || true

if [ -n "${REVISION}" ]; then
  echo "Rolling back ${ROLLOUT} to revision ${REVISION}"
  kubectl argo rollouts undo "${ROLLOUT}" -n "${NAMESPACE}" --to-revision="${REVISION}"
else
  echo "Rolling back ${ROLLOUT} to the previous revision"
  kubectl argo rollouts undo "${ROLLOUT}" -n "${NAMESPACE}"
fi

echo "Final rollout status"
kubectl argo rollouts status "rollout/${ROLLOUT}" -n "${NAMESPACE}" --timeout 10m
