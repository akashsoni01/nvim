#!/usr/bin/env bash
set -euo pipefail

MARKER="Neovim is the primary editor for this project."

CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/nvim}"
STASH_ROOT="${STASH_ROOT:-${CONFIG_DIR}/.vim-only-stash}"
REGISTRY="${REGISTRY:-${STASH_ROOT}/registry}"

vim_only_mode_from_env() {
  local value="${NVIM_VIM_ONLY:-}"
  case "$value" in
    2) printf '2' ;;
    1 | true | yes | TRUE | YES) printf '1' ;;
    0 | false | no | FALSE | NO) printf '0' ;;
    "") printf '1' ;;
    *) printf '1' ;;
  esac
}

vim_only_mode_is_enhanced() {
  [[ "$(vim_only_mode_from_env)" == "2" ]]
}

keep_ignores_on_disk() {
  vim_only_mode_is_enhanced
}

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
  if has_marker "$project/.claude/settings.json"; then
    return 0
  fi
  if is_vim_only_editor_json "$project/.zed/settings.json"; then
    return 0
  fi
  if is_vim_only_agent_file "$project/AGENTS.md"; then
    return 0
  fi

  return 1
}

child_cargo_names() {
  local parent="$1"
  local child name

  for child in "$parent"/*; do
    [[ -d "$child" && -f "$child/Cargo.toml" ]] || continue
    name="$(basename "$child")"
    printf '%s\n' "$name"
  done
}

is_vim_only_agent_file() {
  local file="$1"
  [[ -f "$file" ]] && grep -Fq "$MARKER" "$file"
}

is_vim_only_editor_json() {
  has_marker "$1"
}

is_vim_only_owned_file() {
  local project="$1"
  local rel="$2"
  local path="$project/$rel"

  if is_ignore_rel_path "$rel"; then
    has_marker "$path"
    return
  fi

  case "$rel" in
    .vscode/settings.json | .zed/settings.json | .continue/config.json | .windsurf/settings.json | .fleet/settings.json | .claude/settings.json | .idx/settings.json | .pearai/settings.json | .codex/settings.json | .aider.conf.yml)
      is_vim_only_editor_json "$path"
      ;;
    .sourcery.yaml)
      has_marker "$path"
      ;;
    AGENTS.md | CLAUDE.md | GEMINI.md | BOLT.md | .cursorrules | .windsurfrules | .github/copilot-instructions.md | .github/instructions/neovim-only.instructions.md)
      is_vim_only_agent_file "$path"
      ;;
    .neovim-only)
      is_vim_only_neovim_marker "$path"
      ;;
    .idea/misc.xml)
      is_vim_only_jetbrains_misc "$path"
      ;;
    .cursor/rules/neovim-only.mdc)
      has_marker "$path"
      ;;
    *)
      return 1
      ;;
  esac
}

stash_only_dirs_in_enhanced_mode() {
  local rel="$1"
  case "$rel" in
    .vscode | .cursor | .zed | .continue | .windsurf | .fleet | .github | .claude | .idx | .pearai | .codex | .neovim-only | .idea | .idea/misc.xml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

managed_items() {
  local item
  while IFS= read -r item; do
    [[ -n "$item" ]] && printf '%s\n' "$item"
  done < <(vim_only_file_markers)
  while IFS= read -r item; do
    [[ -n "$item" ]] && printf '%s\n' "$item"
  done < <(vim_only_dir_markers)
}

parent_super_dir() {
  local project="$1"
  local parent count=0 child

  parent="$(dirname "$project")"
  [[ "$parent" != "/" && -d "$parent" ]] || return 0
  [[ -f "$project/Cargo.toml" ]] || return 0
  [[ "$project" != "$parent" ]] || return 0

  for child in "$parent"/*; do
    [[ -d "$child" && -f "$child/Cargo.toml" ]] && count=$((count + 1))
  done
  [[ $count -ge 1 ]] || return 0

  printf '%s' "$parent"
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

write_agent_instruction_file() {
  local file="$1"
  local tool="$2"
  mkdir -p "$(dirname "$file")"
  cat >"$file" <<EOF
# $MARKER

This repository is **Neovim-only**. $tool must not index, search, read, edit, or suggest
changes to project source files. Close this workspace in AI-enabled editors.
EOF
}

is_ignore_rel_path() {
  case "$1" in
    .cursorignore | .cursorindexingignore | .ignore | .claudeignore | .aiderignore | .aiignore | .clineignore | .codeiumignore | .continueignore | .copilotignore | .geminiignore | .rooignore | .tabnineignore | .windsurfignore | .sourcegraphignore | .augmentignore | .junieignore | .openhandsignore | .traeignore | .pearaiignore | .idxignore | .devinignore | .boltignore | .opencodeignore | .codexignore | .qodoignore | .mentatignore | .sourceryignore)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

write_llm_ignore_files() {
  local root="$1"
  write_ignore_file "$root/.cursorignore" "Block Cursor Tab, Agent, Inline Edit, @mentions, and semantic search."
  write_ignore_file "$root/.cursorindexingignore" "Block Cursor codebase embeddings and @codebase search."
  write_ignore_file "$root/.ignore" "Block VS Code/Cursor/Zed/Fleet ripgrep search and quick open."
  write_ignore_file "$root/.claudeignore" "Block Claude Code exploration and indexing."
  write_ignore_file "$root/.aiderignore" "Block Aider from reading project files."
  write_ignore_file "$root/.aiignore" "Block generic AI tooling from indexing project files."
  write_ignore_file "$root/.clineignore" "Block Cline from indexing project files."
  write_ignore_file "$root/.codeiumignore" "Block Codeium indexing and completions context."
  write_ignore_file "$root/.continueignore" "Block Continue.dev indexing and retrieval."
  write_ignore_file "$root/.copilotignore" "Block GitHub Copilot workspace context."
  write_ignore_file "$root/.geminiignore" "Block Google Gemini IDE extensions from indexing."
  write_ignore_file "$root/.rooignore" "Block Roo Code indexing and file access."
  write_ignore_file "$root/.tabnineignore" "Block Tabnine codebase learning and retrieval."
  write_ignore_file "$root/.windsurfignore" "Block Windsurf Cascade indexing and search."
  write_ignore_file "$root/.sourcegraphignore" "Block Sourcegraph Cody codebase context."
  write_ignore_file "$root/.augmentignore" "Block Augment Code indexing."
  write_ignore_file "$root/.junieignore" "Block JetBrains Junie indexing."
  write_ignore_file "$root/.openhandsignore" "Block OpenHands agent file access."
  write_ignore_file "$root/.traeignore" "Block Trae AI editor indexing."
  write_ignore_file "$root/.pearaiignore" "Block PearAI indexing."
  write_ignore_file "$root/.idxignore" "Block Google Project IDX indexing."
  write_ignore_file "$root/.devinignore" "Block Devin / Cognition agent indexing."
  write_ignore_file "$root/.boltignore" "Block Bolt.new / StackBlitz AI indexing."
  write_ignore_file "$root/.opencodeignore" "Block OpenCode CLI indexing."
  write_ignore_file "$root/.codexignore" "Block OpenAI Codex tooling from indexing."
  write_ignore_file "$root/.qodoignore" "Block Qodo Gen / Codium indexing."
  write_ignore_file "$root/.mentatignore" "Block Mentat AI indexing."
  write_ignore_file "$root/.sourceryignore" "Block Sourcery AI review context."
}

write_llm_agent_instructions() {
  local root="$1"
  write_agent_instruction_file "$root/AGENTS.md" "Coding agents"
  write_agent_instruction_file "$root/CLAUDE.md" "Claude Code / Anthropic tools"
  write_agent_instruction_file "$root/GEMINI.md" "Google Gemini tools"
  write_agent_instruction_file "$root/BOLT.md" "Bolt / StackBlitz AI"
  write_agent_instruction_file "$root/.cursorrules" "Cursor rules"
  write_agent_instruction_file "$root/.windsurfrules" "Windsurf Cascade"
  write_agent_instruction_file "$root/.github/copilot-instructions.md" "GitHub Copilot"
  write_agent_instruction_file "$root/.github/instructions/neovim-only.instructions.md" "GitHub Copilot custom instructions"
}

write_zed_settings_json() {
  local root="$1"
  local settings_file="$root/.zed/settings.json"
  mkdir -p "$(dirname "$settings_file")"
  cat >"$settings_file" <<EOF
{
  "//": "$MARKER",
  "file_scan_exclusions": [
    "**"
  ],
  "show_excluded": false
}
EOF
}

write_continue_config_json() {
  local root="$1"
  local config_file="$root/.continue/config.json"
  mkdir -p "$(dirname "$config_file")"
  cat >"$config_file" <<EOF
{
  "//": "$MARKER",
  "disableIndexing": true,
  "tabAutocompleteOptions": {
    "disable": true
  },
  "allowAnonymousTelemetry": false
}
EOF
}

write_windsurf_settings_json() {
  local root="$1"
  local settings_file="$root/.windsurf/settings.json"
  mkdir -p "$(dirname "$settings_file")"
  cat >"$settings_file" <<EOF
{
  "//": "$MARKER",
  "cascade": {
    "enabled": false
  },
  "indexing": {
    "enabled": false
  }
}
EOF
}

write_fleet_settings_json() {
  local root="$1"
  local settings_file="$root/.fleet/settings.json"
  mkdir -p "$(dirname "$settings_file")"
  cat >"$settings_file" <<EOF
{
  "//": "$MARKER",
  "ai": {
    "enabled": false
  }
}
EOF
}

write_aider_conf_yml() {
  local root="$1"
  local conf_file="$root/.aider.conf.yml"
  cat >"$conf_file" <<EOF
# $MARKER
read: never
auto-commits: false
EOF
}

write_sourcery_yaml() {
  local root="$1"
  local file="$root/.sourcery.yaml"
  cat >"$file" <<EOF
# $MARKER
enabled: false
EOF
}

write_idx_settings_json() {
  local root="$1"
  local settings_file="$root/.idx/settings.json"
  mkdir -p "$(dirname "$settings_file")"
  cat >"$settings_file" <<EOF
{
  "//": "$MARKER",
  "ai": {
    "enabled": false
  }
}
EOF
}

write_pearai_settings_json() {
  local root="$1"
  local settings_file="$root/.pearai/settings.json"
  mkdir -p "$(dirname "$settings_file")"
  cat >"$settings_file" <<EOF
{
  "//": "$MARKER",
  "indexing": {
    "enabled": false
  },
  "ai": {
    "enabled": false
  }
}
EOF
}

write_codex_settings_json() {
  local root="$1"
  local settings_file="$root/.codex/settings.json"
  mkdir -p "$(dirname "$settings_file")"
  cat >"$settings_file" <<EOF
{
  "//": "$MARKER",
  "enabled": false
}
EOF
}

write_editor_configs() {
  local root="$1"
  write_zed_settings_json "$root"
  write_continue_config_json "$root"
  write_windsurf_settings_json "$root"
  write_fleet_settings_json "$root"
  write_aider_conf_yml "$root"
  write_sourcery_yaml "$root"
  write_idx_settings_json "$root"
  write_pearai_settings_json "$root"
  write_codex_settings_json "$root"
}

vim_only_file_markers() {
  printf '%s\n' \
    '.cursorignore' \
    '.cursorindexingignore' \
    '.ignore' \
    '.claudeignore' \
    '.aiderignore' \
    '.aiignore' \
    '.clineignore' \
    '.codeiumignore' \
    '.continueignore' \
    '.copilotignore' \
    '.geminiignore' \
    '.rooignore' \
    '.tabnineignore' \
    '.windsurfignore' \
    '.sourcegraphignore' \
    '.augmentignore' \
    '.junieignore' \
    '.openhandsignore' \
    '.traeignore' \
    '.pearaiignore' \
    '.idxignore' \
    '.devinignore' \
    '.boltignore' \
    '.opencodeignore' \
    '.codexignore' \
    '.qodoignore' \
    '.mentatignore' \
    '.sourceryignore' \
    'AGENTS.md' \
    'CLAUDE.md' \
    'GEMINI.md' \
    'BOLT.md' \
    '.cursorrules' \
    '.windsurfrules' \
    '.github/copilot-instructions.md' \
    '.github/instructions/neovim-only.instructions.md' \
    '.aider.conf.yml' \
    '.sourcery.yaml' \
    '.neovim-only' \
    '.idea/misc.xml' \
    '.vscode/settings.json' \
    '.cursor/rules/neovim-only.mdc' \
    '.zed/settings.json' \
    '.continue/config.json' \
    '.windsurf/settings.json' \
    '.fleet/settings.json' \
    '.claude/settings.json' \
    '.idx/settings.json' \
    '.pearai/settings.json' \
    '.codex/settings.json'
}

vim_only_dir_markers() {
  printf '%s\n' '.vscode' '.cursor' '.zed' '.continue' '.windsurf' '.fleet' '.github' '.claude' '.idx' '.pearai' '.codex' '.idea'
}

write_claude_settings_json() {
  local root="$1"
  local parent_super="$2"
  local layout_root="$3"
  local settings_file="$root/.claude/settings.json"
  local deny_json="" name

  mkdir -p "$(dirname "$settings_file")"

  if [[ "$parent_super" == "true" ]]; then
    while IFS= read -r name; do
      [[ -n "$name" ]] || continue
      if [[ -n "$deny_json" ]]; then
        deny_json+=","
      fi
      deny_json+=$'\n      "Read('"$name"'/**)"'
    done < <(child_cargo_names "$layout_root")
    if [[ -z "$deny_json" ]]; then
      deny_json=$'\n      "Read(**)"'
    fi
  else
    deny_json=$'\n      "Read(**)"'
  fi

  cat >"$settings_file" <<EOF
{
  "//": "$MARKER",
  "permissions": {
    "deny": [$deny_json
    ]
  }
}
EOF
}

write_vim_only_files() {
  local root="$1"
  local parent_super="${2:-false}"
  local layout_root="${3:-$root}"

  local vscode_dir="$root/.vscode"
  local vscode_settings="$vscode_dir/settings.json"
  local cursor_rules_dir="$root/.cursor/rules"
  local cursor_rules_file="$cursor_rules_dir/neovim-only.mdc"
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
  "aws.toolkits.amazonq.shareContentWithAWS": false,
  "amazonQ.suppressPrompts": true,
  "anthropic.claudeCode.enabled": false,
  "google.gemini.enabled": false,
  "google.geminiCodeAssist.enabled": false,
  "sourcegraph.cody.enabled": false,
  "tabby.chatEnabled": false,
  "tabby.contextMenuEnabled": false,
  "supermaven.enabled": false,
  "supermaven.enable": {
    "*": false
  },
  "windsurf.cascadeEnabled": false,
  "windsurf.enableAutoCompletions": false,
  "roo-cline.allowedCommands": [],
  "roo-cline.enableCodeActions": false,
  "cline.enableAutoCompletions": false,
  "aider.enabled": false,
  "augment.chat.enabled": false,
  "augment.completions.enabled": false,
  "jetbrains.junie.enabled": false,
  "intellicode.completionsEnabled": false,
  "intellicode.inlineSuggestions.enabled": false,
  "tabnine.experimentalAutoImports": false,
  "tabnine.receiveBetaChannelUpdates": false,
  "blackboxai.enabled": false,
  "phind.enabled": false,
  "mutable-ai.enabled": false,
  "qodoGen.enabled": false,
  "qodo.gen.enabled": false,
  "codium.enabled": false,
  "codiumate.enabled": false,
  "mentat.enabled": false,
  "bito.bitoAIChatTextField": false,
  "bitoAI.enableAutoCompletion": false,
  "openai.chatgpt.enabled": false,
  "openai.chatgpt.runCodeEnabled": false,
  "pearai.enabled": false,
  "pearai.autocomplete.enabled": false,
  "trae.ai.enabled": false,
  "trae.chat.enabled": false,
  "openhands.enabled": false,
  "devin.enabled": false,
  "sourcery.enabled": false,
  "oracle.codeAssist.enabled": false,
  "redhat.telemetry.enabled": false,
  "redhat.optin": false,
  "sonarlint.disableTelemetry": true
}
EOF

  write_llm_ignore_files "$root"
  write_llm_agent_instructions "$root"
  write_editor_configs "$root"

  if vim_only_mode_is_enhanced; then
    write_claude_settings_json "$root" "$parent_super" "$layout_root"
  fi

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
