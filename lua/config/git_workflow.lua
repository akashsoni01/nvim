local M = {}
local project = require("config.project")

local function git_toplevel(start_dir)
  local result = vim.system({ "git", "-C", start_dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  return vim.trim(result.stdout)
end

local function format_java_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "java" and vim.bo[bufnr].modifiable then
      vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end
  end
end

function M.save_fmt_stage()
  vim.cmd("silent! wa")

  local root = project.project_root()
  local has_java = vim.fn.filereadable(root .. "/pom.xml") == 1
    or (vim.fn.glob(root .. "/build.gradle*") or "") ~= ""
  if not has_java then
    vim.notify("No Maven/Gradle project found.", vim.log.levels.ERROR)
    return
  end

  format_java_buffers()
  vim.cmd("checktime")

  if vim.fn.executable("git") ~= 1 then
    vim.notify("git is not installed.", vim.log.levels.ERROR)
    return
  end

  local git_root = git_toplevel(root) or git_toplevel(vim.fn.getcwd())
  if not git_root then
    vim.notify("Not a git repository.", vim.log.levels.ERROR)
    return
  end

  local add = vim.system({ "git", "add", "." }, { cwd = git_root, text = true, stderr = true }):wait()
  if add.code ~= 0 then
    vim.notify((add.stderr or add.stdout or "git add failed"):gsub("%s+$", ""), vim.log.levels.ERROR)
    return
  end

  vim.notify("Saved, formatted Java buffers, git add . (" .. git_root .. ")", vim.log.levels.INFO)
end

return M
