local M = {}

local severity = vim.diagnostic.severity

---@param idx integer
---@param n integer
---@return integer
local function wrap_idx(idx, n)
  idx = (idx - 1) % n
  if idx < 0 then
    idx = idx + n
  end
  return idx + 1
end

---@param sev integer vim.diagnostic.severity
---@return { bufnr: integer, path: string, diagnostic: vim.Diagnostic }[]
local function files_with_diagnostics(sev)
  local all = vim.diagnostic.get(nil, {
    severity = { min = sev, max = sev },
  })

  local by_buf = {}
  for _, d in ipairs(all) do
    local bufnr = d.bufnr
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path ~= "" then
      local existing = by_buf[bufnr]
      if not existing or d.lnum < existing.lnum or (d.lnum == existing.lnum and d.col < existing.col) then
        by_buf[bufnr] = d
      end
    end
  end

  local items = {}
  for bufnr, d in pairs(by_buf) do
    items[#items + 1] = {
      bufnr = bufnr,
      path = vim.api.nvim_buf_get_name(bufnr),
      diagnostic = d,
    }
  end

  table.sort(items, function(a, b)
    if a.path == b.path then
      return a.diagnostic.lnum < b.diagnostic.lnum
    end
    return a.path < b.path
  end)

  return items
end

---@param item { bufnr: integer, path: string, diagnostic: vim.Diagnostic }
local function open_and_jump(item)
  local d = item.diagnostic
  vim.cmd("keepalt edit " .. vim.fn.fnameescape(item.path))
  vim.api.nvim_win_set_cursor(0, { d.lnum + 1, d.col })
  pcall(vim.cmd, "normal! zz")
end

---@param direction integer 1 for next, -1 for previous
---@param sev integer vim.diagnostic.severity
function M.jump_file(direction, sev)
  local items = files_with_diagnostics(sev)
  local n = #items
  if n == 0 then
    local label = sev == severity.ERROR and "error" or "warning"
    vim.notify("No " .. label .. " files in diagnostics", vim.log.levels.INFO)
    return
  end

  local current_path = vim.api.nvim_buf_get_name(0)
  local current_idx = nil
  for i, item in ipairs(items) do
    if item.bufnr == vim.api.nvim_get_current_buf() or item.path == current_path then
      current_idx = i
      break
    end
  end

  local steps = vim.v.count1
  local target_idx

  if current_idx then
    target_idx = wrap_idx(current_idx + direction * steps, n)
  elseif direction > 0 then
    target_idx = 1
    for i, item in ipairs(items) do
      if item.path > current_path then
        target_idx = wrap_idx(i + steps - 1, n)
        break
      end
    end
  else
    target_idx = n
    for i = n, 1, -1 do
      if items[i].path < current_path then
        target_idx = wrap_idx(i - (steps - 1), n)
        break
      end
    end
  end

  open_and_jump(items[target_idx])
end

return M
