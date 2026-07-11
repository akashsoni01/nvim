local M = {}

local security = require("config.security")

local function clip_register()
  return security.allow_system_clipboard() and "+" or '"'
end

local function reg_yank_keys(reg)
  if reg == "+" then
    return '"+y'
  end
  return "y"
end

local function reg_op_keys(reg, op)
  if reg == "+" then
    return '"+' .. op
  end
  return op
end

local function visual_span()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return start_line, end_line
end

function M.copy_visual()
  local mode = vim.fn.visualmode()
  local reg = clip_register()

  if mode == "V" then
    local start_line, end_line = visual_span()
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    vim.fn.setreg(reg, table.concat(lines, "\n") .. "\n", "V")
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(reg_yank_keys(reg), true, false, true), "v", true)
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

function M.cut_visual()
  local reg = clip_register()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(reg_op_keys(reg, "d"), true, false, true),
    "v",
    true
  )
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

function M.paste_visual()
  local reg = clip_register()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(reg_op_keys(reg, "p"), true, false, true),
    "v",
    true
  )
end

return M
