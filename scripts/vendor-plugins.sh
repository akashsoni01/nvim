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
  "saecki/crates.nvim"
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
  "rouge8/neotest-rust"
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
  local found=""
  found="$(command -v codelldb || true)"
  if [[ -n "$found" ]]; then
    echo "Debug adapter found: codelldb ($found)"
    return 0
  fi

  found="$(command -v lldb-dap || true)"
  if [[ -n "$found" ]]; then
    echo "Debug adapter found: lldb-dap ($found)"
    return 0
  fi

  echo "No debug adapter found (codelldb/lldb-dap). Trying to install lldb-dap..."
  mkdir -p "$BIN_DIR"

  case "$(uname -s)" in
    Darwin)
      if command -v xcrun >/dev/null 2>&1; then
        local xcrun_lldb
        xcrun_lldb="$(xcrun --find lldb-dap 2>/dev/null || true)"
        if [[ -n "$xcrun_lldb" ]]; then
          ln -sf "$xcrun_lldb" "$BIN_DIR/lldb-dap"
          echo "Installed lldb-dap shim at $BIN_DIR/lldb-dap"
          return 0
        fi
      fi

      if command -v brew >/dev/null 2>&1; then
        if ! brew list llvm >/dev/null 2>&1; then
          echo "Installing llvm via Homebrew..."
          brew install llvm
        fi
        local brew_prefix
        brew_prefix="$(brew --prefix llvm)"
        if [[ -x "$brew_prefix/bin/lldb-dap" ]]; then
          ln -sf "$brew_prefix/bin/lldb-dap" "$BIN_DIR/lldb-dap"
          echo "Installed lldb-dap shim at $BIN_DIR/lldb-dap"
          return 0
        fi
      fi
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        echo "Installing lldb via apt-get..."
        sudo apt-get update
        sudo apt-get install -y lldb
      elif command -v dnf >/dev/null 2>&1; then
        echo "Installing lldb via dnf..."
        sudo dnf install -y lldb
      elif command -v pacman >/dev/null 2>&1; then
        echo "Installing lldb via pacman..."
        sudo pacman -Sy --noconfirm lldb
      elif command -v zypper >/dev/null 2>&1; then
        echo "Installing lldb via zypper..."
        sudo zypper install -y lldb
      fi
      ;;
  esac

  found="$(command -v lldb-dap || true)"
  if [[ -z "$found" && -x "$BIN_DIR/lldb-dap" ]]; then
    found="$BIN_DIR/lldb-dap"
  fi
  if [[ -n "$found" ]]; then
    echo "Debug adapter ready: $found"
    return 0
  fi

  echo "Warning: Could not auto-install a debug adapter."
  echo "Please install one of: codelldb, lldb-dap"
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
