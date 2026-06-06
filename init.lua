vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.identity").setup()
require("config.vim_only").setup()

require "config.options"
require "config.lazy"
require "config.autocmds"
require("config.theme").setup()
require "config.keymaps"
