local M = {}

local severity = vim.diagnostic.severity
local rust_test = require("config.rust_test")

local function absolute_path(root, path)
  if path:sub(1, 1) == "/" then
    return path
  end

  return vim.fs.normalize(root .. "/" .. path)
end

---@param levels table<string, boolean>
---@return { filename: string, lnum: integer, col: integer, text: string, level: string }[]
local function cargo_compiler_messages(root, levels)
  if vim.fn.executable("cargo") ~= 1 then
    return {}
  end

  vim.notify("Running cargo check…", vim.log.levels.INFO)
  local result = vim.system(
    { "cargo", "check", "--message-format=json", "-q" },
    { cwd = root, text = true, stderr = true }
  ):wait()

  local items = {}
  local seen = {}

  for line in (result.stdout or ""):gmatch("[^\n]+") do
    local ok, obj = pcall(vim.json.decode, line)
    if ok and obj and obj.reason == "compiler-message" and obj.message then
      local level = obj.message.level
      if levels[level] then
        local msg = vim.trim((obj.message.message or ""):gsub("\n%s*", " "))
        local code = obj.message.code and obj.message.code.code
        if code then
          msg = string.format("[%s] %s", code, msg)
        end

        for _, span in ipairs(obj.message.spans or {}) do
          if span.file_name and (span.is_primary or #obj.message.spans == 1) then
            local filename = absolute_path(root, span.file_name)
            local key = string.format("%s:%d:%d:%s", filename, span.line_start, span.column_start, msg)
            if not seen[key] then
              seen[key] = true
              items[#items + 1] = {
                filename = filename,
                lnum = span.line_start,
                col = math.max(0, span.column_start - 1),
                text = msg,
                level = level,
              }
            end
          end
        end
      end
    end
  end

  table.sort(items, function(a, b)
    if a.filename == b.filename then
      if a.lnum == b.lnum then
        return a.col < b.col
      end
      return a.lnum < b.lnum
    end
    return a.filename < b.filename
  end)

  return items
end

---@param sev integer
---@return { filename: string, lnum: integer, col: integer, text: string, level: string }[]
local function lsp_diagnostic_items(sev)
  local items = {}
  local seen = {}

  for _, d in ipairs(vim.diagnostic.get(nil, { severity = { min = sev, max = sev } })) do
    local path = vim.api.nvim_buf_get_name(d.bufnr)
    if path ~= "" then
      local key = string.format("%s:%d:%d:%s", path, d.lnum + 1, d.col, d.message)
      if not seen[key] then
        seen[key] = true
        local level = sev == severity.ERROR and "error" or "warning"
        items[#items + 1] = {
          filename = path,
          lnum = d.lnum + 1,
          col = d.col,
          text = d.message,
          level = level,
        }
      end
    end
  end

  return items
end

---@param kind "error"|"warning"
---@param opts? { run_cargo?: boolean }
local function collect_items(kind, opts)
  opts = opts or {}
  local levels = kind == "error" and { error = true } or { warning = true }
  local sev = kind == "error" and severity.ERROR or severity.WARN

  local items = {}
  local seen = {}

  local function add_list(list)
    for _, item in ipairs(list) do
      local key = string.format("%s:%d:%d:%s", item.filename, item.lnum, item.col, item.text)
      if not seen[key] then
        seen[key] = true
        items[#items + 1] = item
      end
    end
  end

  add_list(lsp_diagnostic_items(sev))

  if opts.run_cargo ~= false then
    local root = rust_test.project_root()
    if root then
      add_list(cargo_compiler_messages(root, levels))
    end
  end

  table.sort(items, function(a, b)
    if a.filename == b.filename then
      if a.lnum == b.lnum then
        return a.col < b.col
      end
      return a.lnum < b.lnum
    end
    return a.filename < b.filename
  end)

  return items
end

---@param kind "error"|"warning"
---@param opts? { run_cargo?: boolean, prompt_title?: string }
function M.telescope_compile_issues(kind, opts)
  opts = opts or {}
  local items = collect_items(kind, opts)
  if #items == 0 then
    local source = opts.run_cargo == false and "current LSP diagnostics" or "cargo check/LSP diagnostics"
    vim.notify("No " .. kind .. "s found in " .. source .. ".", vim.log.levels.INFO)
    return
  end

  local qf = {}
  for _, item in ipairs(items) do
    qf[#qf + 1] = {
      filename = item.filename,
      lnum = item.lnum,
      col = item.col + 1,
      text = item.text,
      type = item.level == "error" and "E" or "W",
    }
  end

  vim.fn.setqflist(qf, "r")
  require("telescope.builtin").quickfix({
    prompt_title = opts.prompt_title or (kind == "error" and "Compile errors" or "Warnings"),
    show_line = true,
  })
end

---@param kind "error"|"warning"
function M.telescope_lsp_issues(kind)
  M.telescope_compile_issues(kind, {
    run_cargo = false,
    prompt_title = kind == "error" and "Current LSP errors" or "Current LSP warnings",
  })
end

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

---@param item { filename: string, lnum: integer, col: integer }
local function open_and_jump(item)
  vim.cmd("keepalt edit " .. vim.fn.fnameescape(item.filename))
  vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
  pcall(vim.cmd, "normal! zz")
end

---@param direction integer
---@param kind "error"|"warning"
function M.jump_file(direction, kind)
  local items = collect_items(kind)
  local n = #items
  if n == 0 then
    M.telescope_compile_issues(kind)
    return
  end

  local current_path = vim.api.nvim_buf_get_name(0)
  local current_idx = nil
  for i, item in ipairs(items) do
    if item.filename == current_path then
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
      if item.filename > current_path then
        target_idx = wrap_idx(i + steps - 1, n)
        break
      end
    end
  else
    target_idx = n
    for i = n, 1, -1 do
      if items[i].filename < current_path then
        target_idx = wrap_idx(i - (steps - 1), n)
        break
      end
    end
  end

  open_and_jump(items[target_idx])
end

return M
