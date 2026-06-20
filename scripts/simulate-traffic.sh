#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:8000}"
REQUESTS="${2:-120}"
SLEEP_SECONDS="${3:-1}"

echo "Sending ${REQUESTS} requests to ${BASE_URL}/api/message"

for i in $(seq 1 "${REQUESTS}"); do
  status="$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/api/message" || true)"
  echo "request=${i} status=${status}"
  sleep "${SLEEP_SECONDS}"
done

echo "Traffic simulation finished."
