#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$APP_DIR"

APP_TARGET="${APP_TARGET:-lib/main.dart}"
APP_BFF_BASE_URL_VALUE="${APP_BFF_BASE_URL:-http://127.0.0.1:8080/api/app}"
APP_BFF_ACTOR_ID_VALUE="${APP_BFF_ACTOR_ID:-}"
APP_BFF_USER_ID_VALUE="${APP_BFF_USER_ID:-}"
APP_INITIAL_ROUTE_VALUE="${APP_INITIAL_ROUTE:-}"

BUILD_ARGS=(
  "build"
  "macos"
  "--debug"
  "--target"
  "$APP_TARGET"
  "--dart-define=APP_BFF_BASE_URL=$APP_BFF_BASE_URL_VALUE"
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
flutter "${BUILD_ARGS[@]}"

APP_BINARY="$APP_DIR/build/macos/Build/Products/Debug/mobile.app/Contents/MacOS/mobile"
if [[ ! -x "$APP_BINARY" ]]; then
  echo "App binary not found: $APP_BINARY" >&2
  exit 1
fi

pkill -f "$APP_BINARY" 2>/dev/null || true

echo "Launching $APP_BINARY"
exec "$APP_BINARY"
