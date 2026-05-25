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
CORPORATE_MODE="${NVIM_CORPORATE_MODE:-0}"

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

sha256_file() {
  local file="$1"
  if have sha256sum; then
    sha256sum "$file" | awk '{print $1}'
    return 0
  fi
  if have shasum; then
    shasum -a 256 "$file" | awk '{print $1}'
    return 0
  fi

  echo "Missing dependency: sha256sum or shasum" >&2
  return 1
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
need_cmd rg

mkdir -p "$CODELLDB_DIR" "$BIN_DIR"
TMP_ZIP="$(mktemp -t codelldb-linux.XXXXXX.zip)"

URL="${CODELLDB_URL:-https://github.com/vadimcn/codelldb/releases/latest/download/codelldb-linux-x64.vsix}"
if [[ "$CORPORATE_MODE" == "1" || "$CORPORATE_MODE" == "true" ]]; then
  if [[ -z "${CODELLDB_URL:-}" || -z "${CODELLDB_SHA256:-}" ]]; then
    echo "Corporate mode requires CODELLDB_URL and CODELLDB_SHA256 for fallback binary download."
    exit 1
  fi
fi

echo "Downloading: $URL"
curl -fL "$URL" -o "$TMP_ZIP"

if [[ -n "${CODELLDB_SHA256:-}" ]]; then
  actual_sha="$(sha256_file "$TMP_ZIP")"
  if [[ "$actual_sha" != "$CODELLDB_SHA256" ]]; then
    echo "SHA256 mismatch for downloaded codelldb archive."
    echo "Expected: $CODELLDB_SHA256"
    echo "Actual:   $actual_sha"
    rm -f "$TMP_ZIP"
    exit 1
  fi
fi

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
