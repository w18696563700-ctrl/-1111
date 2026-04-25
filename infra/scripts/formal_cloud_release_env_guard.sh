#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

. "${REPO_ROOT}/infra/scripts/load_formal_cloud_env.sh"

MODE="${MODE:-check}"
SERVER_APP_ENV_PATH="${SERVER_APP_ENV_PATH:-/srv/apps/server/.env}"
BFF_APP_ENV_PATH="${BFF_APP_ENV_PATH:-/srv/apps/bff/.env}"
RESTART_PM2="${RESTART_PM2:-false}"
SERVER_PM2_NAME="${SERVER_PM2_NAME:-}"
BFF_PM2_NAME="${BFF_PM2_NAME:-}"

case "${MODE}" in
  check|sync)
    ;;
  *)
    echo "Unsupported MODE=${MODE}. Supported: check, sync." >&2
    exit 1
    ;;
esac

ssh_target="${FORMAL_CLOUD_SSH_USER}@${FORMAL_CLOUD_SSH_HOST}"
ssh_port_args=()
if [[ -n "${FORMAL_CLOUD_SSH_PORT}" ]]; then
  ssh_port_args=(-p "${FORMAL_CLOUD_SSH_PORT}")
fi

cat <<'EOF' | ssh "${ssh_port_args[@]}" "${ssh_target}" \
  MODE="${MODE}" \
  SERVER_APP_ENV_PATH="${SERVER_APP_ENV_PATH}" \
  BFF_APP_ENV_PATH="${BFF_APP_ENV_PATH}" \
  RESTART_PM2="${RESTART_PM2}" \
  SERVER_PM2_NAME="${SERVER_PM2_NAME}" \
  BFF_PM2_NAME="${BFF_PM2_NAME}" \
  bash
set -euo pipefail

say() {
  printf '[%s] %s\n' "$1" "$2"
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

server_release_path="$(readlink -f /srv/apps/server/current 2>/dev/null || true)"
bff_release_path="$(readlink -f /srv/apps/bff/current 2>/dev/null || true)"

[[ -n "${server_release_path}" ]] || fail "Unable to resolve /srv/apps/server/current"
[[ -n "${bff_release_path}" ]] || fail "Unable to resolve /srv/apps/bff/current"
[[ -f "${SERVER_APP_ENV_PATH}" ]] || fail "Missing approved server env snapshot: ${SERVER_APP_ENV_PATH}"
[[ -f "${BFF_APP_ENV_PATH}" ]] || fail "Missing approved bff env snapshot: ${BFF_APP_ENV_PATH}"
[[ -f "${server_release_path}/.env" ]] || fail "Missing current server release .env: ${server_release_path}/.env"
[[ -f "${bff_release_path}/.env" ]] || fail "Missing current bff release .env: ${bff_release_path}/.env"

env_subset_ok() {
  local source_file="$1"
  local target_file="$2"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -n "${line}" ]] || continue
    [[ "${line}" == \#* ]] && continue
    grep -Fqx "${line}" "${target_file}" || return 1
  done < "${source_file}"
}

if [[ "${MODE}" == "check" ]]; then
  env_subset_ok "${SERVER_APP_ENV_PATH}" "${server_release_path}/.env" ||
    fail "Server release env does not fully cover the approved snapshot: ${server_release_path}/.env"
  env_subset_ok "${BFF_APP_ENV_PATH}" "${bff_release_path}/.env" ||
    fail "BFF release env does not fully cover the approved snapshot: ${bff_release_path}/.env"
  say PASS "Current release env files are aligned with approved app env snapshots."
  exit 0
fi

cp "${SERVER_APP_ENV_PATH}" "${server_release_path}/.env"
cp "${BFF_APP_ENV_PATH}" "${bff_release_path}/.env"

env_subset_ok "${SERVER_APP_ENV_PATH}" "${server_release_path}/.env" || fail "Server release env sync did not converge."
env_subset_ok "${BFF_APP_ENV_PATH}" "${bff_release_path}/.env" || fail "BFF release env sync did not converge."

if grep -q '^QWEATHER_ENABLED=true$' "${SERVER_APP_ENV_PATH}"; then
  grep -q '^QWEATHER_API_HOST=' "${server_release_path}/.env" || fail "Server release env still misses QWEATHER_API_HOST after sync."
  grep -q '^QWEATHER_API_KEY=' "${server_release_path}/.env" || fail "Server release env still misses QWEATHER_API_KEY after sync."
fi

if [[ "${RESTART_PM2}" == "true" ]]; then
  [[ -n "${SERVER_PM2_NAME}" ]] || fail "RESTART_PM2=true requires SERVER_PM2_NAME."
  [[ -n "${BFF_PM2_NAME}" ]] || fail "RESTART_PM2=true requires BFF_PM2_NAME."
  pm2 restart "${SERVER_PM2_NAME}" >/dev/null
  pm2 restart "${BFF_PM2_NAME}" >/dev/null
  say PASS "Synced release env files and restarted PM2 processes."
  exit 0
fi

say PASS "Synced release env files. PM2 restart was not requested."
EOF
