local group = vim.api.nvim_create_augroup("RustTermuxConfig", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    require("config.theme").apply(require("config.theme").mode)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    require("config.theme").apply("coral")
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*.rs",
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
    local ok_navic, navic = pcall(require, "nvim-navic")
    local file = "%f"
    local crumbs = ""
    if ok_navic and navic.is_available() then
      crumbs = navic.get_location()
    end
    if crumbs ~= "" then
      vim.wo.winbar = " " .. file .. "  >  " .. crumbs
    else
      vim.wo.winbar = " " .. file
    end
  end,
})
