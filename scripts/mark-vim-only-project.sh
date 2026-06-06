#!/usr/bin/env bash
set -euo pipefail

MARKER="Neovim is the primary editor for this project."

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <project-path>" >&2
  echo "Marks a project as Neovim-only so other IDEs stop indexing it." >&2
  exit 1
fi

project="$(cd "$1" && pwd)"
vscode_dir="$project/.vscode"
vscode_settings="$vscode_dir/settings.json"
cursor_ignore="$project/.cursorignore"
cursor_indexing_ignore="$project/.cursorindexingignore"
cursor_rules_dir="$project/.cursor/rules"
cursor_rules_file="$cursor_rules_dir/neovim-only.mdc"
search_ignore="$project/.ignore"
neovim_marker="$project/.neovim-only"
idea_dir="$project/.idea"
jetbrains_misc="$idea_dir/misc.xml"

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

write_ignore_file() {
  local file="$1"
  local note="$2"
  cat >"$file" <<EOF
# $MARKER
# $note
*
**
**/*
EOF
}

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

if [[ -f "$jetbrains_misc" ]]; then
  echo "Kept existing JetBrains config: $jetbrains_misc"
  echo "Reload RustRover/IntelliJ if the project is already open."
else
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

echo "Marked as Neovim-only: $project"
echo "  - $vscode_settings"
echo "  - $cursor_ignore"
echo "  - $cursor_indexing_ignore"
echo "  - $cursor_rules_file"
echo "  - $search_ignore"
echo "  - $neovim_marker"
if [[ -f "$jetbrains_misc" ]]; then
  echo "  - $jetbrains_misc"
fi
echo "Reload the Cursor/VS Code window (Cmd+Shift+P -> Developer: Reload Window) if this project is already open."
