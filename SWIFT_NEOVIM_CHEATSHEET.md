# Swift + Neovim Cheatsheet

## Leader
- `Leader` = `Space`

## New project (terminal)
```bash
mkdir MyApp && cd MyApp
swift package init --type executable --name MyApp
swift build && swift run
nvim .
```
- In Neovim: `:SwiftNewProject` — show these steps.
- In config: see top of `init.lua` and `lua/config/swift-project.lua`.

## Telescope
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |

## LSP (SourceKit)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover |
| `<C-k>` | Signature help |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `<leader>fm` | Format buffer |

## Swift PM (split terminal)
| Key | Command |
|-----|---------|
| `<leader>tb` | `swift build` |
| `<leader>tr` | `swift run` |
| `<leader>ta` | `swift test` |
| `<leader>tt` | `swift test` or `--filter <cword>` |
| `<leader>to` | `swift test -v` |
| `<leader>ts` | `swift test --parallel` |
| `<leader>tc` | `swift package resolve` |

## Debug (LLDB)
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start |
| `<leader>do` / `<leader>di` / `<leader>dO` | Step over / into / out |
| `<leader>du` | DAP UI |
| `<leader>dx` | Terminate |

Build first: `swift build`. Launch config defaults to `.build/debug/<foldername>`; adjust to match your product in `Package.swift`.

## Git
Same as before: `<leader>gs` status, `<leader>gl` log, `<leader>gb` branches, worktree keys, etc. (see `lua/config/keymaps.lua`).

## UI
- `<leader>ub` — theme  
- `<leader>ut` — transparency  
- `<leader>uh` — inlay hints  

## Useful
- `:LspInfo` — clients  
- `:checkhealth`  
- SourceKit: ensure `xcrun sourcekit-lsp` (mac) or `sourcekit-lsp` on `PATH` (Linux).  
