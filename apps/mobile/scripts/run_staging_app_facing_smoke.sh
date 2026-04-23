#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:${PATH:-}"

PYTHON_BIN="${PYTHON_BIN:-/usr/bin/python3}"
MKTEMP_BIN="${MKTEMP_BIN:-/usr/bin/mktemp}"
UUIDGEN_BIN="${UUIDGEN_BIN:-/usr/bin/uuidgen}"
NC_BIN="${NC_BIN:-/usr/bin/nc}"
CURL_BIN="${CURL_BIN:-/usr/bin/curl}"
SSH_BIN="${SSH_BIN:-/usr/bin/ssh}"
RM_BIN="${RM_BIN:-/bin/rm}"
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

. "$REPO_ROOT/infra/scripts/load_formal_cloud_env.sh"

SMOKE_SSH_HOST="${SMOKE_SSH_HOST:-$FORMAL_CLOUD_SSH_HOST}"
SMOKE_SSH_USER="${SMOKE_SSH_USER:-$FORMAL_CLOUD_SSH_USER}"
SMOKE_SSH_PORT="${SMOKE_SSH_PORT:-$FORMAL_CLOUD_SSH_PORT}"
SMOKE_SSH_IDENTITY_FILE="${SMOKE_SSH_IDENTITY_FILE:-}"
SMOKE_SSH_STRICT_HOST_KEY_CHECKING="${SMOKE_SSH_STRICT_HOST_KEY_CHECKING:-accept-new}"

SMOKE_TUNNEL_LOCAL_PORT="${SMOKE_TUNNEL_LOCAL_PORT:-3100}"
SMOKE_TUNNEL_REMOTE_HOST="${SMOKE_TUNNEL_REMOTE_HOST:-127.0.0.1}"
SMOKE_TUNNEL_REMOTE_PORT="${SMOKE_TUNNEL_REMOTE_PORT:-3100}"
SMOKE_TUNNEL_WAIT_SECONDS="${SMOKE_TUNNEL_WAIT_SECONDS:-8}"
SMOKE_SKIP_TUNNEL="${SMOKE_SKIP_TUNNEL:-0}"
SMOKE_TUNNEL_ONLY="${SMOKE_TUNNEL_ONLY:-0}"

export APP_BFF_BASE_URL="${APP_BFF_BASE_URL:-http://127.0.0.1:${SMOKE_TUNNEL_LOCAL_PORT}/api/app}"
export APP_RUNTIME_ENTRY_MODE="${APP_RUNTIME_ENTRY_MODE:-ssh_tunnel}"

SMOKE_ACCOUNT_LABEL="${SMOKE_ACCOUNT_LABEL:-}"
SMOKE_LOGIN_MOBILE="${SMOKE_LOGIN_MOBILE:-}"
SMOKE_LOGIN_PASSWORD="${SMOKE_LOGIN_PASSWORD:-}"
SMOKE_LOGIN_OTP="${SMOKE_LOGIN_OTP:-}"
SMOKE_LOGIN_METHOD="${SMOKE_LOGIN_METHOD:-auto}"

SMOKE_DEVICE_ID="${SMOKE_DEVICE_ID:-staging-smoke-$("$UUIDGEN_BIN" | tr '[:upper:]' '[:lower:]')}"
SMOKE_DEVICE_NAME="${SMOKE_DEVICE_NAME:-Codex Staging Smoke}"
SMOKE_OS_TYPE="${SMOKE_OS_TYPE:-macos}"
SMOKE_CONSENT_ACCEPTED="${SMOKE_CONSENT_ACCEPTED:-true}"

SMOKE_CONNECT_TIMEOUT_SECONDS="${SMOKE_CONNECT_TIMEOUT_SECONDS:-5}"
SMOKE_MAX_TIME_SECONDS="${SMOKE_MAX_TIME_SECONDS:-25}"

SMOKE_RUN_FORUM="${SMOKE_RUN_FORUM:-1}"
SMOKE_ALLOW_PROJECT_WRITE="${SMOKE_ALLOW_PROJECT_WRITE:-0}"

RUN_STAMP="${SMOKE_RUN_STAMP:-$(date '+%Y%m%d%H%M%S')}"

SMOKE_FORUM_TOPIC_ID="${SMOKE_FORUM_TOPIC_ID:-}"
SMOKE_FORUM_TITLE="${SMOKE_FORUM_TITLE:-D2 forum smoke ${RUN_STAMP}}"
SMOKE_FORUM_BODY="${SMOKE_FORUM_BODY:-This is a rerunnable D2 forum smoke body ${RUN_STAMP}.}"
SMOKE_FORUM_COMMENT_BODY="${SMOKE_FORUM_COMMENT_BODY:-D2 forum smoke comment ${RUN_STAMP}}"
SMOKE_REPORT_REASON_CODE="${SMOKE_REPORT_REASON_CODE:-other}"
SMOKE_REPORT_REASON_DETAIL="${SMOKE_REPORT_REASON_DETAIL:-D2 staging smoke ${RUN_STAMP}}"

SMOKE_PROJECT_EXHIBITION_NAME="${SMOKE_PROJECT_EXHIBITION_NAME:-D2 staging smoke exhibition ${RUN_STAMP}}"
SMOKE_PROJECT_BRAND_NAME="${SMOKE_PROJECT_BRAND_NAME:-Codex smoke}"
SMOKE_PROJECT_TITLE="${SMOKE_PROJECT_TITLE:-${SMOKE_PROJECT_EXHIBITION_NAME} - ${SMOKE_PROJECT_BRAND_NAME}}"
SMOKE_PROJECT_BUILDING_TYPE="${SMOKE_PROJECT_BUILDING_TYPE:-exhibition}"
SMOKE_PROJECT_BUDGET_AMOUNT="${SMOKE_PROJECT_BUDGET_AMOUNT:-180000}"
SMOKE_PROJECT_PROVINCE_CODE="${SMOKE_PROJECT_PROVINCE_CODE:-510000}"
SMOKE_PROJECT_PROVINCE_NAME="${SMOKE_PROJECT_PROVINCE_NAME:-Sichuan}"
SMOKE_PROJECT_CITY_CODE="${SMOKE_PROJECT_CITY_CODE:-510100}"
SMOKE_PROJECT_CITY_NAME="${SMOKE_PROJECT_CITY_NAME:-Chengdu}"
SMOKE_PROJECT_DISTRICT_CODE="${SMOKE_PROJECT_DISTRICT_CODE:-}"
SMOKE_PROJECT_DISTRICT_NAME="${SMOKE_PROJECT_DISTRICT_NAME:-}"
SMOKE_PROJECT_DETAIL_ADDRESS="${SMOKE_PROJECT_DETAIL_ADDRESS:-Century City New International Convention and Exhibition Center Gate 6 West}"
SMOKE_PROJECT_SCOPE_SUMMARY="${SMOKE_PROJECT_SCOPE_SUMMARY:-Staging D2 project create smoke ${RUN_STAMP}}"

typeset -i tunnel_pid=0
typeset -i pass_count=0
typeset -i warn_count=0
typeset -i fail_count=0
typeset -i blocked_count=0
typeset -i skipped_count=0

HTTP_STATUS=""
HTTP_BODY=""
ACCESS_TOKEN=""
REFRESH_TOKEN=""
LOGIN_METHOD=""
FORUM_TOPIC_ID=""
FORUM_DRAFT_ID=""
FORUM_POST_ID=""
FORUM_COMMENT_ID=""
FORUM_REPORT_TICKET_ID=""
PROJECT_CREATE_ELIGIBILITY=""

export APP_BFF_BASE_URL
export SMOKE_LOGIN_MOBILE SMOKE_LOGIN_PASSWORD SMOKE_LOGIN_OTP SMOKE_LOGIN_METHOD
export SMOKE_DEVICE_ID SMOKE_DEVICE_NAME SMOKE_OS_TYPE SMOKE_CONSENT_ACCEPTED
export SMOKE_FORUM_TOPIC_ID SMOKE_FORUM_TITLE SMOKE_FORUM_BODY
export SMOKE_FORUM_COMMENT_BODY SMOKE_REPORT_REASON_CODE SMOKE_REPORT_REASON_DETAIL
export SMOKE_PROJECT_EXHIBITION_NAME SMOKE_PROJECT_BRAND_NAME SMOKE_PROJECT_TITLE
export SMOKE_PROJECT_BUILDING_TYPE SMOKE_PROJECT_BUDGET_AMOUNT
export SMOKE_PROJECT_PROVINCE_CODE SMOKE_PROJECT_PROVINCE_NAME
export SMOKE_PROJECT_CITY_CODE SMOKE_PROJECT_CITY_NAME
export SMOKE_PROJECT_DISTRICT_CODE SMOKE_PROJECT_DISTRICT_NAME
export SMOKE_PROJECT_DETAIL_ADDRESS SMOKE_PROJECT_SCOPE_SUMMARY
export FORUM_TOPIC_ID FORUM_DRAFT_ID FORUM_POST_ID FORUM_COMMENT_ID FORUM_REPORT_TICKET_ID

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
  "$NC_BIN" -z 127.0.0.1 "$SMOKE_TUNNEL_LOCAL_PORT" >/dev/null 2>&1
}

cleanup() {
  if (( tunnel_pid > 0 )) && kill -0 "$tunnel_pid" >/dev/null 2>&1; then
    echo "Closing SSH tunnel ${SMOKE_TUNNEL_LOCAL_PORT}:${SMOKE_TUNNEL_REMOTE_HOST}:${SMOKE_TUNNEL_REMOTE_PORT}"
    kill "$tunnel_pid" >/dev/null 2>&1 || true
    wait "$tunnel_pid" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

log_step() {
  local level="$1"
  shift
  echo "[$level] $*"
}

log_step INFO "Runtime entry mode: ${APP_RUNTIME_ENTRY_MODE}"
log_step INFO "BFF base URL: ${APP_BFF_BASE_URL}"

record_pass() {
  pass_count=$((pass_count + 1))
  log_step PASS "$*"
}

record_warn() {
  warn_count=$((warn_count + 1))
  log_step WARN "$*"
}

record_fail() {
  fail_count=$((fail_count + 1))
  log_step FAIL "$*"
}

record_blocked() {
  blocked_count=$((blocked_count + 1))
  log_step BLOCKED "$*"
}

record_skipped() {
  skipped_count=$((skipped_count + 1))
  log_step SKIPPED "$*"
}

extract_message() {
  local body="$1"
  "$PYTHON_BIN" -c '
import json
import sys

text = sys.stdin.read().strip()
if not text:
    raise SystemExit(1)
payload = json.loads(text)
for key in ("message", "error", "code"):
    value = payload.get(key)
    if isinstance(value, str) and value.strip():
        print(value.strip())
        raise SystemExit(0)
raise SystemExit(1)
' <<<"$body" 2>/dev/null || true
}

json_read() {
  local body="$1"
  local query="$2"
  "$PYTHON_BIN" -c '
import json
import sys

query = sys.argv[1]
text = sys.stdin.read().strip()
if not text:
    raise SystemExit(1)

value = json.loads(text)
for part in [item for item in query.split(".") if item]:
    if isinstance(value, list):
        value = value[int(part)]
    else:
        value = value[part]

if value is None:
    print("")
elif isinstance(value, bool):
    print("true" if value else "false")
elif isinstance(value, (dict, list)):
    print(json.dumps(value, ensure_ascii=False))
else:
    print(value)
' "$query" <<<"$body"
}

body_contains_value() {
  local body="$1"
  local needle="$2"
  if [[ -z "$needle" ]]; then
    return 1
  fi

  "$PYTHON_BIN" -c '
import sys

needle = sys.argv[1]
text = sys.stdin.read()
raise SystemExit(0 if needle in text else 1)
' "$needle" <<<"$body" >/dev/null
}

urlencode() {
  local raw="$1"
  "$PYTHON_BIN" -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$raw"
}

resolve_login_method() {
  case "$SMOKE_LOGIN_METHOD" in
    otp)
      LOGIN_METHOD="otp"
      ;;
    password)
      LOGIN_METHOD="password"
      ;;
    auto)
      if [[ -n "$SMOKE_LOGIN_OTP" ]]; then
        LOGIN_METHOD="otp"
      elif [[ -n "$SMOKE_LOGIN_PASSWORD" ]]; then
        LOGIN_METHOD="password"
      else
        LOGIN_METHOD=""
      fi
      ;;
    *)
      LOGIN_METHOD=""
      ;;
  esac

  if [[ -z "$SMOKE_LOGIN_MOBILE" ]]; then
    record_fail "SMOKE_LOGIN_MOBILE is required."
    return 1
  fi

  if [[ "$LOGIN_METHOD" == "otp" && -z "$SMOKE_LOGIN_OTP" ]]; then
    record_fail "SMOKE_LOGIN_METHOD=otp but SMOKE_LOGIN_OTP is empty."
    return 1
  fi

  if [[ "$LOGIN_METHOD" == "password" && -z "$SMOKE_LOGIN_PASSWORD" ]]; then
    record_fail "SMOKE_LOGIN_METHOD=password but SMOKE_LOGIN_PASSWORD is empty."
    return 1
  fi

  if [[ -z "$LOGIN_METHOD" ]]; then
    record_fail "Set SMOKE_LOGIN_OTP or SMOKE_LOGIN_PASSWORD, or force SMOKE_LOGIN_METHOD."
    return 1
  fi

  return 0
}

build_otp_login_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "mobile": os.environ["SMOKE_LOGIN_MOBILE"],
    "otpCode": os.environ["SMOKE_LOGIN_OTP"],
    "deviceId": os.environ["SMOKE_DEVICE_ID"],
    "deviceName": os.environ["SMOKE_DEVICE_NAME"],
    "osType": os.environ["SMOKE_OS_TYPE"],
    "consentAccepted": os.environ["SMOKE_CONSENT_ACCEPTED"].lower() == "true",
}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_password_login_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "mobile": os.environ["SMOKE_LOGIN_MOBILE"],
    "password": os.environ["SMOKE_LOGIN_PASSWORD"],
    "deviceId": os.environ["SMOKE_DEVICE_ID"],
    "deviceName": os.environ["SMOKE_DEVICE_NAME"],
    "osType": os.environ["SMOKE_OS_TYPE"],
    "consentAccepted": os.environ["SMOKE_CONSENT_ACCEPTED"].lower() == "true",
}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_forum_draft_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "draftId": None,
    "topicId": os.environ["FORUM_TOPIC_ID"],
    "title": os.environ["SMOKE_FORUM_TITLE"],
    "body": os.environ["SMOKE_FORUM_BODY"],
    "attachmentFileAssetIds": [],
}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_forum_publish_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {"draftId": os.environ["FORUM_DRAFT_ID"]}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_forum_comment_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "postId": os.environ["FORUM_POST_ID"],
    "body": os.environ["SMOKE_FORUM_COMMENT_BODY"],
}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_toggle_payload() {
  local action="$1"
  "$PYTHON_BIN" -c '
import json
import os
import sys

payload = {
    "postId": os.environ["FORUM_POST_ID"],
    "action": sys.argv[1],
}
print(json.dumps(payload, ensure_ascii=False))
' "$action"
}

build_report_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "targetType": "post",
    "targetId": os.environ["FORUM_POST_ID"],
    "reasonCode": os.environ["SMOKE_REPORT_REASON_CODE"],
    "reasonDetail": os.environ["SMOKE_REPORT_REASON_DETAIL"],
}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_project_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "title": os.environ["SMOKE_PROJECT_TITLE"],
    "exhibitionName": os.environ["SMOKE_PROJECT_EXHIBITION_NAME"],
    "brandName": os.environ["SMOKE_PROJECT_BRAND_NAME"],
    "buildingType": os.environ["SMOKE_PROJECT_BUILDING_TYPE"],
    "budgetAmount": float(os.environ["SMOKE_PROJECT_BUDGET_AMOUNT"]),
    "provinceCode": os.environ["SMOKE_PROJECT_PROVINCE_CODE"],
    "provinceName": os.environ["SMOKE_PROJECT_PROVINCE_NAME"],
    "cityCode": os.environ["SMOKE_PROJECT_CITY_CODE"],
    "cityName": os.environ["SMOKE_PROJECT_CITY_NAME"],
    "detailAddress": os.environ["SMOKE_PROJECT_DETAIL_ADDRESS"],
    "scopeSummary": os.environ["SMOKE_PROJECT_SCOPE_SUMMARY"],
}
district_code = os.environ.get("SMOKE_PROJECT_DISTRICT_CODE", "").strip()
district_name = os.environ.get("SMOKE_PROJECT_DISTRICT_NAME", "").strip()
if district_code and district_name:
    payload["districtCode"] = district_code
    payload["districtName"] = district_name
print(json.dumps(payload, ensure_ascii=False))
'
}

run_request() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local token="${4:-}"

  local url="${APP_BFF_BASE_URL}${path}"
  local body_file
  local headers_file
  body_file="$("$MKTEMP_BIN")"
  headers_file="$("$MKTEMP_BIN")"

  local -a curl_args
  curl_args=(
    "$CURL_BIN"
    -sS
    -X "$method"
    "$url"
    -o "$body_file"
    -D "$headers_file"
    -w '%{http_code}'
    --connect-timeout "$SMOKE_CONNECT_TIMEOUT_SECONDS"
    --max-time "$SMOKE_MAX_TIME_SECONDS"
    -H 'accept: application/json'
  )

  if [[ -n "$token" ]]; then
    curl_args+=(-H "authorization: Bearer $token")
  fi

  if [[ -n "$body" ]]; then
    curl_args+=(-H 'content-type: application/json' --data "$body")
  fi

  local http_status=""
  if ! http_status="$("${curl_args[@]}")"; then
    HTTP_STATUS="000"
    HTTP_BODY=""
    "$RM_BIN" -f "$body_file" "$headers_file"
    return 1
  fi

  HTTP_STATUS="$http_status"
  HTTP_BODY="$(<"$body_file")"
  "$RM_BIN" -f "$body_file" "$headers_file"
  return 0
}

status_is_one_of() {
  local actual="$1"
  shift
  local candidate=""
  for candidate in "$@"; do
    if [[ "$actual" == "$candidate" ]]; then
      return 0
    fi
  done
  return 1
}

request_or_fail() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local token="${4:-}"
  local step_label="$5"

  if ! run_request "$method" "$path" "$body" "$token"; then
    record_fail "$step_label: curl transport error on ${method} ${path}"
    return 1
  fi

  return 0
}

start_tunnel_if_needed() {
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

  if [[ "$SMOKE_SKIP_TUNNEL" == "1" ]]; then
    echo "Skipping tunnel startup and reusing APP_BFF_BASE_URL=$APP_BFF_BASE_URL"
    return 0
  fi

  if is_local_port_listening; then
    record_fail "Local port ${SMOKE_TUNNEL_LOCAL_PORT} is already listening. Set SMOKE_SKIP_TUNNEL=1 to reuse it."
    return 1
  fi

  local -a ssh_command
  ssh_command=(
    "$SSH_BIN"
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

  local ready=0
  local second=0
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
    record_fail "SSH tunnel did not become ready on 127.0.0.1:${SMOKE_TUNNEL_LOCAL_PORT}"
    return 1
  fi

  record_pass "SSH tunnel ready on 127.0.0.1:${SMOKE_TUNNEL_LOCAL_PORT}"
  return 0
}

login() {
  if ! resolve_login_method; then
    return 1
  fi

  local payload=""
  local path=""
  if [[ "$LOGIN_METHOD" == "otp" ]]; then
    path="/auth/otp/login"
    payload="$(build_otp_login_payload)"
  else
    path="/auth/password/login"
    payload="$(build_password_login_payload)"
  fi

  if ! request_or_fail "POST" "$path" "$payload" "" "auth login"; then
    return 1
  fi

  if ! status_is_one_of "$HTTP_STATUS" 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "auth login: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi

  ACCESS_TOKEN="$(json_read "$HTTP_BODY" 'accessToken' 2>/dev/null || true)"
  REFRESH_TOKEN="$(json_read "$HTTP_BODY" 'refreshToken' 2>/dev/null || true)"
  if [[ -z "$ACCESS_TOKEN" || -z "$REFRESH_TOKEN" ]]; then
    record_fail "auth login: success body is missing accessToken or refreshToken."
    return 1
  fi

  record_pass "auth login via ${LOGIN_METHOD}: status=200"
  return 0
}

read_shell_eligibility() {
  if ! request_or_fail "GET" "/shell/context" "" "$ACCESS_TOKEN" "shell context"; then
    return 1
  fi

  if ! status_is_one_of "$HTTP_STATUS" 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "shell context: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi

  local organization_type=""
  local role_keys=""
  local certification_status=""
  organization_type="$(json_read "$HTTP_BODY" 'organizationType' 2>/dev/null || true)"
  role_keys="$(json_read "$HTTP_BODY" 'roleKeys' 2>/dev/null || true)"
  certification_status="$(json_read "$HTTP_BODY" 'certificationStatus' 2>/dev/null || true)"
  PROJECT_CREATE_ELIGIBILITY="$(json_read "$HTTP_BODY" 'projectCreateEligibility.canCreateProject' 2>/dev/null || true)"

  echo "Shell eligibility:"
  echo "  organizationType=${organization_type:-<empty>}"
  echo "  roleKeys=${role_keys:-[]}"
  echo "  certificationStatus=${certification_status:-<empty>}"
  echo "  projectCreateEligibility.canCreateProject=${PROJECT_CREATE_ELIGIBILITY:-<missing>}"

  if [[ -z "$PROJECT_CREATE_ELIGIBILITY" ]]; then
    record_fail "shell context: projectCreateEligibility.canCreateProject is missing."
    return 1
  fi

  record_pass "shell context: status=200"
  return 0
}

run_forum_smoke() {
  if [[ "$SMOKE_RUN_FORUM" != "1" ]]; then
    record_skipped "forum smoke disabled by SMOKE_RUN_FORUM=$SMOKE_RUN_FORUM"
    return 0
  fi

  if ! request_or_fail "GET" "/forum/topic/metadata" "" "" "forum topic metadata"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "forum topic metadata: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi

  FORUM_TOPIC_ID="$SMOKE_FORUM_TOPIC_ID"
  if [[ -z "$FORUM_TOPIC_ID" ]]; then
    FORUM_TOPIC_ID="$(json_read "$HTTP_BODY" 'items.0.topicId' 2>/dev/null || true)"
  fi
  if [[ -z "$FORUM_TOPIC_ID" ]]; then
    record_fail "forum topic metadata: unable to resolve a topicId for rerunnable draft save."
    return 1
  fi
  export FORUM_TOPIC_ID
  record_pass "forum topic metadata: topicId=${FORUM_TOPIC_ID}"

  if ! request_or_fail "GET" "/forum/me/index" "" "$ACCESS_TOKEN" "forum me index"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum me index: status=$HTTP_STATUS"
    return 1
  fi
  record_pass "forum me index: status=200"

  if ! request_or_fail "GET" "/forum/draft/list" "" "$ACCESS_TOKEN" "forum draft list"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum draft list: status=$HTTP_STATUS"
    return 1
  fi
  record_pass "forum draft list: status=200"

  local draft_payload
  draft_payload="$(build_forum_draft_payload)"
  if ! request_or_fail "POST" "/forum/draft/save" "$draft_payload" "$ACCESS_TOKEN" "forum draft save"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 202 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "forum draft save: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi
  FORUM_DRAFT_ID="$(json_read "$HTTP_BODY" 'draftId' 2>/dev/null || true)"
  if [[ -z "$FORUM_DRAFT_ID" ]]; then
    record_fail "forum draft save: success body is missing draftId."
    return 1
  fi
  export FORUM_DRAFT_ID
  record_pass "forum draft save: draftId=${FORUM_DRAFT_ID}"

  if ! request_or_fail "GET" "/forum/draft/detail?draftId=$(urlencode "$FORUM_DRAFT_ID")" "" "$ACCESS_TOKEN" "forum draft detail"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum draft detail: status=$HTTP_STATUS"
    return 1
  fi
  record_pass "forum draft detail: status=200"

  local publish_payload
  publish_payload="$(build_forum_publish_payload)"
  if ! request_or_fail "POST" "/forum/publish" "$publish_payload" "$ACCESS_TOKEN" "forum publish"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 202 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "forum publish: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi

  local decision=""
  decision="$(json_read "$HTTP_BODY" 'decision' 2>/dev/null || true)"
  FORUM_POST_ID="$(json_read "$HTTP_BODY" 'postId' 2>/dev/null || true)"
  if [[ -z "$FORUM_POST_ID" ]]; then
    record_fail "forum publish: success body is missing postId."
    return 1
  fi
  if [[ -n "$decision" && "$decision" != "clear" ]]; then
    record_fail "forum publish: decision=${decision} and the post did not clear the normal publish corridor."
    return 1
  fi
  export FORUM_POST_ID
  record_pass "forum publish: postId=${FORUM_POST_ID}"

  if ! request_or_fail "GET" "/forum/post/detail?postId=$(urlencode "$FORUM_POST_ID")" "" "$ACCESS_TOKEN" "forum post detail"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum post detail: status=$HTTP_STATUS"
    return 1
  fi
  record_pass "forum post detail: status=200"

  local comment_payload
  comment_payload="$(build_forum_comment_payload)"
  if ! request_or_fail "POST" "/forum/post/comment" "$comment_payload" "$ACCESS_TOKEN" "forum post comment"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 202 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "forum post comment: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi
  FORUM_COMMENT_ID="$(json_read "$HTTP_BODY" 'commentId' 2>/dev/null || true)"
  record_pass "forum post comment: status=$HTTP_STATUS${FORUM_COMMENT_ID:+ commentId=$FORUM_COMMENT_ID}"

  local like_payload
  like_payload="$(build_toggle_payload 'like')"
  if ! request_or_fail "POST" "/forum/post/like" "$like_payload" "$ACCESS_TOKEN" "forum post like"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 202 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "forum post like: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi
  record_pass "forum post like: status=$HTTP_STATUS"

  if request_or_fail "GET" "/forum/post/detail?postId=$(urlencode "$FORUM_POST_ID")" "" "$ACCESS_TOKEN" "forum like readback"; then
    if status_is_one_of "$HTTP_STATUS" 200; then
      local viewer_has_liked=""
      viewer_has_liked="$(json_read "$HTTP_BODY" 'viewerHasLiked' 2>/dev/null || true)"
      if [[ "$viewer_has_liked" == "true" ]]; then
        record_pass "forum like readback: viewerHasLiked=true"
      else
        record_warn "forum like readback: request was accepted but viewerHasLiked=${viewer_has_liked:-<missing>} after immediate reread."
      fi
    else
      record_warn "forum like readback: post detail returned status=$HTTP_STATUS"
    fi
  else
    record_warn "forum like readback: transport error on post detail reread"
  fi

  local bookmark_payload
  bookmark_payload="$(build_toggle_payload 'add')"
  if ! request_or_fail "POST" "/forum/post/bookmark" "$bookmark_payload" "$ACCESS_TOKEN" "forum post bookmark"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 202 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "forum post bookmark: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi
  record_pass "forum post bookmark: status=$HTTP_STATUS"

  if request_or_fail "GET" "/forum/post/detail?postId=$(urlencode "$FORUM_POST_ID")" "" "$ACCESS_TOKEN" "forum bookmark readback"; then
    if status_is_one_of "$HTTP_STATUS" 200; then
      local viewer_has_bookmarked=""
      viewer_has_bookmarked="$(json_read "$HTTP_BODY" 'viewerHasBookmarked' 2>/dev/null || true)"
      if [[ "$viewer_has_bookmarked" == "true" ]]; then
        record_pass "forum bookmark readback: viewerHasBookmarked=true"
      else
        record_warn "forum bookmark readback: request was accepted but viewerHasBookmarked=${viewer_has_bookmarked:-<missing>} after immediate reread."
      fi
    else
      record_warn "forum bookmark readback: post detail returned status=$HTTP_STATUS"
    fi
  else
    record_warn "forum bookmark readback: transport error on post detail reread"
  fi

  local report_payload
  report_payload="$(build_report_payload)"
  if ! request_or_fail "POST" "/forum/report/submit" "$report_payload" "$ACCESS_TOKEN" "forum report submit"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 202 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "forum report submit: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi
  FORUM_REPORT_TICKET_ID="$(json_read "$HTTP_BODY" 'reportTicketId' 2>/dev/null || true)"
  record_pass "forum report submit: status=$HTTP_STATUS${FORUM_REPORT_TICKET_ID:+ reportTicketId=$FORUM_REPORT_TICKET_ID}"

  if ! request_or_fail "GET" "/forum/post/comments?postId=$(urlencode "$FORUM_POST_ID")" "" "$ACCESS_TOKEN" "forum post comments"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum post comments: status=$HTTP_STATUS"
    return 1
  fi
  record_pass "forum post comments: status=200"

  if ! request_or_fail "GET" "/forum/me/posts" "" "$ACCESS_TOKEN" "forum me posts"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum me posts: status=$HTTP_STATUS"
    return 1
  fi
  if body_contains_value "$HTTP_BODY" "$FORUM_POST_ID"; then
    record_pass "forum me posts: contains postId=${FORUM_POST_ID}"
  else
    record_warn "forum me posts: status=200 but the new postId was not found in immediate reread."
  fi

  if ! request_or_fail "GET" "/forum/me/comments" "" "$ACCESS_TOKEN" "forum me comments"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum me comments: status=$HTTP_STATUS"
    return 1
  fi
  if [[ -n "$FORUM_COMMENT_ID" ]] && body_contains_value "$HTTP_BODY" "$FORUM_COMMENT_ID"; then
    record_pass "forum me comments: contains commentId=${FORUM_COMMENT_ID}"
  else
    record_warn "forum me comments: status=200 but the new commentId was not found in immediate reread."
  fi

  if ! request_or_fail "GET" "/forum/me/bookmarks" "" "$ACCESS_TOKEN" "forum me bookmarks"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum me bookmarks: status=$HTTP_STATUS"
    return 1
  fi
  if body_contains_value "$HTTP_BODY" "$FORUM_POST_ID"; then
    record_pass "forum me bookmarks: contains postId=${FORUM_POST_ID}"
  else
    record_warn "forum me bookmarks: status=200 but the new postId was not found in immediate reread."
  fi

  if ! request_or_fail "GET" "/forum/reports/mine" "" "$ACCESS_TOKEN" "forum reports mine"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "forum reports mine: status=$HTTP_STATUS"
    return 1
  fi
  if [[ -n "$FORUM_REPORT_TICKET_ID" ]] && body_contains_value "$HTTP_BODY" "$FORUM_REPORT_TICKET_ID"; then
    record_pass "forum reports mine: contains reportTicketId=${FORUM_REPORT_TICKET_ID}"
  else
    record_warn "forum reports mine: status=200 but the new report ticket was not found in immediate reread."
  fi

  return 0
}

run_project_smoke() {
  if [[ "$SMOKE_ALLOW_PROJECT_WRITE" != "1" ]]; then
    record_skipped "project create smoke disabled by SMOKE_ALLOW_PROJECT_WRITE=$SMOKE_ALLOW_PROJECT_WRITE"
    return 0
  fi

  if [[ "$PROJECT_CREATE_ELIGIBILITY" != "true" ]]; then
    record_blocked "project create skipped because shell eligibility is canCreateProject=${PROJECT_CREATE_ELIGIBILITY:-<missing>}."
    return 0
  fi

  local project_payload
  project_payload="$(build_project_payload)"
  if ! request_or_fail "POST" "/project/create" "$project_payload" "$ACCESS_TOKEN" "project create"; then
    return 1
  fi
  if ! status_is_one_of "$HTTP_STATUS" 202 200; then
    local message
    message="$(extract_message "$HTTP_BODY")"
    record_fail "project create: status=$HTTP_STATUS ${message:+message=$message}"
    return 1
  fi

  local project_id=""
  local project_state=""
  project_id="$(json_read "$HTTP_BODY" 'projectId' 2>/dev/null || true)"
  project_state="$(json_read "$HTTP_BODY" 'state' 2>/dev/null || true)"
  if [[ -z "$project_id" ]]; then
    record_fail "project create: success body is missing projectId."
    return 1
  fi

  record_pass "project create: projectId=${project_id} state=${project_state:-<missing>}"
  return 0
}

print_summary_and_exit() {
  echo ""
  echo "Summary:"
  echo "  PASS=$pass_count"
  echo "  WARN=$warn_count"
  echo "  BLOCKED=$blocked_count"
  echo "  SKIPPED=$skipped_count"
  echo "  FAIL=$fail_count"

  if (( fail_count > 0 )); then
    exit 1
  fi
}

main() {
  if ! start_tunnel_if_needed; then
    print_summary_and_exit
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

  if ! login; then
    print_summary_and_exit
  fi

  if ! read_shell_eligibility; then
    print_summary_and_exit
  fi

  if ! run_forum_smoke; then
    print_summary_and_exit
  fi

  if ! run_project_smoke; then
    print_summary_and_exit
  fi

  print_summary_and_exit
}

main "$@"
