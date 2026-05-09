#!/usr/bin/env bash
set -euo pipefail

allowed_file="apps/mobile/pubspec.yaml"
preflight_script="packages/tooling/mobile_version_preflight_check.sh"

fail_fast() {
  printf 'ERROR: %s\n' "$*" >&2
  printf 'FAIL: mobile release commit guard failed.\n' >&2
  exit 1
}

append_line() {
  local current="$1"
  local line="$2"

  if [[ -z "$current" ]]; then
    printf '%s' "$line"
  else
    printf '%s\n%s' "$current" "$line"
  fi
}

add_error() {
  errors="$(append_line "$errors" "- $*")"
}

non_empty_lines() {
  awk 'NF { print }' <<< "$1"
}

line_count() {
  non_empty_lines "$1" | wc -l | tr -d '[:space:]'
}

print_list() {
  local title="$1"
  local lines="$2"
  local compact

  compact="$(non_empty_lines "$lines")"
  printf '%s:\n' "$title"
  if [[ -z "$compact" ]]; then
    printf '%s\n' '- (none)'
  else
    printf '%s\n' "$compact" | sed 's/^/- /'
  fi
}

is_blocked_path() {
  case "$1" in
    infra/env/*|apps/server/*|apps/bff/*|.github/workflows/*|packages/tooling/*|apps/mobile/test/failures/*|runtime/*|artifacts/*|docs/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || fail_fast "Run this script inside a git repository."
repo_root="$(cd "$repo_root" && pwd -P)"
current_dir="$(pwd -P)"
[[ "$current_dir" == "$repo_root" ]] || fail_fast "Run this script from the repository root: $repo_root"

errors=""
blocked_staged_files=""
blocked_unstaged_untracked_files=""
allowed_staged_files=""

staged_files="$(git diff --cached --name-only)"
unstaged_files="$(git diff --name-only)"
untracked_files="$(git ls-files --others --exclude-standard)"

staged_count="$(line_count "$staged_files")"

while IFS= read -r path; do
  [[ -n "$path" ]] || continue

  if [[ "$path" == "$allowed_file" ]]; then
    allowed_staged_files="$(append_line "$allowed_staged_files" "$path")"
  fi

  if is_blocked_path "$path"; then
    blocked_staged_files="$(append_line "$blocked_staged_files" "$path")"
  fi
done <<< "$staged_files"

while IFS= read -r path; do
  [[ -n "$path" ]] || continue

  if is_blocked_path "$path"; then
    blocked_unstaged_untracked_files="$(append_line "$blocked_unstaged_untracked_files" "$path")"
  fi
done <<< "$(printf '%s\n%s\n' "$unstaged_files" "$untracked_files")"

print_list "Staged files" "$staged_files"
print_list "Unstaged files" "$unstaged_files"
print_list "Untracked files" "$untracked_files"
print_list "Allowed release commit file" "$allowed_file"
print_list "Allowed staged files" "$allowed_staged_files"
print_list "Blocked staged files" "$blocked_staged_files"

if [[ -n "$(non_empty_lines "$blocked_unstaged_untracked_files")" ]]; then
  print_list "Blocked unstaged/untracked WARN" "$blocked_unstaged_untracked_files"
  printf 'WARN: blocked paths exist outside the staged release commit. Do not include them in the release commit.\n' >&2
else
  print_list "Blocked unstaged/untracked WARN" ""
fi

if [[ "$staged_count" -eq 0 ]]; then
  add_error "release commit needs and can only stage $allowed_file"
fi

if [[ "$staged_count" -gt 1 ]]; then
  add_error "release commit can stage only one file: $allowed_file"
fi

if [[ "$staged_count" -eq 1 && "$(non_empty_lines "$staged_files")" != "$allowed_file" ]]; then
  add_error "staged file must be $allowed_file"
fi

if [[ -n "$(non_empty_lines "$blocked_staged_files")" ]]; then
  add_error "blocked paths are staged and must be removed from the release commit"
fi

if [[ ! -f "$preflight_script" ]]; then
  add_error "required preflight script not found: $preflight_script"
else
  printf 'Running mobile version preflight...\n'
  if ! bash "$preflight_script"; then
    add_error "mobile version preflight failed: $preflight_script"
  fi
fi

if [[ -n "$errors" ]]; then
  printf 'FAIL reasons:\n%s\n' "$errors" >&2
  printf 'FAIL: mobile release commit guard failed.\n' >&2
  exit 1
fi

printf 'PASS: mobile release commit guard passed.\n'
