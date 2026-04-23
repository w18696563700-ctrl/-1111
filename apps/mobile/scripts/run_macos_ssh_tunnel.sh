#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export APP_RUNTIME_ENTRY_MODE="${APP_RUNTIME_ENTRY_MODE:-ssh_tunnel}"

exec "$SCRIPT_DIR/run_macos_formal.sh"
