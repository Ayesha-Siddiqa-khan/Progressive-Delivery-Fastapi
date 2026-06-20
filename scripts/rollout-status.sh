#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-progressive-delivery-staging}"
ROLLOUT="${2:-progressive-app}"

echo "Watching rollout ${ROLLOUT} in namespace ${NAMESPACE}"
kubectl argo rollouts get rollout "${ROLLOUT}" -n "${NAMESPACE}" --watch
