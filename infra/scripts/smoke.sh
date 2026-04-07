#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/infra/env/.env.example"

if [ -f "${ENV_FILE}" ]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

require_port() {
  local name="$1"
  local port="$2"
  timeout 2 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${port}" >/dev/null 2>&1
  echo "[ok] ${name} port ${port} is reachable"
}

optional_http() {
  local label="$1"
  local url="$2"
  if curl -fsS --max-time 2 "${url}" >/dev/null 2>&1; then
    echo "[ok] ${label} ${url}"
  else
    echo "[warn] ${label} ${url} is not ready yet"
  fi
}

docker compose -f "${ROOT_DIR}/infra/docker-compose.yml" --env-file "${ENV_FILE}" ps

require_port "postgres" "${POSTGRES_PORT:-5432}"
require_port "redis" "${REDIS_PORT:-6379}"
optional_http "minio-live" "http://127.0.0.1:${MINIO_PORT:-9000}/minio/health/live"
optional_http "bff-live" "http://127.0.0.1:${BFF_PORT:-3000}/health/live"
optional_http "server-live" "http://127.0.0.1:${SERVER_PORT:-3001}/health/live"

echo "[done] phase0 smoke completed"
