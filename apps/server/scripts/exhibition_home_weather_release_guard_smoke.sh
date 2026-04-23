#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

. "${REPO_ROOT}/infra/scripts/load_formal_cloud_env.sh"

TARGET_RUNTIME="${TARGET_RUNTIME:-cloud}"
LATITUDE="${LATITUDE:-29.56301}"
LONGITUDE="${LONGITUDE:-106.55156}"
LOCATION_PERMISSION_STATE="${LOCATION_PERMISSION_STATE:-granted}"

resolve_base_url() {
  case "$1" in
    cloud)
      printf '%s' "${FORMAL_CLOUD_ORIGIN}"
      ;;
    ssh_tunnel)
      printf '%s' "http://127.0.0.1:8080"
      ;;
    custom)
      printf '%s' ""
      ;;
    *)
      echo "Unsupported TARGET_RUNTIME=$1. Supported: cloud, ssh_tunnel, custom." >&2
      exit 1
      ;;
  esac
}

BASE_URL="${BASE_URL:-$(resolve_base_url "${TARGET_RUNTIME}")}"

if [[ "${TARGET_RUNTIME}" == "custom" && -z "${BASE_URL}" ]]; then
  echo "TARGET_RUNTIME=custom requires BASE_URL to be set explicitly." >&2
  exit 1
fi

say() {
  printf '\n[%s] %s\n' "$1" "$2"
}

fail() {
  printf '\n[FAIL] %s\n' "$1" >&2
  exit 1
}

compact_json() {
  tr -d '\n\r\t ' <<<"$1"
}

assert_contains() {
  local body="$1"
  local needle="$2"
  local message="$3"
  if [[ "$body" != *"$needle"* ]]; then
    fail "$message"
  fi
}

assert_not_contains() {
  local body="$1"
  local needle="$2"
  local message="$3"
  if [[ "$body" == *"$needle"* ]]; then
    fail "$message"
  fi
}

request_get() {
  local path="$1"
  RESPONSE_STATUS="200"
  RESPONSE_BODY="$(curl -fsS "${BASE_URL}${path}")"
}

request_post() {
  local path="$1"
  local payload="$2"
  local body_file
  body_file="$(mktemp)"
  RESPONSE_STATUS="$(
    curl -sS -o "${body_file}" -w '%{http_code}' \
      -H 'Content-Type: application/json' \
      -X POST "${BASE_URL}${path}" \
      --data "${payload}"
  )"
  RESPONSE_BODY="$(cat "${body_file}")"
  rm -f "${body_file}"
}

HOME_PATH="/api/app/exhibition/home?latitude=${LATITUDE}&longitude=${LONGITUDE}&locationPermissionState=${LOCATION_PERMISSION_STATE}"
SELECT_PAYLOAD="$(printf '{"provinceName":"重庆","displayName":"重庆","latitude":%s,"longitude":%s}' "${LATITUDE}" "${LONGITUDE}")"

say INFO "Running exhibition-home weather release-guard smoke against ${BASE_URL} (target=${TARGET_RUNTIME})"

say STEP "Check exhibition-home live weather response"
request_get "${HOME_PATH}"
home_body="$(compact_json "${RESPONSE_BODY}")"
assert_contains "${home_body}" '"currentLocation":' "exhibition home response is missing currentLocation"
assert_contains "${home_body}" '"sourceLabel":' "exhibition home response is missing sourceLabel"
assert_not_contains "${home_body}" '"currentWeather":"待同步"' "exhibition home weather regressed to placeholder currentWeather"
assert_not_contains "${home_body}" '天气暂不可用' "exhibition home weather is still in controlled degradation instead of live weather"
assert_not_contains "${home_body}" '最小真值' "exhibition home sourceLabel regressed to minimum-truth wording"
assert_not_contains "${home_body}" '"hourlyForecast":[]' "exhibition home hourly forecast is empty"
assert_not_contains "${home_body}" '"dailyForecast":[]' "exhibition home daily forecast is empty"
say PASS "Exhibition-home live weather response is intact"

say STEP "Check unauthenticated refresh still returns AUTH_SESSION_INVALID"
request_post "/api/app/exhibition/home/refresh" '{}'
refresh_body="$(compact_json "${RESPONSE_BODY}")"
assert_contains "${RESPONSE_STATUS}" '401' "exhibition home refresh no longer returns 401 for unauthenticated request"
assert_contains "${refresh_body}" '"code":"AUTH_SESSION_INVALID"' "exhibition home refresh lost AUTH_SESSION_INVALID semantics"
say PASS "Unauthenticated refresh returns AUTH_SESSION_INVALID"

say STEP "Check unauthenticated location-select still returns AUTH_SESSION_INVALID"
request_post "/api/app/exhibition/home/location/select" "${SELECT_PAYLOAD}"
select_body="$(compact_json "${RESPONSE_BODY}")"
assert_contains "${RESPONSE_STATUS}" '401' "exhibition home location-select no longer returns 401 for unauthenticated request"
assert_contains "${select_body}" '"code":"AUTH_SESSION_INVALID"' "exhibition home location-select lost AUTH_SESSION_INVALID semantics"
say PASS "Unauthenticated location-select returns AUTH_SESSION_INVALID"

say DONE "Exhibition-home weather release guard smoke completed successfully"
