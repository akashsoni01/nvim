#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_PLUGINS_DIR="$ROOT_DIR/vendor/plugins"
VENDOR_LAZY_DIR="$ROOT_DIR/vendor/lazy/lazy.nvim"
BIN_DIR="$ROOT_DIR/bin"
LOCK_FILE="$ROOT_DIR/lazy-lock.json"
LOCKED=1

for arg in "$@"; do
  case "$arg" in
    --locked)
      LOCKED=1
      ;;
    --latest)
      LOCKED=0
      ;;
    -h|--help)
      echo "Usage: $0 [--locked|--latest]"
      echo
      echo "Default: --locked, checkout plugin commits from lazy-lock.json."
      echo "Use --latest only during an intentional plugin update/review window."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

mkdir -p "$VENDOR_PLUGINS_DIR"
mkdir -p "$(dirname "$VENDOR_LAZY_DIR")"

lock_commit() {
  local name="$1"

  if [[ "$LOCKED" -ne 1 ]]; then
    return 0
  fi

  if [[ ! -f "$LOCK_FILE" ]]; then
    echo "Missing lock file: $LOCK_FILE" >&2
    exit 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required for locked vendoring." >&2
    exit 1
  fi

  python3 - "$LOCK_FILE" "$name" <<'PY'
import json
import sys

lock_file, name = sys.argv[1], sys.argv[2]
with open(lock_file, "r", encoding="utf-8") as f:
    lock = json.load(f)
entry = lock.get(name)
if entry:
    print(entry["commit"])
PY
}

clone_or_update() {
  local repo="$1"
  local dest="$2"
  local commit="${3:-}"
  local url="https://github.com/${repo}.git"

  if [[ -d "$dest/.git" ]]; then
    echo "Updating $repo"
    git -C "$dest" fetch --all --tags --prune
    if [[ -z "$commit" ]]; then
      git -C "$dest" pull --ff-only
    fi
  else
    echo "Cloning $repo"
    git clone --filter=blob:none "$url" "$dest"
  fi

  if [[ -n "$commit" ]]; then
    echo "Pinning $repo to $commit"
    git -C "$dest" checkout --detach "$commit"
  fi
}

clone_or_update "folke/lazy.nvim" "$VENDOR_LAZY_DIR" "$(lock_commit lazy.nvim)"

repos=(
  "nvim-tree/nvim-web-devicons"
  "nvim-treesitter/nvim-treesitter"
  "williamboman/mason.nvim"
  "williamboman/mason-lspconfig.nvim"
  "neovim/nvim-lspconfig"
  "hrsh7th/cmp-nvim-lsp"
  "SmiteshP/nvim-navic"
  "L3MON4D3/LuaSnip"
  "rafamadriz/friendly-snippets"
  "hrsh7th/nvim-cmp"
  "hrsh7th/cmp-buffer"
  "hrsh7th/cmp-path"
  "mfussenegger/nvim-jdtls"
  "rcasia/neotest-java"
  "nvim-telescope/telescope.nvim"
  "nvim-lua/plenary.nvim"
  "lewis6991/gitsigns.nvim"
  "nvim-lualine/lualine.nvim"
  "akinsho/bufferline.nvim"
  "mfussenegger/nvim-dap"
  "rcarriga/nvim-dap-ui"
  "nvim-neotest/nvim-nio"
  "nvim-neotest/neotest"
  "antoinemadec/FixCursorHold.nvim"
  "folke/which-key.nvim"
  "numToStr/Comment.nvim"
  "utilyre/barbecue.nvim"
  "folke/tokyonight.nvim"
)

for repo in "${repos[@]}"; do
  name="${repo##*/}"
  clone_or_update "$repo" "$VENDOR_PLUGINS_DIR/$name" "$(lock_commit "$name")"
done

ensure_debug_adapter() {
  echo "Java DAP: install jdtls, java-debug-adapter, and java-test with :Mason (see README)."
  return 0
}

ensure_debug_adapter

echo
if "$ROOT_DIR/scripts/check-worktree.sh"; then
  echo "Git worktree check complete."
else
  echo "Warning: git worktree is not available. Worktree keymaps require a Git version with worktree support."
fi

echo
echo "Vendoring complete."
echo "You can now run Neovim offline with local plugin sources."
