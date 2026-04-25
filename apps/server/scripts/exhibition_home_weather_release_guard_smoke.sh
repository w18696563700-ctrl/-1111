#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

. "${REPO_ROOT}/infra/scripts/load_formal_cloud_env.sh"

TARGET_RUNTIME="${TARGET_RUNTIME:-cloud}"
LATITUDE="${LATITUDE:-29.56301}"
LONGITUDE="${LONGITUDE:-106.55156}"
LOCATION_PERMISSION_STATE="${LOCATION_PERMISSION_STATE:-granted}"
PROVINCE_NAME="${PROVINCE_NAME:-重庆市}"
CITY_NAME="${CITY_NAME:-重庆市}"
DISTRICT_NAME="${DISTRICT_NAME:-南岸区}"

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

urlencode() {
  python3 - "$1" <<'PY'
import sys, urllib.parse
print(urllib.parse.quote(sys.argv[1]))
PY
}

HOME_PATH="/api/app/exhibition/home?latitude=${LATITUDE}&longitude=${LONGITUDE}&locationPermissionState=${LOCATION_PERMISSION_STATE}"
MANUAL_HOME_PATH="/api/app/exhibition/home?provinceName=$(urlencode "${PROVINCE_NAME}")&cityName=$(urlencode "${CITY_NAME}")&districtName=$(urlencode "${DISTRICT_NAME}")"
SELECT_PAYLOAD="$(printf '{"provinceName":"%s","displayName":"%s","cityName":"%s","districtName":"%s","latitude":%s,"longitude":%s}' "${PROVINCE_NAME}" "${CITY_NAME}" "${CITY_NAME}" "${DISTRICT_NAME}" "${LATITUDE}" "${LONGITUDE}")"

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

say STEP "Check exhibition-home live weather response for manual-selection style region hints"
request_get "${MANUAL_HOME_PATH}"
manual_home_body="$(compact_json "${RESPONSE_BODY}")"
assert_contains "${manual_home_body}" '"currentLocation":' "manual-selection weather response is missing currentLocation"
assert_contains "${manual_home_body}" '"sourceLabel":' "manual-selection weather response is missing sourceLabel"
assert_not_contains "${manual_home_body}" '"currentWeather":"待同步"' "manual-selection weather regressed to placeholder currentWeather"
assert_not_contains "${manual_home_body}" '天气暂不可用' "manual-selection weather is still in controlled degradation instead of live weather"
assert_not_contains "${manual_home_body}" '最小真值' "manual-selection sourceLabel regressed to minimum-truth wording"
assert_not_contains "${manual_home_body}" '"hourlyForecast":[]' "manual-selection hourly forecast is empty"
assert_not_contains "${manual_home_body}" '"dailyForecast":[]' "manual-selection daily forecast is empty"
say PASS "Manual-selection weather response is intact"

say STEP "Check location-select route still returns live weather for manual selection"
request_post "/api/app/exhibition/home/location/select" "${SELECT_PAYLOAD}"
select_body="$(compact_json "${RESPONSE_BODY}")"
assert_contains "${RESPONSE_STATUS}" '200' "exhibition home location-select no longer returns success for manual weather selection"
assert_contains "${select_body}" '"currentLocation":' "location-select response is missing currentLocation"
assert_not_contains "${select_body}" '"currentWeather":"待同步"' "location-select weather regressed to placeholder currentWeather"
assert_not_contains "${select_body}" '天气暂不可用' "location-select weather is still in controlled degradation instead of live weather"
assert_not_contains "${select_body}" '最小真值' "location-select sourceLabel regressed to minimum-truth wording"
assert_not_contains "${select_body}" '"hourlyForecast":[]' "location-select hourly forecast is empty"
assert_not_contains "${select_body}" '"dailyForecast":[]' "location-select daily forecast is empty"
say PASS "Location-select weather response is intact"

say DONE "Exhibition-home weather release guard smoke completed successfully"
