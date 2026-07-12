local M = {}

local severity = vim.diagnostic.severity
local project = require("config.project")
local cached_build_items = {
  error = {},
  warning = {},
}

local function absolute_path(root, path)
  if path:sub(1, 1) == "/" then
    return path
  end

  return vim.fs.normalize(root .. "/" .. path)
end

---@param levels table<string, boolean>
---@return { filename: string, lnum: integer, col: integer, text: string, detail: string, level: string }[]
local function swift_compiler_messages(root, levels)
  if vim.fn.executable("swift") ~= 1 then
    return {}
  end

  vim.notify("Running swift build…", vim.log.levels.INFO)
  local result = vim.system({ "swift", "build" }, { cwd = root, text = true, stderr = true }):wait()

  local items = {}
  local seen = {}
  local combined = (result.stdout or "") .. "\n" .. (result.stderr or "")

  for line in combined:gmatch("[^\n]+") do
    local path, lnum, col, level, msg = line:match("^(.-):(%d+):(%d+):%s*(error|warning):%s*(.+)$")
    if path and levels[level] then
      local filename = absolute_path(root, path)
      local key = string.format("%s:%d:%d:%s", filename, lnum, col, msg)
      if not seen[key] then
        seen[key] = true
        items[#items + 1] = {
          filename = filename,
          lnum = tonumber(lnum),
          col = math.max(0, tonumber(col) - 1),
          text = msg,
          detail = line,
          level = level,
        }
      end
    end
  end

  if result.code ~= 0 and #items == 0 and result.stderr and result.stderr ~= "" then
    items[#items + 1] = {
      filename = root .. "/Package.swift",
      lnum = 1,
      col = 0,
      text = vim.trim(result.stderr:gsub("\n%s*", " ")),
      detail = result.stderr,
      level = "error",
    }
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
---@return { filename: string, lnum: integer, col: integer, text: string, detail: string, level: string }[]
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
          detail = d.message,
          level = level,
        }
      end
    end
  end

  return items
end

---@param kind "error"|"warning"
---@param opts? { run_build?: boolean }
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

  if opts.run_build ~= false then
    cached_build_items[kind] = {}
    for _, root in ipairs(project.project_roots()) do
      local build_items = swift_compiler_messages(root, levels)
      vim.list_extend(cached_build_items[kind], build_items)
      add_list(build_items)
    end
  else
    add_list(cached_build_items[kind])
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

local function item_lines(item)
  local rel = vim.fn.fnamemodify(item.filename, ":.")
  local header = string.format("%s:%d:%d [%s]", rel, item.lnum, item.col + 1, item.level)
  local lines = { header, string.rep("-", #header), "" }
  vim.list_extend(lines, vim.split(item.detail or item.text, "\n", { plain = true }))
  return lines
end

local function show_issue_float(item)
  local lines = item_lines(item)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  width = math.min(math.max(width, 40), math.floor(vim.o.columns * 0.8))
  local height = math.min(#lines, math.floor(vim.o.lines * 0.5))
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "swift"

  vim.api.nvim_open_win(bufnr, false, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = height,
    border = "rounded",
    style = "minimal",
    title = " compile diagnostic ",
  })
end

local function open_and_jump(item)
  vim.cmd("keepalt edit " .. vim.fn.fnameescape(item.filename))
  vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
  pcall(vim.cmd, "normal! zz")
end

---@param kind "error"|"warning"
---@param opts? { run_build?: boolean, prompt_title?: string }
function M.telescope_compile_issues(kind, opts)
  opts = opts or {}
  local items = collect_items(kind, opts)
  if #items == 0 then
    local source = opts.run_build == false and "current LSP diagnostics or cached swift build results" or "swift build/LSP diagnostics"
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
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  pickers
    .new({}, {
      prompt_title = opts.prompt_title or (kind == "error" and "Compile errors" or "Warnings"),
      finder = finders.new_table({
        results = items,
        entry_maker = function(item)
          local rel = vim.fn.fnamemodify(item.filename, ":.")
          local display = string.format("%s:%d:%d [%s] %s", rel, item.lnum, item.col + 1, item.level, item.text)
          return {
            value = item,
            display = display,
            ordinal = display .. "\n" .. (item.detail or item.text),
            filename = item.filename,
            lnum = item.lnum,
            col = item.col + 1,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "Full diagnostic",
        define_preview = function(self, entry)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, item_lines(entry.value))
          vim.bo[self.state.bufnr].filetype = "swift"
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          open_and_jump(entry.value)
          vim.defer_fn(function()
            show_issue_float(entry.value)
          end, 50)
        end)
        return true
      end,
    })
    :find()
end

---@param kind "error"|"warning"
function M.telescope_lsp_issues(kind)
  M.telescope_compile_issues(kind, {
    run_build = false,
    prompt_title = kind == "error" and "Current/cached errors" or "Current/cached warnings",
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

---@param direction integer
---@param kind "error"|"warning"
function M.jump_issue(direction, kind)
  local items = collect_items(kind, { run_build = false })
  local n = #items
  if n == 0 then
    vim.notify("No " .. kind .. "s found in current LSP diagnostics or cached swift build results.", vim.log.levels.INFO)
    return
  end

  local current_path = vim.api.nvim_buf_get_name(0)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_lnum = cursor[1]
  local current_col = cursor[2]
  local target_idx = nil

  if direction > 0 then
    for i, item in ipairs(items) do
      if item.filename > current_path
        or (item.filename == current_path and item.lnum > current_lnum)
        or (item.filename == current_path and item.lnum == current_lnum and item.col > current_col)
      then
        target_idx = i
        break
      end
    end
    target_idx = target_idx or 1
  else
    for i = n, 1, -1 do
      local item = items[i]
      if item.filename < current_path
        or (item.filename == current_path and item.lnum < current_lnum)
        or (item.filename == current_path and item.lnum == current_lnum and item.col < current_col)
      then
        target_idx = i
        break
      end
    end
    target_idx = target_idx or n
  end

  local steps = vim.v.count1
  target_idx = wrap_idx(target_idx + direction * (steps - 1), n)

  local item = items[target_idx]
  open_and_jump(item)
  vim.defer_fn(function()
    show_issue_float(item)
  end, 50)
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
