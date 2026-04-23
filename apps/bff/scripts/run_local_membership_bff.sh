#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

export NODE_ENV="${NODE_ENV:-development}"
if [[ "$NODE_ENV" == "production" ]]; then
  echo "Refusing to start local-only membership BFF with NODE_ENV=production." >&2
  exit 1
fi

export APP_NAME="${APP_NAME:-exhibition-bff-local-membership}"
export RUNTIME_ENTRY_LABEL="${RUNTIME_ENTRY_LABEL:-local-membership-bff}"
export PORT="${PORT:-3000}"
export SERVER_BASE_URL="${SERVER_BASE_URL:-http://127.0.0.1:3001}"
export SERVER_GET_TIMEOUT_MS="${SERVER_GET_TIMEOUT_MS:-5000}"
export SERVER_POST_TIMEOUT_MS="${SERVER_POST_TIMEOUT_MS:-10000}"

cd "$APP_DIR"

echo "Starting LOCAL-ONLY membership BFF on :$PORT"
echo "Runtime entry: $RUNTIME_ENTRY_LABEL"
echo "Server upstream: $SERVER_BASE_URL"

exec npm run start:dev
