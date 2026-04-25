#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"

cd "$APP_DIR"

. "$REPO_ROOT/infra/scripts/load_formal_cloud_env.sh"

APP_TARGET="${APP_TARGET:-lib/main.dart}"
APP_RUNTIME_ENTRY_MODE_VALUE="${APP_RUNTIME_ENTRY_MODE:-ssh_tunnel}"
APP_FORMAL_CLOUD_BFF_BASE_URL_VALUE="${APP_FORMAL_CLOUD_BFF_BASE_URL:-$FORMAL_CLOUD_BFF_BASE_URL}"
APP_BFF_ACTOR_ID_VALUE="${APP_BFF_ACTOR_ID:-}"
APP_BFF_USER_ID_VALUE="${APP_BFF_USER_ID:-}"
APP_INITIAL_ROUTE_VALUE="${APP_INITIAL_ROUTE:-}"
APP_BOOTSTRAP_ACCESS_TOKEN_VALUE="${APP_BOOTSTRAP_ACCESS_TOKEN:-}"
APP_BOOTSTRAP_REFRESH_TOKEN_VALUE="${APP_BOOTSTRAP_REFRESH_TOKEN:-}"
APP_BOOTSTRAP_EXPIRES_IN_SECONDS_VALUE="${APP_BOOTSTRAP_EXPIRES_IN_SECONDS:-}"
APP_BOOTSTRAP_DEVICE_ID_VALUE="${APP_BOOTSTRAP_DEVICE_ID:-}"
APP_ENABLE_PERSISTED_SESSION_VALUE="${APP_ENABLE_PERSISTED_SESSION:-true}"
APP_SESSION_STORAGE_NAMESPACE_VALUE="${APP_SESSION_STORAGE_NAMESPACE:-formal}"
APP_SKIP_KILL_EXISTING_MOBILE_VALUE="${APP_SKIP_KILL_EXISTING_MOBILE:-}"

ENTRY_LABEL=""
DEFAULT_BASE_URL=""
GUARD_HOST=""
GUARD_PORT=""
GUARD_HINT=""

configure_entry_mode() {
  case "$1" in
    cloud)
      ENTRY_LABEL="正式云端"
      DEFAULT_BASE_URL="$FORMAL_CLOUD_BFF_BASE_URL"
      ;;
    ssh_tunnel)
      ENTRY_LABEL="SSH隧道"
      DEFAULT_BASE_URL="http://127.0.0.1:8080/api/app"
      GUARD_HOST="127.0.0.1"
      GUARD_PORT="8080"
      GUARD_HINT="未检测到 127.0.0.1:8080 的 SSH 隧道。请先建立隧道，或在明确需要时改用 run_macos_cloud.sh。"
      ;;
    local_dev)
      echo "APP_RUNTIME_ENTRY_MODE=local_dev is disabled. Flutter App must run against the Aliyun BFF through the approved SSH tunnel on 127.0.0.1:8080." >&2
      exit 1
      ;;
    custom)
      ENTRY_LABEL="自定义入口"
      ;;
    *)
      echo "Unsupported APP_RUNTIME_ENTRY_MODE=$1. Supported: cloud, ssh_tunnel, custom." >&2
      exit 1
      ;;
  esac
}

ensure_guard_endpoint_ready() {
  local host="$1"
  local port="$2"
  local hint="$3"
  local nc_bin
  nc_bin="$(command -v nc || true)"
  if [[ -z "$nc_bin" ]]; then
    return 0
  fi
  if ! "$nc_bin" -z "$host" "$port" >/dev/null 2>&1; then
    echo "$hint" >&2
    exit 1
  fi
}

ensure_base_url_allowed() {
  local base_url="$1"
  case "$base_url" in
    http://127.0.0.1:8080/*|http://localhost:8080/*|https://127.0.0.1:8080/*|https://localhost:8080/*)
      return 0
      ;;
    http://127.0.0.1/*|http://localhost/*|https://127.0.0.1/*|https://localhost/*|http://127.0.0.1:*|http://localhost:*|https://127.0.0.1:*|https://localhost:*)
      echo "Local loopback BFF URLs other than 127.0.0.1:8080 are disabled. Use the approved SSH tunnel or an explicit cloud URL." >&2
      exit 1
      ;;
  esac
}

configure_entry_mode "$APP_RUNTIME_ENTRY_MODE_VALUE"
APP_BFF_BASE_URL_VALUE="${APP_BFF_BASE_URL:-$DEFAULT_BASE_URL}"
ensure_base_url_allowed "$APP_BFF_BASE_URL_VALUE"

if [[ "$APP_RUNTIME_ENTRY_MODE_VALUE" == "custom" && -z "$APP_BFF_BASE_URL_VALUE" ]]; then
  echo "APP_RUNTIME_ENTRY_MODE=custom requires APP_BFF_BASE_URL to be set explicitly." >&2
  exit 1
fi

if [[ -z "${APP_BFF_BASE_URL:-}" && -n "$GUARD_HOST" ]]; then
  ensure_guard_endpoint_ready "$GUARD_HOST" "$GUARD_PORT" "$GUARD_HINT"
fi

BUILD_ARGS=(
  "build"
  "macos"
  "--debug"
  "--target"
  "$APP_TARGET"
  "--dart-define=APP_FORMAL_CLOUD_BFF_BASE_URL=$APP_FORMAL_CLOUD_BFF_BASE_URL_VALUE"
  "--dart-define=APP_BFF_BASE_URL=$APP_BFF_BASE_URL_VALUE"
  "--dart-define=APP_RUNTIME_ENTRY_MODE=$APP_RUNTIME_ENTRY_MODE_VALUE"
  "--dart-define=APP_ENABLE_PERSISTED_SESSION=$APP_ENABLE_PERSISTED_SESSION_VALUE"
  "--dart-define=APP_SESSION_STORAGE_NAMESPACE=$APP_SESSION_STORAGE_NAMESPACE_VALUE"
)

if [[ -n "$APP_BFF_ACTOR_ID_VALUE" ]]; then
  BUILD_ARGS+=("--dart-define=APP_BFF_ACTOR_ID=$APP_BFF_ACTOR_ID_VALUE")
fi

if [[ -n "$APP_BFF_USER_ID_VALUE" ]]; then
  BUILD_ARGS+=("--dart-define=APP_BFF_USER_ID=$APP_BFF_USER_ID_VALUE")
fi

if [[ -n "$APP_INITIAL_ROUTE_VALUE" ]]; then
  BUILD_ARGS+=("--dart-define=APP_INITIAL_ROUTE=$APP_INITIAL_ROUTE_VALUE")
fi

if [[ -n "$APP_BOOTSTRAP_ACCESS_TOKEN_VALUE" ]]; then
  BUILD_ARGS+=("--dart-define=APP_BOOTSTRAP_ACCESS_TOKEN=$APP_BOOTSTRAP_ACCESS_TOKEN_VALUE")
fi

if [[ -n "$APP_BOOTSTRAP_REFRESH_TOKEN_VALUE" ]]; then
  BUILD_ARGS+=("--dart-define=APP_BOOTSTRAP_REFRESH_TOKEN=$APP_BOOTSTRAP_REFRESH_TOKEN_VALUE")
fi

if [[ -n "$APP_BOOTSTRAP_EXPIRES_IN_SECONDS_VALUE" ]]; then
  BUILD_ARGS+=("--dart-define=APP_BOOTSTRAP_EXPIRES_IN_SECONDS=$APP_BOOTSTRAP_EXPIRES_IN_SECONDS_VALUE")
fi

if [[ -n "$APP_BOOTSTRAP_DEVICE_ID_VALUE" ]]; then
  BUILD_ARGS+=("--dart-define=APP_BOOTSTRAP_DEVICE_ID=$APP_BOOTSTRAP_DEVICE_ID_VALUE")
fi

echo "Building macOS app from $APP_TARGET"
echo "Runtime entry mode: $APP_RUNTIME_ENTRY_MODE_VALUE ($ENTRY_LABEL)"
echo "BFF base URL: $APP_BFF_BASE_URL_VALUE"
flutter "${BUILD_ARGS[@]}"

APP_BINARY="$APP_DIR/build/macos/Build/Products/Debug/mobile.app/Contents/MacOS/mobile"
if [[ ! -x "$APP_BINARY" ]]; then
  echo "App binary not found: $APP_BINARY" >&2
  exit 1
fi

if [[ "$APP_SKIP_KILL_EXISTING_MOBILE_VALUE" != "1" ]]; then
  pkill -f "$APP_BINARY" 2>/dev/null || true
fi

echo "Launching $APP_BINARY"
exec "$APP_BINARY"
