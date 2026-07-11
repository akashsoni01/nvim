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
  NVIM_VIM_ONLY=0 nvim ~/code/my-workspace
  NVIM_VIM_FORCE=1 nvim .

Environment:
  (default)         No IDE/LLM changes — plain nvim startup
  NVIM_VIM_ONLY=1   Mark workspace Neovim-only; stash IDE/LLM files on enter
  NVIM_VIM_ONLY=0   Restore IDE indexing for the workspace/crate root
  NVIM_VIM_ONLY=2   Enhanced block: mark parent super/, add Claude ignores,
                    keep ignore files on disk while Neovim runs
  NVIM_VIM_FORCE=1  Enable system clipboard, external completions, and network installs
  NVIM_LIGHT=1      Low-memory mode: lighter rust-analyzer, skip target/ in grep, faster gd fallback
  NVIM_RA_LINK_ALL=1 Load all sibling Cargo crates (cross-crate gd); uses more RAM

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
