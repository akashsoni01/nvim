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

  case "$rel" in
    .vscode)
      has_marker "$project/.vscode/settings.json"
      ;;
    .cursor)
      has_marker "$project/.cursor/rules/neovim-only.mdc"
      ;;
    .cursorignore | .cursorindexingignore | .ignore)
      has_marker "$project/$rel"
      ;;
    .neovim-only)
      is_vim_only_neovim_marker "$project/$rel"
      ;;
    .idea/misc.xml)
      is_vim_only_jetbrains_misc "$project/$rel"
      ;;
    *)
      return 1
      ;;
  esac
}

managed_items() {
  printf '%s\n' \
    '.vscode' \
    '.cursor' \
    '.cursorignore' \
    '.cursorindexingignore' \
    '.ignore' \
    '.neovim-only' \
    '.idea/misc.xml'
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
    remove_empty_parents "$(dirname "$src")" "$project"
  elif [[ "$rel" == ".vscode" || "$rel" == ".cursor" ]]; then
    remove_empty_parents "$src" "$project"
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
  elif [[ "$rel" == ".vscode" || "$rel" == ".cursor" ]]; then
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
