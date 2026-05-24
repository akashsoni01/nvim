vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.identity").setup()

require "config.options"
require "config.lazy"
require "config.autocmds"
require "config.keymaps"
