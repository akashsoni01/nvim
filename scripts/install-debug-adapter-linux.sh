#!/usr/bin/env bash
set -euo pipefail
# Legacy name: Java DAP comes from Mason; this script installs a JDK on Linux.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-java-linux.sh" "$@"
