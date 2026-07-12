--[[
  Neovim config: Swift only (SourceKit, SPM, LLDB, Telescope, Git).

  New Swift project — run in a terminal:
    mkdir MyApp && cd MyApp
    swift package init --type executable --name MyApp
    swift build && swift run
    nvim .

  Command :SwiftNewProject — show these steps in a notification.
  Module: lua/config/swift-project.lua (same text + :lua require("config.swift-project").print_help())
--]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.identity").setup()
require("config.vim_only").setup()

require "config.options"
require "config.lazy"
require "config.autocmds"
require("config.theme").setup()
require "config.keymaps"

vim.api.nvim_create_user_command("SwiftNewProject", function()
  require("config.swift-project").print_help()
end, { desc = "Show how to create a new Swift package" })
