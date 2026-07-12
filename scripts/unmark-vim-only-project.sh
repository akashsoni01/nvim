#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=vim-only-common.sh
source "$SCRIPT_DIR/vim-only-common.sh"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-path>" >&2
  echo "Restores IDE indexing markers created by mark-vim-only-project.sh." >&2
  exit 1
fi

project="$(cd "$1" && pwd)"
stash_dir="$(stash_dir_for "$project")"

removed=0
skipped=0

remove_owned_file() {
  local file="$1"

  if is_vim_only_owned_file "$project" "$file"; then
    rm -f "$project/$file"
    removed=$((removed + 1))
    echo "Removed: $project/$file"
    return 0
  fi

  if [[ -f "$project/$file" ]]; then
    skipped=$((skipped + 1))
    echo "Skipped (custom file): $project/$file"
  fi
}

remove_owned_dir_if_marker() {
  local dir="$1"
  local marker_file="$2"

  if [[ ! -e "$project/$dir" ]]; then
    return 0
  fi

  if [[ -n "$marker_file" ]] && ! is_vim_only_owned_file "$project" "$marker_file"; then
    skipped=$((skipped + 1))
    echo "Skipped (custom path): $project/$dir"
    return 0
  fi

  rm -rf "$project/$dir"
  removed=$((removed + 1))
  echo "Removed: $project/$dir"
}

bash "$SCRIPT_DIR/vim-only-stash.sh" force-restore "$project" >/dev/null 2>&1 || true

local_rel=""
while IFS= read -r local_rel; do
  [[ -n "$local_rel" ]] || continue
  remove_owned_file "$local_rel"
done < <(vim_only_file_markers)

while IFS= read -r local_rel; do
  [[ -n "$local_rel" ]] || continue
  case "$local_rel" in
    .vscode) remove_owned_dir_if_marker ".vscode" ".vscode/settings.json" ;;
    .cursor) remove_owned_dir_if_marker ".cursor" ".cursor/rules/neovim-only.mdc" ;;
    .idea) remove_owned_dir_if_marker ".idea" ".idea/misc.xml" ;;
    .zed | .continue | .windsurf | .fleet | .github | .claude | .idx | .pearai | .codex)
      marker=""
      case "$local_rel" in
        .zed) marker=".zed/settings.json" ;;
        .continue) marker=".continue/config.json" ;;
        .windsurf) marker=".windsurf/settings.json" ;;
        .fleet) marker=".fleet/settings.json" ;;
        .github) marker=".github/copilot-instructions.md" ;;
        .claude) marker=".claude/settings.json" ;;
        .idx) marker=".idx/settings.json" ;;
        .pearai) marker=".pearai/settings.json" ;;
        .codex) marker=".codex/settings.json" ;;
      esac
      remove_owned_dir_if_marker "$local_rel" "$marker"
      ;;
  esac
done < <(vim_only_dir_markers)

if [[ -d "$stash_dir" ]]; then
  rm -rf "$stash_dir"
  removed=$((removed + 1))
  echo "Removed stash: $stash_dir"
fi

registry_remove "$project"

if [[ $removed -eq 0 && $skipped -eq 0 ]]; then
  echo "Nothing to reset in: $project"
  exit 0
fi

echo "Reset IDE indexing for: $project"
if [[ $skipped -gt 0 ]]; then
  echo "Left $skipped custom file(s) untouched."
fi
