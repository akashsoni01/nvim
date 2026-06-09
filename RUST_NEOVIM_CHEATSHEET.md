# Rust + Neovim Cheatsheet (Termux)

## Leader Key
- `Leader` = `Space`

## All Shortkeys Table

| Area | Shortcut | Action |
| --- | --- | --- |
| Telescope | `<leader>ff` | Find files |
| Telescope | `<leader>fg` | Live grep in project |
| Telescope | `<leader>fc` | Search text in current buffer |
| Telescope | `<leader>fb` | List open buffers |
| Telescope | `<leader>fh` | Help tags |
| LSP | `gd` / `<leader>ld` | Jump to definition |
| LSP | `gpd` / `<leader>lD` | Show definition (peek float, stay in place) |
| LSP | `gr` | Find references |
| LSP | `K` | Hover documentation |
| LSP | `<C-k>` | Signature help |
| LSP | `<leader>ca` | Code actions |
| LSP | `<leader>rn` | Rename symbol |
| LSP | `<leader>fm` | Format current buffer |
| LSP | `<leader>len` | Next compile error |
| LSP | `<leader>lep` | Previous compile error |
| LSP | `<leader>lwn` | Next warning |
| LSP | `<leader>lwp` | Previous warning |
| LSP | `<leader>lfe` | Telescope: all compile errors (file:line) |
| LSP | `<leader>lee` | Telescope: current/cached errors with full log |
| LSP | `<leader>lfE` | Previous error file |
| LSP | `<leader>lfw` | Telescope: all warnings (file:line) |
| LSP | `<leader>lww` | Telescope: current/cached warnings with full log |
| LSP | `<leader>lfW` | Previous file with warning |
| Completion | `<C-Space>` | Open completion menu |
| Completion | `<CR>` | Confirm selected completion |
| Completion | `<Tab>` | Next completion item / snippet jump |
| Completion | `<S-Tab>` | Previous completion item / snippet jump back |
| Debug | `<leader>db` | Toggle breakpoint |
| Debug | `<leader>dc` | Continue/start debugger |
| Debug | `<leader>dn` | Jump to next breakpoint |
| Debug | `<leader>do` | Step over |
| Debug | `<leader>di` | Step into |
| Debug | `<leader>dO` | Step out |
| Debug | `<leader>dr` | Open DAP REPL |
| Debug | `<leader>du` | Toggle debug UI screen |
| Debug | `<leader>de` | Eval variable/expression under cursor |
| Debug | `<leader>dx` | Terminate debug session |
| Git | `<leader>gs` | Git status |
| Git | `<leader>gl` | Git commits log |
| Git | `<leader>gd` | Git diff |
| Git | `<leader>gb` | Git branches |
| Git | `<leader>gC` | Git commits for current buffer |
| Git | `<leader>gco` | Git checkout branch |
| Git | `<leader>gf` | Git fetch all remotes |
| Git | `<leader>gpl` | Git pull fast-forward only |
| Git | `<leader>gps` | Git push current branch |
| Git | `<leader>gS` | Git stash including untracked files |
| Git | `<leader>gL` | Git stash list |
| Git | `<leader>gA` | Git stash apply latest |
| Git | `<leader>ghn` | Next git hunk |
| Git | `<leader>ghN` | Previous git hunk |
| Git | `<leader>ghp` | Preview git hunk |
| Git | `<leader>ghs` | Stage git hunk |
| Git | `<leader>ghr` | Reset git hunk |
| Git | `<leader>ghb` | Blame current line |
| Git | `<leader>ghd` | Toggle deleted lines |
| Git | `<leader>gwc` | Create git worktree |
| Git | `<leader>gwa` | Add git worktree alias |
| Git | `<leader>gwb` | Create git worktree with new branch |
| Git | `<leader>gwl` | List git worktrees |
| Git | `<leader>gws` | Switch Neovim to a worktree |
| Git | `<leader>gwd` | Delete git worktree |
| Git | `<leader>gwr` | Remove git worktree alias |
| Window | `<leader>sv` | Vertical split |
| Window | `<leader>sh` | Horizontal split |
| Window | `<leader>se` | Equalize split sizes |
| Window | `<leader>sx` | Close current split |
| Quit | `<leader>qa` | Save all buffers and quit all windows |
| Quit | `<leader>qQ` | Quit all windows without saving |
| Terminal | `<leader>th` | Open horizontal terminal split |
| Terminal | `<leader>tv` | Open vertical terminal split |
| Terminal | `<C-\><C-n>` | Exit terminal insert mode |
| Testing | `<leader>tt` | Run test under cursor |
| Testing | `<leader>ta` | Run all tests |
| Testing | `<leader>to` | Toggle neotest output panel |
| Testing | `<leader>ts` | Toggle neotest summary panel |
| Testing | `<leader>tc` | Run cargo clippy |
| Testing | `<leader>tf` | Run cargo fmt |
| Testing | `<leader>tb` | Run cargo build |
| Testing | `<leader>tr` | Run cargo run |
| UI | `<leader>ul` | Telescope theme picker (30 themes) |
| UI | `<leader>ut` | Toggle transparency |
| UI | `<leader>uh` | Toggle LSP inlay hints |
| File type | `<leader>ftm` | Set buffer filetype: Markdown (`.md`, docs) |
| File type | `<leader>ftt` | Set buffer filetype: TOML (e.g. `Cargo.toml`) |
| File type | `<leader>fty` | Set buffer filetype: YAML (`.yml` / `.yaml`) |
| File type | `<leader>ftr` | Set buffer filetype: Rust (e.g. after `<leader>ftm`) |
| Grep/Replace (current file, **any** type) | `<leader>sr` | Find & replace in the **open file** only (literal `:%s/.../.../gc`; not terminal) |
| Grep/Replace (`.rs` / `.toml` only) | `<leader>sf` | Same as `sr` but only if the buffer is **Rust or TOML** |
| Grep/Replace (`.rs` / `.toml` only) | `<leader>sg` | **Find** in project: Telescope `live_grep` on `*.rs` + `*.toml` only (needs `rg`) |
| Grep/Replace (`.rs` / `.toml` only) | `<leader>sR` | Find & **replace in project** (literal): all `*.rs` and `*.toml` under cwd (needs `rg`) |
| Grep/Replace (any file) | `<leader>fA` or `<leader>fg` | **Find** in project: Telescope `live_grep` on **all** files (needs `rg`; obeys `.gitignore`); `fA` and `fg` are equivalent |
| Grep/Replace (any file) | `<leader>sA` | Find & **replace in project** (literal) in **all** files `rg` matches (needs `rg`) |
| Editing | `<leader>yf` | Yank full file to clipboard (`NVIM_VIM_FORCE=1`) |
| Editing | `<leader>pf` | Paste full file from clipboard (`NVIM_VIM_FORCE=1`) |
| Editing | `<leader>xf` | Cut full file to clipboard (`NVIM_VIM_FORCE=1`) |
| Editing | `<leader>p` | Paste from system clipboard after cursor (`NVIM_VIM_FORCE=1`) |
| Editing | `<leader>P` | Paste from system clipboard before cursor (`NVIM_VIM_FORCE=1`) |

## Core Shortcuts

### Telescope / Navigation
- `<leader>ff` - Find files
- `<leader>fg` - Live grep in project
- `<leader>fc` - Search text in current buffer
- `<leader>fb` - List open buffers
- `<leader>fh` - Help tags

### LSP
- `gd` / `<leader>ld` - Jump to definition
- `gpd` / `<leader>lD` - Show definition (peek float)
- `gr` - Find references
- `K` - Hover documentation
- `<C-k>` - Signature help (function params)
- `<leader>ca` - Code actions (imports/derives/impl assists)
- `<leader>rn` - Rename symbol
- `<leader>fm` - Format current buffer
- `<leader>len` - Next current/cached compile error; opens the full diagnostic log near the cursor
- `<leader>lep` - Previous current/cached compile error; opens the full diagnostic log near the cursor
- `<leader>lwn` - Next current/cached warning; opens the full diagnostic log near the cursor
- `<leader>lwp` - Previous current/cached warning; opens the full diagnostic log near the cursor
- `<leader>lfe` - **Telescope**: all compile errors (`cargo check` + LSP), with full compiler log in preview; Enter jumps and opens the full log near the cursor
- `<leader>lee` - **Telescope**: current LSP errors + last cached cargo errors; does **not** run `cargo check`
- `<leader>lfE` - Previous error file (from the same list)
- `<leader>lfw` - **Telescope**: all warnings (`cargo check` + LSP), with full compiler log in preview; Enter jumps and opens the full log near the cursor
- `<leader>lww` - **Telescope**: current LSP warnings + last cached cargo warnings; does **not** run `cargo check`
- `<leader>lfW` - Previous warning file

Use `<leader>len` / `<leader>lwn` for next current/cached diagnostics, and `<leader>lep` / `<leader>lwp` for previous current/cached diagnostics. These navigation keys open the full diagnostic float. Use `<leader>lfe` / `<leader>lfw` when you want a fresh `cargo check` scan, including files that are not open yet. After that, `<leader>lee` / `<leader>lww` reopen the current LSP diagnostics plus the last cached cargo results without running `cargo check` again.

If you open a parent folder like `superdir/` with child crates such as `1/` (binary) and `2/` (library), fresh cargo diagnostics (`<leader>lfe` / `<leader>lfw`) run `cargo check` in each direct child crate that has a `Cargo.toml`.

### File type (Markdown, TOML, YAML, Rust)
Use when a buffer is plain text or the wrong syntax (extensionless scratch buffer, copy-paste, or rare paths):
- `<leader>ftm` - Set filetype to Markdown
- `<leader>ftt` - Set filetype to TOML
- `<leader>fty` - Set filetype to YAML (covers `.yml` and `.yaml`)
- `<leader>ftr` - Set filetype back to Rust (after testing another `ft*` on a `.rs` buffer, or to fix detection)

### Find & replace in one file
- **`<leader>sr`** (current buffer, **any** file) — Literal find & replace in **this file only**; runs `:%s/.../.../gc` (confirm each change with `y`/`n`). Use in normal editable buffers, not the terminal. **Readonly** buffers are blocked.

- **`<leader>sf`** (Rust / TOML only) — Same flow as `sr`, but only if the buffer is **`.rs` / `Cargo.toml` / other `.toml`** (or `rust` / `toml` filetype).

### Find & replace (project; Rust / TOML scope)
The following are scoped to **`.rs`** and **`.toml`** (including `Cargo.toml`) for **project** search/replace.
- **`<leader>sg`** (project) — **Search** in the repo: Telescope **live_grep** with `rg` globs `*.rs` and `*.toml` only. Run Neovim from the **project root** (or the cwd you want to search). Requires **ripgrep** (`rg`).
- **`<leader>sR`** (project) — **Replace** the literal search string with the replacement in **all** `*.rs` and `*.toml` files that contain a match. Uses `rg` to list files, then rewrites them on disk. **Reload** buffers in Neovim if you had those files open (`:e` or `:checktime`). Run from the **project root** so paths resolve correctly.

- **`<leader>fA`** (project, **any** file) — **Search** the whole tree with Telescope `live_grep` and no extension filter. Same idea as **`<leader>fg`** (use whichever you remember). Needs **`rg`**.

- **`<leader>sA`** (project, **any** file) — **Replace** a literal string in every file under cwd that `rg` reports as containing a match (not limited to `.rs`/`.toml`). Respects **`.gitignore`**. **Reload** open buffers after; use with care on large trees.

### Debugging (DAP)
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue/start debugger
- `<leader>dn` - Jump to next breakpoint (continue without stepping)
- `<leader>do` - Step over
- `<leader>di` - Step into
- `<leader>dO` - Step out
- `<leader>dr` - Open DAP REPL
- `<leader>du` - Toggle debug UI screen (DAP UI)
- `<leader>de` - Eval variable/expression under cursor
- `<leader>dx` - Terminate debug session

### Git
- `<leader>gs` - Git status (Telescope)
- `<leader>gl` - Git commits log (Telescope)
- `<leader>gd` - Git diff (Gitsigns)
- `<leader>gb` - Git branches (Telescope)
- `<leader>gC` - Current buffer commit history (Telescope)
- `<leader>gco` - Checkout/switch branch with `git checkout <branch>`
- `<leader>gf` - Fetch all remotes and prune deleted refs
- `<leader>gpl` - Pull current branch with `--ff-only`
- `<leader>gps` - Push current branch
- `<leader>gS` - Stash tracked and untracked changes
- `<leader>gL` - List stashes
- `<leader>gA` - Apply latest stash
- `<leader>ghn` / `<leader>ghN` - Next/previous hunk
- `<leader>ghp` - Preview current hunk
- `<leader>ghs` - Stage current hunk
- `<leader>ghr` - Reset current hunk
- `<leader>ghb` - Blame current line
- `<leader>ghd` - Toggle deleted lines
- `:GitCheckout [branch]` - Command form for checkout/switch branch
- `:GitFetch` / `:GitPull` / `:GitPush` - Command forms for sync actions
- `:GitStash` / `:GitStashList` - Command forms for stash actions
- `<leader>gwc` - Create a worktree with `git worktree add <path> [branch]`
- `<leader>gwa` - Alias for create/add worktree
- `<leader>gwb` - Create a worktree and new branch with `git worktree add -b`
- `<leader>gwl` - List worktrees with `git worktree list`
- `<leader>gws` - Switch Neovim's cwd to a selected worktree
- `:GitWorktreeSwitch` - Command form of `<leader>gws`
- `<leader>gwd` - Delete a worktree with `git worktree remove`
- `<leader>gwr` - Alias for delete/remove worktree

#### Git Worktree: What to Use When

| Use case | Shortcut | Command pattern |
| --- | --- | --- |
| Work on an existing branch in a second folder | `<leader>gwc` | `git worktree add <path> <branch>` |
| Create a fresh branch and checkout together | `<leader>gwb` | `git worktree add -b <new-branch> <path> [start-point]` |
| Check all linked worktrees before switching/deleting | `<leader>gwl` | `git worktree list` |
| Move this Neovim session to another worktree | `<leader>gws` | `:cd <selected-worktree>` |
| Delete a finished worktree folder | `<leader>gwd` | `git worktree remove <path>` |

#### Git Shortcuts: What to Use When

| Use case | Shortcut | Command pattern |
| --- | --- | --- |
| Browse changed files | `<leader>gs` | `Telescope git_status` |
| Browse branches | `<leader>gb` | `Telescope git_branches` |
| Switch branch in the current checkout | `<leader>gco` | `git checkout <branch>` |
| Update remote branch info | `<leader>gf` | `git fetch --all --prune` |
| Update your current branch | `<leader>gpl` | `git pull --ff-only` |
| Push current branch | `<leader>gps` | `git push` |
| Save unfinished dirty work | `<leader>gS` | `git stash push -u` |
| Commit only part of a file | `<leader>ghs` | Gitsigns stage hunk |
| Discard one bad hunk | `<leader>ghr` | Gitsigns reset hunk |
| Check why a line changed | `<leader>ghb` | Gitsigns blame line |

### Window / Split Management
- `<leader>sv` - Vertical split
- `<leader>sh` - Horizontal split
- `<leader>se` - Equalize split sizes
- `<leader>sx` - Close current split
- `<leader>qa` - Save all buffers and quit all windows (`:wqa`)
- `<leader>qQ` - Quit all windows without saving (`:qa!`)

### Terminal (open and use)
- Open terminal in horizontal split: `<leader>th`
- Open terminal in vertical split: `<leader>tv`
- Manual commands (alternative):
  - `:split | terminal`
  - `:vsplit | terminal`
- Use existing run mappings (opens terminal split automatically):
  - `<leader>tr` (`cargo run`)
  - `<leader>tc` (`cargo clippy --all-targets --all-features`)
  - `<leader>tf` (`cargo fmt`)
  - `<leader>ta` / `<leader>tt` (test runs)
- Exit terminal insert mode to normal mode: `<C-\><C-n>`
- Close current terminal split: `<leader>sx`

### Testing
- `<leader>tt` - Run test under cursor (`cargo test <word-under-cursor>`)
- `<leader>ta` - Run all tests (`cargo test`)
- `<leader>to` - Toggle neotest output panel
- `<leader>ts` - Toggle neotest summary panel
- `<leader>tc` - Run `cargo clippy --all-targets --all-features`
- `<leader>tf` - Run `cargo fmt`
- `<leader>tb` - Run `cargo build`
- `<leader>tr` - Run `cargo run`

### UI Toggles
- `<leader>ul` - Telescope theme picker
- `<leader>ut` - Toggle transparency
- `<leader>uh` - Toggle LSP inlay hints

### Change Theme
- Press `<leader>ul` to open the Telescope theme picker (30 themes, fuzzy search, preview pane). List order: **all dark themes first**, then **all bright themes**.
- Move through results to **live-preview** each theme; press **Enter** to apply and **save as default** for future sessions.
- `Esc` cancels and restores the theme you had when the picker opened.
- Available palettes:
  - **Coral** / **Light** — orange dark + clean white
  - **Yellow** — gold dark + warm cream
  - **Ocean** — teal dark + seafoam bright
  - **Violet** — cosmic purple dark + lavender bright
  - **Mint** — emerald dark + fresh green bright
  - **Rose** — sakura pink dark + blush bright
  - **Slate** — cool gray dark + clean silver bright
  - **Amber** — burnt honey dark + warm cream bright
  - **Cherry** — crimson dark + soft red bright
  - **Arctic** — icy blue dark + frost bright
  - **Forest** — deep pine dark + meadow bright
  - **Dracula** — classic purple/pink dark + soft light
  - **Solarized** — Ethan Schoonover dark + light
  - **Xcode** — Apple-style dark + bright
  - **Xcode2** — high-contrast for default macOS Terminal.app (black/white base)
- Command mode:
  - Picker: `:lua require("config.theme").pick()`
  - Direct apply: `:lua require("config.theme").apply("xcode2_dark")` (aliases: `xcode2`, `xcode`, `dracula`, `solarized`, `yellow`, `ocean`, `violet`, `mint`, `rose`, `slate`, `amber`, `cherry`, `arctic`, `forest`, `mono`)

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
  - Run fmt: `<leader>tf` (format whole project)
  - Build app: `<leader>tb`

#### Open terminal manually in project
1. Horizontal terminal: `<leader>th`
2. Vertical terminal: `<leader>tv`
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

#### Debugging cheat sheet (table)

| Goal | Shortcut / Command | What it does |
| --- | --- | --- |
| Install adapter on macOS | `./scripts/install-debug-adapter-macos.sh` | Installs/links `lldb-dap` using Xcode CLT or Homebrew llvm |
| Install adapter on Linux | `./scripts/install-debug-adapter-linux.sh` | Installs `lldb-dap` from package manager or falls back to `codelldb` |
| Install adapter on Termux | `./scripts/install-debug-adapter-termux.sh` | Installs `llvm` and links `lldb-dap` |
| Verify adapter | `which lldb-dap || which codelldb` | Confirms debug adapter exists |
| Build debug binary | `cargo build` | Creates `target/debug/<binary>` |
| Start Neovim in project | `nvim .` | Opens project root so DAP uses correct workspace |
| Toggle breakpoint | `<leader>db` | Add/remove breakpoint at current line |
| Start debugger | `<leader>dc` | Starts debug session; config stops on entry so you can step from program start |
| Start debugger command | `:lua require("dap").continue()` | Same as `<leader>dc` |
| Pick executable | `target/debug/<your-binary-name>` | Choose actual binary file, not `target/debug/` directory |
| Jump to next breakpoint | `<leader>dn` | Continue without stepping into library code |
| Step over line | `<leader>do` | Line-by-line execution in current function |
| Step into function | `<leader>di` | Enter function call; may enter library code |
| Step out | `<leader>dO` | Return from current function to caller |
| Toggle debug screen | `<leader>du` | Show/hide DAP UI panels |
| Inspect variable under cursor | `<leader>de` | Evaluate current variable/expression |
| Open debug REPL | `<leader>dr` | Run expressions like `my_var` or `my_struct.field` |
| Stop debugging | `<leader>dx` | Terminate debug session |

| Debug UI panel | What to look for |
| --- | --- |
| `Scopes` | Local variables, function arguments, current values |
| `Stacks` | Call stack / frames; selecting a frame changes visible variables |
| `Watches` | Expressions you want to keep checking |
| `Breakpoints` | Active breakpoint list |
| `REPL` | Manual expression evaluation while paused |

| Problem | Fix |
| --- | --- |
| Error: `target/debug/` is not valid executable | Select `target/debug/<binary-name>`, not the folder |
| Variables missing or `<optimized out>` | Run `cargo build`, avoid release build while debugging |
| Debugger enters `std`, `core`, `alloc`, `tokio`, etc. | Use `<leader>dO` to step out, then `<leader>do` or `<leader>dn` |
| Program runs directly without stopping | Add breakpoint with `<leader>db` on the exact assignment line, or restart Neovim so `stopOnEntry = true` loads |
| Nothing opens for debug state | Press `<leader>du` to toggle DAP UI |
| Adapter missing | Run platform install script or `./scripts/vendor-plugins.sh` |

#### One-time setup (install adapter)
- macOS:
  - `./scripts/install-debug-adapter-macos.sh`
- Linux:
  - `./scripts/install-debug-adapter-linux.sh`
- Termux:
  - `./scripts/install-debug-adapter-termux.sh`
- Or run everything (plugins + adapter check/install):
  - `./scripts/vendor-plugins.sh`

#### Cleanup / uninstall
- Remove vendored plugin repos:
  - `./scripts/remove-vendor.sh`
- Remove config-managed debug adapter shims and downloaded `codelldb` files:
  - `./scripts/uninstall-deps.sh`
- Also try package-manager uninstall for `llvm`/`lldb`:
  - `./scripts/uninstall-deps.sh --system`

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
   - command form: `:lua require("dap").continue()`
5. When prompted, choose a real binary file like:
   - `target/debug/<your-crate-name>`
   - not `target/debug/` (directory)
6. The debugger now stops on entry. Press `<leader>do` to step line-by-line, or `<leader>dn` to continue to the next breakpoint.

#### See debugger state while paused
- Variables/scopes/call stack:
  - opens automatically with `nvim-dap-ui` after debugger starts
  - toggle manually anytime: `<leader>du`
- Step controls:
  - `<leader>do` step over
  - `<leader>di` step into
  - `<leader>dO` step out
- Open DAP REPL:
  - `<leader>dr`
- Inspect expression under cursor:
  - `<leader>de`
- Stop session:
  - `<leader>dx`

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
- To stop on an assignment statement, put the cursor exactly on that assignment line and press `<leader>db` before `<leader>dc`.

#### Debug line-by-line vs step into functions
- `<leader>dc` - Continue execution (or start debugger). Runs until next breakpoint.
- `<leader>dn` - Jump from current breakpoint to next breakpoint without stepping through library code.
- `<leader>do` - Step over current line. Use this for normal line-by-line debugging in your app code.
- `<leader>di` - Step into function call on current line. This can enter dependency/library code.
- `<leader>dO` - Step out of current function and return to caller.
- If debugger goes inside `std`, `core`, `alloc`, `tokio`, etc.:
  - press `<leader>dO` to leave that function
  - then continue line-by-line with `<leader>do`
  - avoid `<leader>di` unless you really want to inspect that function
- LLDB is configured to avoid common Rust/library frames while stepping, but step-into can still enter libraries when source/debug info is available.

#### Typical debug flow
1. Set 1-3 breakpoints with `<leader>db`.
2. Start/continue with `<leader>dc`.
3. At a breakpoint:
   - Use `<leader>do` for line-by-line in current function.
   - Use `<leader>dn` to jump directly to the next breakpoint.
   - Use `<leader>di` when a called function is suspicious.
   - Use `<leader>dO` to return back quickly if you entered a library or helper function.
4. Continue to next breakpoint with `<leader>dn` or `<leader>dc`.

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

### `rust-analyzer` not working (`gd` / `K` do nothing)
- Verify install:
  - `pkg install rust`
  - `rustup component add rust-analyzer`
- In Neovim:
  - `:Mason` and ensure `rust_analyzer` is present (auto-installed on startup when online)
  - `:LspInfo` — should show `rust_analyzer` attached to `.rs` buffers
  - `:checkhealth vim.lsp` for startup errors
- Project root:
  - Open a file **inside** a crate (`Cargo.toml` folder), or a parent folder with child crates (`1/`, `2/`)
  - If filetype is wrong, use `<leader>ftr` to set Rust
- Wait a few seconds after opening a file — `rust-analyzer` indexes before `gd` / `K` return docs

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
- `yy` yank line, `<leader>yf` yank full file, `<leader>pf` paste full file, `<leader>xf` cut full file, `p` or `<leader>p` paste after
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
- `./scripts/check-worktree.sh` - verify `git worktree` support
- `./scripts/remove-vendor.sh` - remove local vendored plugin repos
- `./scripts/uninstall-deps.sh` - remove config-managed debug adapter files


## Enterprise Defaults (`NVIM_VIM_FORCE`)
- Default: `nvim .` (enterprise-safe; no external read/write integrations)
- Opt in to clipboard, path/crate completions, plugin downloads, proc macros:
  - `NVIM_VIM_FORCE=1 nvim .`
- Without force mode:
  - No Linux clipboard (`wl-clipboard` / `xclip` / `xsel`) or `+` register maps
  - No `cmp-path` or `crates.nvim` completion
  - No `lazy.nvim` missing-plugin download or luarocks
  - No `rust-analyzer` proc macros / check-on-save
  - No `codelldb` network download in `install-debug-adapter-linux.sh`

## Neovim-Only Workspace (default)
- `nvim .` marks the workspace and stashes `.vscode` / `.cursor` / ignore files while Neovim runs
- Restore IDE indexing for a project: `NVIM_VIM_ONLY=0 nvim .`
- Commands: `:VimOnlyMark`, `:VimOnlyReset`

## Corporate Mode
- Start locked-down mode: `NVIM_CORPORATE_MODE=1 nvim .`
- Requires reviewed vendored plugins; missing plugins are not downloaded automatically.
- Rust proc macros and check-on-save need force mode and an explicit trust flag:
  - `NVIM_VIM_FORCE=1 NVIM_CORPORATE_MODE=1 NVIM_TRUST_RUST_PROJECT=1 nvim .`
- Vendor reviewed plugin commits from `lazy-lock.json`:
  - `bash ./scripts/vendor-plugins.sh --locked`
- Update to latest plugin commits only during review:
  - `bash ./scripts/vendor-plugins.sh --latest`

## Environment Variables
| Variable | Default | Effect |
| --- | --- | --- |
| `NVIM_VIM_FORCE` | off | Enable clipboard, external completions, downloads, proc macros |
| `NVIM_VIM_ONLY` | mark on `nvim .` | `0` = unmark project; `1` = explicit mark |
| `NVIM_CORPORATE_MODE` | off | Require vendored plugins; block lazy downloads |
| `NVIM_TRUST_RUST_PROJECT` | off | Allow rust proc macros when corporate + force mode |

