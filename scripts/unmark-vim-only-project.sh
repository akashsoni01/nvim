#!/usr/bin/env bash
set -euo pipefail

MARKER="Neovim is the primary editor for this project."

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-path>" >&2
  echo "Restores IDE indexing markers created by mark-vim-only-project.sh." >&2
  exit 1
fi

project="$(cd "$1" && pwd)"
vscode_dir="$project/.vscode"
vscode_settings="$vscode_dir/settings.json"
cursor_ignore="$project/.cursorignore"
cursor_indexing_ignore="$project/.cursorindexingignore"
cursor_rules_file="$project/.cursor/rules/neovim-only.mdc"
search_ignore="$project/.ignore"
neovim_marker="$project/.neovim-only"
jetbrains_misc="$project/.idea/misc.xml"

removed=0
skipped=0

has_marker() {
  local file="$1"
  [[ -f "$file" ]] && grep -Fq "$MARKER" "$file"
}

is_vim_only_neovim_marker() {
  local file="$1"
  [[ -f "$file" ]] && grep -Fxq "$MARKER" "$file"
}

is_vim_only_jetbrains_misc() {
  local file="$1"
  [[ -f "$file" ]] && grep -Fq '<component name="NeovimOnlyProject"' "$file"
}

if has_marker "$vscode_settings"; then
  rm -f "$vscode_settings"
  removed=$((removed + 1))
  echo "Removed: $vscode_settings"

  if [[ -d "$vscode_dir" ]] && [[ -z "$(ls -A "$vscode_dir")" ]]; then
    rmdir "$vscode_dir"
    echo "Removed empty directory: $vscode_dir"
  fi
elif [[ -f "$vscode_settings" ]]; then
  skipped=$((skipped + 1))
  echo "Skipped (custom settings): $vscode_settings"
fi

for ignore_file in "$cursor_ignore" "$cursor_indexing_ignore" "$search_ignore"; do
  if has_marker "$ignore_file"; then
    rm -f "$ignore_file"
    removed=$((removed + 1))
    echo "Removed: $ignore_file"
  elif [[ -f "$ignore_file" ]]; then
    skipped=$((skipped + 1))
    echo "Skipped (custom ignore file): $ignore_file"
  fi
done

if has_marker "$cursor_rules_file"; then
  rm -f "$cursor_rules_file"
  removed=$((removed + 1))
  echo "Removed: $cursor_rules_file"

  if [[ -d "$project/.cursor/rules" ]] && [[ -z "$(ls -A "$project/.cursor/rules")" ]]; then
    rmdir "$project/.cursor/rules"
    echo "Removed empty directory: $project/.cursor/rules"
  fi
  if [[ -d "$project/.cursor" ]] && [[ -z "$(ls -A "$project/.cursor")" ]]; then
    rmdir "$project/.cursor"
    echo "Removed empty directory: $project/.cursor"
  fi
elif [[ -f "$cursor_rules_file" ]]; then
  skipped=$((skipped + 1))
  echo "Skipped (custom Cursor rule): $cursor_rules_file"
fi

if is_vim_only_neovim_marker "$neovim_marker"; then
  rm -f "$neovim_marker"
  removed=$((removed + 1))
  echo "Removed: $neovim_marker"
elif [[ -f "$neovim_marker" ]]; then
  skipped=$((skipped + 1))
  echo "Skipped (custom marker): $neovim_marker"
fi

if is_vim_only_jetbrains_misc "$jetbrains_misc"; then
  rm -f "$jetbrains_misc"
  removed=$((removed + 1))
  echo "Removed: $jetbrains_misc"

  if [[ -d "$project/.idea" ]] && [[ -z "$(ls -A "$project/.idea")" ]]; then
    rmdir "$project/.idea"
    echo "Removed empty directory: $project/.idea"
  fi
elif [[ -f "$jetbrains_misc" ]]; then
  skipped=$((skipped + 1))
  echo "Skipped (custom JetBrains config): $jetbrains_misc"
fi

if [[ $removed -eq 0 && $skipped -eq 0 ]]; then
  echo "Nothing to reset in: $project"
  exit 0
fi

echo "Reset IDE indexing for: $project"
if [[ $skipped -gt 0 ]]; then
  echo "Left $skipped custom file(s) untouched."
fi
echo "Reload the Cursor/VS Code window (Cmd+Shift+P -> Developer: Reload Window) if this project is already open."
