# Scripts

## Environment variables

| Variable | Default | Used by |
| --- | --- | --- |
| `NVIM_VIM_FORCE` | off | Clipboard, external completions, plugin downloads, proc macros, `codelldb` download |
| `NVIM_VIM_ONLY` | mark on `nvim .` | `mark-vim-only-project.sh`, `vim_only.lua` |
| `NVIM_CORPORATE_MODE` | off | `vendor-plugins.sh`, `lazy.lua`, debug adapter install |
| `NVIM_TRUST_RUST_PROJECT` | off | `rust-analyzer` proc macros (with force + corporate) |

## Vim-only / IDE blocking

| Script | Description |
| --- | --- |
| `nvim-workspace.sh` | Wrapper invoked by `nvim`; forwards args to real Neovim binary |
| `install-nvim-wrapper.sh` | Install `nvim()` shell function and `~/.local/bin/nvim` shim |
| `mark-vim-only-project.sh` | Create IDE/LLM blockers in `~/.config/nvim/.vim-only-stash/` and deploy |
| `unmark-vim-only-project.sh` | Remove blockers, stash, and registry entry |
| `vim-only-stash.sh` | `stash`, `restore`, `deploy`, `force-restore`, `is-vim-only` |
| `vim-only-common.sh` | Shared marker writers and registry helpers (sourced, not run directly) |

Flow:
1. `nvim .` marks the workspace (unless `NVIM_VIM_ONLY=0`)
2. On enter, IDE marker dirs are moved to `.vim-only-stash/<hash>/`
3. On exit, markers are restored to the project

## Offline / corporate

| Script | Description |
| --- | --- |
| `vendor-plugins.sh` | Vendor `lazy.nvim` and plugins (`--locked` or `--latest`) |
| `remove-vendor.sh` | Remove vendored plugin trees |
| `resolve-nvim-bin.sh` | Resolve real Neovim binary (skips wrapper) |

## Debug adapters

| Script | Description |
| --- | --- |
| `install-debug-adapter-linux.sh` | Install LLDB DAP; network `codelldb` fallback needs `NVIM_VIM_FORCE=1` |
| `install-debug-adapter-macos.sh` | macOS LLDB / codelldb setup |
| `install-debug-adapter-termux.sh` | Termux LLDB setup |
| `uninstall-deps.sh` | Remove config-managed adapters (`--system` for package manager) |

## Utilities

| Script | Description |
| --- | --- |
| `check-worktree.sh` | Verify git worktree support |
