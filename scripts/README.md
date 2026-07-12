# Scripts

## Environment variables

| Variable | Default | Used by |
| --- | --- | --- |
| `NVIM_VIM_FORCE` | off | Clipboard, external completions, plugin downloads, proc macros, `codelldb` download |
| `NVIM_VIM_ONLY` | off (no change) | `1` = mark; `0` = unmark; `2` = enhanced — `vim_only.lua` |
| `NVIM_VIM_ONLY=2` | enhanced Claude/parent block | parent `super/` mark, `.claudeignore`, on-disk ignores |
| `NVIM_CORPORATE_MODE` | off | `vendor-plugins.sh`, `lazy.lua`, debug adapter install |
| `NVIM_TRUST_RUST_PROJECT` | off | `rust-analyzer` proc macros (with force + corporate) |
| `NVIM_LIGHT` | off | Low-memory `rust-analyzer`, faster Telescope grep |
| `NVIM_RA_LINK_ALL` | off | Link all sibling `Cargo.toml` crates for cross-crate `gd` |

## Vim-only / IDE blocking

| Script | Description |
| --- | --- |
| `nvim-workspace.sh` | Wrapper invoked by `nvim`; forwards args to real Neovim binary |
| `install-nvim-wrapper.sh` | Install `nvim()` shell function and `~/.local/bin/nvim` shim |
| `mark-vim-only-project.sh` | Create IDE/LLM blockers in `~/.config/nvim/.vim-only-stash/` and deploy |
| `unmark-vim-only-project.sh` | Remove blockers, stash, and registry entry |
| `vim-only-stash.sh` | `stash`, `restore`, `deploy`, `force-restore`, `is-vim-only` |
| `vim-only-common.sh` | Shared marker writers and registry helpers (sourced, not run directly) |

Flow (only when `NVIM_VIM_ONLY` is set, or via `:VimOnlyMark`):
1. `NVIM_VIM_ONLY=1 nvim .` marks the workspace; `NVIM_VIM_ONLY=0` unmarks
2. On enter (`NVIM_VIM_ONLY=1` or `2`), IDE marker dirs are moved to `.vim-only-stash/<hash>/`
3. On exit, markers are restored to the project
4. Plain `nvim .` does not mark, unmark, or stash anything

`NVIM_VIM_ONLY=2` additionally:
- Marks the parent `super/` folder when marking a child Cargo crate
- Writes ignore/agent/config files for Cursor, Claude, Copilot, Windsurf, Zed, Continue, Codeium, Cody, Tabnine, Aider, Gemini, JetBrains, PearAI, IDX, Codex, and other common AI tools
- Leaves ignore and agent instruction files on disk while Neovim runs

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
| `install-swift.sh` | Install Swift toolchain (macOS/Linux/Termux) |
