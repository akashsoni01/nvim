-- Find/replace in current buffer or in project, scoped to .rs and .toml (via ripglob).
local M = {}
local telescope_grep = require("config.telescope_grep")

local delim = "#"

--- Literal whole-buffer replace; returns (new_str, n_replacements).
local function literal_replace_all(data, old, new_)
  if old == "" then
    return data, 0
  end
  local n, i, out = 0, 1, data
  while true do
    local a, b = out:find(old, i, true)
    if not a then
      break
    end
    n = n + 1
    out = out:sub(1, a - 1) .. new_ .. out:sub(b + 1)
    i = a + #new_
  end
  return out, n
end

local function escape_very_no_magic(s)
  s = s:gsub("\\", "\\\\")
  s = s:gsub(delim, "\\" .. delim)
  return s
end

function M.buf_is_rs_or_toml()
  local ft = vim.bo.filetype
  if ft == "rust" or ft == "toml" then
    return true
  end
  local ext = vim.fn.expand("%:e")
  return ext == "rs" or ext == "toml"
end

--- Literal find & replace in the current buffer only (`:%s` with confirm).
local function substitute_current_buffer()
  vim.ui.input({ prompt = "Search (literal): " }, function(search)
    if search == nil or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      -- empty repl is valid (delete matches)
      local s = escape_very_no_magic(search)
      local p = escape_very_no_magic(repl)
      vim.cmd("%s" .. delim .. [[\V]] .. s .. delim .. p .. delim .. "gc")
    end)
  end)
end

function M.replace_in_file()
  if not M.buf_is_rs_or_toml() then
    vim.notify("Find/replace in file: use a .rs or .toml buffer (or set filetype).", vim.log.levels.WARN)
    return
  end
  substitute_current_buffer()
end

--- Find & replace in the **current file** (any buffer type suitable for editing).
function M.replace_in_buffer()
  local bt = vim.bo.buftype
  if bt == "terminal" or bt == "prompt" then
    vim.notify("Find/replace: not in terminal/prompt buffers; open a file buffer.", vim.log.levels.WARN)
    return
  end
  if vim.bo.readonly then
    vim.notify("Find/replace: buffer is readonly (`set noreadonly` or use `w!`).", vim.log.levels.WARN)
    return
  end
  substitute_current_buffer()
end

function M.find_in_project()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required. Scoped to *.rs and *.toml.", vim.log.levels.ERROR)
    return
  end
  require("telescope.builtin").live_grep(
    telescope_grep.live_grep_opts({
      prompt_title = "Grep in *.rs and *.toml",
      additional_args = { "-g", "*.rs", "-g", "*.toml" },
    })
  )
end

--- Live grep across the whole project (any file `rg` searches; honors .gitignore).
function M.find_in_project_all()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required for project search.", vim.log.levels.ERROR)
    return
  end
  require("telescope.builtin").live_grep(
    telescope_grep.live_grep_opts({
      prompt_title = "Grep in project (all files)",
    })
  )
end

local function replace_in_paths(paths, search, repl, file_desc)
  if #paths == 0 then
    vim.notify("No files contain that text.", vim.log.levels.WARN)
    return
  end
  local total_r, file_r = 0, 0
  for _, f in ipairs(paths) do
    local p = f
    if vim.fn.filereadable(p) ~= 1 then
      p = vim.fn.fnamemodify(vim.fn.getcwd() .. "/" .. f, ":p")
    end
    if vim.fn.filereadable(p) ~= 1 then
      goto continue
    end
    local lines = vim.fn.readfile(p)
    local data = table.concat(lines, "\n")
    local new, n = literal_replace_all(data, search, repl)
    if n > 0 then
      file_r = file_r + 1
      total_r = total_r + n
      local out_lines = vim.split(new, "\n", { plain = true })
      vim.fn.writefile(out_lines, p)
    end
    ::continue::
  end
  if file_r == 0 then
    vim.notify("No replacements made (files may be read-only or pattern mismatch).", vim.log.levels.WARN)
  else
    vim.notify(
      string.format("Replaced %d occurrence(s) in %d file(s)%s.", total_r, file_r, file_desc),
      vim.log.levels.INFO
    )
  end
end

function M.replace_in_project()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required for project replace.", vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = "Search in *.rs + *.toml (literal): " }, function(search)
    if search == nil or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local paths = vim.fn.systemlist({
        "rg",
        "-F",
        "-l",
        "-g",
        "*.rs",
        "-g",
        "*.toml",
        "--",
        search,
        ".",
      })
      if vim.v.shell_error ~= 0 and #paths == 0 then
        vim.notify("rg failed. Run from the project root (or fix ripgrep).", vim.log.levels.WARN)
        return
      end
      replace_in_paths(paths, search, repl, " (*.rs / *.toml)")
    end)
  end)
end

--- Literal replace in every file under cwd that `rg` lists (full project, respects .gitignore).
function M.replace_in_project_all()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required for project replace.", vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = "Search in project (literal, all files): " }, function(search)
    if search == nil or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local paths = vim.fn.systemlist({ "rg", "-F", "-l", "--", search, "." })
      if vim.v.shell_error ~= 0 and #paths == 0 then
        vim.notify("rg failed. Run from the project root (or fix ripgrep).", vim.log.levels.WARN)
        return
      end
      replace_in_paths(paths, search, repl, " (all matching files)")
    end)
  end)
end

return M
