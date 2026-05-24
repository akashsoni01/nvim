#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PREFIX_DIR="${PREFIX:-/data/data/com.termux/files/usr}"
BIN_DIR="${HOME}/.config/nvim/bin"

echo "Checking existing debug adapter..."
if command -v codelldb >/dev/null 2>&1; then
  echo "Found codelldb: $(command -v codelldb)"
  exit 0
fi

if command -v lldb-dap >/dev/null 2>&1; then
  echo "Found lldb-dap: $(command -v lldb-dap)"
  exit 0
fi

echo "Installing llvm package in Termux..."
pkg update -y
pkg install -y llvm

mkdir -p "$BIN_DIR"
if [[ -x "$PREFIX_DIR/bin/lldb-dap" ]]; then
  ln -sf "$PREFIX_DIR/bin/lldb-dap" "$BIN_DIR/lldb-dap"
  echo "Installed lldb-dap shim at $BIN_DIR/lldb-dap"
else
  echo "lldb-dap not found after llvm install."
  echo "Available LLDB binaries:"
  ls -1 "$PREFIX_DIR/bin"/lldb* 2>/dev/null || true
  exit 1
fi

echo "Done. Ensure '$BIN_DIR' is in PATH for Neovim."
