#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

. "${REPO_ROOT}/infra/scripts/load_formal_cloud_env.sh"

TARGET_RUNTIME="${TARGET_RUNTIME:-cloud}"
APP_TOKEN="${APP_TOKEN:-}"

FACTORY_ENTERPRISE_ID="${FACTORY_ENTERPRISE_ID:-a9b46040-956e-44fd-8e35-e3c533687e27}"
COMPANY_ENTERPRISE_ID="${COMPANY_ENTERPRISE_ID:-e2a016f4-0b6a-497d-902c-409413858ca9}"
FACTORY_CASE_ID="${FACTORY_CASE_ID:-e3940909-b9ec-4f21-a150-7d34dafce31c}"

FACTORY_TITLE_EXPECTED="${FACTORY_TITLE_EXPECTED:-重庆海川展览工厂}"

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

get_public() {
  local path="$1"
  curl -fsS "${BASE_URL}${path}"
}

get_auth() {
  local path="$1"
  if [ -z "$APP_TOKEN" ]; then
    fail "APP_TOKEN is required for authenticated smoke: ${path}"
  fi
  curl -fsS -H "Authorization: Bearer ${APP_TOKEN}" "${BASE_URL}${path}"
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

assert_nonempty_case_image_map() {
  local body="$1"
  local compact
  compact="$(compact_json "$body")"

  assert_contains "$compact" "\"caseImageUrlMap\":" "private case detail is missing caseImageUrlMap"
  assert_not_contains "$compact" "\"caseImageUrlMap\":{}" "private case detail returned an empty caseImageUrlMap"
}

say INFO "Running enterprise_hub post-release smoke against ${BASE_URL} (target=${TARGET_RUNTIME})"

say STEP "Check factory public detail title"
factory_detail="$(get_public "/api/app/exhibition/enterprise-hub/enterprises/${FACTORY_ENTERPRISE_ID}?boardType=factory")"
assert_contains "$factory_detail" "$FACTORY_TITLE_EXPECTED" "factory public detail title is not factoryName"
say PASS "Factory public detail title is correct"

say STEP "Check company public detail does not leak factory approved case"
company_detail="$(get_public "/api/app/exhibition/enterprise-hub/enterprises/${COMPANY_ENTERPRISE_ID}?boardType=company")"
assert_not_contains "$company_detail" "$FACTORY_CASE_ID" "company public detail leaked the factory approved case id"
say PASS "Company public detail does not leak factory approved case"

say STEP "Check public-cases route is reachable"
public_case="$(get_public "/api/app/exhibition/enterprise-hub/public-cases/${FACTORY_CASE_ID}")"
assert_contains "$public_case" "$FACTORY_CASE_ID" "public-cases route did not return the target case id"
say PASS "public-cases route is reachable"

if [ -n "$APP_TOKEN" ]; then
  say STEP "Check authenticated factory workbench includes the target case"
  factory_workbench="$(get_auth "/api/app/exhibition/enterprise-hub/workbench?boardType=factory")"
  assert_contains "$factory_workbench" "$FACTORY_CASE_ID" "factory workbench does not include the target case"
  say PASS "Authenticated factory workbench includes the target case"

  say STEP "Check private case detail returns non-empty caseImageUrlMap"
  private_case="$(get_auth "/api/app/exhibition/enterprise-hub/cases/${FACTORY_CASE_ID}")"
  assert_nonempty_case_image_map "$private_case"
  say PASS "Private case detail returns non-empty caseImageUrlMap"
else
  say INFO "APP_TOKEN not provided; skipping authenticated workbench and private case detail checks"
fi

say DONE "Post-release smoke completed successfully"
