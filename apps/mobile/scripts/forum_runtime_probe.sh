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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

. "$REPO_ROOT/infra/scripts/load_formal_cloud_env.sh"

FORUM_PROBE_SSH_HOST="${FORUM_PROBE_SSH_HOST:-$FORMAL_CLOUD_SSH_HOST}"
FORUM_PROBE_SSH_USER="${FORUM_PROBE_SSH_USER:-$FORMAL_CLOUD_SSH_USER}"
FORUM_PROBE_SSH_PORT="${FORUM_PROBE_SSH_PORT:-$FORMAL_CLOUD_SSH_PORT}"
FORUM_PROBE_SSH_IDENTITY_FILE="${FORUM_PROBE_SSH_IDENTITY_FILE:-}"
FORUM_PROBE_SSH_STRICT_HOST_KEY_CHECKING="${FORUM_PROBE_SSH_STRICT_HOST_KEY_CHECKING:-accept-new}"

FORUM_PROBE_TUNNEL_LOCAL_PORT="${FORUM_PROBE_TUNNEL_LOCAL_PORT:-8080}"
FORUM_PROBE_TUNNEL_REMOTE_HOST="${FORUM_PROBE_TUNNEL_REMOTE_HOST:-127.0.0.1}"
FORUM_PROBE_TUNNEL_REMOTE_PORT="${FORUM_PROBE_TUNNEL_REMOTE_PORT:-80}"
FORUM_PROBE_TUNNEL_WAIT_SECONDS="${FORUM_PROBE_TUNNEL_WAIT_SECONDS:-8}"
FORUM_PROBE_SKIP_TUNNEL="${FORUM_PROBE_SKIP_TUNNEL:-0}"

FORUM_PROBE_BASE_URL="${FORUM_PROBE_BASE_URL:-http://127.0.0.1:${FORUM_PROBE_TUNNEL_LOCAL_PORT}/api/app}"
FORUM_PROBE_ACCOUNT_LABEL="${FORUM_PROBE_ACCOUNT_LABEL:-}"
FORUM_PROBE_DUMMY_ACTOR_ID="${FORUM_PROBE_DUMMY_ACTOR_ID:-actor-1}"
FORUM_PROBE_ALLOW_WRITE="${FORUM_PROBE_ALLOW_WRITE:-0}"

FORUM_PROBE_LOGIN_MOBILE="${FORUM_PROBE_LOGIN_MOBILE:-}"
FORUM_PROBE_LOGIN_PASSWORD="${FORUM_PROBE_LOGIN_PASSWORD:-}"
FORUM_PROBE_LOGIN_OTP="${FORUM_PROBE_LOGIN_OTP:-}"
FORUM_PROBE_LOGIN_METHOD="${FORUM_PROBE_LOGIN_METHOD:-auto}"

FORUM_PROBE_DEVICE_ID="${FORUM_PROBE_DEVICE_ID:-forum-runtime-probe-$("$UUIDGEN_BIN" | tr '[:upper:]' '[:lower:]')}"
FORUM_PROBE_DEVICE_NAME="${FORUM_PROBE_DEVICE_NAME:-Codex Forum Runtime Probe}"
FORUM_PROBE_OS_TYPE="${FORUM_PROBE_OS_TYPE:-macos}"
FORUM_PROBE_CONSENT_ACCEPTED="${FORUM_PROBE_CONSENT_ACCEPTED:-true}"

FORUM_PROBE_CONNECT_TIMEOUT_SECONDS="${FORUM_PROBE_CONNECT_TIMEOUT_SECONDS:-5}"
FORUM_PROBE_MAX_TIME_SECONDS="${FORUM_PROBE_MAX_TIME_SECONDS:-25}"

FORUM_PROBE_TOPIC_ID="${FORUM_PROBE_TOPIC_ID:-}"
FORUM_PROBE_POST_ID="${FORUM_PROBE_POST_ID:-}"
FORUM_PROBE_AUTHOR_ID="${FORUM_PROBE_AUTHOR_ID:-}"

RUN_STAMP="${FORUM_PROBE_RUN_STAMP:-$(date '+%Y%m%d%H%M%S')}"
FORUM_PROBE_SEARCH_QUERY="${FORUM_PROBE_SEARCH_QUERY:-forum-runtime-probe-${RUN_STAMP}}"
FORUM_PROBE_DRAFT_TITLE="${FORUM_PROBE_DRAFT_TITLE:-Forum runtime probe draft ${RUN_STAMP}}"
FORUM_PROBE_DRAFT_BODY="${FORUM_PROBE_DRAFT_BODY:-This is a controlled forum runtime probe draft ${RUN_STAMP}.}"
FORUM_PROBE_REPORT_DIR="${FORUM_PROBE_REPORT_DIR:-$REPO_ROOT/.tmp/forum_runtime_probe}"
FORUM_PROBE_REPORT_FILE="${FORUM_PROBE_REPORT_FILE:-$FORUM_PROBE_REPORT_DIR/forum_runtime_probe_${RUN_STAMP}.md}"

export FORUM_PROBE_LOGIN_MOBILE FORUM_PROBE_LOGIN_PASSWORD FORUM_PROBE_LOGIN_OTP
export FORUM_PROBE_DEVICE_ID FORUM_PROBE_DEVICE_NAME FORUM_PROBE_OS_TYPE
export FORUM_PROBE_CONSENT_ACCEPTED FORUM_PROBE_DRAFT_TITLE FORUM_PROBE_DRAFT_BODY

typeset -i tunnel_pid=0
typeset -i pass_count=0
typeset -i warn_count=0
typeset -i fail_count=0
typeset -i skip_count=0
typeset -a report_lines
report_lines=()

HTTP_STATUS=""
HTTP_BODY=""
ACCESS_TOKEN=""
REFRESH_TOKEN=""
LOGIN_METHOD=""
DISCOVERED_TOPIC_ID="$FORUM_PROBE_TOPIC_ID"
DISCOVERED_POST_ID="$FORUM_PROBE_POST_ID"
DISCOVERED_AUTHOR_ID="$FORUM_PROBE_AUTHOR_ID"
SAVED_DRAFT_ID=""

print_usage() {
  cat <<'EOF'
Usage: apps/mobile/scripts/forum_runtime_probe.sh

Environment:
  FORUM_PROBE_SKIP_TUNNEL=1          Reuse an existing local tunnel.
  FORUM_PROBE_BASE_URL=...           Override the app-facing base URL.
  FORUM_PROBE_LOGIN_MOBILE=...
  FORUM_PROBE_LOGIN_PASSWORD=...
  FORUM_PROBE_LOGIN_OTP=...
  FORUM_PROBE_LOGIN_METHOD=auto|password|otp
  FORUM_PROBE_ALLOW_WRITE=1          Enable draft save/detail/delete smoke.

Behavior:
  1. Reuse or open the SSH tunnel.
  2. Probe forum route materialization with a fake actor hint.
  3. If login credentials are provided, run authenticated forum reads.
  4. If ALLOW_WRITE=1, run draft save -> detail -> delete with the login account.
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  print_usage
  exit 0
fi

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

log_step() {
  local level="$1"
  shift
  echo "[$level] $*"
}

append_report_line() {
  report_lines+=("$1")
}

record_pass() {
  pass_count=$((pass_count + 1))
  log_step PASS "$*"
  append_report_line "- PASS: $*"
}

record_warn() {
  warn_count=$((warn_count + 1))
  log_step WARN "$*"
  append_report_line "- WARN: $*"
}

record_fail() {
  fail_count=$((fail_count + 1))
  log_step FAIL "$*"
  append_report_line "- FAIL: $*"
}

record_skip() {
  skip_count=$((skip_count + 1))
  log_step SKIP "$*"
  append_report_line "- SKIP: $*"
}

is_local_port_listening() {
  "$NC_BIN" -z 127.0.0.1 "$FORUM_PROBE_TUNNEL_LOCAL_PORT" >/dev/null 2>&1
}

cleanup() {
  if (( tunnel_pid > 0 )) && kill -0 "$tunnel_pid" >/dev/null 2>&1; then
    log_step INFO "Closing SSH tunnel ${FORUM_PROBE_TUNNEL_LOCAL_PORT}:${FORUM_PROBE_TUNNEL_REMOTE_HOST}:${FORUM_PROBE_TUNNEL_REMOTE_PORT}"
    kill "$tunnel_pid" >/dev/null 2>&1 || true
    wait "$tunnel_pid" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

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
' "$query" <<<"$body" 2>/dev/null || true
}

urlencode() {
  local raw="$1"
  "$PYTHON_BIN" -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$raw"
}

response_is_missing_route() {
  local method="$1"
  local path="$2"
  local body="$3"
  local canonical_path="/api/app${path}"
  [[ "$body" == *"Cannot ${method} ${canonical_path}"* ]]
}

response_summary() {
  local code=""
  local message=""
  code="$(json_read "$HTTP_BODY" 'code')"
  message="$(extract_message "$HTTP_BODY")"
  if [[ -n "$code" && -n "$message" ]]; then
    echo "status=${HTTP_STATUS} code=${code} message=${message}"
    return 0
  fi
  if [[ -n "$message" ]]; then
    echo "status=${HTTP_STATUS} message=${message}"
    return 0
  fi
  echo "status=${HTTP_STATUS}"
}

run_request() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local token="${4:-}"
  local extra_header="${5:-}"

  local body_file=""
  local headers_file=""
  body_file="$("$MKTEMP_BIN")"
  headers_file="$("$MKTEMP_BIN")"

  local url="${FORUM_PROBE_BASE_URL}${path}"
  local -a curl_args
  curl_args=(
    "$CURL_BIN"
    -sS
    -X "$method"
    "$url"
    -o "$body_file"
    -D "$headers_file"
    -w '%{http_code}'
    --connect-timeout "$FORUM_PROBE_CONNECT_TIMEOUT_SECONDS"
    --max-time "$FORUM_PROBE_MAX_TIME_SECONDS"
    -H 'accept: application/json'
  )

  if [[ -n "$token" ]]; then
    curl_args+=(-H "authorization: Bearer $token")
  fi

  if [[ -n "$extra_header" ]]; then
    curl_args+=(-H "$extra_header")
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

run_probe_step() {
  "$@" || true
}

write_report() {
  mkdir -p "$FORUM_PROBE_REPORT_DIR"
  {
    echo "# Forum Runtime Probe"
    echo
    echo "- runStamp: ${RUN_STAMP}"
    echo "- baseUrl: ${FORUM_PROBE_BASE_URL}"
    echo "- accountLabel: ${FORUM_PROBE_ACCOUNT_LABEL:-n/a}"
    echo "- allowWrite: ${FORUM_PROBE_ALLOW_WRITE}"
    echo "- discoveredTopicId: ${DISCOVERED_TOPIC_ID:-n/a}"
    echo "- discoveredPostId: ${DISCOVERED_POST_ID:-n/a}"
    echo "- discoveredAuthorId: ${DISCOVERED_AUTHOR_ID:-n/a}"
    echo "- summary: pass=${pass_count} warn=${warn_count} fail=${fail_count} skip=${skip_count}"
    echo
    echo "## Results"
    if (( ${#report_lines[@]} == 0 )); then
      echo "- No probe steps were recorded."
    else
      local line=""
      for line in "${report_lines[@]}"; do
        echo "$line"
      done
    fi
  } >"$FORUM_PROBE_REPORT_FILE"
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

probe_route_materialization() {
  local label="$1"
  local method="$2"
  local path="$3"
  local body="${4:-}"

  if ! run_request "$method" "$path" "$body" "" "x-actor-id: ${FORUM_PROBE_DUMMY_ACTOR_ID}"; then
    record_fail "$label: curl transport error on ${method} ${path}"
    return 1
  fi

  if response_is_missing_route "$method" "$path" "$HTTP_BODY"; then
    record_fail "$label: missing route on ${method} ${path}"
    return 1
  fi

  if [[ "$HTTP_STATUS" == 5* ]]; then
    record_fail "$label: $(response_summary)"
    return 1
  fi

  record_pass "$label: $(response_summary)"
  return 0
}

probe_authenticated_read() {
  local label="$1"
  local path="$2"

  if ! run_request "GET" "$path" "" "$ACCESS_TOKEN"; then
    record_fail "$label: curl transport error on GET ${path}"
    return 1
  fi

  if response_is_missing_route "GET" "$path" "$HTTP_BODY"; then
    record_fail "$label: missing route on GET ${path}"
    return 1
  fi

  if status_is_one_of "$HTTP_STATUS" 200; then
    record_pass "$label: $(response_summary)"
    return 0
  fi

  record_fail "$label: expected status=200, got $(response_summary)"
  return 1
}

build_otp_login_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "mobile": os.environ["FORUM_PROBE_LOGIN_MOBILE"],
    "otpCode": os.environ["FORUM_PROBE_LOGIN_OTP"],
    "deviceId": os.environ["FORUM_PROBE_DEVICE_ID"],
    "deviceName": os.environ["FORUM_PROBE_DEVICE_NAME"],
    "osType": os.environ["FORUM_PROBE_OS_TYPE"],
    "consentAccepted": os.environ["FORUM_PROBE_CONSENT_ACCEPTED"].lower() == "true",
}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_password_login_payload() {
  "$PYTHON_BIN" -c '
import json
import os

payload = {
    "mobile": os.environ["FORUM_PROBE_LOGIN_MOBILE"],
    "password": os.environ["FORUM_PROBE_LOGIN_PASSWORD"],
    "deviceId": os.environ["FORUM_PROBE_DEVICE_ID"],
    "deviceName": os.environ["FORUM_PROBE_DEVICE_NAME"],
    "osType": os.environ["FORUM_PROBE_OS_TYPE"],
    "consentAccepted": os.environ["FORUM_PROBE_CONSENT_ACCEPTED"].lower() == "true",
}
print(json.dumps(payload, ensure_ascii=False))
'
}

build_post_id_payload() {
  local post_id="$1"
  "$PYTHON_BIN" -c '
import json
import sys

print(json.dumps({"postId": sys.argv[1]}, ensure_ascii=False))
' "$post_id"
}

build_comment_payload() {
  local post_id="$1"
  "$PYTHON_BIN" -c '
import json
import sys

print(json.dumps({"postId": sys.argv[1], "body": "Forum runtime probe comment."}, ensure_ascii=False))
' "$post_id"
}

build_like_payload() {
  local post_id="$1"
  "$PYTHON_BIN" -c '
import json
import sys

print(json.dumps({"postId": sys.argv[1], "action": "like"}, ensure_ascii=False))
' "$post_id"
}

build_bookmark_payload() {
  local post_id="$1"
  "$PYTHON_BIN" -c '
import json
import sys

print(json.dumps({"postId": sys.argv[1], "action": "add"}, ensure_ascii=False))
' "$post_id"
}

build_draft_payload() {
  local topic_id="$1"
  "$PYTHON_BIN" -c '
import json
import os
import sys

payload = {
    "topicId": sys.argv[1],
    "title": os.environ["FORUM_PROBE_DRAFT_TITLE"],
    "body": os.environ["FORUM_PROBE_DRAFT_BODY"],
    "attachmentFileAssetIds": [],
}
print(json.dumps(payload, ensure_ascii=False))
' "$topic_id"
}

start_tunnel_if_needed() {
  log_step INFO "Forum probe base URL: ${FORUM_PROBE_BASE_URL}"
  if [[ -n "$FORUM_PROBE_ACCOUNT_LABEL" ]]; then
    log_step INFO "Forum probe account label: ${FORUM_PROBE_ACCOUNT_LABEL}"
  fi
  if [[ -n "$FORUM_PROBE_LOGIN_MOBILE" ]]; then
    log_step INFO "Forum probe login mobile: $(mask_secret "$FORUM_PROBE_LOGIN_MOBILE")"
  fi
  if [[ -n "$FORUM_PROBE_LOGIN_PASSWORD" ]]; then
    log_step INFO "Forum probe login password: [set]"
  fi
  if [[ -n "$FORUM_PROBE_LOGIN_OTP" ]]; then
    log_step INFO "Forum probe login OTP: [set]"
  fi

  if [[ "$FORUM_PROBE_SKIP_TUNNEL" == "1" ]]; then
    log_step INFO "Skipping tunnel startup and reusing ${FORUM_PROBE_BASE_URL}"
    return 0
  fi

  if is_local_port_listening; then
    log_step INFO "Reusing existing listener on 127.0.0.1:${FORUM_PROBE_TUNNEL_LOCAL_PORT}"
    return 0
  fi

  local -a ssh_command
  ssh_command=(
    "$SSH_BIN"
    -N
    -p "$FORUM_PROBE_SSH_PORT"
    -o "ExitOnForwardFailure=yes"
    -o "ServerAliveInterval=30"
    -o "ServerAliveCountMax=3"
    -o "StrictHostKeyChecking=${FORUM_PROBE_SSH_STRICT_HOST_KEY_CHECKING}"
    -L "${FORUM_PROBE_TUNNEL_LOCAL_PORT}:${FORUM_PROBE_TUNNEL_REMOTE_HOST}:${FORUM_PROBE_TUNNEL_REMOTE_PORT}"
  )

  if [[ -n "$FORUM_PROBE_SSH_IDENTITY_FILE" ]]; then
    ssh_command+=(-i "$FORUM_PROBE_SSH_IDENTITY_FILE")
  fi

  ssh_command+=("${FORUM_PROBE_SSH_USER}@${FORUM_PROBE_SSH_HOST}")

  log_step INFO "Opening SSH tunnel via ${FORUM_PROBE_SSH_USER}@${FORUM_PROBE_SSH_HOST}:${FORUM_PROBE_SSH_PORT}"
  "${ssh_command[@]}" &
  tunnel_pid=$!

  local ready=0
  local second=0
  for (( second = 1; second <= FORUM_PROBE_TUNNEL_WAIT_SECONDS; second += 1 )); do
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
    record_fail "SSH tunnel did not become ready on 127.0.0.1:${FORUM_PROBE_TUNNEL_LOCAL_PORT}"
    return 1
  fi

  record_pass "SSH tunnel ready on 127.0.0.1:${FORUM_PROBE_TUNNEL_LOCAL_PORT}"
  return 0
}

discover_forum_context() {
  if [[ -z "$DISCOVERED_TOPIC_ID" ]]; then
    if run_request "GET" "/forum/topic/metadata" "" "" "x-actor-id: ${FORUM_PROBE_DUMMY_ACTOR_ID}" &&
      [[ "$HTTP_STATUS" == "200" ]]; then
      DISCOVERED_TOPIC_ID="$(json_read "$HTTP_BODY" 'items.0.topicId')"
    fi
  fi

  if [[ -z "$DISCOVERED_POST_ID" || -z "$DISCOVERED_AUTHOR_ID" ]]; then
    if run_request "GET" "/forum/feed?scope=all" "" "" "x-actor-id: ${FORUM_PROBE_DUMMY_ACTOR_ID}" &&
      [[ "$HTTP_STATUS" == "200" ]]; then
      if [[ -z "$DISCOVERED_POST_ID" ]]; then
        DISCOVERED_POST_ID="$(json_read "$HTTP_BODY" 'items.0.postId')"
      fi
      if [[ -z "$DISCOVERED_AUTHOR_ID" ]]; then
        DISCOVERED_AUTHOR_ID="$(json_read "$HTTP_BODY" 'items.0.author.authorId')"
      fi
      if [[ -z "$DISCOVERED_TOPIC_ID" ]]; then
        DISCOVERED_TOPIC_ID="$(json_read "$HTTP_BODY" 'items.0.topicId')"
      fi
    fi
  fi

  if [[ -z "$DISCOVERED_TOPIC_ID" ]]; then
    DISCOVERED_TOPIC_ID="expo-materials"
    record_warn "topicId discovery failed, falling back to ${DISCOVERED_TOPIC_ID}"
  else
    log_step INFO "Discovered topicId=${DISCOVERED_TOPIC_ID}"
  fi

  if [[ -z "$DISCOVERED_POST_ID" ]]; then
    DISCOVERED_POST_ID="post-probe"
    record_warn "postId discovery failed, falling back to ${DISCOVERED_POST_ID}"
  else
    log_step INFO "Discovered postId=${DISCOVERED_POST_ID}"
  fi

  if [[ -z "$DISCOVERED_AUTHOR_ID" ]]; then
    DISCOVERED_AUTHOR_ID="$FORUM_PROBE_DUMMY_ACTOR_ID"
    record_warn "authorId discovery failed, falling back to ${DISCOVERED_AUTHOR_ID}"
  else
    log_step INFO "Discovered authorId=${DISCOVERED_AUTHOR_ID}"
  fi
}

has_login_inputs() {
  [[ -n "$FORUM_PROBE_LOGIN_MOBILE" && ( -n "$FORUM_PROBE_LOGIN_PASSWORD" || -n "$FORUM_PROBE_LOGIN_OTP" ) ]]
}

resolve_login_method() {
  case "$FORUM_PROBE_LOGIN_METHOD" in
    otp)
      LOGIN_METHOD="otp"
      ;;
    password)
      LOGIN_METHOD="password"
      ;;
    auto)
      if [[ -n "$FORUM_PROBE_LOGIN_OTP" ]]; then
        LOGIN_METHOD="otp"
      elif [[ -n "$FORUM_PROBE_LOGIN_PASSWORD" ]]; then
        LOGIN_METHOD="password"
      else
        LOGIN_METHOD=""
      fi
      ;;
    *)
      LOGIN_METHOD=""
      ;;
  esac

  if [[ -z "$FORUM_PROBE_LOGIN_MOBILE" ]]; then
    record_fail "FORUM_PROBE_LOGIN_MOBILE is required for authenticated probe."
    return 1
  fi

  if [[ "$LOGIN_METHOD" == "otp" && -z "$FORUM_PROBE_LOGIN_OTP" ]]; then
    record_fail "FORUM_PROBE_LOGIN_METHOD=otp but FORUM_PROBE_LOGIN_OTP is empty."
    return 1
  fi

  if [[ "$LOGIN_METHOD" == "password" && -z "$FORUM_PROBE_LOGIN_PASSWORD" ]]; then
    record_fail "FORUM_PROBE_LOGIN_METHOD=password but FORUM_PROBE_LOGIN_PASSWORD is empty."
    return 1
  fi

  if [[ -z "$LOGIN_METHOD" ]]; then
    record_fail "Set FORUM_PROBE_LOGIN_OTP or FORUM_PROBE_LOGIN_PASSWORD, or force FORUM_PROBE_LOGIN_METHOD."
    return 1
  fi

  return 0
}

login() {
  if ! resolve_login_method; then
    return 1
  fi

  local path=""
  local payload=""
  if [[ "$LOGIN_METHOD" == "otp" ]]; then
    path="/auth/otp/login"
    payload="$(build_otp_login_payload)"
  else
    path="/auth/password/login"
    payload="$(build_password_login_payload)"
  fi

  if ! run_request "POST" "$path" "$payload"; then
    record_fail "auth login: curl transport error on POST ${path}"
    return 1
  fi

  if ! status_is_one_of "$HTTP_STATUS" 200; then
    record_fail "auth login: expected status=200, got $(response_summary)"
    return 1
  fi

  ACCESS_TOKEN="$(json_read "$HTTP_BODY" 'accessToken')"
  REFRESH_TOKEN="$(json_read "$HTTP_BODY" 'refreshToken')"

  if [[ -z "$ACCESS_TOKEN" || -z "$REFRESH_TOKEN" ]]; then
    record_fail "auth login: success body is missing accessToken or refreshToken"
    return 1
  fi

  record_pass "auth login via ${LOGIN_METHOD}: status=200"
  return 0
}

run_structure_phase() {
  local topic_q
  local post_q
  local author_q
  local search_q
  topic_q="$(urlencode "$DISCOVERED_TOPIC_ID")"
  post_q="$(urlencode "$DISCOVERED_POST_ID")"
  author_q="$(urlencode "$DISCOVERED_AUTHOR_ID")"
  search_q="$(urlencode "$FORUM_PROBE_SEARCH_QUERY")"

  run_probe_step probe_route_materialization "route forum_feed" "GET" "/forum/feed?scope=all"
  run_probe_step probe_route_materialization "route forum_topic_metadata" "GET" "/forum/topic/metadata"
  run_probe_step probe_route_materialization "route forum_topic_list" "GET" "/forum/topic/list"
  run_probe_step probe_route_materialization "route forum_topic_detail" "GET" "/forum/topic/detail?topicId=${topic_q}"
  run_probe_step probe_route_materialization "route forum_post_detail" "GET" "/forum/post/detail?postId=${post_q}"
  run_probe_step probe_route_materialization "route forum_post_comments" "GET" "/forum/post/comments?postId=${post_q}"
  run_probe_step probe_route_materialization "route forum_search" "GET" "/forum/search?q=${search_q}"
  run_probe_step probe_route_materialization "route forum_me_index" "GET" "/forum/me/index"
  run_probe_step probe_route_materialization "route forum_me_posts" "GET" "/forum/me/posts"
  run_probe_step probe_route_materialization "route forum_me_comments" "GET" "/forum/me/comments"
  run_probe_step probe_route_materialization "route forum_me_bookmarks" "GET" "/forum/me/bookmarks"
  run_probe_step probe_route_materialization "route forum_me_follows" "GET" "/forum/me/follows"
  run_probe_step probe_route_materialization "route forum_author_profile" "GET" "/forum/author/profile?authorId=${author_q}"
  run_probe_step probe_route_materialization "route forum_author_posts" "GET" "/forum/author/posts?authorId=${author_q}"
  run_probe_step probe_route_materialization "route forum_interaction_inbox" "GET" "/forum/interaction/inbox?tab=replies"
  run_probe_step probe_route_materialization "route forum_draft_list" "GET" "/forum/draft/list"
  run_probe_step probe_route_materialization "route forum_draft_detail" "GET" "/forum/draft/detail?draftId=probe-draft-id"
  run_probe_step probe_route_materialization "route forum_reports_mine" "GET" "/forum/reports/mine"
  run_probe_step probe_route_materialization "route forum_post_comment" "POST" "/forum/post/comment" "$(build_comment_payload "$DISCOVERED_POST_ID")"
  run_probe_step probe_route_materialization "route forum_post_like" "POST" "/forum/post/like" "$(build_like_payload "$DISCOVERED_POST_ID")"
  run_probe_step probe_route_materialization "route forum_post_bookmark" "POST" "/forum/post/bookmark" "$(build_bookmark_payload "$DISCOVERED_POST_ID")"
  run_probe_step probe_route_materialization "route forum_post_edit" "POST" "/forum/post/edit" "$(build_post_id_payload "$DISCOVERED_POST_ID")"
  run_probe_step probe_route_materialization "route forum_post_delete" "POST" "/forum/post/delete" "$(build_post_id_payload "$DISCOVERED_POST_ID")"
  run_probe_step probe_route_materialization "route forum_draft_save" "POST" "/forum/draft/save" "$(build_draft_payload "$DISCOVERED_TOPIC_ID")"
  run_probe_step probe_route_materialization "route forum_draft_delete" "POST" "/forum/draft/delete" '{"draftId":"probe-draft-id"}'
  run_probe_step probe_route_materialization "route forum_publish" "POST" "/forum/publish" '{"draftId":"probe-draft-id"}'
}

run_authenticated_read_phase() {
  local topic_q
  local post_q
  local author_q
  local search_q
  topic_q="$(urlencode "$DISCOVERED_TOPIC_ID")"
  post_q="$(urlencode "$DISCOVERED_POST_ID")"
  author_q="$(urlencode "$DISCOVERED_AUTHOR_ID")"
  search_q="$(urlencode "$FORUM_PROBE_SEARCH_QUERY")"

  run_probe_step probe_authenticated_read "auth forum_feed" "/forum/feed?scope=all"
  run_probe_step probe_authenticated_read "auth forum_topic_metadata" "/forum/topic/metadata"
  run_probe_step probe_authenticated_read "auth forum_topic_list" "/forum/topic/list"
  run_probe_step probe_authenticated_read "auth forum_topic_detail" "/forum/topic/detail?topicId=${topic_q}"
  run_probe_step probe_authenticated_read "auth forum_post_detail" "/forum/post/detail?postId=${post_q}"
  run_probe_step probe_authenticated_read "auth forum_post_comments" "/forum/post/comments?postId=${post_q}"
  run_probe_step probe_authenticated_read "auth forum_search" "/forum/search?q=${search_q}"
  run_probe_step probe_authenticated_read "auth forum_me_index" "/forum/me/index"
  run_probe_step probe_authenticated_read "auth forum_me_posts" "/forum/me/posts"
  run_probe_step probe_authenticated_read "auth forum_me_comments" "/forum/me/comments"
  run_probe_step probe_authenticated_read "auth forum_me_bookmarks" "/forum/me/bookmarks"
  run_probe_step probe_authenticated_read "auth forum_me_follows" "/forum/me/follows"
  run_probe_step probe_authenticated_read "auth forum_author_profile" "/forum/author/profile?authorId=${author_q}"
  run_probe_step probe_authenticated_read "auth forum_author_posts" "/forum/author/posts?authorId=${author_q}"
  run_probe_step probe_authenticated_read "auth forum_interaction_inbox" "/forum/interaction/inbox?tab=replies"
  run_probe_step probe_authenticated_read "auth forum_draft_list" "/forum/draft/list"
  run_probe_step probe_authenticated_read "auth forum_reports_mine" "/forum/reports/mine"
}

run_authenticated_write_phase() {
  local payload=""
  local draft_q=""

  payload="$(build_draft_payload "$DISCOVERED_TOPIC_ID")"
  if ! run_request "POST" "/forum/draft/save" "$payload" "$ACCESS_TOKEN"; then
    record_fail "auth forum_draft_save: curl transport error on POST /forum/draft/save"
    return 1
  fi

  if response_is_missing_route "POST" "/forum/draft/save" "$HTTP_BODY"; then
    record_fail "auth forum_draft_save: missing route on POST /forum/draft/save"
    return 1
  fi

  if ! status_is_one_of "$HTTP_STATUS" 202; then
    record_fail "auth forum_draft_save: expected status=202, got $(response_summary)"
    return 1
  fi

  SAVED_DRAFT_ID="$(json_read "$HTTP_BODY" 'draftId')"
  if [[ -z "$SAVED_DRAFT_ID" ]]; then
    record_fail "auth forum_draft_save: success body is missing draftId"
    return 1
  fi

  record_pass "auth forum_draft_save: status=202 draftId=${SAVED_DRAFT_ID}"

  draft_q="$(urlencode "$SAVED_DRAFT_ID")"
  run_probe_step probe_authenticated_read "auth forum_draft_detail" "/forum/draft/detail?draftId=${draft_q}"

  if ! run_request "POST" "/forum/draft/delete" "{\"draftId\":\"${SAVED_DRAFT_ID}\"}" "$ACCESS_TOKEN"; then
    record_fail "auth forum_draft_delete: curl transport error on POST /forum/draft/delete"
    return 1
  fi

  if response_is_missing_route "POST" "/forum/draft/delete" "$HTTP_BODY"; then
    record_fail "auth forum_draft_delete: missing route on POST /forum/draft/delete"
    return 1
  fi

  if ! status_is_one_of "$HTTP_STATUS" 202; then
    record_fail "auth forum_draft_delete: expected status=202, got $(response_summary)"
    return 1
  fi

  record_pass "auth forum_draft_delete: status=202 draftId=${SAVED_DRAFT_ID}"
  return 0
}

log_step INFO "Starting forum runtime probe"
append_report_line "- INFO: Starting forum runtime probe"
start_tunnel_if_needed
discover_forum_context

log_step INFO "Phase 1: route materialization probe"
run_structure_phase

if has_login_inputs; then
  log_step INFO "Phase 2: authenticated forum probe"
  if login; then
    run_authenticated_read_phase
    if [[ "$FORUM_PROBE_ALLOW_WRITE" == "1" ]]; then
      log_step INFO "Phase 3: authenticated draft write probe"
      run_authenticated_write_phase
    else
      record_skip "authenticated write probe is disabled; set FORUM_PROBE_ALLOW_WRITE=1 to enable it"
    fi
  fi
else
  record_skip "authenticated probe skipped; set FORUM_PROBE_LOGIN_MOBILE plus password or OTP to enable it"
fi

log_step INFO "Forum runtime probe summary: pass=${pass_count} warn=${warn_count} fail=${fail_count} skip=${skip_count}"
write_report
log_step INFO "Forum runtime probe report: ${FORUM_PROBE_REPORT_FILE}"
if (( fail_count > 0 )); then
  exit 1
fi

exit 0
