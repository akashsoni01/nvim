#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_PLUGINS_DIR="$ROOT_DIR/vendor/plugins"
VENDOR_LAZY_DIR="$ROOT_DIR/vendor/lazy/lazy.nvim"
BIN_DIR="$ROOT_DIR/bin"

mkdir -p "$VENDOR_PLUGINS_DIR"
mkdir -p "$(dirname "$VENDOR_LAZY_DIR")"

clone_or_update() {
  local repo="$1"
  local dest="$2"
  local url="https://github.com/${repo}.git"

  if [[ -d "$dest/.git" ]]; then
    echo "Updating $repo"
    git -C "$dest" fetch --all --tags --prune
    git -C "$dest" pull --ff-only
  else
    echo "Cloning $repo"
    git clone --filter=blob:none "$url" "$dest"
  fi
}

clone_or_update "folke/lazy.nvim" "$VENDOR_LAZY_DIR"

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
  clone_or_update "$repo" "$VENDOR_PLUGINS_DIR/$name"
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
