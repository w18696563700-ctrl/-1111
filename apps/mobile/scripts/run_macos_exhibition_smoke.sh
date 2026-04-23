#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

. "$REPO_ROOT/infra/scripts/load_formal_cloud_env.sh"

SMOKE_SSH_HOST="${SMOKE_SSH_HOST:-$FORMAL_CLOUD_SSH_HOST}"
SMOKE_SSH_USER="${SMOKE_SSH_USER:-$FORMAL_CLOUD_SSH_USER}"
SMOKE_SSH_PORT="${SMOKE_SSH_PORT:-$FORMAL_CLOUD_SSH_PORT}"
SMOKE_SSH_IDENTITY_FILE="${SMOKE_SSH_IDENTITY_FILE:-}"
SMOKE_SSH_STRICT_HOST_KEY_CHECKING="${SMOKE_SSH_STRICT_HOST_KEY_CHECKING:-accept-new}"

SMOKE_TUNNEL_LOCAL_PORT="${SMOKE_TUNNEL_LOCAL_PORT:-8080}"
SMOKE_TUNNEL_REMOTE_HOST="${SMOKE_TUNNEL_REMOTE_HOST:-127.0.0.1}"
SMOKE_TUNNEL_REMOTE_PORT="${SMOKE_TUNNEL_REMOTE_PORT:-80}"
SMOKE_TUNNEL_WAIT_SECONDS="${SMOKE_TUNNEL_WAIT_SECONDS:-8}"
SMOKE_SKIP_TUNNEL="${SMOKE_SKIP_TUNNEL:-0}"
SMOKE_TUNNEL_ONLY="${SMOKE_TUNNEL_ONLY:-0}"

SMOKE_ACCOUNT_LABEL="${SMOKE_ACCOUNT_LABEL:-}"
SMOKE_LOGIN_MOBILE="${SMOKE_LOGIN_MOBILE:-}"
SMOKE_LOGIN_PASSWORD="${SMOKE_LOGIN_PASSWORD:-}"
SMOKE_LOGIN_OTP="${SMOKE_LOGIN_OTP:-}"

export APP_BFF_BASE_URL="${APP_BFF_BASE_URL:-http://127.0.0.1:${SMOKE_TUNNEL_LOCAL_PORT}/api/app}"
export APP_RUNTIME_ENTRY_MODE="${APP_RUNTIME_ENTRY_MODE:-ssh_tunnel}"

typeset -i tunnel_pid=0

mask_secret() {
  local raw="$1"
  if [[ -z "$raw" ]]; then
    echo ""
    return 0
  fi

  if (( ${#raw} <= 7 )); then
    echo "***"
    return 0
  fi

  echo "${raw[1,3]}****${raw[-4,-1]}"
}

is_local_port_listening() {
  nc -z 127.0.0.1 "$SMOKE_TUNNEL_LOCAL_PORT" >/dev/null 2>&1
}

cleanup() {
  if (( tunnel_pid > 0 )) && kill -0 "$tunnel_pid" >/dev/null 2>&1; then
    echo "Closing SSH tunnel ${SMOKE_TUNNEL_LOCAL_PORT}:${SMOKE_TUNNEL_REMOTE_HOST}:${SMOKE_TUNNEL_REMOTE_PORT}"
    kill "$tunnel_pid" >/dev/null 2>&1 || true
    wait "$tunnel_pid" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

echo "Smoke runtime entry mode: $APP_RUNTIME_ENTRY_MODE"
echo "Smoke base URL: $APP_BFF_BASE_URL"
if [[ -n "$SMOKE_ACCOUNT_LABEL" ]]; then
  echo "Smoke account label: $SMOKE_ACCOUNT_LABEL"
fi
if [[ -n "$SMOKE_LOGIN_MOBILE" ]]; then
  echo "Smoke login mobile: $(mask_secret "$SMOKE_LOGIN_MOBILE")"
fi
if [[ -n "$SMOKE_LOGIN_PASSWORD" ]]; then
  echo "Smoke login password: [set]"
fi
if [[ -n "$SMOKE_LOGIN_OTP" ]]; then
  echo "Smoke login OTP: [set]"
fi

if [[ "$SMOKE_SKIP_TUNNEL" != "1" ]]; then
  if is_local_port_listening; then
    echo "Local port ${SMOKE_TUNNEL_LOCAL_PORT} is already listening." >&2
    echo "Set SMOKE_SKIP_TUNNEL=1 to reuse the existing tunnel, or change SMOKE_TUNNEL_LOCAL_PORT." >&2
    exit 1
  fi

  ssh_command=(
    ssh
    -N
    -p "$SMOKE_SSH_PORT"
    -o "ExitOnForwardFailure=yes"
    -o "ServerAliveInterval=30"
    -o "ServerAliveCountMax=3"
    -o "StrictHostKeyChecking=${SMOKE_SSH_STRICT_HOST_KEY_CHECKING}"
    -L "${SMOKE_TUNNEL_LOCAL_PORT}:${SMOKE_TUNNEL_REMOTE_HOST}:${SMOKE_TUNNEL_REMOTE_PORT}"
  )

  if [[ -n "$SMOKE_SSH_IDENTITY_FILE" ]]; then
    ssh_command+=(-i "$SMOKE_SSH_IDENTITY_FILE")
  fi

  ssh_command+=("${SMOKE_SSH_USER}@${SMOKE_SSH_HOST}")

  echo "Opening SSH tunnel via ${SMOKE_SSH_USER}@${SMOKE_SSH_HOST}:${SMOKE_SSH_PORT}"
  "${ssh_command[@]}" &
  tunnel_pid=$!

  ready=0
  for (( second = 1; second <= SMOKE_TUNNEL_WAIT_SECONDS; second += 1 )); do
    if is_local_port_listening; then
      ready=1
      break
    fi
    if ! kill -0 "$tunnel_pid" >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  if (( ready == 0 )); then
    echo "SSH tunnel did not become ready on 127.0.0.1:${SMOKE_TUNNEL_LOCAL_PORT}." >&2
    exit 1
  fi

  echo "SSH tunnel ready on 127.0.0.1:${SMOKE_TUNNEL_LOCAL_PORT}"
else
  echo "Skipping tunnel startup and reusing APP_BFF_BASE_URL=$APP_BFF_BASE_URL"
fi

if [[ "$SMOKE_TUNNEL_ONLY" == "1" ]]; then
  echo "Tunnel-only mode active. Press Ctrl+C to stop the tunnel."
  if (( tunnel_pid > 0 )); then
    wait "$tunnel_pid"
  else
    while true; do
      sleep 3600
    done
  fi
  exit 0
fi

"$SCRIPT_DIR/run_macos_formal.sh"
