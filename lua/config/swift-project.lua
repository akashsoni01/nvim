--[[
  Swift PM — start a new executable package (run these in a terminal, not in Neovim):

    mkdir MyApp && cd MyApp
    swift package init --type executable --name MyApp
    swift build
    swift run
    nvim .

  Then edit Sources/MyApp/MyApp.swift. Use <leader>tb / <leader>tr / <leader>ta.
  The package folder name and product in Package.swift must match for defaults.
--]]

local M = {}

M.help = [[
Swift: new package (copy into a terminal)

  mkdir MyApp && cd MyApp
  swift package init --type executable --name MyApp
  swift build && swift run
  nvim .

For a library package:
  swift package init --type library

If `swift` is not installed, from this Neovim config repo run:
  bash ./scripts/install-swift.sh
See: https://www.swift.org/install/
]]

function M.print_help()
  vim.notify(M.help, vim.log.levels.INFO, { title = "Swift: new project" })
end

return M
