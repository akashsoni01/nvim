#!/usr/bin/env bash
set -euo pipefail

# Dependencies:
# - Xcode Command Line Tools (for xcrun/xcode-select)
# - Optional: Homebrew (fallback install path)
#
# What this script installs:
# - Preferred: lldb-dap via Xcode toolchain
# - Fallback: llvm via Homebrew, then lldb-dap

BIN_DIR="${HOME}/.config/nvim/bin"

have() {
  command -v "$1" >/dev/null 2>&1
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

mkdir -p "$BIN_DIR"

echo "Trying Xcode toolchain (xcrun --find lldb-dap)..."
if have xcrun; then
  XCRUN_LLDB="$(xcrun --find lldb-dap 2>/dev/null || true)"
  if [[ -n "${XCRUN_LLDB}" ]]; then
    ln -sf "${XCRUN_LLDB}" "$BIN_DIR/lldb-dap"
    echo "Installed lldb-dap shim at $BIN_DIR/lldb-dap"
    exit 0
  fi
fi

echo "lldb-dap not found in Xcode CLT."
echo "If missing, install CLT: xcode-select --install"

if ! have brew; then
  echo "Homebrew not found. Install from: https://brew.sh"
  exit 1
fi

echo "Installing llvm via Homebrew..."
if ! brew list llvm >/dev/null 2>&1; then
  brew install llvm
fi

BREW_LLVM_PREFIX="$(brew --prefix llvm)"
if [[ -x "${BREW_LLVM_PREFIX}/bin/lldb-dap" ]]; then
  ln -sf "${BREW_LLVM_PREFIX}/bin/lldb-dap" "$BIN_DIR/lldb-dap"
  echo "Installed lldb-dap shim at $BIN_DIR/lldb-dap"
  exit 0
fi

echo "Failed to install lldb-dap via Homebrew llvm."
exit 1
