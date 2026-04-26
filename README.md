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
- If you add new plugins later, run the vendor script again.
- Check Git worktree support anytime with:
  - `bash ./scripts/check-worktree.sh`

## Beginner: Open and Navigate a Project

### 1) Open Neovim in your project folder
- From Termux:
  - `cd /path/to/your/rust-project`
  - `nvim .`
- This opens Neovim with your project as the current workspace.

### 2) Find and open files quickly
- `<leader>ff` - Find files in project
- `<leader>fg` - Search text in project (live grep)
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
| Paste | `p` | Paste after cursor | `P` pastes before cursor |
| Delete Line | `dd` | Delete current line | Use count like `2dd` |
| Change Word | `ciw` | Replace word under cursor | Very common refactor action |
| Command Mode | `:` | Enter command-line mode | Run Ex commands from here |
| File Finder | `<leader>ff` | Telescope find files | Main way to open project files |
| Live Grep | `<leader>fg` | Telescope text search | Search symbols across project |
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
| Toggle Breakpoint | `<leader>db` | Add/remove debugger breakpoint | Start debugging flow |
| Debug Continue | `<leader>dc` | Continue/start debugger | Launches DAP session |
| Step Over | `<leader>do` | Debug step over line | Skip entering function calls |
| Step Into | `<leader>di` | Debug step into function | Inspect deeper behavior |
| Git Status | `<leader>gs` | Telescope git status | See changed files quickly |
| Git Commits | `<leader>gl` | Telescope commit history | Browse recent commits |
| Git Diff | `<leader>gd` | Diff current file | Review current changes |
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
