-- Swift project roots and helpers (SPM).
local M = {}

function M.project_root(start_dir)
  start_dir = start_dir or vim.fn.getcwd()
  return vim.fs.root(start_dir, { "Package.swift", ".git" }) or start_dir
end

function M.project_roots()
  return { M.project_root() }
end

function M.buf_is_project_file()
  local ft = vim.bo.filetype
  if ft == "swift" then
    return true
  end
  local ext = vim.fn.expand("%:e")
  return ext == "swift" or vim.fn.expand("%:t") == "Package.swift"
end

return M
