#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=vim-only-common.sh
source "$SCRIPT_DIR/vim-only-common.sh"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-path>" >&2
  echo "Marks a project as Neovim-only so other IDEs stop indexing it." >&2
  exit 1
fi

project="$(cd "$1" && pwd)"
stash_dir="$(stash_dir_for "$project")"

mkdir -p "$stash_dir"
write_vim_only_files "$stash_dir"
printf '%s\n' "$project" >"$stash_dir/project.path"
registry_add "$project"

bash "$SCRIPT_DIR/vim-only-stash.sh" deploy "$project"

echo "Marked as Neovim-only: $project"
echo "  - stash: $stash_dir"
echo "IDE/LLM marker files stay in the project only while Neovim is closed."
