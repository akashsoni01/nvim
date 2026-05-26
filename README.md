# Neovim Rust Setup (Termux)

This config is a `lazy.nvim`-based Neovim setup focused on Rust development in Termux.

## Highlights
- Coral theme as default with light white toggle
- Rust LSP (`rust-analyzer`) + completion + snippets
- Treesitter syntax highlighting and rustfmt on save
- DAP debugging support for LLDB adapters
- Telescope/Git/LSP/testing keymaps

## Docs
- Full shortcut + workflow guide: [`RUST_NEOVIM_CHEATSHEET.md`](./RUST_NEOVIM_CHEATSHEET.md)

## Offline Mode (Vendor Plugins)
- Run once while online:
  - `bash ./scripts/vendor-plugins.sh`
- This vendors `lazy.nvim` and plugin repos into:
  - `vendor/lazy/lazy.nvim`
  - `vendor/plugins/*`
- After that, this config prefers local vendor paths automatically, so Neovim can start offline.
- The vendor script defaults to `--locked`: it checks out plugin commits from `lazy-lock.json`.
- Use `bash ./scripts/vendor-plugins.sh --latest` only during an intentional plugin update/review window.
- If you add new plugins later, run the vendor script again.
- Remove vendored plugin repos:
  - `bash ./scripts/remove-vendor.sh`
- Check Git worktree support anytime with:
  - `bash ./scripts/check-worktree.sh`

## Corporate Mode
- Start with:
  - `NVIM_CORPORATE_MODE=1 nvim .`
- Corporate mode requires vendored `lazy.nvim` and plugins; it does not fall back to downloaded lazy data or install missing plugins.
- Rust project code execution is reduced by disabling `rust-analyzer` proc macros and check-on-save unless explicitly trusted:
  - `NVIM_CORPORATE_MODE=1 NVIM_TRUST_RUST_PROJECT=1 nvim .`
- For Linux `codelldb` fallback downloads in corporate mode, pin and verify the binary:
  - `CODELLDB_URL=... CODELLDB_SHA256=... NVIM_CORPORATE_MODE=1 ./scripts/install-debug-adapter-linux.sh`

## Cleanup / Uninstall Scripts
- Remove local vendored plugin sources:
  - `bash ./scripts/remove-vendor.sh`
- Remove config-managed debug adapter shims and downloaded `codelldb` files:
  - `bash ./scripts/uninstall-deps.sh`
- Also try package-manager uninstall for `llvm`/`lldb`:
  - `bash ./scripts/uninstall-deps.sh --system`

## Beginner: Open and Navigate a Project

### 1) Open Neovim in your project folder
- From Termux:
  - `cd /path/to/your/rust-project`
  - `nvim .`
- This opens Neovim with your project as the current workspace.

### 2) Find and open files quickly
- `<leader>ff` - Find files in project
- `<leader>fg` - Search text in project (live grep)
- `<leader>fc` - Search text in current file
- `<leader>fb` - Switch between open buffers
- `<leader>fh` - Search Neovim help tags

### 3) Basic movement inside a file
- `h` `j` `k` `l` - left/down/up/right
- `w` / `b` - next/previous word
- `gg` / `G` - top/bottom of file
- `/text` then `n` / `N` - search and jump next/previous match

### 4) Work with multiple files and splits
- `<leader>sv` - Open vertical split
- `<leader>sh` - Open horizontal split
- `<leader>se` - Equalize split sizes
- `<leader>sx` - Close current split
- Move between splits with `Ctrl-w` then `h/j/k/l`

### 5) Navigate Rust code with LSP
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover documentation
- `<leader>rn` - Rename symbol project-wide

### 6) First useful workflow (recommended)
1. Open project: `nvim .`
2. Find file: `<leader>ff`
3. Jump to definition: `gd`
4. Fix issues with code actions: `<leader>ca`
5. Save to format (`rustfmt` runs on save)

## Big Table: Widely Used Commands

| Category | Command / Key | What it does | Beginner tip |
|---|---|---|---|
| Open Project | `nvim .` | Open Neovim in current folder | Run this from your Rust project root |
| Quit | `:q` | Quit current window | If unsaved, use `:q!` to force |
| Save | `:w` | Save current file | Use often while learning |
| Save + Quit | `:wq` | Save then quit | Fast exit command |
| Force Quit | `:q!` | Quit without saving | Discards unsaved changes |
| Move | `h` `j` `k` `l` | Left/down/up/right | Think of `j` as down arrow |
| Word Jump | `w` | Move to next word start | Great for quick code movement |
| Word Back | `b` | Move to previous word start | Use with `w` together |
| Line Start | `0` | Jump to start of line | `^` jumps first non-space |
| Line End | `$` | Jump to end of line | Useful before appending text |
| File Top | `gg` | Jump to top of file | Press twice quickly |
| File Bottom | `G` | Jump to bottom of file | Good for logs and long files |
| Search Forward | `/text` | Search forward for text | Press `n` for next result |
| Search Backward | `?text` | Search backward for text | Press `N` for opposite direction |
| Next Match | `n` | Next search result | Works after `/` or `?` |
| Previous Match | `N` | Previous search result | Reverse direction |
| Insert Mode | `i` | Insert before cursor | Most common editing mode |
| Append | `a` | Insert after cursor | Faster than moving then `i` |
| New Line Below | `o` | New line below and insert | Good for writing code quickly |
| New Line Above | `O` | New line above and insert | Useful in function headers |
| Undo | `u` | Undo last change | Press multiple times for history |
| Redo | `<C-r>` | Redo undone change | Opposite of undo |
| Copy Line | `yy` | Yank (copy) line | Use count like `3yy` |
| Copy Full File | `<leader>yf` | Yank entire file to clipboard | Native alt: `ggyG` |
| Paste Full File | `<leader>pf` | Replace buffer with clipboard | Pair with `<leader>yf` |
| Cut Full File | `<leader>xf` | Cut entire file to clipboard | Clears buffer; use `u` to undo |
| Paste | `p` or `<leader>p` | Paste after cursor | `P` / `<leader>P` paste before cursor |
| Delete Line | `dd` | Delete current line | Use count like `2dd` |
| Change Word | `ciw` | Replace word under cursor | Very common refactor action |
| Command Mode | `:` | Enter command-line mode | Run Ex commands from here |
| File Finder | `<leader>ff` | Telescope find files | Main way to open project files |
| Live Grep | `<leader>fg` | Telescope text search | Search symbols across project |
| Buffer Search | `<leader>fc` | Search text in current file | Fuzzy find in open buffer; no `rg` needed |
| Find in `*.rs` / `*.toml` | `<leader>sg` | Telescope `live_grep` with `rg` globs | Project search only in Rust and TOML files (needs `rg`) |
| Find in any file in project | `<leader>fA` or `<leader>fg` | Telescope `live_grep` (no ext filter) | Same behavior; all text files (needs `rg`; respects `.gitignore`) |
| Replace in any file in project | `<leader>sA` | Literal string replace in every file `rg` lists | All matching files under cwd; needs `rg`; reload buffers; use with care |
| Find & replace in **one** file (any) | `<leader>sr` | Literal `:%s/.../.../gc` with confirm | Current buffer only; any normal file; not terminal/readonly |
| Replace in `*.rs` / `*.toml` (buffer) | `<leader>sf` | Same as `sr`, scoped to Rust/TOML buffers only | Use `sr` for other file types |
| Replace in `*.rs` / `*.toml` (project) | `<leader>sR` | Literal replace on disk in all matches | All matching files from cwd; needs `rg`; reload buffers after |
| Buffers | `<leader>fb` | List open buffers | Quick file switching |
| Help Search | `<leader>fh` | Search help docs | Learn Neovim interactively |
| Vertical Split | `<leader>sv` | Open vertical split | Compare files side-by-side |
| Horizontal Split | `<leader>sh` | Open horizontal split | Useful for terminal + code |
| Equalize Splits | `<leader>se` | Make split sizes equal | Fix uneven layout quickly |
| Close Split | `<leader>sx` | Close current split | Safe cleanup |
| Split Navigation | `<C-w> h/j/k/l` | Move between windows | Core multi-pane workflow |
| Go to Definition | `gd` | Jump to symbol definition | Use constantly in Rust code |
| References | `gr` | Show symbol references | Great for safe refactors |
| Hover Docs | `K` | Show docs for symbol | API info without leaving file |
| Signature Help | `<C-k>` | Show function parameters | Helpful while typing calls |
| Code Action | `<leader>ca` | LSP fixes/actions | Auto-imports and quick fixes |
| Rename Symbol | `<leader>rn` | Rename symbol project-wide | Safer than manual rename |
| Format Buffer | `<leader>fm` | Format current file | Rustfmt also runs on save |
| Next Error | `<leader>len` | Jump to next compile error in file | Line-by-line in current buffer |
| Previous Error | `<leader>lE` | Jump to previous compile error in file | Use count like `3<leader>len` |
| Next Warning | `<leader>lwn` | Jump to next warning in file | Clippy and other WARN diagnostics |
| Previous Warning | `<leader>lW` | Jump to previous warning in file | Wraps at end of file |
| Next Error File | `<leader>lfe` | Telescope list of all compile errors | Runs `cargo check`; full log in preview |
| Current Error List | `<leader>lee` | Telescope list of current/cached errors | Reuses last `lfe`; full log in preview |
| Previous Error File | `<leader>lfE` | Jump to previous error file | After `lfe`, or uses cargo + LSP list |
| Next Warning File | `<leader>lfw` | Telescope list of all warnings | Same as errors, full log in preview |
| Current Warning List | `<leader>lww` | Telescope list of current/cached warnings | Reuses last `lfw`; full log in preview |
| Previous Warning File | `<leader>lfW` | Open previous file with warning | Sorted by file path |
| Parent Rust Folder | `nvim .` from parent | Check direct child crates like `1/` and `2/` | Used by `<leader>lfe` / `<leader>lfw` |
| Toggle Breakpoint | `<leader>db` | Add/remove debugger breakpoint | Start debugging flow |
| Debug Continue | `<leader>dc` | Continue/start debugger | Launches DAP session |
| Step Over | `<leader>do` | Debug step over line | Skip entering function calls |
| Step Into | `<leader>di` | Debug step into function | Inspect deeper behavior |
| Git Status | `<leader>gs` | Telescope git status | See changed files quickly |
| Git Commits | `<leader>gl` | Telescope commit history | Browse recent commits |
| Git Diff | `<leader>gd` | Diff current file | Review current changes |
| Git Branches | `<leader>gb` | Telescope git branches | Switch or inspect branches |
| Git Buffer Commits | `<leader>gC` | Telescope commits for current file | See file-specific history |
| Git Checkout | `<leader>gco` or `:GitCheckout [branch]` | Run `git checkout <branch>` | Switch the current repo to another branch |
| Git Fetch | `<leader>gf` or `:GitFetch` | Run `git fetch --all --prune` | Update remote refs before branching |
| Git Pull | `<leader>gpl` or `:GitPull` | Run `git pull --ff-only` | Update current branch safely |
| Git Push | `<leader>gps` or `:GitPush` | Run `git push` | Push current branch |
| Git Stash | `<leader>gS` or `:GitStash` | Run `git stash push -u` | Save dirty work including untracked files |
| Git Stash List | `<leader>gL` or `:GitStashList` | Run `git stash list` | Review saved stashes |
| Git Stash Apply | `<leader>gA` | Run `git stash apply` | Reapply latest stash |
| Git Hunk Preview | `<leader>ghp` | Preview current hunk | Inspect nearby changes inline |
| Git Hunk Stage | `<leader>ghs` | Stage current hunk | Commit part of a file |
| Git Hunk Reset | `<leader>ghr` | Reset current hunk | Discard one local hunk |
| Git Hunk Blame | `<leader>ghb` | Blame current line | See who last changed a line |
| Git Worktree Create | `<leader>gwc` | Run `git worktree add <path> [branch]` | Create another checkout for an existing branch or commit |
| Git Worktree Branch | `<leader>gwb` | Run `git worktree add -b <branch> <path>` | Create a new branch and checkout together |
| Git Worktree List | `<leader>gwl` | Run `git worktree list` | See all linked worktrees |
| Git Worktree Switch | `<leader>gws` or `:GitWorktreeSwitch` | Change Neovim cwd to a selected worktree | Move this Neovim session to another checkout |
| Git Worktree Delete | `<leader>gwd` | Run `git worktree remove <path>` | Delete a worktree path after cleanup |
| Run Test | `<leader>tt` | Run nearest Rust test | Fast feedback loop |
| Run All Tests | `<leader>ta` | Run full test suite | Use before commits |
| Test Output | `<leader>to` | Toggle test output panel | Debug failed tests |
| Test Summary | `<leader>ts` | Toggle test summary | See pass/fail overview |
| Cargo Clippy | `<leader>tc` | Run clippy with all targets/features | Catch lint issues early |
| Cargo Fmt | `<leader>tf` | Run `cargo fmt` on the project | Format whole crate before commit |
| Cargo Run | `<leader>tr` | Run Rust app | Quick manual verification |
| Toggle Theme | `<leader>ub` | Coral <-> Light White | Pick visual comfort mode |
| Toggle Transparency | `<leader>ut` | Enable/disable transparent bg | Useful per terminal theme |
| Toggle Inlay Hints | `<leader>uh` | Show/hide Rust inlay hints | Reduce visual noise when needed |

## Git Worktree: What to Use When

| Use case | Shortcut | Command pattern |
|---|---|---|
| Work on an existing branch in a second folder | `<leader>gwc` | `git worktree add <path> <branch>` |
| Create a fresh branch and a worktree together | `<leader>gwb` | `git worktree add -b <new-branch> <path> [start-point]` |
| Check which worktrees exist before switching or deleting | `<leader>gwl` | `git worktree list` |
| Move Neovim to another existing worktree | `<leader>gws` | `:cd <selected-worktree>` |
| Delete a finished worktree folder | `<leader>gwd` | `git worktree remove <path>` |

Aliases: `<leader>gwa` also creates/adds a worktree, and `<leader>gwr` also removes/deletes one.

## Git Shortcuts: What to Use When

| Use case | Shortcut | Command pattern |
|---|---|---|
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
