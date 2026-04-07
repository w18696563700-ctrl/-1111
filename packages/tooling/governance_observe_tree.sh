#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/.tmp/governance/observe_tree"
REPORT_TXT="${OUTPUT_DIR}/report.txt"
REPORT_JSON="${OUTPUT_DIR}/report.json"
GENERATED_AT="$(date '+%Y-%m-%d %H:%M:%S %z')"

mkdir -p "${OUTPUT_DIR}"

TEXT_REPORT=""
JSON_ITEMS=""
PRESENT_COUNT=0
MISSING_COUNT=0
PLACEHOLDER_COUNT=0

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

append_line() {
  TEXT_REPORT+="$1"$'\n'
}

append_item() {
  local level="$1"
  local kind="$2"
  local name="$3"
  local target="$4"
  local status="$5"
  local detail="$6"
  local item

  case "${status}" in
    present) PRESENT_COUNT=$((PRESENT_COUNT + 1)) ;;
    missing) MISSING_COUNT=$((MISSING_COUNT + 1)) ;;
    placeholder) PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1)) ;;
  esac

  append_line "[${level}][${kind}][${status}] ${name} :: ${target} :: ${detail}"

  item=$(
    printf '{\"level\":\"%s\",\"kind\":\"%s\",\"name\":\"%s\",\"target\":\"%s\",\"status\":\"%s\",\"detail\":\"%s\"}' \
      "$(json_escape "${level}")" \
      "$(json_escape "${kind}")" \
      "$(json_escape "${name}")" \
      "$(json_escape "${target}")" \
      "$(json_escape "${status}")" \
      "$(json_escape "${detail}")"
  )

  if [ -n "${JSON_ITEMS}" ]; then
    JSON_ITEMS+=$',\n'
  fi
  JSON_ITEMS+="    ${item}"
}

check_path_presence() {
  local level="$1"
  local kind="$2"
  local name="$3"
  local relative_path="$4"

  if [ -e "${ROOT_DIR}/${relative_path}" ]; then
    append_item "${level}" "${kind}" "${name}" "${relative_path}" "present" "local path present"
  else
    append_item "${level}" "${kind}" "${name}" "${relative_path}" "missing" "local path missing"
  fi
}

append_placeholder() {
  local level="$1"
  local kind="$2"
  local name="$3"
  local target="$4"
  local detail="$5"
  append_item "${level}" "${kind}" "${name}" "${target}" "placeholder" "${detail}"
}

append_line "# Governance Observe Tree"
append_line "generated_at: ${GENERATED_AT}"
append_line "root_dir: ${ROOT_DIR}"
append_line "mode: readonly by default; only stdout and .tmp/governance/observe_tree outputs are written"
append_line ""
append_line "## L0 truth"
check_path_presence "L0" "truth_file" "stage objective" "docs/00_ssot/next_stage_candidate_ranking_and_unique_goal.md"
check_path_presence "L0" "truth_file" "governance baseline" "docs/00_ssot/engineering_governance_testing_repo_hygiene_addendum.md"
check_path_presence "L0" "truth_file" "repo cleanliness constitution" "docs/00_ssot/repo_cleanliness_constitution.md"
check_path_presence "L0" "truth_file" "gate register" "docs/00_ssot/gate_register_v1.md"
check_path_presence "L0" "truth_file" "source of truth map" "docs/00_ssot/source_of_truth_map.md"
check_path_presence "L0" "truth_root" "canonical contracts root" "docs/01_contracts"
check_path_presence "L0" "truth_file" "canonical contract entrypoint" "docs/01_contracts/openapi.yaml"
check_path_presence "L0" "truth_file" "audit sign-off reference" "docs/02_backend/audit_log_spec.md"

append_line ""
append_line "## L1 implementation projection"
check_path_presence "L1" "workspace_root" "server implementation root" "apps/server"
check_path_presence "L1" "workspace_root" "bff implementation root" "apps/bff"
check_path_presence "L1" "workspace_root" "mobile implementation root" "apps/mobile"
check_path_presence "L1" "workspace_root" "admin implementation root" "apps/admin"
check_path_presence "L1" "workspace_root" "tooling root" "packages/tooling"
check_path_presence "L1" "workspace_root" "contracts projection root" "packages/contracts"
append_placeholder "L1" "cloud_release" "cloud server release root" "/srv/releases/server" "cloud-only verification entry placeholder; not probed by this local governance script"
append_placeholder "L1" "cloud_release" "cloud bff release root" "/srv/releases/bff" "cloud-only verification entry placeholder; not probed by this local governance script"
append_placeholder "L1" "cloud_current" "active server current symlink" "/srv/apps/server/current" "cloud-only verification entry placeholder; not probed by this local governance script"
append_placeholder "L1" "cloud_current" "active bff current symlink" "/srv/apps/bff/current" "cloud-only verification entry placeholder; not probed by this local governance script"

append_line ""
append_line "## L2 runtime health"
check_path_presence "L2" "runtime_support_root" "local nginx config root" "infra/nginx"
check_path_presence "L2" "runtime_support_root" "local infra scripts root" "infra/scripts"
append_placeholder "L2" "runtime_probe" "systemctl exhibition-server" "systemctl status exhibition-server" "runtime verification placeholder only; no cloud command is executed in this batch"
append_placeholder "L2" "runtime_probe" "systemctl exhibition-bff" "systemctl status exhibition-bff" "runtime verification placeholder only; no cloud command is executed in this batch"
append_placeholder "L2" "runtime_probe" "systemctl nginx" "systemctl status nginx" "runtime verification placeholder only; no cloud command is executed in this batch"
append_placeholder "L2" "endpoint_probe" "canonical app-facing endpoint responses" "curl /api/app/*" "app-facing endpoint verification entry placeholder only; no runtime smoke is executed in this batch"
append_placeholder "L2" "nginx_probe" "canonical path stability" "nginx canonical-path stability" "Nginx canonical-path verification placeholder only; no runtime smoke is executed in this batch"

append_line ""
append_line "## L3 persistence and audit evidence"
check_path_presence "L3" "spec_reference" "db schema reference" "docs/02_backend/db_schema.md"
check_path_presence "L3" "spec_reference" "audit log reference" "docs/02_backend/audit_log_spec.md"
append_placeholder "L3" "persistence_probe" "business truth rows" "postgres truth rows verification" "persistence verification placeholder only; no database query is executed in this batch"
append_placeholder "L3" "audit_probe" "append-only audit rows" "postgres append-only audit verification" "audit verification placeholder only; no database query is executed in this batch"

append_line ""
append_line "## Summary"
append_line "present=${PRESENT_COUNT}"
append_line "missing=${MISSING_COUNT}"
append_line "placeholder=${PLACEHOLDER_COUNT}"
append_line "report_txt=${REPORT_TXT}"
append_line "report_json=${REPORT_JSON}"

cat > "${REPORT_TXT}" <<EOF
${TEXT_REPORT}
EOF

cat > "${REPORT_JSON}" <<EOF
{
  "script": "governance_observe_tree.sh",
  "generatedAt": "$(json_escape "${GENERATED_AT}")",
  "rootDir": "$(json_escape "${ROOT_DIR}")",
  "mode": "readonly-default",
  "summary": {
    "present": ${PRESENT_COUNT},
    "missing": ${MISSING_COUNT},
    "placeholder": ${PLACEHOLDER_COUNT}
  },
  "items": [
${JSON_ITEMS}
  ]
}
EOF

printf '%s\n' "${TEXT_REPORT}"
