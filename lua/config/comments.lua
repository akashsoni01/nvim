local M = {}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function line_indent(line)
  return line:match("^(%s*)") or ""
end

local function get_visual_lines()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return start_line, end_line
end

local function wrapped_block_comment(bufnr, start_line, end_line, first, last)
  if trim(first) == "/*" and trim(last) == "*/" then
    return true
  end

  local before = start_line > 1 and vim.api.nvim_buf_get_lines(bufnr, start_line - 2, start_line - 1, false)[1]
  local after = vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1]
  return before and trim(before) == "/*" and after and trim(after) == "*/"
end

local function inline_block_comment(first, last)
  local open = first:find("/%*", 1, true)
  local close = last:find("%*/", 1, true)
  return open ~= nil and close ~= nil and not (trim(first) == "/*" and trim(last) == "*/")
end

local function uncomment_wrapped(bufnr, start_line, end_line, first, last)
  if trim(first) == "/*" and trim(last) == "*/" then
    if start_line == end_line then
      vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, {})
      return start_line - 1
    end

    vim.api.nvim_buf_set_lines(bufnr, end_line - 1, end_line, false, {})
    vim.api.nvim_buf_set_lines(bufnr, start_line - 1, start_line, false, {})
    return start_line
  end

  -- Closing `*/` sits on the line after the selection (1-indexed end_line + 1).
  vim.api.nvim_buf_set_lines(bufnr, end_line, end_line + 1, false, {})
  vim.api.nvim_buf_set_lines(bufnr, start_line - 2, start_line - 1, false, {})
  return start_line - 1
end

local function uncomment_inline(bufnr, start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  lines[1] = lines[1]:gsub("^(%s*)/%*", "%1")
  lines[#lines] = lines[#lines]:gsub("%*/%s*$", "")
  vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, lines)
  return start_line
end

local function comment_wrapped(bufnr, start_line, end_line)
  local first = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
  local indent = line_indent(first)
  vim.api.nvim_buf_set_lines(bufnr, start_line - 1, start_line - 1, false, { indent .. "/*" })
  vim.api.nvim_buf_set_lines(bufnr, end_line + 1, end_line + 1, false, { indent .. "*/" })
end

local function finish(lnum, col)
  col = col or 1
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  vim.schedule(function()
    local max = vim.api.nvim_buf_line_count(0)
    lnum = math.min(math.max(lnum, 1), max)
    pcall(vim.api.nvim_win_set_cursor, 0, { lnum, col - 1 })
  end)
end

function M.toggle_block()
  if vim.bo.modifiable == false then
    vim.notify("Cannot comment a readonly buffer.", vim.log.levels.WARN)
    return
  end

  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local start_line, end_line = get_visual_lines()
  local first = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]
  local last = vim.api.nvim_buf_get_lines(bufnr, end_line - 1, end_line, false)[1]

  if wrapped_block_comment(bufnr, start_line, end_line, first, last) then
    local cursor_line = uncomment_wrapped(bufnr, start_line, end_line, first, last)
    finish(cursor_line)
    return
  end

  if inline_block_comment(first, last) then
    local cursor_line = uncomment_inline(bufnr, start_line, end_line)
    finish(cursor_line)
    return
  end

  comment_wrapped(bufnr, start_line, end_line)
  finish(start_line + 1)
end

return M
