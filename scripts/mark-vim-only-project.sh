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

mark_one_project() {
  local project="$1"
  local parent_super="${2:-false}"
  local stash_dir

  stash_dir="$(stash_dir_for "$project")"
  mkdir -p "$stash_dir"
  write_vim_only_files "$stash_dir" "$parent_super" "$project"
  printf '%s\n' "$project" >"$stash_dir/project.path"
  registry_add "$project"
  bash "$SCRIPT_DIR/vim-only-stash.sh" deploy "$project"
  echo "Marked as Neovim-only: $project"
  echo "  - stash: $stash_dir"
}

project="$(cd "$1" && pwd)"

mark_one_project "$project" false

if vim_only_mode_is_enhanced; then
  parent="$(parent_super_dir "$project")"
  if [[ -n "$parent" && "$parent" != "$project" ]]; then
    mark_one_project "$parent" true
    echo "  - parent super marked: $parent"
  fi
fi

echo "IDE/LLM marker files stay in the project only while Neovim is closed."
if keep_ignores_on_disk; then
  echo "Ignore files (.cursorignore, .claudeignore, .ignore) stay on disk while Neovim runs (NVIM_VIM_ONLY=2)."
fi
