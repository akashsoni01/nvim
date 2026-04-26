local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 350
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true
opt.wrap = false

-- Live preview when typing :substitute in the command line (split window).
opt.inccommand = "split"

-- GUI: Averia Libre + JetBrains Nerd; cycle with <leader>f[ ] and size with <leader>f+ / <leader>f- (see keymaps).
require("config.guifont_cycle").init_from_g()
