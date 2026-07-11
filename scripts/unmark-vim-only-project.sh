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
  local check_fn="$2"

  if "$check_fn" "$file"; then
    rm -f "$file"
    removed=$((removed + 1))
    echo "Removed: $file"
    return 0
  fi

  if [[ -f "$file" ]]; then
    skipped=$((skipped + 1))
    echo "Skipped (custom file): $file"
  fi
}

remove_owned_tree() {
  local path="$1"
  local marker_file="$2"
  local check_fn="$3"

  if "$check_fn" "$marker_file"; then
    rm -rf "$path"
    removed=$((removed + 1))
    echo "Removed: $path"
    return 0
  fi

  if [[ -e "$path" ]]; then
    skipped=$((skipped + 1))
    echo "Skipped (custom path): $path"
  fi
}

bash "$SCRIPT_DIR/vim-only-stash.sh" force-restore "$project" >/dev/null 2>&1 || true

remove_owned_tree "$project/.vscode" "$project/.vscode/settings.json" has_marker

for ignore_file in \
  "$project/.cursorignore" \
  "$project/.cursorindexingignore" \
  "$project/.ignore"; do
  remove_owned_file "$ignore_file" has_marker
done

remove_owned_file "$project/.cursor/rules/neovim-only.mdc" has_marker
if [[ -d "$project/.cursor/rules" ]] && [[ -z "$(ls -A "$project/.cursor/rules")" ]]; then
  rmdir "$project/.cursor/rules"
fi
if [[ -d "$project/.cursor" ]] && [[ -z "$(ls -A "$project/.cursor")" ]]; then
  rmdir "$project/.cursor"
fi

remove_owned_file "$project/.neovim-only" is_vim_only_neovim_marker

if is_vim_only_jetbrains_misc "$project/.idea/misc.xml"; then
  rm -f "$project/.idea/misc.xml"
  removed=$((removed + 1))
  echo "Removed: $project/.idea/misc.xml"
  if [[ -d "$project/.idea" ]] && [[ -z "$(ls -A "$project/.idea")" ]]; then
    rmdir "$project/.idea"
    echo "Removed empty directory: $project/.idea"
  fi
elif [[ -f "$project/.idea/misc.xml" ]]; then
  skipped=$((skipped + 1))
  echo "Skipped (custom JetBrains config): $project/.idea/misc.xml"
fi

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
