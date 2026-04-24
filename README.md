# Neovim Rust Setup (Termux)

This config is a `lazy.nvim`-based Neovim setup focused on Rust development in Termux.

## Highlights
- Coral theme as default with monochrome toggle
- Rust LSP (`rust-analyzer`) + completion + snippets
- Treesitter syntax highlighting and rustfmt on save
- DAP debugging support for LLDB adapters
- Telescope/Git/LSP/testing keymaps

## Docs
- Full shortcut + workflow guide: [`RUST_NEOVIM_CHEATSHEET.md`](./RUST_NEOVIM_CHEATSHEET.md)

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
