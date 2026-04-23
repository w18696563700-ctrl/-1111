#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf '%s\n' "$1" >&2
  return 1 2>/dev/null || exit 1
}

if [[ -z "${REPO_ROOT:-}" ]]; then
  fail "REPO_ROOT is required before sourcing infra/scripts/load_formal_cloud_env.sh."
fi

FORMAL_CLOUD_ENV_FILE="${FORMAL_CLOUD_ENV_FILE:-${REPO_ROOT}/infra/env/formal_cloud_target.env}"

if [[ ! -f "${FORMAL_CLOUD_ENV_FILE}" ]]; then
  fail "Formal cloud target file not found: ${FORMAL_CLOUD_ENV_FILE}"
fi

set -a
# shellcheck disable=SC1090
. "${FORMAL_CLOUD_ENV_FILE}"
set +a

FORMAL_CLOUD_SCHEME="${FORMAL_CLOUD_SCHEME:-http}"
FORMAL_CLOUD_HOST="${FORMAL_CLOUD_HOST:-}"
FORMAL_CLOUD_PORT="${FORMAL_CLOUD_PORT:-}"
FORMAL_CLOUD_SSH_USER="${FORMAL_CLOUD_SSH_USER:-root}"
FORMAL_CLOUD_SSH_PORT="${FORMAL_CLOUD_SSH_PORT:-22}"

if [[ -z "${FORMAL_CLOUD_HOST}" ]]; then
  fail "FORMAL_CLOUD_HOST must be set in ${FORMAL_CLOUD_ENV_FILE} or the current environment."
fi

FORMAL_CLOUD_ORIGIN="${FORMAL_CLOUD_SCHEME}://${FORMAL_CLOUD_HOST}"
if [[ -n "${FORMAL_CLOUD_PORT}" ]]; then
  FORMAL_CLOUD_ORIGIN="${FORMAL_CLOUD_ORIGIN}:${FORMAL_CLOUD_PORT}"
fi

FORMAL_CLOUD_BFF_BASE_URL="${FORMAL_CLOUD_BFF_BASE_URL:-${FORMAL_CLOUD_ORIGIN}/api/app}"
FORMAL_CLOUD_SERVER_ADMIN_BASE_URL="${FORMAL_CLOUD_SERVER_ADMIN_BASE_URL:-${FORMAL_CLOUD_ORIGIN}/server/admin}"
FORMAL_CLOUD_SSH_HOST="${FORMAL_CLOUD_SSH_HOST:-${FORMAL_CLOUD_HOST}}"

export FORMAL_CLOUD_ENV_FILE
export FORMAL_CLOUD_SCHEME
export FORMAL_CLOUD_HOST
export FORMAL_CLOUD_PORT
export FORMAL_CLOUD_ORIGIN
export FORMAL_CLOUD_BFF_BASE_URL
export FORMAL_CLOUD_SERVER_ADMIN_BASE_URL
export FORMAL_CLOUD_SSH_HOST
export FORMAL_CLOUD_SSH_USER
export FORMAL_CLOUD_SSH_PORT
