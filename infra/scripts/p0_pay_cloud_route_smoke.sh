#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${P0_PAY_CLOUD_BASE_URL:-http://127.0.0.1:8080}"

request_status() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  if [ "${method}" = "POST" ]; then
    curl -sS -o /tmp/p0_pay_cloud_smoke_body.json -w "%{http_code}" \
      -m 5 \
      -X POST \
      "${BASE_URL}${path}" \
      -H 'content-type: application/json' \
      --data "${body}"
  else
    curl -sS -o /tmp/p0_pay_cloud_smoke_body.json -w "%{http_code}" \
      -m 5 \
      "${BASE_URL}${path}"
  fi
}

assert_status() {
  local label="$1"
  local expected="$2"
  local method="$3"
  local path="$4"
  local body="${5:-}"
  local actual
  actual="$(request_status "${method}" "${path}" "${body}")"
  if [ "${actual}" != "${expected}" ]; then
    echo "[fail] ${label}: expected ${expected}, got ${actual}"
    sed -n '1,8p' /tmp/p0_pay_cloud_smoke_body.json || true
    exit 1
  fi
  echo "[ok] ${label}: ${actual}"
}

echo "[info] P0-Pay cloud route smoke base: ${BASE_URL}"

assert_status \
  "exhibition home ingress baseline" \
  "200" \
  "GET" \
  "/api/app/exhibition/home"

assert_status \
  "trade-task summary route mounted and auth-gated" \
  "401" \
  "GET" \
  "/api/app/exhibition/trade-tasks/probe/p0-pay-summary"

assert_status \
  "trade-task create route mounted and payload-gated" \
  "400" \
  "POST" \
  "/api/app/exhibition/trade-tasks" \
  "{}"

assert_status \
  "state action route mounted and payload-gated" \
  "400" \
  "POST" \
  "/api/app/exhibition/trade-tasks/probe/p0-pay-actions/release-non-winning" \
  "{}"

echo "[done] P0-Pay cloud route family is mounted with controlled gates."
