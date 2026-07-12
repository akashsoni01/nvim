local group = vim.api.nvim_create_augroup("JavaNvimConfig", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    require("config.theme").apply(require("config.theme").mode)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    require("config.theme").apply_default()
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.java",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
  group = group,
  callback = function()
    vim.diagnostic.config({
      virtual_text = {
        source = "if_many",
        spacing = 2,
        prefix = "●",
      },
      underline = true,
      signs = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "BufWinEnter" }, {
  group = group,
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      return
    end

    local bt = vim.bo.buftype
    if bt == "nofile" or bt == "prompt" or bt == "terminal" or bt == "quickfix" then
      vim.wo.winbar = ""
      return
    end

    local width = vim.api.nvim_win_get_width(0)
    if width < 40 then
      vim.wo.winbar = ""
      return
    end

    local ok_navic, navic = pcall(require, "nvim-navic")
    local file = vim.fn.expand("%:t")
    if file == "" then
      file = "[No Name]"
    end
    file = file:gsub("%%", "%%%%")
    local crumbs = ""
    if ok_navic and navic.is_available() then
      crumbs = navic.get_location()
    end
    local text
    if crumbs ~= "" then
      text = " " .. file .. "  >  " .. crumbs
    else
      text = " " .. file
    end

    if #text > width - 4 then
      text = text:sub(1, math.max(1, width - 7)) .. "..."
    end

    pcall(function()
      vim.wo.winbar = text
    end)
  end,
})
