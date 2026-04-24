# Rust + Neovim Cheatsheet (Termux)

## Leader Key
- `Leader` = `Space`

## Core Shortcuts

### Telescope / Navigation
- `<leader>ff` - Find files
- `<leader>fg` - Live grep in project
- `<leader>fb` - List open buffers
- `<leader>fh` - Help tags

### LSP
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover documentation
- `<C-k>` - Signature help (function params)
- `<leader>ca` - Code actions (imports/derives/impl assists)
- `<leader>rn` - Rename symbol
- `<leader>fm` - Format current buffer

### Debugging (DAP)
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue/start debugger
- `<leader>do` - Step over
- `<leader>di` - Step into

### Git
- `<leader>gs` - Git status (Telescope)
- `<leader>gl` - Git commits log (Telescope)
- `<leader>gd` - Git diff (Gitsigns)

### Window / Split Management
- `<leader>sv` - Vertical split
- `<leader>sh` - Horizontal split
- `<leader>se` - Equalize split sizes
- `<leader>sx` - Close current split

### Testing
- `<leader>tt` - Run test under cursor (`cargo test <word-under-cursor>`)
- `<leader>ta` - Run all tests (`cargo test`)
- `<leader>to` - Toggle neotest output panel
- `<leader>ts` - Toggle neotest summary panel
- `<leader>tc` - Run `cargo clippy --all-targets --all-features`
- `<leader>tr` - Run `cargo run`

### UI Toggles
- `<leader>ub` - Toggle Coral <-> B&W mode
- `<leader>ut` - Toggle transparency
- `<leader>uh` - Toggle LSP inlay hints

---

## Rust-Specific Workflows

### 0) Build, Test, and Run (from project root)
- Start Neovim in your Rust project root:
  - `nvim .`
- Inside Neovim, use these mapped shortcuts:
  - Run app: `<leader>tr`
  - Run nearest test: `<leader>tt`
  - Run all tests: `<leader>ta`
  - Run clippy: `<leader>tc` (great before commit)

#### Typical safe flow (terminal)
1. `cargo fmt`
2. `cargo clippy --all-targets --all-features -- -D warnings`
3. `cargo test`
4. `cargo run`

### 1) Edit -> Diagnose -> Fix -> Format
1. Open a Rust file (`.rs`)
2. Wait for `rust-analyzer` diagnostics/virtual text
3. Use `<leader>ca` for quick fixes and imports
4. Save file to auto-format (`rustfmt` on save)

### 2) Symbol Navigation
1. Place cursor on symbol
2. `gd` to jump to definition
3. `gr` to inspect usages
4. `K` for API docs without leaving buffer

### 3) Test-Driven Cycle
1. Put cursor on target test/function name
2. `<leader>tt` for focused test run
3. `<leader>ta` for full suite before commit

### 4) Debugging Rust Binary
1. Build debug binary:
   - `cargo build`
2. Start debugger:
   - `<leader>dc`
3. When prompted, select executable in `target/debug/`
4. Use step keys (`<leader>do`, `<leader>di`) and breakpoints (`<leader>db`)

### 5) Cargo.toml Productivity
1. Open `Cargo.toml`
2. Use completion for crate names/versions
3. Use LSP + completion to keep dependencies tidy quickly

---

## LSP Navigation Tips
- If completion is not shown, press `<C-Space>` in insert mode.
- Confirm selected completion with `<CR>`.
- Use `Tab`/`Shift-Tab` to cycle completion items/snippet jumps.
- Prefer `<leader>ca` before manual edits for:
  - Missing imports
  - Derive suggestions
  - Boilerplate assists (when available from rust-analyzer)

---

## Termux Troubleshooting

### `rust-analyzer` not working
- Verify install:
  - `pkg install rust`
  - `rustup component add rust-analyzer`
- In Neovim:
  - `:Mason` and ensure `rust_analyzer` is present
  - `:LspInfo` to verify attached client

### Formatter not running
- Check `rustfmt`:
  - `rustup component add rustfmt`
- Manual trigger:
  - `<leader>fm`

### Live grep finds nothing
- Ensure `ripgrep` exists:
  - `pkg install ripgrep`

### Debugger fails to launch
- Install LLDB:
  - `pkg install lldb`
- Confirm adapter binary:
  - `which lldb-dap`
  - or `which codelldb`

### Icons not rendering
- Use a Nerd Font in your terminal app.
- In GUI clients, fallback is configured to JetBrains Mono Nerd Font.

---

## Quick Reference Cards

### Motions
- `w` next word, `b` previous word, `e` end of word
- `0` line start, `^` first non-blank, `$` line end
- `gg` top of file, `G` bottom of file
- `%` jump matching bracket/paren

### Editing
- `ciw` change inner word
- `di(` delete inside parentheses
- `yy` yank line, `p` paste after
- `u` undo, `<C-r>` redo
- `.` repeat last change

### Searching
- `/pattern` forward search, `?pattern` backward search
- `n` next match, `N` previous match
- `*` search word under cursor forward
- `#` search word under cursor backward

---

## Useful Commands
- `:LspInfo` - show active LSP clients
- `:Mason` - manage/install language servers and tools
- `:Telescope` - browse pickers
- `:checkhealth` - global Neovim health checks
