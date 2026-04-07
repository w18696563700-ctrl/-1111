#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/.tmp/governance/release_signoff"
REPORT_TXT="${OUTPUT_DIR}/report.txt"
REPORT_JSON="${OUTPUT_DIR}/report.json"

remote_host=""
remote_user=""
channel_type=""

server_release_path=""
bff_release_path=""
exhibition_server_status=""
nginx_status=""
exhibition_bff_status=""
server_release_id=""
bff_release_id=""
signoff_conclusion="blocked"
blocking_reasons=()

mkdir -p "${OUTPUT_DIR}"

json_escape() {
  printf '%s' "$1" | tr '\r\n\t' '   ' | sed 's/\\/\\\\/g; s/"/\\"/g'
}

append_blocking_reason() {
  local reason="$1"
  reason="$(printf '%s' "${reason}" | tr '\r\n\t' '   ')"
  blocking_reasons+=("${reason}")
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --host)
        remote_host="${2:-}"
        shift 2
        ;;
      --user)
        remote_user="${2:-}"
        shift 2
        ;;
      --channel)
        channel_type="${2:-}"
        shift 2
        ;;
      *)
        append_blocking_reason "unsupported argument: $1"
        shift
        ;;
    esac
  done

  [ -n "${remote_host}" ] || append_blocking_reason "--host is required"
  [ -n "${remote_user}" ] || append_blocking_reason "--user is required"
  [ -n "${channel_type}" ] || append_blocking_reason "--channel is required"

  if [ -n "${channel_type}" ] && [ "${channel_type}" != "ssh" ]; then
    append_blocking_reason "unsupported channel type: ${channel_type}"
  fi
}

run_remote_readonly_probe() {
  local remote_target remote_command ssh_output ssh_status=0 line key value
  remote_target="${remote_user}@${remote_host}"

  if ! command -v ssh >/dev/null 2>&1; then
    append_blocking_reason "ssh command is unavailable on this local host"
    return
  fi

  remote_command="$(cat <<'EOF'
server_release_path="$(readlink -f /srv/apps/server/current 2>/dev/null || true)"
bff_release_path="$(readlink -f /srv/apps/bff/current 2>/dev/null || true)"
exhibition_server_status="$(systemctl is-active exhibition-server 2>/dev/null || true)"
nginx_status="$(systemctl is-active nginx 2>/dev/null || true)"
exhibition_bff_status="$(systemctl is-active exhibition-bff 2>/dev/null || true)"
printf "server_release_path=%s\n" "$server_release_path"
printf "bff_release_path=%s\n" "$bff_release_path"
printf "exhibition_server_status=%s\n" "$exhibition_server_status"
printf "nginx_status=%s\n" "$nginx_status"
printf "exhibition_bff_status=%s\n" "$exhibition_bff_status"
EOF
)"

  ssh_output="$(
    ssh \
      -o BatchMode=yes \
      -o ConnectTimeout=5 \
      -o LogLevel=ERROR \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      "${remote_target}" \
      "sh -lc $(printf '%q' "${remote_command}")" 2>&1
  )" || ssh_status=$?

  if [ "${ssh_status}" -ne 0 ]; then
    append_blocking_reason "independent verification channel unavailable: ${ssh_output}"
    return
  fi

  while IFS='=' read -r key value; do
    case "${key}" in
      server_release_path) server_release_path="${value}" ;;
      bff_release_path) bff_release_path="${value}" ;;
      exhibition_server_status) exhibition_server_status="${value}" ;;
      nginx_status) nginx_status="${value}" ;;
      exhibition_bff_status) exhibition_bff_status="${value}" ;;
    esac
  done <<EOF
${ssh_output}
EOF

  [ -n "${server_release_path}" ] || append_blocking_reason "server release path is unreadable"
  [ -n "${bff_release_path}" ] || append_blocking_reason "bff release path is unreadable"
  [ -n "${exhibition_server_status}" ] || append_blocking_reason "exhibition-server status could not be read"
  [ -n "${nginx_status}" ] || append_blocking_reason "nginx status could not be read"
  [ -n "${exhibition_bff_status}" ] || append_blocking_reason "exhibition-bff status could not be read"
}

derive_version_locator() {
  if [ -n "${server_release_path}" ]; then
    server_release_id="$(basename "${server_release_path}")"
  fi
  if [ -n "${bff_release_path}" ]; then
    bff_release_id="$(basename "${bff_release_path}")"
  fi
}

finalize_conclusion() {
  if [ "${#blocking_reasons[@]}" -eq 0 ]; then
    signoff_conclusion="passed"
  else
    signoff_conclusion="blocked"
  fi
}

write_text_report() {
  local reasons_text="[]"
  if [ "${#blocking_reasons[@]}" -gt 0 ]; then
    reasons_text="["
    local first=1
    local reason
    for reason in "${blocking_reasons[@]}"; do
      if [ "${first}" -eq 0 ]; then
        reasons_text="${reasons_text}; "
      fi
      reasons_text="${reasons_text}${reason}"
      first=0
    done
    reasons_text="${reasons_text}]"
  fi

  cat > "${REPORT_TXT}" <<EOF
server_release_path=${server_release_path}
bff_release_path=${bff_release_path}
exhibition_server_status=${exhibition_server_status}
nginx_status=${nginx_status}
exhibition_bff_status=${exhibition_bff_status}
server_release_id=${server_release_id}
bff_release_id=${bff_release_id}
remote_host=${remote_host}
remote_user=${remote_user}
channel_type=${channel_type}
signoff_conclusion=${signoff_conclusion}
blocking_reasons=${reasons_text}
EOF
}

write_json_report() {
  local reasons_json=""
  local reason
  for reason in "${blocking_reasons[@]}"; do
    if [ -n "${reasons_json}" ]; then
      reasons_json+=", "
    fi
    reasons_json+="\"$(json_escape "${reason}")\""
  done

  cat > "${REPORT_JSON}" <<EOF
{
  "server_release_path": "$(json_escape "${server_release_path}")",
  "bff_release_path": "$(json_escape "${bff_release_path}")",
  "service_status": {
    "exhibition_server_status": "$(json_escape "${exhibition_server_status}")",
    "nginx_status": "$(json_escape "${nginx_status}")",
    "exhibition_bff_status": "$(json_escape "${exhibition_bff_status}")"
  },
  "version_locator": {
    "server_release_id": "$(json_escape "${server_release_id}")",
    "bff_release_id": "$(json_escape "${bff_release_id}")",
    "remote_host": "$(json_escape "${remote_host}")",
    "remote_user": "$(json_escape "${remote_user}")",
    "channel_type": "$(json_escape "${channel_type}")"
  },
  "signoff_conclusion": "$(json_escape "${signoff_conclusion}")",
  "blocking_reasons": [${reasons_json}]
}
EOF
}

print_stdout() {
  cat "${REPORT_TXT}"
}

main() {
  parse_args "$@"

  if [ "${#blocking_reasons[@]}" -eq 0 ] && [ "${channel_type}" = "ssh" ]; then
    run_remote_readonly_probe
  fi

  derive_version_locator
  finalize_conclusion
  write_text_report
  write_json_report
  print_stdout
}

main "$@"
