#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

real_nvim() {
  CONFIG_DIR="$CONFIG_DIR" "$SCRIPT_DIR/resolve-nvim-bin.sh"
}

usage() {
  cat <<EOF
Usage: nvim [nvim args...]

Examples:
  nvim .
  NVIM_VIM_ONLY=1 nvim .
  NVIM_VIM_ONLY=0 nvim ~/code/my-workspace

Environment:
  NVIM_VIM_ONLY=1   Stop Cursor/VS Code/JetBrains indexing for the workspace/crate root
  NVIM_VIM_ONLY=0   Restore IDE indexing for the workspace/crate root

Plain \`nvim .\` does not change IDE indexing.

Install once on any machine:
  ${CONFIG_DIR}/scripts/install-nvim-wrapper.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

nvim_bin="$(real_nvim)"
nvim_args=("$@")

if [[ ${#nvim_args[@]} -eq 0 ]]; then
  nvim_args=(".")
fi

exec "$nvim_bin" "${nvim_args[@]}"
