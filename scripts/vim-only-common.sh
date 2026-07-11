#!/usr/bin/env bash
set -euo pipefail

MARKER="Neovim is the primary editor for this project."

CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/nvim}"
STASH_ROOT="${STASH_ROOT:-${CONFIG_DIR}/.vim-only-stash}"
REGISTRY="${REGISTRY:-${STASH_ROOT}/registry}"

stash_id() {
  printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
}

stash_dir_for() {
  local project="$1"
  printf '%s/%s' "$STASH_ROOT" "$(stash_id "$project")"
}

registry_add() {
  local project="$1"
  mkdir -p "$STASH_ROOT"
  touch "$REGISTRY"
  if ! grep -Fxq "$project" "$REGISTRY"; then
    printf '%s\n' "$project" >>"$REGISTRY"
  fi
}

registry_remove() {
  local project="$1"
  [[ -f "$REGISTRY" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  grep -Fxv "$project" "$REGISTRY" >"$tmp" || true
  mv "$tmp" "$REGISTRY"
}

registry_contains() {
  local project="$1"
  [[ -f "$REGISTRY" ]] && grep -Fxq "$project" "$REGISTRY"
}

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

is_vim_only_project() {
  local project="$1"
  local stash_dir
  stash_dir="$(stash_dir_for "$project")"

  if registry_contains "$project"; then
    return 0
  fi
  if [[ -f "$stash_dir/project.path" ]]; then
    return 0
  fi
  if is_vim_only_neovim_marker "$project/.neovim-only"; then
    return 0
  fi
  if has_marker "$project/.vscode/settings.json"; then
    return 0
  fi

  return 1
}

write_ignore_file() {
  local file="$1"
  local note="$2"
  mkdir -p "$(dirname "$file")"
  cat >"$file" <<EOF
# $MARKER
# $note
*
**
**/*
EOF
}

write_vim_only_files() {
  local root="$1"

  local vscode_dir="$root/.vscode"
  local vscode_settings="$vscode_dir/settings.json"
  local cursor_ignore="$root/.cursorignore"
  local cursor_indexing_ignore="$root/.cursorindexingignore"
  local cursor_rules_dir="$root/.cursor/rules"
  local cursor_rules_file="$cursor_rules_dir/neovim-only.mdc"
  local search_ignore="$root/.ignore"
  local neovim_marker="$root/.neovim-only"
  local idea_dir="$root/.idea"
  local jetbrains_misc="$idea_dir/misc.xml"

  mkdir -p "$vscode_dir"

  cat >"$vscode_settings" <<EOF
{
  "//": "$MARKER",
  "rust-analyzer.enable": false,
  "rust-analyzer.checkOnSave": false,
  "files.exclude": {
    "*": true,
    "**": true,
    "**/*": true,
    ".vscode": false,
    "**/.vscode": false,
    "**/.vscode/**": false
  },
  "search.exclude": {
    "*": true,
    "**": true,
    "**/*": true
  },
  "files.watcherExclude": {
    "*": true,
    "**": true,
    "**/*": true,
    "**/.vscode/**": false
  },
  "search.useIgnoreFiles": true,
  "extensions.ignoreRecommendations": true,
  "chat.disableAIFeatures": true,
  "chat.agent.enabled": false,
  "chat.commandCenter.enabled": false,
  "chat.useAgentsMdFile": false,
  "chat.useClaudeMdFile": false,
  "chat.useNestedAgentsMdFiles": false,
  "github.copilot.enable": {
    "*": false
  },
  "github.copilot.editor.enableAutoCompletions": false,
  "github.copilot.editor.enableCodeActions": false,
  "github.copilot.nextEditSuggestions.enabled": false,
  "github.copilot.renameSuggestions.triggerAutomatically": false,
  "github.copilot.chat.codesearch.enabled": false,
  "editor.inlineSuggest.enabled": false,
  "cursor.tab.enabled": false,
  "cursor.completions.enabled": false,
  "cursor.cpp.disabledLanguages": ["*"],
  "cursor.aipreview.enabled": false,
  "cursor.semanticSearch.includePullRequests": false,
  "continue.enableTabAutocomplete": false,
  "continue.telemetryEnabled": false,
  "codeium.enableConfig": {
    "*": false
  },
  "codeium.disableIndexing": true,
  "codeium.enableCodeLens": false,
  "codeium.enableSupercompletion": false,
  "cody.autocomplete.enabled": false,
  "cody.codebase.enabled": false,
  "aws.toolkits.amazonq.shareContentWithAWS": false
}
EOF

  write_ignore_file "$cursor_ignore" "Hard block for Cursor Tab, Agent, Inline Edit, @mentions, and semantic search."
  write_ignore_file "$cursor_indexing_ignore" "Exclude project files from Cursor codebase embeddings and @codebase search."
  write_ignore_file "$search_ignore" "Exclude project files from VS Code/Cursor ripgrep search and quick open."

  mkdir -p "$cursor_rules_dir"
  cat >"$cursor_rules_file" <<EOF
---
description: $MARKER
alwaysApply: true
---

# $MARKER

This workspace is Neovim-only. Do not index, search, read, edit, or suggest changes to project source files.
EOF

  cat >"$neovim_marker" <<EOF
$MARKER
EOF

  if [[ ! -f "$jetbrains_misc" ]] || is_vim_only_jetbrains_misc "$jetbrains_misc"; then
    mkdir -p "$idea_dir"
    cat >"$jetbrains_misc" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectRootManager" version="2" languageLevel="JDK_21" default="true" project-jdk-name="21" project-jdk-type="JavaSDK">
    <output url="file://$PROJECT_DIR$/out" />
    <content url="file://$PROJECT_DIR$">
      <excludeFolder url="file://$PROJECT_DIR$/target" />
      <excludeFolder url="file://$PROJECT_DIR$/src" />
      <excludeFolder url="file://$PROJECT_DIR$/crates" />
      <excludeFolder url="file://$PROJECT_DIR$/benches" />
      <excludeFolder url="file://$PROJECT_DIR$/examples" />
      <excludeFolder url="file://$PROJECT_DIR$/tests" />
      <excludeFolder url="file://$PROJECT_DIR$/fuzz" />
    </content>
  </component>
  <component name="NeovimOnlyProject" />
</project>
EOF
  fi
}

remove_empty_parents() {
  local dir="$1"
  local stop="$2"

  while [[ "$dir" != "$stop" && "$dir" != "/" && -d "$dir" ]]; do
    if [[ -z "$(ls -A "$dir")" ]]; then
      rmdir "$dir"
      dir="$(dirname "$dir")"
    else
      break
    fi
  done
}
