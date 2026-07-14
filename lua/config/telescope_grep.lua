local M = {}

local uv = vim.uv or vim.loop

local rg_sort_supported

local function system(cmd, opts)
  opts = opts or {}
  if vim.system then
    return vim.system(cmd, opts):wait()
  end

  local job_opts = {
    cwd = opts.cwd,
    stdout_buffered = true,
    stderr_buffered = true,
  }
  local stdout, stderr = {}, {}
  job_opts.on_stdout = function(_, data)
    if data then
      vim.list_extend(stdout, data)
    end
  end
  job_opts.on_stderr = function(_, data)
    if data then
      vim.list_extend(stderr, data)
    end
  end

  local job = vim.fn.jobstart(cmd, job_opts)
  if job <= 0 then
    return { code = 1, stdout = "", stderr = "jobstart failed" }
  end

  vim.fn.jobwait({ job })
  return {
    code = vim.fn.jobresult(job),
    stdout = table.concat(stdout, "\n"),
    stderr = table.concat(stderr, "\n"),
  }
end

local function termux_prefix()
  if vim.env.TERMUX_VERSION or uv.fs_stat("/data/data/com.termux/files/usr") then
    return vim.env.PREFIX or "/data/data/com.termux/files/usr"
  end
  return nil
end

local function rg_binary()
  if vim.fn.executable("rg") == 1 then
    return "rg"
  end

  local candidates = {
    "/opt/homebrew/bin/rg",
    "/usr/local/bin/rg",
    vim.fn.stdpath("data") .. "/mason/bin/rg",
  }

  local prefix = termux_prefix()
  if prefix then
    table.insert(candidates, 1, prefix .. "/bin/rg")
  end

  for _, candidate in ipairs(candidates) do
    if candidate ~= "" and vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return nil
end

local function rg_supports_sort_path()
  if rg_sort_supported ~= nil then
    return rg_sort_supported
  end

  local rg = rg_binary()
  if not rg then
    rg_sort_supported = false
    return false
  end

  local result = system({ rg, "--sort", "path", "--no-ignore-dot", "--files", "." }, {
    cwd = M.project_cwd(),
    text = true,
  })
  rg_sort_supported = result.code == 0
  return rg_sort_supported
end

local function bootstrap_telescope_setup()
  local setup_opts = {
    defaults = vim.tbl_extend("force", M.list_picker_opts(), {
      sorting_strategy = "ascending",
    }),
  }

  local vimgrep = M.vimgrep_arguments()
  if vimgrep then
    setup_opts.defaults.vimgrep_arguments = vimgrep
  end

  local find_command = M.find_command()
  if find_command then
    setup_opts.defaults.find_command = find_command
  end

  require("telescope").setup(setup_opts)
end

local function telescope_ready()
  local ok_cfg, cfg = pcall(function()
    return require("telescope.config").values
  end)
  return ok_cfg and cfg and cfg.layout_strategy ~= nil
end

local function ensure_telescope()
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then
    pcall(lazy.load, { plugins = { "plenary.nvim", "telescope.nvim" } })
  end

  local ok_builtin, builtin = pcall(require, "telescope.builtin")
  if not ok_builtin then
    return nil, "Telescope failed to load: " .. tostring(builtin)
  end

  local ok_pickers = pcall(require, "telescope.pickers")
  if not ok_pickers then
    return nil, "Telescope pickers missing. Run scripts/vendor-plugins.sh"
  end

  if not telescope_ready() then
    local ok_setup, err = pcall(bootstrap_telescope_setup)
    if not ok_setup then
      return nil, "telescope.setup() failed: " .. tostring(err)
    end
    if not telescope_ready() then
      return nil, "telescope.setup() did not initialize (layout_strategy missing)"
    end
  end

  return builtin
end

function M.builtin()
  local builtin, err = ensure_telescope()
  if not builtin then
    error(err or "Telescope unavailable", 0)
  end
  return builtin
end

function M.list_picker_opts(extra)
  return vim.tbl_extend("force", {
    path_display = { "filename", "tail" },
    previewer = false,
    layout_strategy = "center",
    layout_config = {
      height = 0.9,
      width = 0.92,
      anchor = "N",
      prompt_position = "top",
    },
  }, extra or {})
end

function M.buffer_picker_opts(extra)
  return M.list_picker_opts(vim.tbl_extend("force", {
    bufnr = 0,
    prompt_title = "Search current buffer",
    path_display = { "filename" },
    sorting_strategy = "ascending",
  }, extra or {}))
end

function M.find_files_picker_opts(extra)
  return M.list_picker_opts(vim.tbl_extend("force", {
    prompt_title = "Find files",
    hidden = true,
    file_ignore_patterns = {},
    sorting_strategy = "ascending",
  }, extra or {}))
end

local function buffer_has_searchable_text(bufnr)
  bufnr = bufnr or 0
  local bt = vim.bo[bufnr].buftype
  if bt ~= "" then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then
    return false
  end
  if #lines == 1 and (lines[1] == nil or lines[1] == "") then
    return false
  end

  return true
end

function M.fallback_buffer_search()
  local query = vim.fn.input("Search in buffer: ")
  if query == nil or query == "" then
    return false
  end

  local ok, pos = pcall(vim.fn.search, query, "n")
  if not ok or pos == 0 then
    vim.notify("No match for: " .. query, vim.log.levels.WARN)
    return false
  end

  vim.cmd("normal! zz")
  return true
end

function M.current_buffer_fuzzy_find(extra)
  if not buffer_has_searchable_text(0) then
    vim.notify(
      "No file open — use <leader>ff to find files in the project.",
      vim.log.levels.INFO
    )
    return M.find_files(vim.tbl_extend("force", { prompt_title = "Find files" }, extra or {}))
  end

  local builtin, err = ensure_telescope()
  if not builtin then
    vim.notify(err .. " Falling back to / search.", vim.log.levels.WARN)
    return M.fallback_buffer_search()
  end

  local ok, picker_err = pcall(builtin.current_buffer_fuzzy_find, M.buffer_picker_opts(extra))
  if not ok then
    vim.notify("Buffer search failed: " .. tostring(picker_err), vim.log.levels.ERROR)
    return M.fallback_buffer_search()
  end

  return true
end

function M.find_files(extra)
  local builtin, err = ensure_telescope()
  if not builtin then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  local opts = M.find_files_picker_opts(vim.tbl_extend("force", {
    cwd = M.project_cwd(),
  }, extra or {}))

  local find_command = M.find_command()
  if find_command then
    opts.find_command = find_command
  end

  local ok, picker_err = pcall(builtin.find_files, opts)
  if not ok then
    vim.notify("Find files failed: " .. tostring(picker_err), vim.log.levels.ERROR)
    return false
  end

  return true
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

  local args = {
    rg,
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
    "--no-ignore-dot",
  }

  if rg_supports_sort_path() then
    table.insert(args, "--sort")
    table.insert(args, "path")
  end

  return args
end

--- Grep/live_grep UI: filename in results, no preview pane.
function M.grep_picker_opts()
  return M.list_picker_opts({
    sorting_strategy = "ascending",
    layout_config = {
      height = 0.9,
      width = 0.92,
      anchor = "N",
      prompt_position = "top",
    },
  })
end

--- Keep live_grep / grep_string results in ripgrep path order (stable across runs).
function M.stable_grep_picker_opts()
  return vim.tbl_extend("force", M.grep_picker_opts(), {
    sorting_strategy = "ascending",
    tiebreak = function(_, _, _)
      return false
    end,
  })
end

function M.project_cwd()
  local cwd = uv.cwd()
  local git_root = vim.fs.root(cwd, ".git")
  if git_root then
    return git_root
  end

  local cargo_root = vim.fs.root(cwd, "Cargo.toml")
  if cargo_root then
    return cargo_root
  end

  -- Parent folder opened with `nvim .` (e.g. testing/ with child crates in files/)
  local ok, rust_test = pcall(require, "config.rust_test")
  if ok and #rust_test.child_cargo_roots(cwd) > 0 then
    return cwd
  end

  return cwd
end

--- Ripgrep --files command for Telescope find_files (skips IDE .ignore blockers).
function M.find_command()
  local rg = rg_binary()
  if not rg then
    return nil
  end
  return { rg, "--files", "--color", "never", "--no-ignore-dot", "." }
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

  return vim.tbl_extend("force", M.stable_grep_picker_opts(), {
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

  local builtin, err = ensure_telescope()
  if not builtin then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  local ok, picker_err = pcall(builtin.live_grep, opts)
  if not ok then
    vim.notify("Live grep failed: " .. tostring(picker_err), vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.grep_word(word, opts)
  opts = opts or {}

  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    local saved_reg = vim.fn.getreg("v")
    vim.cmd([[noautocmd sil norm! "vy]])
    word = vim.fn.getreg("v")
    vim.fn.setreg("v", saved_reg)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  else
    word = word or vim.fn.expand("<cword>")
  end

  word = (word or ""):gsub("^%s+", ""):gsub("%s+$", "")
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
  local builtin, err = ensure_telescope()
  if not builtin then
    vim.notify(err, vim.log.levels.ERROR)
    return false
  end

  local sorters = require("telescope.sorters")
  local ok, picker_err = pcall(builtin.grep_string, vim.tbl_extend("force", M.stable_grep_picker_opts(), {
    cwd = M.project_cwd(),
    search = word,
    prompt_title = "Grep: " .. word,
    vimgrep_arguments = M.vimgrep_arguments(),
    sorter = sorters.get_substr_matcher(),
    additional_args = function()
      return M.fast_grep_args()
    end,
  }, opts))

  if not ok then
    vim.notify("Grep word failed: " .. tostring(picker_err), vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.buffer_search_self_test()
  local builtin, err = ensure_telescope()
  if not builtin then
    return false, err
  end

  if type(builtin.current_buffer_fuzzy_find) ~= "function" then
    return false, "telescope.builtin.current_buffer_fuzzy_find missing"
  end

  if not telescope_ready() then
    return false, "telescope.setup() not run (layout_strategy missing)"
  end

  return true, "buffer search ok"
end

--- Non-interactive self-test for CI / :GrepSelfTest
function M.self_test()
  local ok_buf, msg_buf = M.buffer_search_self_test()
  if not ok_buf then
    return false, msg_buf
  end

  local rg = rg_binary()
  if not rg then
    return false, "rg not found (pkg install ripgrep on Termux)"
  end

  local result, probe, match_count
  for _, word in ipairs({ "telescope", "fn", "def", "import", "return", "the" }) do
    local args = vim.list_extend(M.vimgrep_arguments(), vim.list_extend(M.fast_grep_args(), { "--", word, "." }))
    local attempt = system(args, { cwd = M.project_cwd(), text = true })
    if attempt.code == 0 then
      local lines = vim.split(attempt.stdout or "", "\n", { plain = true })
      local n = 0
      for _, line in ipairs(lines) do
        if line ~= "" then
          n = n + 1
        end
      end
      if n > 0 then
        result = attempt
        probe = word
        match_count = n
        break
      end
    end
  end

  if not result then
    return false, "rg returned no matches for probe queries in " .. M.project_cwd()
  end

  if rg_supports_sort_path() then
    local args = vim.list_extend(M.vimgrep_arguments(), vim.list_extend(M.fast_grep_args(), { "--", probe, "." }))
    local result2 = system(args, { cwd = M.project_cwd(), text = true })
    if result2.code ~= 0 then
      return false, "rg stability check failed"
    end
    if result.stdout ~= result2.stdout then
      return false, "rg output order not stable (add --sort path)"
    end
  end

  local builtin, err = ensure_telescope()
  if not builtin then
    return false, err
  end

  if type(builtin.live_grep) ~= "function" then
    return false, "telescope.builtin.live_grep missing"
  end

  local sort_note = rg_supports_sort_path() and "sorted" or "unsorted-rg"
  return true, string.format("ok (buffer+grep, %d matches, probe=%s, rg=%s, %s)", match_count, probe, rg, sort_note)
end

return M
