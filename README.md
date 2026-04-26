# Neovim — Swift development

`lazy.nvim` config for **Swift only**: SourceKit LSP, Treesitter, LLDB debugging, Telescope, Git, format on save for `*.swift`. Open any Swift package with `nvim .` (from the folder that contains `Package.swift`).

## New Swift project (basic)

In a terminal:

```bash
mkdir MyApp && cd MyApp
swift package init --type executable --name MyApp
swift build
swift run
nvim .
```

Edit `Sources/MyApp/MyApp.swift`. Inside Neovim you can run `:SwiftNewProject` to show the same steps in a notification, or read `lua/config/swift-project.lua` / the comment at the top of `init.lua`.

## Requirements

- **Swift** toolchain ([swift.org](https://www.swift.org/install/))
- **SourceKit LSP**: on macOS often `xcrun sourcekit-lsp` (Xcode or CLT); on Linux, `sourcekit-lsp` on your `PATH`
- **LLDB** for DAP: `lldb-dap` or `codelldb` (run `scripts/vendor-plugins.sh` to try a macOS `bin/lldb-dap` shim)

## Highlights

- SourceKit (`sourcekit`) + completion + snippets  
- Treesitter `swift` + common helpers  
- `BufWritePre` format for `*.swift`  
- Same leader keys as before for **SPM**: `<leader>tb` build, `<leader>tr` run, `<leader>ta` / `<leader>tt` tests, `<leader>tc` `package resolve`  
- Offline vendoring: `bash ./scripts/vendor-plugins.sh`  

## Docs

- Cheatsheet: [`SWIFT_NEOVIM_CHEATSHEET.md`](./SWIFT_NEOVIM_CHEATSHEET.md)

## Offline mode (vendor plugins)

```bash
bash ./scripts/vendor-plugins.sh
```

Removes need to fetch plugins at startup if `vendor/` is populated. Refresh when you change `lua/plugins/init.lua`.

```bash
bash ./scripts/remove-vendor.sh
```

## Cleanup

```bash
bash ./scripts/uninstall-deps.sh
```

## Beginner workflow

1. `cd` into your package (with `Package.swift`)  
2. `nvim .`  
3. `<leader>ff` find files, `gd` / `K` LSP, `<leader>tb` build, `<leader>tr` run  
4. Debug: `<leader>db`, `<leader>dc`, pick `.build/debug/<ProductName>`  
