#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export APP_BFF_BASE_URL="${APP_BFF_BASE_URL:-http://47.108.180.198/api/app}"

exec "$SCRIPT_DIR/run_macos_formal.sh"
