#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/.tmp/governance/repo_hygiene"
REPORT_TXT="${OUTPUT_DIR}/report.txt"
REPORT_JSON="${OUTPUT_DIR}/report.json"
GENERATED_AT="$(date '+%Y-%m-%d %H:%M:%S %z')"

mkdir -p "${OUTPUT_DIR}"

TEXT_REPORT=""
JSON_FINDINGS=""

DOCS_CHECKED=0
DOCS_MISSING=0
POLLUTION_COUNT=0
FORBIDDEN_TYPE_COUNT=0
FILE_WARN_COUNT=0
FILE_BLOCK_COUNT=0
FUNCTION_WARN_COUNT=0
FUNCTION_BLOCK_COUNT=0

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

append_line() {
  TEXT_REPORT+="$1"$'\n'
}

append_finding() {
  local severity="$1"
  local category="$2"
  local target="$3"
  local detail="$4"
  local item

  case "${category}" in
    docs_metadata) DOCS_MISSING=$((DOCS_MISSING + 1)) ;;
    source_pollution) POLLUTION_COUNT=$((POLLUTION_COUNT + 1)) ;;
    forbidden_src_lib_type) FORBIDDEN_TYPE_COUNT=$((FORBIDDEN_TYPE_COUNT + 1)) ;;
    file_length)
      if [ "${severity}" = "block" ]; then
        FILE_BLOCK_COUNT=$((FILE_BLOCK_COUNT + 1))
      else
        FILE_WARN_COUNT=$((FILE_WARN_COUNT + 1))
      fi
      ;;
    function_length)
      if [ "${severity}" = "block" ]; then
        FUNCTION_BLOCK_COUNT=$((FUNCTION_BLOCK_COUNT + 1))
      else
        FUNCTION_WARN_COUNT=$((FUNCTION_WARN_COUNT + 1))
      fi
      ;;
  esac

  append_line "[${severity}][${category}] ${target} :: ${detail}"

  item=$(
    printf '{\"severity\":\"%s\",\"category\":\"%s\",\"target\":\"%s\",\"detail\":\"%s\"}' \
      "$(json_escape "${severity}")" \
      "$(json_escape "${category}")" \
      "$(json_escape "${target}")" \
      "$(json_escape "${detail}")"
  )

  if [ -n "${JSON_FINDINGS}" ]; then
    JSON_FINDINGS+=$',\n'
  fi
  JSON_FINDINGS+="    ${item}"
}

relative_path() {
  local path="$1"
  printf '%s' "${path#${ROOT_DIR}/}"
}

is_exempt_code_file() {
  case "$1" in
    */generated/*|*/migrations/*|*/fixtures/*|*/seeds/*|*/__mocks__/*|*/mock/*)
      return 0
      ;;
    *.g.dart|*.freezed.dart|*.gen.ts|*.generated.ts)
      return 0
      ;;
    *route*.dart|*routes*.dart|*route*.ts|*routes*.ts)
      return 0
      ;;
    */test/*|*/tests/*|*.test.ts|*.spec.ts|*.test.dart)
      return 0
      ;;
  esac
  return 1
}

scan_docs_metadata() {
  local file rel
  append_line "## docs metadata"
  while IFS= read -r file; do
    DOCS_CHECKED=$((DOCS_CHECKED + 1))
    rel="$(relative_path "${file}")"
    if ! awk '
      BEGIN {
        top_owner = 0
        top_status = 0
        top_purpose = 0
        in_doc_meta = 0
        doc_owner = 0
        doc_status = 0
        doc_purpose = 0
      }
      NR > 40 { exit }
      /^owner:[[:space:]]*/ { top_owner = 1 }
      /^status:[[:space:]]*/ { top_status = 1 }
      /^purpose:[[:space:]]*/ { top_purpose = 1 }
      /^doc_meta:[[:space:]]*$/ { in_doc_meta = 1; next }
      in_doc_meta && /^[^[:space:]]/ { in_doc_meta = 0 }
      in_doc_meta && /^[[:space:]]+owner:[[:space:]]*/ { doc_owner = 1 }
      in_doc_meta && /^[[:space:]]+status:[[:space:]]*/ { doc_status = 1 }
      in_doc_meta && /^[[:space:]]+purpose:[[:space:]]*/ { doc_purpose = 1 }
      END {
        if ((top_owner && top_status && top_purpose) || (doc_owner && doc_status && doc_purpose)) {
          exit 0
        }
        exit 1
      }
    ' "${file}"; then
      append_finding "warn" "docs_metadata" "${rel}" "missing required owner/status/purpose metadata in front matter or doc_meta"
    fi
  done < <(find "${ROOT_DIR}/docs" -type f | LC_ALL=C sort)

  if [ "${DOCS_MISSING}" -eq 0 ]; then
    append_line "[ok][docs_metadata] all ${DOCS_CHECKED} docs files include owner/status/purpose"
  fi
  append_line ""
}

scan_source_pollution() {
  local root file rel
  append_line "## source pollution"
  for root in \
    "${ROOT_DIR}/apps/server/src" \
    "${ROOT_DIR}/apps/bff/src" \
    "${ROOT_DIR}/apps/admin/src" \
    "${ROOT_DIR}/apps/mobile/lib"; do
    [ -d "${root}" ] || continue
    while IFS= read -r file; do
      rel="$(relative_path "${file}")"
      append_finding "block" "source_pollution" "${rel}" "suspicious non-truth filename found in source tree"
    done < <(
      find "${root}" -type f \
        \( -iname '*prompt*' -o -iname '*report*' -o -iname '*notes*' -o -iname '*backup*' -o -iname '*screenshot*' \) \
        | LC_ALL=C sort
    )
  done

  if [ "${POLLUTION_COUNT}" -eq 0 ]; then
    append_line "[ok][source_pollution] no obvious prompt/report/backup/screenshot filenames found under src/lib roots"
  fi
  append_line ""
}

scan_forbidden_types() {
  local root file rel
  append_line "## forbidden src/lib file types"
  for root in \
    "${ROOT_DIR}/apps/server/src" \
    "${ROOT_DIR}/apps/bff/src" \
    "${ROOT_DIR}/apps/admin/src" \
    "${ROOT_DIR}/apps/mobile/lib"; do
    [ -d "${root}" ] || continue
    while IFS= read -r file; do
      rel="$(relative_path "${file}")"
      append_finding "block" "forbidden_src_lib_type" "${rel}" "forbidden non-code file type in src/lib root"
    done < <(
      find "${root}" -type f \
        \( -iname '*.docx' -o -iname '*.txt' -o -iname '*.pdf' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.bak' -o -iname '*.backup' \) \
        | LC_ALL=C sort
    )
  done

  if [ "${FORBIDDEN_TYPE_COUNT}" -eq 0 ]; then
    append_line "[ok][forbidden_src_lib_type] no forbidden file types found under src/lib roots"
  fi
  append_line ""
}

scan_file_lengths() {
  local file rel lines severity
  append_line "## handwritten business source length"
  while IFS= read -r file; do
    is_exempt_code_file "${file}" && continue
    lines="$(wc -l < "${file}" | tr -d ' ')"
    if [ "${lines}" -ge 450 ]; then
      severity="block"
    elif [ "${lines}" -ge 400 ]; then
      severity="warn"
    else
      continue
    fi
    rel="$(relative_path "${file}")"
    append_finding "${severity}" "file_length" "${rel}" "handwritten source length=${lines} (warn=400 block=450)"
  done < <(
    find "${ROOT_DIR}/apps/server/src" "${ROOT_DIR}/apps/bff/src" "${ROOT_DIR}/apps/admin/src" "${ROOT_DIR}/apps/mobile/lib" \
      -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.dart' \) \
      | LC_ALL=C sort
  )

  if [ "${FILE_WARN_COUNT}" -eq 0 ] && [ "${FILE_BLOCK_COUNT}" -eq 0 ]; then
    append_line "[ok][file_length] no handwritten business source candidates reached the 400/450 thresholds"
  fi
  append_line ""
}

scan_function_lengths() {
  local file rel output severity start length header
  append_line "## handwritten function/method length"
  while IFS= read -r file; do
    is_exempt_code_file "${file}" && continue
    output="$(
      awk -v file="${file}" '
        function trim(s) {
          sub(/^[ \t]+/, "", s)
          sub(/[ \t]+$/, "", s)
          return s
        }
        function brace_delta(line,    i, c, delta, in_string, quote, prev) {
          delta = 0
          in_string = 0
          quote = ""
          prev = ""
          for (i = 1; i <= length(line); i++) {
            c = substr(line, i, 1)
            if (in_string) {
              if (c == quote && prev != "\\") {
                in_string = 0
                quote = ""
              }
            } else {
              if (c == "\"" || c == "'\''") {
                in_string = 1
                quote = c
              } else if (c == "{") {
                delta++
              } else if (c == "}") {
                delta--
              }
            }
            prev = c
          }
          return delta
        }
        function looks_like_function(line,    t) {
          t = trim(line)
          if (t ~ /^\/\// || t ~ /^\*/ || t ~ /^#/) return 0
          if (t ~ /^(if|for|while|switch|catch|else|try|do)\b/) return 0
          if (t !~ /\{/) return 0
          if (t ~ /function[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\(/) return 1
          if (t ~ /(const|let|var)[[:space:]]+[A-Za-z0-9_]+[[:space:]]*=[[:space:]]*(async[[:space:]]*)?\([^;]*\)[[:space:]]*=>[[:space:]]*\{/) return 1
          if (t ~ /^(async[[:space:]]+)?[A-Za-z0-9_]+[[:space:]]*\([^;]*\)[[:space:]]*\{/) return 1
          if (t ~ /^[A-Za-z0-9_<>,?. \[\]]+[[:space:]]+[A-Za-z0-9_]+[[:space:]]*\([^;]*\)[[:space:]]*\{/) return 1
          return 0
        }
        {
          if (!active && looks_like_function($0)) {
            active = 1
            start = NR
            header = trim($0)
            depth = brace_delta($0)
            if (depth <= 0) {
              length_lines = NR - start + 1
              if (length_lines >= 80) {
                severity = (length_lines >= 120 ? "block" : "warn")
                printf "%s\t%s\t%d\t%d\t%s\n", severity, file, start, length_lines, header
              }
              active = 0
              depth = 0
            }
            next
          }
          if (active) {
            depth += brace_delta($0)
            if (depth <= 0) {
              length_lines = NR - start + 1
              if (length_lines >= 80) {
                severity = (length_lines >= 120 ? "block" : "warn")
                printf "%s\t%s\t%d\t%d\t%s\n", severity, file, start, length_lines, header
              }
              active = 0
              depth = 0
            }
          }
        }
      ' "${file}"
    )"

    [ -n "${output}" ] || continue
    while IFS=$'\t' read -r severity _ start length header; do
      [ -n "${severity}" ] || continue
      rel="$(relative_path "${file}")"
      append_finding "${severity}" "function_length" "${rel}:${start}" "length=${length}; heuristic candidate=${header}"
    done <<EOF
${output}
EOF
  done < <(
    find "${ROOT_DIR}/apps/server/src" "${ROOT_DIR}/apps/bff/src" "${ROOT_DIR}/apps/admin/src" "${ROOT_DIR}/apps/mobile/lib" \
      -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.dart' \) \
      | LC_ALL=C sort
  )

  if [ "${FUNCTION_WARN_COUNT}" -eq 0 ] && [ "${FUNCTION_BLOCK_COUNT}" -eq 0 ]; then
    append_line "[ok][function_length] no heuristic handwritten function/method candidates reached the 80/120 thresholds"
  fi
  append_line ""
}

append_line "# Governance Repo Hygiene Check"
append_line "generated_at: ${GENERATED_AT}"
append_line "root_dir: ${ROOT_DIR}"
append_line "mode: readonly by default; only stdout and .tmp/governance/repo_hygiene outputs are written"
append_line ""

scan_docs_metadata
scan_source_pollution
scan_forbidden_types
scan_file_lengths
scan_function_lengths

append_line "## Summary"
append_line "docs_checked=${DOCS_CHECKED}"
append_line "docs_missing=${DOCS_MISSING}"
append_line "source_pollution=${POLLUTION_COUNT}"
append_line "forbidden_src_lib_type=${FORBIDDEN_TYPE_COUNT}"
append_line "file_length_warn=${FILE_WARN_COUNT}"
append_line "file_length_block=${FILE_BLOCK_COUNT}"
append_line "function_length_warn=${FUNCTION_WARN_COUNT}"
append_line "function_length_block=${FUNCTION_BLOCK_COUNT}"
append_line "report_txt=${REPORT_TXT}"
append_line "report_json=${REPORT_JSON}"

cat > "${REPORT_TXT}" <<EOF
${TEXT_REPORT}
EOF

cat > "${REPORT_JSON}" <<EOF
{
  "script": "governance_repo_hygiene_check.sh",
  "generatedAt": "$(json_escape "${GENERATED_AT}")",
  "rootDir": "$(json_escape "${ROOT_DIR}")",
  "mode": "readonly-default",
  "summary": {
    "docsChecked": ${DOCS_CHECKED},
    "docsMissing": ${DOCS_MISSING},
    "sourcePollution": ${POLLUTION_COUNT},
    "forbiddenSrcLibType": ${FORBIDDEN_TYPE_COUNT},
    "fileLengthWarn": ${FILE_WARN_COUNT},
    "fileLengthBlock": ${FILE_BLOCK_COUNT},
    "functionLengthWarn": ${FUNCTION_WARN_COUNT},
    "functionLengthBlock": ${FUNCTION_BLOCK_COUNT}
  },
  "findings": [
${JSON_FINDINGS}
  ]
}
EOF

printf '%s\n' "${TEXT_REPORT}"
