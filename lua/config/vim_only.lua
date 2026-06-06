local M = {}

local config_root = vim.fn.stdpath("config")

local function script_path(name)
  return config_root .. "/scripts/" .. name
end

local function has_workspace_manifest(path)
  local cargo = path .. "/Cargo.toml"
  if not vim.uv.fs_stat(cargo) then
    return false
  end

  local lines = vim.fn.readfile(cargo)
  for _, line in ipairs(lines) do
    if line:match("^%[workspace%]") then
      return true
    end
  end

  return false
end

function M.workspace_root(start_dir)
  local dir = vim.fs.normalize(start_dir or vim.fn.getcwd())
  local nearest_crate = nil

  while dir and dir ~= "" and dir ~= "/" do
    if vim.uv.fs_stat(dir .. "/Cargo.toml") then
      nearest_crate = dir
      if has_workspace_manifest(dir) then
        return dir
      end
    end
    dir = vim.fs.dirname(dir)
  end

  return nearest_crate or vim.fn.getcwd()
end

local function run_script(script_name, ...)
  local script = script_path(script_name)
  if vim.fn.filereadable(script) ~= 1 then
    vim.notify("Missing script: " .. script, vim.log.levels.ERROR)
    return false
  end

  local cmd = { "bash", script, ... }
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    local message = (result.stderr or result.stdout or "unknown error"):gsub("%s+$", "")
    vim.notify(message, vim.log.levels.ERROR)
    return false
  end

  local message = (result.stdout or ""):gsub("%s+$", "")
  if message ~= "" then
    vim.notify(message, vim.log.levels.INFO)
  end

  return true
end

function M.is_vim_only_project(dir)
  local root = M.workspace_root(dir)
  local script = script_path("vim-only-stash.sh")
  if vim.fn.filereadable(script) ~= 1 then
    return false
  end

  local result = vim.system({ "bash", script, "is-vim-only", root }, { text = true }):wait()
  return result.code == 0
end

function M.mark(dir)
  local root = M.workspace_root(dir)
  return run_script("mark-vim-only-project.sh", root)
end

function M.unmark(dir)
  local root = M.workspace_root(dir)
  return run_script("unmark-vim-only-project.sh", root)
end

function M.stash_ide_markers(dir)
  local root = M.workspace_root(dir)
  return run_script("vim-only-stash.sh", "stash", root)
end

function M.restore_ide_markers(dir)
  local root = M.workspace_root(dir)
  return run_script("vim-only-stash.sh", "restore", root)
end

local function parse_vim_only_env()
  local value = vim.fn.getenv("NVIM_VIM_ONLY")
  if value == vim.NIL or value == "" then
    return nil
  end

  local lower = value:lower()
  if value == "1" or lower == "true" or lower == "yes" then
    return true
  end
  if value == "0" or lower == "false" or lower == "no" then
    return false
  end

  return nil
end

function M.handle_startup_env()
  local vim_only = parse_vim_only_env()
  if vim_only == false then
    M.unmark()
    return
  end

  if not M.is_vim_only_project() then
    M.mark()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("VimOnlyMark", function()
    M.mark()
    M.stash_ide_markers()
  end, { desc = "Stop IDE indexing for the workspace root" })

  vim.api.nvim_create_user_command("VimOnlyReset", function()
    M.unmark()
  end, { desc = "Restore IDE indexing for the workspace root" })

  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      M.handle_startup_env()
      M.stash_ide_markers()
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      M.restore_ide_markers()
    end,
  })
end

return M
