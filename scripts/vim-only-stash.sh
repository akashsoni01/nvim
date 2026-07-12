#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=vim-only-common.sh
source "$SCRIPT_DIR/vim-only-common.sh"

usage() {
  cat <<EOF
Usage: $0 <stash|restore|deploy|force-restore|is-vim-only> <project-path>
EOF
}

session_dir_for() {
  local stash_dir="$1"
  printf '%s/sessions' "$stash_dir"
}

cleanup_dead_sessions() {
  local sessions_dir="$1"
  [[ -d "$sessions_dir" ]] || return 0

  local pid_file pid
  for pid_file in "$sessions_dir"/*.pid; do
    [[ -e "$pid_file" ]] || continue
    pid="$(basename "$pid_file" .pid)"
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f "$pid_file"
    fi
  done
}

active_session_count() {
  local sessions_dir="$1"
  cleanup_dead_sessions "$sessions_dir"
  find "$sessions_dir" -maxdepth 1 -name '*.pid' 2>/dev/null | wc -l | tr -d ' '
}

register_session() {
  local stash_dir="$1"
  local sessions_dir
  sessions_dir="$(session_dir_for "$stash_dir")"
  mkdir -p "$sessions_dir"
  printf '%s\n' "$$" >"$sessions_dir/$$.pid"
}

unregister_session() {
  local stash_dir="$1"
  local sessions_dir
  sessions_dir="$(session_dir_for "$stash_dir")"
  rm -f "$sessions_dir/$$.pid"
  cleanup_dead_sessions "$sessions_dir"
}

should_move_from_project() {
  local project="$1"
  local rel="$2"

  if keep_ignores_on_disk && ! stash_only_dirs_in_enhanced_mode "$rel"; then
    return 1
  fi

  case "$rel" in
    .vscode)
      has_marker "$project/.vscode/settings.json"
      ;;
    .cursor)
      has_marker "$project/.cursor/rules/neovim-only.mdc"
      ;;
    .zed)
      is_vim_only_editor_json "$project/.zed/settings.json"
      ;;
    .continue)
      is_vim_only_editor_json "$project/.continue/config.json"
      ;;
    .windsurf)
      is_vim_only_editor_json "$project/.windsurf/settings.json"
      ;;
    .fleet)
      is_vim_only_editor_json "$project/.fleet/settings.json"
      ;;
    .github)
      is_vim_only_agent_file "$project/.github/copilot-instructions.md" \
        || is_vim_only_agent_file "$project/.github/instructions/neovim-only.instructions.md"
      ;;
    .claude)
      is_vim_only_editor_json "$project/.claude/settings.json"
      ;;
    .idx)
      is_vim_only_editor_json "$project/.idx/settings.json"
      ;;
    .pearai)
      is_vim_only_editor_json "$project/.pearai/settings.json"
      ;;
    .codex)
      is_vim_only_editor_json "$project/.codex/settings.json"
      ;;
    .idea)
      is_vim_only_jetbrains_misc "$project/.idea/misc.xml"
      ;;
    .neovim-only)
      is_vim_only_neovim_marker "$project/$rel"
      ;;
    .idea/misc.xml)
      is_vim_only_jetbrains_misc "$project/$rel"
      ;;
    *)
      is_vim_only_owned_file "$project" "$rel"
      ;;
  esac
}

move_item_to_stash() {
  local project="$1"
  local stash_dir="$2"
  local rel="$3"
  local src="$project/$rel"
  local dest="$stash_dir/$rel"

  should_move_from_project "$project" "$rel" || return 0
  [[ -e "$src" ]] || return 0

  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" ]]; then
    rm -rf "$dest"
  fi
  mv "$src" "$dest"

  if [[ "$rel" == ".idea/misc.xml" ]]; then
    remove_empty_parents "$project/.idea" "$project"
  elif [[ "$rel" == ".claude/settings.json" ]]; then
    remove_empty_parents "$project/.claude" "$project"
  elif [[ "$rel" == ".zed/settings.json" ]]; then
    remove_empty_parents "$project/.zed" "$project"
  elif [[ "$rel" == ".continue/config.json" ]]; then
    remove_empty_parents "$project/.continue" "$project"
  elif [[ "$rel" == ".windsurf/settings.json" ]]; then
    remove_empty_parents "$project/.windsurf" "$project"
  elif [[ "$rel" == ".fleet/settings.json" ]]; then
    remove_empty_parents "$project/.fleet" "$project"
  elif [[ "$rel" == ".idx/settings.json" || "$rel" == ".pearai/settings.json" || "$rel" == ".codex/settings.json" || "$rel" == ".sourcery.yaml" ]]; then
    remove_empty_parents "$(dirname "$src")" "$project"
  elif [[ "$rel" == ".github/copilot-instructions.md" || "$rel" == ".github/instructions/neovim-only.instructions.md" ]]; then
    remove_empty_parents "$project/.github" "$project"
  elif [[ "$rel" == ".vscode" || "$rel" == ".cursor" || "$rel" == ".zed" || "$rel" == ".continue" || "$rel" == ".windsurf" || "$rel" == ".fleet" || "$rel" == ".github" || "$rel" == ".claude" || "$rel" == ".idx" || "$rel" == ".pearai" || "$rel" == ".codex" || "$rel" == ".idea" ]]; then
    remove_empty_parents "$project/$rel" "$project"
  fi
}

move_item_to_project() {
  local project="$1"
  local stash_dir="$2"
  local rel="$3"
  local src="$stash_dir/$rel"
  local dest="$project/$rel"

  [[ -e "$src" ]] || return 0
  if [[ -e "$dest" ]]; then
    rm -rf "$dest"
  fi
  mkdir -p "$(dirname "$dest")"
  mv "$src" "$dest"

  if [[ "$rel" == ".idea/misc.xml" ]]; then
    remove_empty_parents "$(dirname "$src")" "$stash_dir"
  elif [[ "$rel" == ".claude/settings.json" ]]; then
    remove_empty_parents "$(dirname "$src")" "$stash_dir"
  elif [[ "$rel" == ".zed/settings.json" || "$rel" == ".continue/config.json" || "$rel" == ".windsurf/settings.json" || "$rel" == ".fleet/settings.json" ]]; then
    remove_empty_parents "$(dirname "$src")" "$stash_dir"
  elif [[ "$rel" == ".idx/settings.json" || "$rel" == ".pearai/settings.json" || "$rel" == ".codex/settings.json" || "$rel" == ".sourcery.yaml" ]]; then
    remove_empty_parents "$(dirname "$src")" "$stash_dir"
  elif [[ "$rel" == ".github/copilot-instructions.md" || "$rel" == ".github/instructions/neovim-only.instructions.md" ]]; then
    remove_empty_parents "$(dirname "$src")" "$stash_dir"
  elif [[ "$rel" == ".vscode" || "$rel" == ".cursor" || "$rel" == ".zed" || "$rel" == ".continue" || "$rel" == ".windsurf" || "$rel" == ".fleet" || "$rel" == ".github" || "$rel" == ".claude" || "$rel" == ".idx" || "$rel" == ".pearai" || "$rel" == ".codex" || "$rel" == ".idea" ]]; then
    remove_empty_parents "$src" "$stash_dir"
  fi
}

stash_project_markers() {
  local project="$1"
  local stash_dir="$2"
  local rel

  mkdir -p "$stash_dir"
  printf '%s\n' "$project" >"$stash_dir/project.path"

  while IFS= read -r rel; do
    move_item_to_stash "$project" "$stash_dir" "$rel"
  done < <(managed_items)
}

restore_project_markers() {
  local project="$1"
  local stash_dir="$2"
  local rel

  while IFS= read -r rel; do
    move_item_to_project "$project" "$stash_dir" "$rel"
  done < <(managed_items)
}

cmd_stash() {
  local project="$1"
  local stash_dir
  stash_dir="$(stash_dir_for "$project")"

  is_vim_only_project "$project" || return 0
  mkdir -p "$stash_dir"
  printf '%s\n' "$project" >"$stash_dir/project.path"

  stash_project_markers "$project" "$stash_dir"
  register_session "$stash_dir"
}

cmd_restore() {
  local project="$1"
  local stash_dir
  local sessions_dir
  local count

  stash_dir="$(stash_dir_for "$project")"
  sessions_dir="$(session_dir_for "$stash_dir")"

  is_vim_only_project "$project" || return 0
  [[ -d "$stash_dir" ]] || return 0

  unregister_session "$stash_dir"
  count="$(active_session_count "$sessions_dir")"
  if [[ "$count" -gt 0 ]]; then
    return 0
  fi

  restore_project_markers "$project" "$stash_dir"
}

cmd_force_restore() {
  local project="$1"
  local stash_dir
  stash_dir="$(stash_dir_for "$project")"

  [[ -d "$stash_dir" ]] || return 0
  rm -rf "$(session_dir_for "$stash_dir")"
  restore_project_markers "$project" "$stash_dir"
}

cmd_deploy() {
  local project="$1"
  local stash_dir
  stash_dir="$(stash_dir_for "$project")"

  [[ -d "$stash_dir" ]] || return 0
  restore_project_markers "$project" "$stash_dir"
}

if [[ $# -lt 2 ]]; then
  usage >&2
  exit 1
fi

action="$1"
project="$(cd "$2" && pwd)"

case "$action" in
  stash)
    cmd_stash "$project"
    ;;
  restore)
    cmd_restore "$project"
    ;;
  deploy)
    cmd_deploy "$project"
    ;;
  force-restore)
    cmd_force_restore "$project"
    ;;
  is-vim-only)
    is_vim_only_project "$project"
    ;;
  -h | --help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
