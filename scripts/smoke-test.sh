#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://localhost:8000}"

echo "Running smoke tests against ${BASE_URL}"

echo "Checking /health"
curl -fsS "${BASE_URL}/health"
echo

echo "Checking /version"
curl -fsS "${BASE_URL}/version"
echo

echo "Checking /api/message"
curl -fsS "${BASE_URL}/api/message"
echo

echo "Smoke tests passed."
