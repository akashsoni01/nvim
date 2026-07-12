-- Java project roots (Maven / Gradle).
local M = {}

function M.project_root(start_dir)
  start_dir = start_dir or vim.fn.getcwd()
  return vim.fs.root(start_dir, {
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  }) or start_dir
end

function M.project_roots()
  return { M.project_root() }
end

function M.buf_is_project_file()
  local ft = vim.bo.filetype
  if ft == "java" then
    return true
  end
  local name = vim.fn.expand("%:t")
  return name == "pom.xml" or name:match("^build%.gradle") or name:match("^settings%.gradle")
end

return M
