#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$ROOT_DIR/bin"
CODELLDB_DIR="${HOME}/.local/share/codelldb"

YES=0
SYSTEM=0

for arg in "$@"; do
  case "$arg" in
    -y|--yes)
      YES=1
      ;;
    --system)
      SYSTEM=1
      ;;
    -h|--help)
      echo "Usage: $0 [--yes] [--system]"
      echo
      echo "Removes config-managed debug adapter shims and downloaded codelldb files."
      echo "Use --system to also try uninstalling package-manager deps such as llvm/lldb."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

confirm() {
  local prompt="$1"
  if [[ "$YES" -eq 1 ]]; then
    return 0
  fi

  local answer
  read -r -p "$prompt [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

remove_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    rm -rf -- "$path"
    echo "Removed: $path"
  fi
}

echo "This removes Neovim config-managed debug adapter files:"
echo "  $BIN_DIR/lldb-dap"
echo "  $BIN_DIR/codelldb"
echo "  $BIN_DIR/lldb-vscode"
echo "  $CODELLDB_DIR"
echo

if confirm "Remove config-managed debug adapter files?"; then
  remove_path "$BIN_DIR/lldb-dap"
  remove_path "$BIN_DIR/codelldb"
  remove_path "$BIN_DIR/lldb-vscode"
  remove_path "$CODELLDB_DIR"
else
  echo "Skipped config-managed files."
fi

if [[ "$SYSTEM" -ne 1 ]]; then
  echo
  echo "Skipped package-manager uninstall."
  echo "Run with --system to also try uninstalling llvm/lldb packages."
  exit 0
fi

echo
echo "System package uninstall can affect other projects."
if ! confirm "Continue with package-manager uninstall?"; then
  echo "Skipped package-manager uninstall."
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    if command -v brew >/dev/null 2>&1 && brew list llvm >/dev/null 2>&1; then
      brew uninstall llvm
    else
      echo "No Homebrew llvm package found."
    fi
    ;;
  Linux)
    if [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d /data/data/com.termux/files/usr ]]; then
      if command -v pkg >/dev/null 2>&1; then
        pkg uninstall -y llvm
      else
        echo "Termux pkg command not found."
      fi
    elif command -v apt-get >/dev/null 2>&1; then
      sudo apt-get remove -y lldb
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf remove -y lldb
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -R --noconfirm lldb
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper remove -y lldb
    else
      echo "No supported package manager found for llvm/lldb uninstall."
    fi
    ;;
  *)
    echo "Unsupported OS for package-manager uninstall: $(uname -s)"
    ;;
esac

echo "Dependency cleanup complete."
