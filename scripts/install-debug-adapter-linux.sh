#!/usr/bin/env bash
set -euo pipefail

# Dependencies:
# - curl, tar, unzip, file
# - one package manager: apt-get | dnf | pacman | zypper
# - sudo (if not root)
#
# What this script installs:
# - Preferred: lldb-dap (from distro llvm/lldb package)
# - Fallback: codelldb (downloaded from GitHub release)

BIN_DIR="${HOME}/.config/nvim/bin"
CODELLDB_DIR="${HOME}/.local/share/codelldb"

have() {
  command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  local cmd="$1"
  if ! have "$cmd"; then
    echo "Missing dependency: $cmd"
    exit 1
  fi
}

maybe_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    if ! have sudo; then
      echo "Missing dependency: sudo (or run as root)"
      exit 1
    fi
    sudo "$@"
  fi
}

echo "Checking existing debug adapter..."
if have codelldb; then
  echo "Found codelldb: $(command -v codelldb)"
  exit 0
fi
if have lldb-dap; then
  echo "Found lldb-dap: $(command -v lldb-dap)"
  exit 0
fi

echo "Trying package-manager install for lldb-dap..."
if have apt-get; then
  maybe_sudo apt-get update
  maybe_sudo apt-get install -y lldb
elif have dnf; then
  maybe_sudo dnf install -y lldb
elif have pacman; then
  maybe_sudo pacman -Sy --noconfirm lldb
elif have zypper; then
  maybe_sudo zypper install -y lldb
else
  echo "No supported package manager found for lldb install."
fi

if have lldb-dap; then
  mkdir -p "$BIN_DIR"
  ln -sf "$(command -v lldb-dap)" "$BIN_DIR/lldb-dap"
  echo "Installed lldb-dap shim at $BIN_DIR/lldb-dap"
  exit 0
fi

echo "lldb-dap still missing. Falling back to codelldb binary install..."
need_cmd curl
need_cmd unzip
need_cmd file

mkdir -p "$CODELLDB_DIR" "$BIN_DIR"
TMP_ZIP="$(mktemp -t codelldb-linux.XXXXXX.zip)"

URL="${CODELLDB_URL:-https://github.com/vadimcn/codelldb/releases/latest/download/codelldb-linux-x64.vsix}"
echo "Downloading: $URL"
curl -fL "$URL" -o "$TMP_ZIP"

if ! file "$TMP_ZIP" | rg -q "Zip archive data"; then
  echo "Downloaded file is not a valid VSIX/ZIP archive."
  rm -f "$TMP_ZIP"
  exit 1
fi

unzip -q -o "$TMP_ZIP" -d "$CODELLDB_DIR"
rm -f "$TMP_ZIP"

if [[ -x "$CODELLDB_DIR/extension/adapter/codelldb" ]]; then
  ln -sf "$CODELLDB_DIR/extension/adapter/codelldb" "$BIN_DIR/codelldb"
  echo "Installed codelldb shim at $BIN_DIR/codelldb"
  exit 0
fi

echo "Failed to install codelldb adapter binary."
exit 1
