local opt = vim.opt

local function configure_linux_clipboard()
  if vim.fn.has("linux") ~= 1 then
    return
  end

  if vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
    vim.g.clipboard = {
      name = "wl-clipboard",
      copy = {
        ["+"] = "wl-copy --foreground --type text/plain",
        ["*"] = "wl-copy --foreground --primary --type text/plain",
      },
      paste = {
        ["+"] = "wl-paste --no-newline",
        ["*"] = "wl-paste --no-newline --primary",
      },
      cache_enabled = 0,
    }
    return
  end

  if vim.fn.executable("xclip") == 1 then
    vim.g.clipboard = {
      name = "xclip",
      copy = {
        ["+"] = "xclip -quiet -selection clipboard",
        ["*"] = "xclip -quiet -selection primary",
      },
      paste = {
        ["+"] = "xclip -o -selection clipboard",
        ["*"] = "xclip -o -selection primary",
      },
      cache_enabled = 0,
    }
    return
  end

  if vim.fn.executable("xsel") == 1 then
    vim.g.clipboard = {
      name = "xsel",
      copy = {
        ["+"] = "xsel --clipboard --input",
        ["*"] = "xsel --primary --input",
      },
      paste = {
        ["+"] = "xsel --clipboard --output",
        ["*"] = "xsel --primary --output",
      },
      cache_enabled = 0,
    }
    return
  end

  vim.schedule(function()
    vim.notify(
      "Clipboard provider missing on Linux. Install wl-clipboard (Wayland) or xclip/xsel (X11).",
      vim.log.levels.WARN
    )
  end)
end

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

-- GUI clients can use this; terminal fallback remains external.
opt.guifont = "Averia_Libre:h13,JetBrainsMono Nerd Font:h13"

configure_linux_clipboard()
