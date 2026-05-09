#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Required file not found: $path"
}

require_pattern() {
  local path="$1"
  local pattern="$2"
  local description="$3"

  if ! grep -Eq "$pattern" "$path"; then
    fail "$description is not configured as expected in $path"
  fi
}

plist_key_uses_value() {
  local path="$1"
  local key="$2"
  local expected="$3"

  awk -v key="<key>${key}</key>" -v expected="<string>${expected}</string>" '
    index($0, key) {
      found = 1
      next
    }
    found && index($0, expected) {
      ok = 1
      exit
    }
    found && index($0, "<key>") {
      exit 1
    }
    END {
      if (!ok) {
        exit 1
      }
    }
  ' "$path"
}

repo_root_required_files=(
  "package.json"
  "apps/mobile/pubspec.yaml"
)

for required in "${repo_root_required_files[@]}"; do
  require_file "$required"
done

pubspec_path="apps/mobile/pubspec.yaml"
android_gradle_path="apps/mobile/android/app/build.gradle.kts"
ios_info_plist_path="apps/mobile/ios/Runner/Info.plist"
xcode_project_path="apps/mobile/ios/Runner.xcodeproj/project.pbxproj"

require_file "$android_gradle_path"
require_file "$ios_info_plist_path"

version_line="$(grep -E '^[[:space:]]*version:' "$pubspec_path" | head -n 1 || true)"
[[ -n "$version_line" ]] || fail "Missing version field in $pubspec_path"

version_value="${version_line#*:}"
version_value="${version_value%%#*}"
version_value="$(printf '%s' "$version_value" | xargs)"

if [[ ! "$version_value" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  fail "Mobile version must use x.y.z+n format in $pubspec_path, got: $version_value"
fi

app_version="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
build_number="${BASH_REMATCH[4]}"

if (( 10#$build_number <= 0 )); then
  fail "Mobile build number must be greater than 0, got: $build_number"
fi

require_pattern \
  "$android_gradle_path" \
  '^[[:space:]]*versionName[[:space:]]*=[[:space:]]*flutter\.versionName[[:space:]]*$' \
  "Android versionName"

require_pattern \
  "$android_gradle_path" \
  '^[[:space:]]*versionCode[[:space:]]*=[[:space:]]*flutter\.versionCode[[:space:]]*$' \
  "Android versionCode"

if ! plist_key_uses_value "$ios_info_plist_path" "CFBundleShortVersionString" '$(FLUTTER_BUILD_NAME)'; then
  fail "iOS CFBundleShortVersionString must use \$(FLUTTER_BUILD_NAME) in $ios_info_plist_path"
fi

if ! plist_key_uses_value "$ios_info_plist_path" "CFBundleVersion" '$(FLUTTER_BUILD_NUMBER)'; then
  fail "iOS CFBundleVersion must use \$(FLUTTER_BUILD_NUMBER) in $ios_info_plist_path"
fi

printf 'Mobile version preflight check\n'
printf 'App version: %s\n' "$app_version"
printf 'Build number: %s\n' "$build_number"
printf 'Android versionName source: flutter.versionName\n'
printf 'Android versionCode source: flutter.versionCode\n'
printf 'iOS CFBundleShortVersionString source: $(FLUTTER_BUILD_NAME)\n'
printf 'iOS CFBundleVersion source: $(FLUTTER_BUILD_NUMBER)\n'

if [[ -f "$xcode_project_path" ]]; then
  static_current_project_version="$(
    grep -nE 'CURRENT_PROJECT_VERSION[[:space:]]*=[[:space:]]*"?[0-9]+([.][0-9]+)?' "$xcode_project_path" || true
  )"
  static_marketing_version="$(
    grep -nE 'MARKETING_VERSION[[:space:]]*=[[:space:]]*"?[0-9]+([.][0-9]+)?' "$xcode_project_path" || true
  )"

  if [[ -n "$static_current_project_version" ]]; then
    warn "Static CURRENT_PROJECT_VERSION entries may drift from Flutter build number:"
    printf '%s\n' "$static_current_project_version" >&2
  fi

  if [[ -n "$static_marketing_version" ]]; then
    warn "Static MARKETING_VERSION entries may drift from Flutter build name:"
    printf '%s\n' "$static_marketing_version" >&2
  fi
fi

printf 'PASS: mobile version preflight check passed.\n'
