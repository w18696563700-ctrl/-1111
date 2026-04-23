#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$APP_DIR/../.." && pwd)"
ENV_FILE="${ROOT_DIR}/infra/env/.env.example"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

export NODE_ENV="${NODE_ENV:-development}"
if [[ "$NODE_ENV" == "production" ]]; then
  echo "Refusing to start local-only membership Server with NODE_ENV=production." >&2
  exit 1
fi

export APP_NAME="${APP_NAME:-exhibition-server-local-membership}"
export RUNTIME_ENTRY_LABEL="${RUNTIME_ENTRY_LABEL:-local-membership-server}"
export PORT="${PORT:-3001}"

export POSTGRES_HOST="${POSTGRES_HOST:-127.0.0.1}"
export POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export POSTGRES_DB="${POSTGRES_DB:-exhibition_app}"
export POSTGRES_USER="${POSTGRES_USER:-exhibition}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-exhibition_dev}"

export REDIS_ENABLED="${REDIS_ENABLED:-true}"
export REDIS_HOST="${REDIS_HOST:-127.0.0.1}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export REDIS_DB="${REDIS_DB:-0}"

export MINIO_ROOT_USER="${MINIO_ROOT_USER:-minioadmin}"
export MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-minioadmin}"
export MINIO_PORT="${MINIO_PORT:-9000}"
export UPLOAD_BUCKET="${UPLOAD_BUCKET:-exhibition-uploads}"
export UPLOAD_S3_ENDPOINT="${UPLOAD_S3_ENDPOINT:-http://127.0.0.1:${MINIO_PORT}}"
export UPLOAD_S3_ACCESS_KEY_ID="${UPLOAD_S3_ACCESS_KEY_ID:-${MINIO_ROOT_USER}}"
export UPLOAD_S3_SECRET_ACCESS_KEY="${UPLOAD_S3_SECRET_ACCESS_KEY:-${MINIO_ROOT_PASSWORD}}"
export UPLOAD_S3_FORCE_PATH_STYLE="${UPLOAD_S3_FORCE_PATH_STYLE:-true}"

export AUTH_WHITELIST_TEST_SESSION_ENABLED="${AUTH_WHITELIST_TEST_SESSION_ENABLED:-true}"
export SESSION_SIGNING_SECRET="${SESSION_SIGNING_SECRET:-dev-session-signing-secret}"
export SESSION_OPAQUE_VERIFIER_SECRET="${SESSION_OPAQUE_VERIFIER_SECRET:-dev-session-opaque-secret}"
export AUTH_ACCESS_TOKEN_SECRET="${AUTH_ACCESS_TOKEN_SECRET:-dev-auth-access-secret}"
export JWT_ACCESS_TOKEN_SECRET="${JWT_ACCESS_TOKEN_SECRET:-dev-jwt-access-secret}"
export JWT_REFRESH_TOKEN_SECRET="${JWT_REFRESH_TOKEN_SECRET:-dev-jwt-refresh-secret}"
export SESSION_REFRESH_TOKEN_PEPPER="${SESSION_REFRESH_TOKEN_PEPPER:-dev-refresh-pepper}"
export AUTH_PASSWORD_PEPPER="${AUTH_PASSWORD_PEPPER:-dev-password-pepper}"

cd "$APP_DIR"

echo "Starting LOCAL-ONLY membership Server on :$PORT"
echo "Runtime entry: ${RUNTIME_ENTRY_LABEL}"
echo "Postgres: ${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
echo "Redis: ${REDIS_HOST}:${REDIS_PORT}/${REDIS_DB}"
echo "Upload transport: ${UPLOAD_S3_ENDPOINT}"
echo "Whitelist test session: ${AUTH_WHITELIST_TEST_SESSION_ENABLED}"

exec npm run start:dev
