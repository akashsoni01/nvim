local M = {}

local rust_test = require("config.rust_test")

local function git_toplevel(start_dir)
  local result = vim.system({ "git", "-C", start_dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  return vim.trim(result.stdout)
end

function M.save_fmt_stage()
  vim.cmd("silent! wa")

  if vim.fn.executable("cargo") ~= 1 then
    vim.notify("cargo is not installed or not on PATH.", vim.log.levels.ERROR)
    return
  end

  local roots = rust_test.project_roots()
  if #roots == 0 then
    vim.notify(
      "No Cargo.toml found. Open a Rust crate, workspace, or parent folder containing a Cargo child project.",
      vim.log.levels.ERROR
    )
    return
  end

  for _, root in ipairs(roots) do
    local fmt = vim.system({ "cargo", "fmt" }, { cwd = root, text = true, stderr = true }):wait()
    if fmt.code ~= 0 then
      local msg = (fmt.stderr or fmt.stdout or ""):gsub("%s+$", "")
      vim.notify("cargo fmt failed in " .. root .. (msg ~= "" and (":\n" .. msg) or ""), vim.log.levels.ERROR)
      return
    end
  end

  vim.cmd("checktime")

  if vim.fn.executable("git") ~= 1 then
    vim.notify("git is not installed or not on PATH.", vim.log.levels.ERROR)
    return
  end

  local git_root = git_toplevel(roots[1]) or git_toplevel(vim.fn.getcwd())
  if not git_root then
    vim.notify("Not a git repository.", vim.log.levels.ERROR)
    return
  end

  local add = vim.system({ "git", "add", "." }, { cwd = git_root, text = true, stderr = true }):wait()
  if add.code ~= 0 then
    local msg = (add.stderr or add.stdout or ""):gsub("%s+$", "")
    vim.notify("git add failed" .. (msg ~= "" and (":\n" .. msg) or ""), vim.log.levels.ERROR)
    return
  end

  local root_label = #roots == 1 and roots[1] or (#roots .. " crates")
  vim.notify("Saved, cargo fmt (" .. root_label .. "), git add . (" .. git_root .. ")", vim.log.levels.INFO)
end

return M
