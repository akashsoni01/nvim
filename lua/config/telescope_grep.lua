local M = {}

local function rg_binary()
  if vim.fn.executable("rg") == 1 then
    return "rg"
  end

  for _, candidate in ipairs({
    "/opt/homebrew/bin/rg",
    "/usr/local/bin/rg",
    vim.fn.stdpath("data") .. "/mason/bin/rg",
  }) do
    if candidate ~= "" and vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return nil
end

local function ensure_telescope()
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then
    pcall(lazy.load, { plugins = { "telescope.nvim" } })
  end
  return require("telescope.builtin")
end

--- Ripgrep args that keep big workspaces fast (skip build artifacts).
function M.fast_grep_args()
  return {
    "-g",
    "!target",
    "-g",
    "!.build",
    "-g",
    "!DerivedData",
    "-g",
    "!node_modules",
    "-g",
    "!.git",
  }
end

function M.vimgrep_arguments()
  local rg = rg_binary()
  if not rg then
    return nil
  end
  return {
    rg,
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
  }
end

function M.project_cwd()
  return vim.fs.root(vim.uv.cwd(), ".git") or vim.uv.cwd()
end

function M.live_grep_opts(extra)
  extra = extra or {}
  local rg = rg_binary()
  if not rg then
    return nil
  end

  local fast_args = M.fast_grep_args()
  local user_args = extra.additional_args
  if type(user_args) == "function" then
    user_args = user_args(extra)
  end
  user_args = user_args or {}

  local merged_args = vim.list_extend(vim.deepcopy(fast_args), user_args)

  return vim.tbl_extend("force", {
    cwd = M.project_cwd(),
    vimgrep_arguments = M.vimgrep_arguments(),
    additional_args = function()
      return merged_args
    end,
  }, extra)
end

function M.live_grep(extra)
  local rg = rg_binary()
  if not rg then
    vim.notify(
      "ripgrep (rg) not found. Install with: brew install ripgrep (macOS) or pkg install ripgrep (Termux).",
      vim.log.levels.ERROR
    )
    return false
  end

  local opts = M.live_grep_opts(extra)
  if not opts then
    return false
  end

  local builtin = ensure_telescope()
  builtin.live_grep(opts)
  return true
end

function M.grep_word(word, opts)
  word = (word or vim.fn.expand("<cword>")):gsub("^%s+", ""):gsub("%s+$", "")
  if word == "" then
    vim.notify("No word under cursor to search.", vim.log.levels.WARN)
    return false
  end

  local rg = rg_binary()
  if not rg then
    vim.notify("ripgrep (rg) not found.", vim.log.levels.ERROR)
    return false
  end

  opts = opts or {}
  local builtin = ensure_telescope()
  builtin.grep_string(
    vim.tbl_extend("force", {
      cwd = M.project_cwd(),
      search = word,
      prompt_title = "Grep: " .. word,
      vimgrep_arguments = M.vimgrep_arguments(),
      additional_args = function()
        return M.fast_grep_args()
      end,
    }, opts)
  )
  return true
end

--- Non-interactive self-test for CI / :GrepSelfTest
function M.self_test()
  local rg = rg_binary()
  if not rg then
    return false, "rg not found"
  end

  local args = vim.list_extend(M.vimgrep_arguments(), vim.list_extend(M.fast_grep_args(), { "--", "telescope", "." }))
  local result = vim.system(args, { cwd = M.project_cwd(), text = true }):wait()
  if result.code ~= 0 then
    return false, (result.stderr or result.stdout or "rg failed"):gsub("%s+$", "")
  end

  local lines = vim.split(result.stdout or "", "\n", { plain = true })
  if #lines == 0 or (lines[1] == "" and #lines == 1) then
    return false, "rg returned no matches for probe query 'telescope'"
  end

  local ok, builtin = pcall(ensure_telescope)
  if not ok then
    return false, "telescope not loadable: " .. tostring(builtin)
  end

  if type(builtin.live_grep) ~= "function" then
    return false, "telescope.builtin.live_grep missing"
  end

  return true, string.format("ok (%d matches, rg=%s)", #lines, rg)
end

return M
