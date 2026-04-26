#!/usr/bin/env bash
set -euo pipefail
# Legacy name: this config uses Mason in Neovim for Java DAP. This script checks/installs a JDK on macOS.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-java-macos.sh" "$@"
