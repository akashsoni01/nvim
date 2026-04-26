#!/usr/bin/env bash
set -euo pipefail
# Legacy name: Java DAP comes from Mason; this script installs a JDK in Termux.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-java-termux.sh" "$@"
