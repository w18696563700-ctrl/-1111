#!/usr/bin/env bash
set -euo pipefail

workspace=""
report_dir=""
report_txt=""
report_json=""

t0_status="blocked"
t1_status="blocked"
t2_status="blocked"
t3_status="blocked"
gate_conclusion="blocked"

declare -a cli_blocking_reasons=()
declare -a t0_blocking_reasons=()
declare -a t1_blocking_reasons=()
declare -a t2_blocking_reasons=()
declare -a t3_blocking_reasons=()

sanitize_text() {
  printf '%s' "$1" | tr '\r\n\t' '   '
}

json_escape() {
  sanitize_text "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

append_reason() {
  local array_name="$1"
  local reason
  local escaped_reason
  reason="$(sanitize_text "$2")"
  printf -v escaped_reason '%q' "${reason}"
  eval "${array_name}+=(${escaped_reason})"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --workspace)
        workspace="${2:-}"
        shift 2
        ;;
      *)
        append_reason "cli_blocking_reasons" "unsupported argument: $1"
        shift
        ;;
    esac
  done

  if [ -z "${workspace}" ]; then
    append_reason "cli_blocking_reasons" "--workspace is required"
    return
  fi

  case "${workspace}" in
    /*) ;;
    *)
      append_reason "cli_blocking_reasons" "--workspace must be an absolute path"
      ;;
  esac

  if [ ! -d "${workspace}" ]; then
    append_reason "cli_blocking_reasons" "--workspace does not exist or is not a directory"
  fi
}

setup_output_paths() {
  report_dir="${workspace}/.tmp/governance/test_gate"
  report_txt="${report_dir}/report.txt"
  report_json="${report_dir}/report.json"
  mkdir -p "${report_dir}"
}

propagate_cli_blockers() {
  local reason
  for reason in "${cli_blocking_reasons[@]}"; do
    append_reason "t0_blocking_reasons" "${reason}"
    append_reason "t1_blocking_reasons" "${reason}"
    append_reason "t2_blocking_reasons" "${reason}"
    append_reason "t3_blocking_reasons" "${reason}"
  done
}

check_readable_file() {
  local array_name="$1"
  local file_path="$2"
  local label="$3"

  if [ ! -e "${file_path}" ]; then
    append_reason "${array_name}" "${label} is missing: ${file_path}"
    return
  fi

  if [ ! -r "${file_path}" ]; then
    append_reason "${array_name}" "${label} is not readable: ${file_path}"
  fi
}

check_executable_file() {
  local array_name="$1"
  local file_path="$2"
  local label="$3"

  check_readable_file "${array_name}" "${file_path}" "${label}"
  if [ -e "${file_path}" ] && [ ! -x "${file_path}" ]; then
    append_reason "${array_name}" "${label} is not executable: ${file_path}"
  fi
}

check_file_contains() {
  local array_name="$1"
  local file_path="$2"
  local pattern="$3"
  local label="$4"

  if [ ! -r "${file_path}" ]; then
    append_reason "${array_name}" "${label} is unreadable for pattern check: ${file_path}"
    return
  fi

  if ! rg -Fq -- "${pattern}" "${file_path}"; then
    append_reason "${array_name}" "${label} is not frozen in ${file_path}: ${pattern}"
  fi
}

evaluate_t0() {
  check_readable_file \
    "t0_blocking_reasons" \
    "${workspace}/docs/00_ssot/engineering_governance_testing_repo_hygiene_addendum.md" \
    "T0 engineering governance addendum"
  check_readable_file \
    "t0_blocking_reasons" \
    "${workspace}/docs/00_ssot/gate_register_v1.md" \
    "T0 gate register"
  check_readable_file \
    "t0_blocking_reasons" \
    "${workspace}/docs/00_ssot/source_of_truth_map.md" \
    "T0 source-of-truth map"
}

evaluate_t1() {
  check_executable_file \
    "t1_blocking_reasons" \
    "${workspace}/packages/tooling/governance_observe_tree.sh" \
    "T1 governance_observe_tree.sh"
  check_executable_file \
    "t1_blocking_reasons" \
    "${workspace}/packages/tooling/governance_repo_hygiene_check.sh" \
    "T1 governance_repo_hygiene_check.sh"
  check_executable_file \
    "t1_blocking_reasons" \
    "${workspace}/packages/tooling/governance_release_signoff_check.sh" \
    "T1 governance_release_signoff_check.sh"
}

evaluate_t2() {
  local smoke_script="${workspace}/infra/scripts/smoke.sh"
  local signoff_script="${workspace}/packages/tooling/governance_release_signoff_check.sh"

  check_executable_file \
    "t2_blocking_reasons" \
    "${smoke_script}" \
    "T2 runtime smoke entry script"
  check_readable_file \
    "t2_blocking_reasons" \
    "${signoff_script}" \
    "T2 release signoff entry script"
  check_file_contains \
    "t2_blocking_reasons" \
    "${signoff_script}" \
    ".tmp/governance/release_signoff" \
    "T2 release signoff output directory"
  check_file_contains \
    "t2_blocking_reasons" \
    "${signoff_script}" \
    "report.txt" \
    "T2 release signoff report.txt output"
  check_file_contains \
    "t2_blocking_reasons" \
    "${signoff_script}" \
    "report.json" \
    "T2 release signoff report.json output"
}

evaluate_t3() {
  check_readable_file \
    "t3_blocking_reasons" \
    "${workspace}/docs/00_ssot/engineering_governance_testing_repo_hygiene_addendum.md" \
    "T3 engineering governance addendum"
  check_readable_file \
    "t3_blocking_reasons" \
    "${workspace}/docs/00_ssot/gate_register_v1.md" \
    "T3 gate register"
  check_readable_file \
    "t3_blocking_reasons" \
    "${workspace}/docs/00_ssot/independent_verification_channel_recovery_addendum.md" \
    "T3 independent verification recovery addendum"
}

finalize_status() {
  local array_name="$1"
  local status_name="$2"
  local reasons=()

  set +u
  eval "reasons=(\"\${${array_name}[@]}\")"
  set -u
  if [ "${#reasons[@]}" -eq 0 ]; then
    printf -v "${status_name}" '%s' "passed"
  else
    printf -v "${status_name}" '%s' "blocked"
  fi
}

reasons_to_text() {
  local array_name="$1"
  local output="[]"
  local reason
  local first=1
  local reasons=()

  set +u
  eval "reasons=(\"\${${array_name}[@]}\")"
  set -u
  if [ "${#reasons[@]}" -eq 0 ]; then
    printf '%s' "${output}"
    return
  fi

  output="["
  for reason in "${reasons[@]}"; do
    if [ "${first}" -eq 0 ]; then
      output="${output}; "
    fi
    output="${output}${reason}"
    first=0
  done
  output="${output}]"
  printf '%s' "${output}"
}

reasons_to_json() {
  local array_name="$1"
  local json=""
  local reason
  local reasons=()

  set +u
  eval "reasons=(\"\${${array_name}[@]}\")"
  set -u

  if [ "${#reasons[@]}" -eq 0 ]; then
    printf '%s' "[]"
    return
  fi

  for reason in "${reasons[@]}"; do
    if [ -n "${json}" ]; then
      json="${json}, "
    fi
    json="${json}\"$(json_escape "${reason}")\""
  done

  printf '%s' "[${json}]"
}

write_reports() {
  cat > "${report_txt}" <<EOF
workspace=${workspace}
t0_status=${t0_status}
t0_blocking_reasons=$(reasons_to_text "t0_blocking_reasons")
t1_status=${t1_status}
t1_blocking_reasons=$(reasons_to_text "t1_blocking_reasons")
t2_status=${t2_status}
t2_blocking_reasons=$(reasons_to_text "t2_blocking_reasons")
t3_status=${t3_status}
t3_blocking_reasons=$(reasons_to_text "t3_blocking_reasons")
gate_conclusion=${gate_conclusion}
EOF

  cat > "${report_json}" <<EOF
{
  "workspace": "$(json_escape "${workspace}")",
  "t0": {
    "status": "$(json_escape "${t0_status}")",
    "blocking_reasons": $(reasons_to_json "t0_blocking_reasons")
  },
  "t1": {
    "status": "$(json_escape "${t1_status}")",
    "blocking_reasons": $(reasons_to_json "t1_blocking_reasons")
  },
  "t2": {
    "status": "$(json_escape "${t2_status}")",
    "blocking_reasons": $(reasons_to_json "t2_blocking_reasons")
  },
  "t3": {
    "status": "$(json_escape "${t3_status}")",
    "blocking_reasons": $(reasons_to_json "t3_blocking_reasons")
  },
  "gate_conclusion": "$(json_escape "${gate_conclusion}")"
}
EOF
}

print_stdout() {
  cat "${report_txt}"
}

main() {
  parse_args "$@"

  if [ -n "${workspace}" ] && [ "${workspace#/}" != "${workspace}" ]; then
    setup_output_paths
  fi

  if [ "${#cli_blocking_reasons[@]}" -gt 0 ]; then
    propagate_cli_blockers
  else
    evaluate_t0
    evaluate_t1
    evaluate_t2
    evaluate_t3
  fi

  finalize_status "t0_blocking_reasons" "t0_status"
  finalize_status "t1_blocking_reasons" "t1_status"
  finalize_status "t2_blocking_reasons" "t2_status"
  finalize_status "t3_blocking_reasons" "t3_status"

  if [ "${t0_status}" = "passed" ] && \
     [ "${t1_status}" = "passed" ] && \
     [ "${t2_status}" = "passed" ] && \
     [ "${t3_status}" = "passed" ]; then
    gate_conclusion="passed"
  else
    gate_conclusion="blocked"
  fi

  if [ -n "${report_dir}" ]; then
    write_reports
    print_stdout
  else
    cat <<EOF
workspace=${workspace}
t0_status=${t0_status}
t0_blocking_reasons=$(reasons_to_text "t0_blocking_reasons")
t1_status=${t1_status}
t1_blocking_reasons=$(reasons_to_text "t1_blocking_reasons")
t2_status=${t2_status}
t2_blocking_reasons=$(reasons_to_text "t2_blocking_reasons")
t3_status=${t3_status}
t3_blocking_reasons=$(reasons_to_text "t3_blocking_reasons")
gate_conclusion=${gate_conclusion}
EOF
  fi
}

main "$@"
