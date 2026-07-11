#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_SCRIPT="$SCRIPT_DIR/nvim-workspace.sh"
BIN_DIR="${XDG_BIN_HOME:-${HOME}/.local/bin}"
WRAPPER_BIN="${BIN_DIR}/nvim"
NVIM_BIN_CACHE="$CONFIG_DIR/.nvim-bin"
PATH_MARKER='# >>> nvim workspace env (NVIM_VIM_ONLY / NVIM_VIM_FORCE) >>>'
PATH_MARKER_END='# <<< nvim workspace flags <<<'

usage() {
  cat <<EOF
Usage: $0 [--dry-run]

Installs a universal nvim wrapper so these work on any machine:
  nvim .
  NVIM_VIM_ONLY=0 nvim .
  NVIM_VIM_FORCE=1 nvim .

Uses a shell function (reliable even when Homebrew/pyenv reorder PATH).
Supported shells: bash, zsh, sh/profile, fish
Supported OS: macOS, Linux, WSL, Git Bash / MSYS / Cygwin on Windows
EOF
}

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
elif [[ -n "${1:-}" ]]; then
  usage >&2
  exit 1
fi

run() {
  if $dry_run; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

write_wrapper() {
  run mkdir -p "$BIN_DIR"
  if $dry_run; then
    echo "+ write wrapper: $WRAPPER_BIN"
    return 0
  fi

  cat >"$WRAPPER_BIN" <<EOF
#!/usr/bin/env bash
NVIM_CONFIG="\${XDG_CONFIG_HOME:-\${HOME}/.config}/nvim"
exec "\$NVIM_CONFIG/scripts/nvim-workspace.sh" "\$@"
EOF
  chmod +x "$WRAPPER_BIN"
}

cache_real_nvim() {
  local real_nvim=""
  if ! real_nvim="$(
    CONFIG_DIR="$CONFIG_DIR" \
      NVIM_BIN_CACHE="$NVIM_BIN_CACHE" \
      BIN_DIR="$BIN_DIR" \
      WRAPPER_BIN="$WRAPPER_BIN" \
      NVIM_BIN="${NVIM_BIN:-}" \
      PATH="${PATH}" \
      bash "$SCRIPT_DIR/resolve-nvim-bin.sh"
  )"; then
    echo "Could not locate a real nvim binary." >&2
    echo "Install Neovim first, or set NVIM_BIN=/path/to/nvim and rerun." >&2
    exit 1
  fi

  if $dry_run; then
    echo "+ cache real nvim: $real_nvim"
    return 0
  fi

  printf '%s\n' "$real_nvim" >"$NVIM_BIN_CACHE"
}

shell_block() {
  cat <<EOF
$PATH_MARKER
nvim() {
  command bash "\${XDG_CONFIG_HOME:-\${HOME}/.config}/nvim/scripts/nvim-workspace.sh" "\$@"
}
export PATH="${BIN_DIR}:\$PATH"
$PATH_MARKER_END
EOF
}

fish_block() {
  cat <<EOF
$PATH_MARKER
function nvim
  bash "\$XDG_CONFIG_HOME/nvim/scripts/nvim-workspace.sh" \$argv
end
fish_add_path -gm "$BIN_DIR"
$PATH_MARKER_END
EOF
}

install_block_from_file() {
  local rc="$1"
  local block_file="$2"

  [[ -f "$rc" ]] || return 0

  if $dry_run; then
    echo "+ update shell rc: $rc"
    return 0
  fi

  local tmp
  tmp="$(mktemp)"

  if grep -Fq "$PATH_MARKER" "$rc"; then
    awk -v start="$PATH_MARKER" -v end="$PATH_MARKER_END" -v block_file="$block_file" '
      $0 == start {
        while ((getline line < block_file) > 0) {
          print line
        }
        close(block_file)
        skip = 1
        next
      }
      $0 == end { skip = 0; next }
      !skip { print }
    ' "$rc" >"$tmp"
  else
    cp "$rc" "$tmp"
    echo "" >>"$tmp"
    cat "$block_file" >>"$tmp"
  fi

  mv "$tmp" "$rc"
}

install_shell_block() {
  local rc="$1"
  local block_file
  block_file="$(mktemp)"
  shell_block >"$block_file"
  install_block_from_file "$rc" "$block_file"
  rm -f "$block_file"
}

install_fish_block() {
  local rc="${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish"
  local block_file
  block_file="$(mktemp)"
  fish_block >"$block_file"
  install_block_from_file "$rc" "$block_file"
  rm -f "$block_file"
}

write_wrapper
cache_real_nvim

install_shell_block "${HOME}/.profile"
install_shell_block "${HOME}/.bashrc"
install_shell_block "${HOME}/.zshrc"
install_fish_block

if ! $dry_run; then
  echo "Installed nvim wrapper: $WRAPPER_BIN"
  echo "Cached real nvim binary: $(tr -d '\r\n' <"$NVIM_BIN_CACHE")"
  echo "Installed shell function: nvim() { ... nvim-workspace.sh ... }"
  echo ""
  echo "Restart your shell, then run:"
  echo "  type nvim"
  echo "  nvim ."
  echo "  NVIM_VIM_FORCE=1 nvim ."
fi
