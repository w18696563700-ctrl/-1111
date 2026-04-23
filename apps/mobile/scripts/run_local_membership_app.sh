#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

LOCAL_MEMBERSHIP_MODE="${LOCAL_MEMBERSHIP_MODE:-app}"
FLUTTER_DEVICE="${FLUTTER_DEVICE:-macos}"
APP_TARGET="${APP_TARGET:-lib/main.dart}"
APP_RUNTIME_ENTRY_MODE_VALUE="${APP_RUNTIME_ENTRY_MODE:-local_dev}"
APP_BFF_BASE_URL_VALUE="${APP_BFF_BASE_URL:-http://127.0.0.1:3000/api/app}"
APP_BFF_ACTOR_ID_VALUE="${APP_BFF_ACTOR_ID:-}"
APP_BFF_USER_ID_VALUE="${APP_BFF_USER_ID:-}"
APP_INITIAL_ROUTE_VALUE="${APP_INITIAL_ROUTE:-}"

cd "$APP_DIR"

flutter pub get >/dev/null

if [[ "$LOCAL_MEMBERSHIP_MODE" == "smoke" ]]; then
  echo "Running membership local smoke against $APP_BFF_BASE_URL_VALUE"
  export RUN_LOCAL_MEMBERSHIP_EXECUTION_SMOKE=true
  exec flutter test test/profile_membership_execution_local_smoke_test.dart
fi

RUN_ARGS=(
  "run"
  "-d"
  "$FLUTTER_DEVICE"
  "--target"
  "$APP_TARGET"
  "--dart-define=APP_BFF_BASE_URL=$APP_BFF_BASE_URL_VALUE"
  "--dart-define=APP_RUNTIME_ENTRY_MODE=$APP_RUNTIME_ENTRY_MODE_VALUE"
)

if [[ -n "$APP_BFF_ACTOR_ID_VALUE" ]]; then
  RUN_ARGS+=("--dart-define=APP_BFF_ACTOR_ID=$APP_BFF_ACTOR_ID_VALUE")
fi

if [[ -n "$APP_BFF_USER_ID_VALUE" ]]; then
  RUN_ARGS+=("--dart-define=APP_BFF_USER_ID=$APP_BFF_USER_ID_VALUE")
fi

if [[ -n "$APP_INITIAL_ROUTE_VALUE" ]]; then
  RUN_ARGS+=("--dart-define=APP_INITIAL_ROUTE=$APP_INITIAL_ROUTE_VALUE")
fi

echo "Launching Flutter membership local app on device $FLUTTER_DEVICE"
echo "Runtime entry mode: $APP_RUNTIME_ENTRY_MODE_VALUE"
echo "BFF base URL: $APP_BFF_BASE_URL_VALUE"

exec flutter "${RUN_ARGS[@]}"
