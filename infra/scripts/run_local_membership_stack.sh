#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/infra/env/.env.example"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

STACK_MODE="${STACK_MODE:-app}"
STACK_SKIP_INFRA="${STACK_SKIP_INFRA:-0}"
STACK_SKIP_MOBILE="${STACK_SKIP_MOBILE:-0}"
STACK_SERVER_PORT="${STACK_SERVER_PORT:-3001}"
STACK_BFF_PORT="${STACK_BFF_PORT:-3000}"
STACK_RUNTIME_ENTRY_LABEL="${STACK_RUNTIME_ENTRY_LABEL:-local-membership-stack}"
STACK_LOG_DIR="${STACK_LOG_DIR:-${ROOT_DIR}/.tmp/membership-local}"
FLUTTER_DEVICE="${FLUTTER_DEVICE:-macos}"

mkdir -p "$STACK_LOG_DIR"

SERVER_LOG_FILE="${STACK_LOG_DIR}/server.log"
BFF_LOG_FILE="${STACK_LOG_DIR}/bff.log"

server_pid=0
bff_pid=0

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "Missing required command: $name" >&2
    exit 1
  fi
}

port_is_ready() {
  local port="$1"
  nc -z 127.0.0.1 "$port" >/dev/null 2>&1
}

wait_for_port() {
  local label="$1"
  local port="$2"
  local timeout_seconds="${3:-30}"
  local second

  for ((second = 1; second <= timeout_seconds; second += 1)); do
    if port_is_ready "$port"; then
      echo "$label is ready on 127.0.0.1:$port"
      return 0
    fi
    sleep 1
  done

  echo "$label did not become ready on 127.0.0.1:$port" >&2
  return 1
}

cleanup() {
  if (( bff_pid > 0 )) && kill -0 "$bff_pid" >/dev/null 2>&1; then
    kill "$bff_pid" >/dev/null 2>&1 || true
    wait "$bff_pid" 2>/dev/null || true
  fi

  if (( server_pid > 0 )) && kill -0 "$server_pid" >/dev/null 2>&1; then
    kill "$server_pid" >/dev/null 2>&1 || true
    wait "$server_pid" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

require_command nc
require_command npm

echo "Starting LOCAL-ONLY membership stack"
echo "Runtime entry prefix: ${STACK_RUNTIME_ENTRY_LABEL}"

if [[ "$STACK_SKIP_INFRA" != "1" ]]; then
  if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
    if port_is_ready "${POSTGRES_PORT:-5432}"; then
      echo "Docker daemon is unavailable; falling back to local Postgres without docker infra."
      echo "Redis and MinIO will be skipped for the membership local stack."
      STACK_SKIP_INFRA="1"
      export REDIS_ENABLED="${REDIS_ENABLED:-false}"
    else
      echo "Docker daemon is unavailable and no local Postgres is listening on ${POSTGRES_PORT:-5432}." >&2
      echo "Start Docker Desktop or provide a local Postgres before running the membership local stack." >&2
      exit 1
    fi
  fi
fi

if [[ "$STACK_SKIP_MOBILE" != "1" ]]; then
  require_command flutter
fi

if [[ "$STACK_SKIP_INFRA" != "1" ]]; then
  echo "Starting local infra dependencies with docker compose"
  docker compose -f "${ROOT_DIR}/infra/docker-compose.yml" \
    --env-file "${ENV_FILE}" \
    up -d postgres redis minio

  wait_for_port "Postgres" "${POSTGRES_PORT:-5432}" 30
  wait_for_port "Redis" "${REDIS_PORT:-6379}" 30
  wait_for_port "MinIO" "${MINIO_PORT:-9000}" 30
else
  echo "Skipping infra startup"
  if [[ -z "${REDIS_ENABLED:-}" ]] && ! port_is_ready "${REDIS_PORT:-6379}"; then
    export REDIS_ENABLED=false
  fi
fi

echo "Starting local Server (log: ${SERVER_LOG_FILE})"
(
  cd "$ROOT_DIR"
  export RUNTIME_ENTRY_LABEL="${STACK_RUNTIME_ENTRY_LABEL}-server"
  exec bash apps/server/scripts/run_local_membership_server.sh
) >"$SERVER_LOG_FILE" 2>&1 &
server_pid=$!

wait_for_port "Server" "$STACK_SERVER_PORT" 45

echo "Starting local BFF (log: ${BFF_LOG_FILE})"
(
  cd "$ROOT_DIR"
  export RUNTIME_ENTRY_LABEL="${STACK_RUNTIME_ENTRY_LABEL}-bff"
  export SERVER_BASE_URL="http://127.0.0.1:${STACK_SERVER_PORT}"
  export PORT="$STACK_BFF_PORT"
  exec bash apps/bff/scripts/run_local_membership_bff.sh
) >"$BFF_LOG_FILE" 2>&1 &
bff_pid=$!

wait_for_port "BFF" "$STACK_BFF_PORT" 45

echo "Server log: $SERVER_LOG_FILE"
echo "BFF log: $BFF_LOG_FILE"

if [[ "$STACK_SKIP_MOBILE" == "1" ]]; then
  echo "STACK_SKIP_MOBILE=1, services will keep running until this process exits."
  echo "Press Ctrl+C to stop Server and BFF."
  while true; do
    sleep 3600
  done
fi

export APP_BFF_BASE_URL="http://127.0.0.1:${STACK_BFF_PORT}/api/app"
export FLUTTER_DEVICE

if [[ "$STACK_MODE" == "smoke" ]]; then
  export LOCAL_MEMBERSHIP_MODE=smoke
  exec bash "${ROOT_DIR}/apps/mobile/scripts/run_local_membership_app.sh"
fi

exec bash "${ROOT_DIR}/apps/mobile/scripts/run_local_membership_app.sh"
