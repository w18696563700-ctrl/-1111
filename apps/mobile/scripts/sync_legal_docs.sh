#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/docs/legal"
TARGET_DIR="${ROOT_DIR}/apps/mobile/assets/legal"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "missing source dir: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}"

for file_name in user_agreement.md privacy_policy.md; do
  source_path="${SOURCE_DIR}/${file_name}"
  target_path="${TARGET_DIR}/${file_name}"

  if [[ ! -f "${source_path}" ]]; then
    echo "missing source file: ${source_path}" >&2
    exit 1
  fi

  cp "${source_path}" "${target_path}"
  echo "synced ${file_name}"
done
