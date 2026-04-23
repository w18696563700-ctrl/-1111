#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"

cd "$APP_DIR"

. "$REPO_ROOT/infra/scripts/load_formal_cloud_env.sh"

APP_TARGET="${APP_TARGET:-lib/main.dart}"
APP_RUNTIME_ENTRY_MODE_VALUE="${APP_RUNTIME_ENTRY_MODE:-cloud}"
APP_FORMAL_CLOUD_BFF_BASE_URL_VALUE="${APP_FORMAL_CLOUD_BFF_BASE_URL:-$FORMAL_CLOUD_BFF_BASE_URL}"
APP_BFF_ACTOR_ID_VALUE="${APP_BFF_ACTOR_ID:-}"
APP_BFF_USER_ID_VALUE="${APP_BFF_USER_ID:-}"
APP_INITIAL_ROUTE_VALUE="${APP_INITIAL_ROUTE:-}"

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
      GUARD_HINT="未检测到 127.0.0.1:8080 的 SSH 隧道。请先建立隧道，或改用 run_macos_cloud.sh / run_macos_local_dev.sh。"
      ;;
    local_dev)
      ENTRY_LABEL="本地开发"
      DEFAULT_BASE_URL="http://127.0.0.1:3000/api/app"
      GUARD_HOST="127.0.0.1"
      GUARD_PORT="3000"
      GUARD_HINT="未检测到 127.0.0.1:3000 的本地 BFF。请先启动本地链路，或切换到云端 / SSH 隧道入口。"
      ;;
    custom)
      ENTRY_LABEL="自定义入口"
      ;;
    *)
      echo "Unsupported APP_RUNTIME_ENTRY_MODE=$1. Supported: cloud, ssh_tunnel, local_dev, custom." >&2
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

configure_entry_mode "$APP_RUNTIME_ENTRY_MODE_VALUE"
APP_BFF_BASE_URL_VALUE="${APP_BFF_BASE_URL:-$DEFAULT_BASE_URL}"

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

echo "Building macOS app from $APP_TARGET"
echo "Runtime entry mode: $APP_RUNTIME_ENTRY_MODE_VALUE ($ENTRY_LABEL)"
echo "BFF base URL: $APP_BFF_BASE_URL_VALUE"
flutter "${BUILD_ARGS[@]}"

APP_BINARY="$APP_DIR/build/macos/Build/Products/Debug/mobile.app/Contents/MacOS/mobile"
if [[ ! -x "$APP_BINARY" ]]; then
  echo "App binary not found: $APP_BINARY" >&2
  exit 1
fi

pkill -f "$APP_BINARY" 2>/dev/null || true

echo "Launching $APP_BINARY"
exec "$APP_BINARY"
