-- Find/replace in project (Java: *.java, pom.xml, Gradle files).
local M = {}
local telescope_grep = require("config.telescope_grep")
local project = require("config.project")

local delim = "#"
local GLOB_ARGS = {
  "-g",
  "*.java",
  "-g",
  "pom.xml",
  "-g",
  "build.gradle*",
  "-g",
  "settings.gradle*",
  "-g",
  "*.properties",
}

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

local function substitute_current_buffer()
  vim.ui.input({ prompt = "Search (literal): " }, function(search)
    if search == nil or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local s = escape_very_no_magic(search)
      local p = escape_very_no_magic(repl)
      vim.cmd("%s" .. delim .. [[\V]] .. s .. delim .. p .. delim .. "gc")
    end)
  end)
end

function M.replace_in_file()
  if not project.buf_is_project_file() then
    vim.notify("Find/replace in file: use a .java or build file buffer.", vim.log.levels.WARN)
    return
  end
  substitute_current_buffer()
end

function M.replace_in_buffer()
  local bt = vim.bo.buftype
  if bt == "terminal" or bt == "prompt" then
    vim.notify("Find/replace: not in terminal/prompt buffers.", vim.log.levels.WARN)
    return
  end
  substitute_current_buffer()
end

function M.find_in_project()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required.", vim.log.levels.ERROR)
    return
  end
  require("telescope.builtin").live_grep(
    telescope_grep.live_grep_opts({
      prompt_title = "Grep in Java project",
      additional_args = GLOB_ARGS,
    })
  )
end

function M.find_in_project_all()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required.", vim.log.levels.ERROR)
    return
  end
  require("telescope.builtin").live_grep(
    telescope_grep.live_grep_opts({ prompt_title = "Grep in project (all files)" })
  )
end

local function replace_in_paths(paths, search, repl, file_desc)
  if #paths == 0 then
    vim.notify("No files contain that text.", vim.log.levels.WARN)
    return
  end
  local total_r, file_r = 0, 0
  for _, f in ipairs(paths) do
    local p = vim.fn.filereadable(f) == 1 and f or vim.fn.fnamemodify(vim.fn.getcwd() .. "/" .. f, ":p")
    if vim.fn.filereadable(p) ~= 1 then
      goto continue
    end
    local data = table.concat(vim.fn.readfile(p), "\n")
    local new, n = literal_replace_all(data, search, repl)
    if n > 0 then
      file_r = file_r + 1
      total_r = total_r + n
      vim.fn.writefile(vim.split(new, "\n", { plain = true }), p)
    end
    ::continue::
  end
  if file_r == 0 then
    vim.notify("No replacements made.", vim.log.levels.WARN)
  else
    vim.notify(string.format("Replaced %d occurrence(s) in %d file(s)%s.", total_r, file_r, file_desc), vim.log.levels.INFO)
  end
end

function M.replace_in_project()
  if vim.fn.executable("rg") ~= 1 then
    return
  end
  vim.ui.input({ prompt = "Search in Java files (literal): " }, function(search)
    if not search or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local paths = vim.fn.systemlist(vim.list_extend({ "rg", "-F", "-l" }, vim.list_extend(GLOB_ARGS, { "--", search, "." })))
      replace_in_paths(paths, search, repl, " (Java project files)")
    end)
  end)
end

function M.replace_in_project_all()
  if vim.fn.executable("rg") ~= 1 then
    return
  end
  vim.ui.input({ prompt = "Search in project (literal, all files): " }, function(search)
    if not search or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local paths = vim.fn.systemlist({ "rg", "-F", "-l", "--", search, "." })
      replace_in_paths(paths, search, repl, " (all matching files)")
    end)
  end)
end

return M
