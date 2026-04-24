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

### Terminal (open and use)
- Open terminal in horizontal split: `:split | terminal`
- Open terminal in vertical split: `:vsplit | terminal`
- Use existing run mappings (opens terminal split automatically):
  - `<leader>tr` (`cargo run`)
  - `<leader>tc` (`cargo clippy --all-targets --all-features`)
  - `<leader>ta` / `<leader>tt` (test runs)
- Exit terminal insert mode to normal mode: `<C-\><C-n>`
- Close current terminal split: `<leader>sx`

### Testing
- `<leader>tt` - Run test under cursor (`cargo test <word-under-cursor>`)
- `<leader>ta` - Run all tests (`cargo test`)
- `<leader>to` - Toggle neotest output panel
- `<leader>ts` - Toggle neotest summary panel
- `<leader>tc` - Run `cargo clippy --all-targets --all-features`
- `<leader>tr` - Run `cargo run`

### UI Toggles
- `<leader>ub` - Toggle Coral <-> Light White mode
- `<leader>ut` - Toggle transparency
- `<leader>uh` - Toggle LSP inlay hints

### Change Theme
- Quick switch: press `<leader>ub` to toggle between Coral and Light White.
- Command mode options:
  - Toggle: `:lua require("config.theme").toggle()`
  - Set Coral: `:lua require("config.theme").apply("coral")`
  - Set Light White: `:lua require("config.theme").apply("light")`
  - Backward-compatible alias: `:lua require("config.theme").apply("mono")`

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

#### Open terminal manually in project
1. Horizontal terminal: `:split | terminal`
2. Vertical terminal: `:vsplit | terminal`
3. Return terminal to normal mode: `<C-\><C-n>`
4. Close terminal split: `<leader>sx`

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

### 4) Debugging Rust Binary (Setup + Run + State)

#### One-time setup (install adapter)
- macOS:
  - `./scripts/install-debug-adapter-macos.sh`
- Linux:
  - `./scripts/install-debug-adapter-linux.sh`
- Termux:
  - `./scripts/install-debug-adapter-termux.sh`
- Or run everything (plugins + adapter check/install):
  - `./scripts/vendor-plugins.sh`

#### Dependencies by platform
- macOS:
  - Xcode CLT (`xcrun`, `xcode-select`)
  - optional Homebrew (`brew`) for llvm fallback
- Linux:
  - one package manager (`apt-get` / `dnf` / `pacman` / `zypper`)
  - `sudo` (or run as root)
  - fallback downloader tools: `curl`, `unzip`, `file`
- Termux:
  - `pkg` and `llvm`

#### Verify adapter is available
- `which lldb-dap || which codelldb`
- Confirm local shim (used by this config):
  - `ls -l ~/.config/nvim/bin/lldb-dap`

#### Build and start debugging
1. Build target first:
   - `cargo build`
2. Open project root in Neovim:
   - `nvim .`
3. Set breakpoint(s):
   - `<leader>db`
4. Start/continue debugger:
   - `<leader>dc`
5. When prompted, choose a real binary file like:
   - `target/debug/<your-crate-name>`
   - not `target/debug/` (directory)

#### See debugger state while paused
- Variables/scopes/call stack:
  - opens automatically with `nvim-dap-ui` after debugger starts
- Step controls:
  - `<leader>do` step over
  - `<leader>di` step into
  - `:lua require("dap").step_out()` step out
- Open DAP REPL:
  - `:lua require("dap").repl.open()`
- Inspect expression under cursor:
  - `:lua require("dapui").eval()`
- Stop session:
  - `:lua require("dap").terminate()`

#### How to see variable values (quick)
1. Start debug and pause on a breakpoint (`<leader>db`, then `<leader>dc`).
2. Check left DAP UI panels:
   - `Scopes` shows locals/arguments for current frame
   - `Stacks` lets you switch call frames (variables update per frame)
3. For one-off value under cursor:
   - place cursor on variable and run `:lua require("dapui").eval()`
4. For custom expressions in current context:
   - `:lua require("dap").repl.open()`
   - type expressions like `my_var`, `my_struct.field`, `vec.len()`
5. If value is `<optimized out>` or missing:
   - rebuild with debug info and lower optimization:
   - `cargo build`
   - prefer dev profile / avoid release while debugging

#### Add breakpoints
- Move cursor to the line you want to pause on.
- Press `<leader>db` to toggle a breakpoint on that line.
- Press `<leader>db` again on the same line to remove it.

#### Debug line-by-line vs step into functions
- `<leader>dc` - Continue execution (or start debugger). Runs until next breakpoint.
- `<leader>do` - Step over current line. Good for line-by-line flow in the same function.
- `<leader>di` - Step into function call on current line. Use when you want internal function details.
- `:lua require("dap").step_out()` - Step out of current function and return to caller.

#### Typical debug flow
1. Set 1-3 breakpoints with `<leader>db`.
2. Start/continue with `<leader>dc`.
3. At a breakpoint:
   - Use `<leader>do` for line-by-line in current function.
   - Use `<leader>di` when a called function is suspicious.
   - Use `:lua require("dap").step_out()` to return back quickly.
4. Continue to next breakpoint with `<leader>dc`.

#### Minimal run and debug example
1. `cargo build`
2. In Neovim open `src/main.rs`
3. Put cursor on a target line and press `<leader>db`
4. Press `<leader>dc`
5. Select `target/debug/<your-binary-name>`
6. Use `<leader>do` / `<leader>di` while paused

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
- Ensure binary is built:
  - `cargo build`
- If error says "not a valid executable", you selected a folder path.
  - Pick exact binary file: `target/debug/<your-binary-name>`
- Confirm adapter binary:
  - `which lldb-dap || which codelldb`
- Run platform installer if missing:
  - `./scripts/install-debug-adapter-macos.sh`
  - `./scripts/install-debug-adapter-linux.sh`
  - `./scripts/install-debug-adapter-termux.sh`

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
