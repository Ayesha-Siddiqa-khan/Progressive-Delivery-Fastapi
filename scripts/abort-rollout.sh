#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:-progressive-delivery-staging}"
ROLLOUT="${2:-progressive-app}"

echo "Aborting rollout ${ROLLOUT} in namespace ${NAMESPACE}"
kubectl argo rollouts abort "${ROLLOUT}" -n "${NAMESPACE}"
