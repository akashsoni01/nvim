local M = {}

--- Ripgrep args that keep big workspaces fast (skip build artifacts).
function M.fast_grep_args()
  return {
    "--glob",
    "!target/**",
    "--glob",
    "!**/target/**",
    "--glob",
    "!.build/**",
    "--glob",
    "!**/.build/**",
    "--glob",
    "!DerivedData/**",
    "--glob",
    "!node_modules/**",
    "--glob",
    "!.git/**",
  }
end

function M.live_grep_opts(extra)
  extra = extra or {}
  local args = vim.list_extend(M.fast_grep_args(), extra.additional_args or {})
  return vim.tbl_extend("force", extra, { additional_args = args })
end

function M.live_grep(extra)
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) not found. Install rg for project search.", vim.log.levels.ERROR)
    return false
  end

  require("telescope.builtin").live_grep(M.live_grep_opts(extra))
  return true
end

function M.grep_word(word, opts)
  word = (word or vim.fn.expand("<cword>")):gsub("^%s+", ""):gsub("%s+$", "")
  if word == "" then
    vim.notify("No word under cursor to search.", vim.log.levels.WARN)
    return false
  end

  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) not found.", vim.log.levels.ERROR)
    return false
  end

  opts = opts or {}
  require("telescope.builtin").grep_string(
    vim.tbl_extend("force", {
      search = word,
      prompt_title = "Grep: " .. word,
      additional_args = M.fast_grep_args(),
    }, opts)
  )
  return true
end

return M
