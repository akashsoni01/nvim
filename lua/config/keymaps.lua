local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", vim.tbl_extend("force", opts, { desc = "Find files" }))
map("n", "<leader>fg", function()
  local builtin = require("telescope.builtin")
  if vim.fn.executable("rg") == 1 then
    builtin.live_grep()
  else
    vim.notify("ripgrep (rg) not found. Using current buffer fuzzy search.", vim.log.levels.WARN)
    builtin.current_buffer_fuzzy_find()
  end
end, vim.tbl_extend("force", opts, { desc = "Live grep" }))
map("n", "<leader>fc", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, vim.tbl_extend("force", opts, { desc = "Search current buffer" }))
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", vim.tbl_extend("force", opts, { desc = "Buffers" }))
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", vim.tbl_extend("force", opts, { desc = "Help tags" }))

vim.api.nvim_create_user_command("FF", function()
  require("telescope.builtin").find_files()
end, { desc = "Telescope find files" })

vim.api.nvim_create_user_command("FG", function()
  local builtin = require("telescope.builtin")
  if vim.fn.executable("rg") == 1 then
    builtin.live_grep()
  else
    vim.notify("ripgrep (rg) not found. Using current buffer fuzzy search.", vim.log.levels.WARN)
    builtin.current_buffer_fuzzy_find()
  end
end, { desc = "Telescope live grep" })

vim.api.nvim_create_user_command("FC", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Telescope search current buffer" })

map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
map("n", "<leader>fm", function()
  vim.lsp.buf.format({ async = true })
end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

local severity = vim.diagnostic.severity
local diagnostic_nav = require("config.diagnostic_nav")

local function jump_diagnostic(direction, min_severity, max_severity)
  local jump_opts = {
    count = direction * vim.v.count1,
    severity = { min = min_severity, max = max_severity or min_severity },
    wrap = true,
  }

  if vim.diagnostic.jump then
    vim.diagnostic.jump(jump_opts)
    return
  end

  local goto_opts = { wrap = true, severity = jump_opts.severity }
  for _ = 1, vim.v.count1 do
    if direction > 0 then
      vim.diagnostic.goto_next(goto_opts)
    else
      vim.diagnostic.goto_prev(goto_opts)
    end
  end
end

map("n", "<leader>len", function()
  jump_diagnostic(1, severity.ERROR, severity.ERROR)
end, vim.tbl_extend("force", opts, { desc = "Next compile error" }))
map("n", "<leader>lE", function()
  jump_diagnostic(-1, severity.ERROR, severity.ERROR)
end, vim.tbl_extend("force", opts, { desc = "Previous compile error" }))
map("n", "<leader>lwn", function()
  jump_diagnostic(1, severity.WARN, severity.WARN)
end, vim.tbl_extend("force", opts, { desc = "Next warning" }))
map("n", "<leader>lW", function()
  jump_diagnostic(-1, severity.WARN, severity.WARN)
end, vim.tbl_extend("force", opts, { desc = "Previous warning" }))

map("n", "<leader>lfe", function()
  diagnostic_nav.telescope_compile_issues("error")
end, vim.tbl_extend("force", opts, { desc = "List compile errors (Telescope)" }))
map("n", "<leader>lee", function()
  diagnostic_nav.telescope_lsp_issues("error")
end, vim.tbl_extend("force", opts, { desc = "List current LSP errors (Telescope)" }))
map("n", "<leader>lfE", function()
  diagnostic_nav.jump_file(-1, "error")
end, vim.tbl_extend("force", opts, { desc = "Previous error file" }))
map("n", "<leader>lfw", function()
  diagnostic_nav.telescope_compile_issues("warning")
end, vim.tbl_extend("force", opts, { desc = "List warnings (Telescope)" }))
map("n", "<leader>lww", function()
  diagnostic_nav.telescope_lsp_issues("warning")
end, vim.tbl_extend("force", opts, { desc = "List current LSP warnings (Telescope)" }))
map("n", "<leader>lfW", function()
  diagnostic_nav.jump_file(-1, "warning")
end, vim.tbl_extend("force", opts, { desc = "Previous warning file" }))

vim.api.nvim_create_user_command("CargoErrors", function()
  diagnostic_nav.telescope_compile_issues("error")
end, { desc = "Telescope: all cargo/LSP compile errors" })

vim.api.nvim_create_user_command("CargoWarnings", function()
  diagnostic_nav.telescope_compile_issues("warning")
end, { desc = "Telescope: all cargo/LSP warnings" })

vim.api.nvim_create_user_command("LspErrors", function()
  diagnostic_nav.telescope_lsp_issues("error")
end, { desc = "Telescope: current LSP errors without cargo check" })

vim.api.nvim_create_user_command("LspWarnings", function()
  diagnostic_nav.telescope_lsp_issues("warning")
end, { desc = "Telescope: current LSP warnings without cargo check" })

map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
map("n", "<leader>dc", function()
  require("dap").continue()
end, vim.tbl_extend("force", opts, { desc = "Debug continue" }))
map("n", "<leader>dn", function()
  require("dap").continue()
end, vim.tbl_extend("force", opts, { desc = "Debug next breakpoint" }))
map("n", "<leader>do", function()
  require("dap").step_over()
end, vim.tbl_extend("force", opts, { desc = "Debug step over" }))
map("n", "<leader>di", function()
  require("dap").step_into()
end, vim.tbl_extend("force", opts, { desc = "Debug step into" }))
map("n", "<leader>dO", function()
  require("dap").step_out()
end, vim.tbl_extend("force", opts, { desc = "Debug step out" }))
map("n", "<leader>dr", function()
  require("dap").repl.open()
end, vim.tbl_extend("force", opts, { desc = "Debug REPL open" }))
map("n", "<leader>du", function()
  require("dapui").toggle()
end, vim.tbl_extend("force", opts, { desc = "Debug UI toggle" }))
map("n", "<leader>de", function()
  require("dapui").eval()
end, vim.tbl_extend("force", opts, { desc = "Debug eval under cursor" }))
map("n", "<leader>dx", function()
  require("dap").terminate()
end, vim.tbl_extend("force", opts, { desc = "Debug terminate" }))

local rust_test = require("config.rust_test")

map("n", "<leader>tt", function()
  local test_name = vim.fn.expand("<cword>")
  local terminal_fallback = function()
    vim.cmd("split | terminal cargo test " .. vim.fn.shellescape(test_name))
  end

  rust_test.run_neotest(function()
    require("neotest").run.run()
  end, terminal_fallback)
end, vim.tbl_extend("force", opts, { desc = "Run test under cursor" }))
map("n", "<leader>ta", function()
  local terminal_fallback = function()
    vim.cmd("split | terminal cargo test")
  end

  rust_test.run_neotest(function()
    require("neotest").run.run(vim.fn.getcwd())
  end, terminal_fallback)
end, vim.tbl_extend("force", opts, { desc = "Run all tests" }))
map("n", "<leader>to", function()
  local ok, neotest = pcall(require, "neotest")
  if ok then
    neotest.output_panel.toggle()
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle test output panel" }))
map("n", "<leader>ts", function()
  local ok, neotest = pcall(require, "neotest")
  if ok then
    neotest.summary.toggle()
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle test summary" }))
map("n", "<leader>tc", "<cmd>split | terminal cargo clippy --all-targets --all-features<cr>", vim.tbl_extend("force", opts, { desc = "Run cargo clippy" }))
map("n", "<leader>tf", "<cmd>split | terminal cargo fmt<cr>", vim.tbl_extend("force", opts, { desc = "Run cargo fmt" }))
map("n", "<leader>tb", "<cmd>split | terminal cargo build<cr>", vim.tbl_extend("force", opts, { desc = "Run cargo build" }))
map("n", "<leader>tr", "<cmd>split | terminal cargo run<cr>", vim.tbl_extend("force", opts, { desc = "Run cargo run" }))

map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", vim.tbl_extend("force", opts, { desc = "Git status" }))
map("n", "<leader>gl", "<cmd>Telescope git_commits<cr>", vim.tbl_extend("force", opts, { desc = "Git log" }))
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", vim.tbl_extend("force", opts, { desc = "Git diff" }))
map("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", vim.tbl_extend("force", opts, { desc = "Git branches" }))
map("n", "<leader>gC", "<cmd>Telescope git_bcommits<cr>", vim.tbl_extend("force", opts, { desc = "Git buffer commits" }))

local function git_terminal(args)
  if vim.fn.executable("git") ~= 1 then
    vim.notify("git is not installed or not on PATH.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("split | terminal git " .. args)
end

local function git_checkout_branch(branch)
  if vim.fn.executable("git") ~= 1 then
    vim.notify("git is not installed or not on PATH.", vim.log.levels.ERROR)
    return
  end

  if branch and branch ~= "" then
    git_terminal("checkout " .. vim.fn.shellescape(branch))
    return
  end

  local lines = vim.fn.systemlist({
    "git",
    "for-each-ref",
    "--format=%(refname:short)",
    "refs/heads",
    "refs/remotes",
  })
  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR)
    return
  end

  local branches = {}
  for _, line in ipairs(lines) do
    if line ~= "" and not line:match("/HEAD$") then
      table.insert(branches, line)
    end
  end

  if #branches == 0 then
    vim.notify("No git branches found.", vim.log.levels.WARN)
    return
  end

  vim.ui.select(branches, { prompt = "Checkout branch:" }, function(choice)
    if choice then
      git_terminal("checkout " .. vim.fn.shellescape(choice))
    end
  end)
end

local function gitsigns_action(action)
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    vim.notify("gitsigns is not available for this buffer.", vim.log.levels.WARN)
    return
  end

  if action == "next_hunk" then
    if gitsigns.nav_hunk then
      gitsigns.nav_hunk("next")
    else
      gitsigns.next_hunk()
    end
    return
  end

  if action == "prev_hunk" then
    if gitsigns.nav_hunk then
      gitsigns.nav_hunk("prev")
    else
      gitsigns.prev_hunk()
    end
    return
  end

  gitsigns[action]()
end

map("n", "<leader>gf", function()
  git_terminal("fetch --all --prune")
end, vim.tbl_extend("force", opts, { desc = "Git fetch all" }))
map("n", "<leader>gpl", function()
  git_terminal("pull --ff-only")
end, vim.tbl_extend("force", opts, { desc = "Git pull fast-forward" }))
map("n", "<leader>gps", function()
  git_terminal("push")
end, vim.tbl_extend("force", opts, { desc = "Git push" }))
map("n", "<leader>gS", function()
  git_terminal("stash push -u")
end, vim.tbl_extend("force", opts, { desc = "Git stash include untracked" }))
map("n", "<leader>gL", function()
  git_terminal("stash list")
end, vim.tbl_extend("force", opts, { desc = "Git stash list" }))
map("n", "<leader>gA", function()
  git_terminal("stash apply")
end, vim.tbl_extend("force", opts, { desc = "Git stash apply latest" }))
map("n", "<leader>gco", function()
  git_checkout_branch()
end, vim.tbl_extend("force", opts, { desc = "Git checkout branch" }))
map("n", "<leader>ghn", function()
  gitsigns_action("next_hunk")
end, vim.tbl_extend("force", opts, { desc = "Git next hunk" }))
map("n", "<leader>ghN", function()
  gitsigns_action("prev_hunk")
end, vim.tbl_extend("force", opts, { desc = "Git previous hunk" }))
map("n", "<leader>ghp", function()
  gitsigns_action("preview_hunk")
end, vim.tbl_extend("force", opts, { desc = "Git preview hunk" }))
map("n", "<leader>ghs", function()
  gitsigns_action("stage_hunk")
end, vim.tbl_extend("force", opts, { desc = "Git stage hunk" }))
map("n", "<leader>ghr", function()
  gitsigns_action("reset_hunk")
end, vim.tbl_extend("force", opts, { desc = "Git reset hunk" }))
map("n", "<leader>ghb", function()
  gitsigns_action("blame_line")
end, vim.tbl_extend("force", opts, { desc = "Git blame line" }))
map("n", "<leader>ghd", function()
  gitsigns_action("toggle_deleted")
end, vim.tbl_extend("force", opts, { desc = "Git toggle deleted lines" }))

local function git_worktree(args)
  git_terminal("worktree " .. args)
end

local function git_worktree_switch()
  if vim.fn.executable("git") ~= 1 then
    vim.notify("git is not installed or not on PATH.", vim.log.levels.ERROR)
    return
  end

  local lines = vim.fn.systemlist({ "git", "worktree", "list", "--porcelain" })
  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR)
    return
  end

  local worktrees = {}
  local current = nil
  for _, line in ipairs(lines) do
    local path = line:match("^worktree (.+)$")
    if path then
      if current then
        table.insert(worktrees, current)
      end
      current = { path = path }
    elseif current then
      local branch = line:match("^branch refs/heads/(.+)$")
      if branch then
        current.branch = branch
      end
    end
  end
  if current then
    table.insert(worktrees, current)
  end

  if #worktrees == 0 then
    vim.notify("No git worktrees found.", vim.log.levels.WARN)
    return
  end

  vim.ui.select(worktrees, {
    prompt = "Switch to worktree:",
    format_item = function(item)
      if item.branch then
        return item.branch .. " - " .. item.path
      end
      return item.path
    end,
  }, function(choice)
    if not choice then
      return
    end

    vim.cmd("cd " .. vim.fn.fnameescape(choice.path))
    vim.notify("Switched worktree: " .. choice.path)
  end)
end

local function git_worktree_create()
  local path = vim.fn.input("Worktree path: ", "", "dir")
  if path == "" then
    return
  end

  local branch = vim.fn.input("Branch/commit (optional): ")
  local args = "add " .. vim.fn.shellescape(path)
  if branch ~= "" then
    args = args .. " " .. vim.fn.shellescape(branch)
  end

  git_worktree(args)
end

local function git_worktree_create_branch()
  local path = vim.fn.input("Worktree path: ", "", "dir")
  if path == "" then
    return
  end

  local branch = vim.fn.input("New branch name: ")
  if branch == "" then
    vim.notify("Worktree branch name is required.", vim.log.levels.WARN)
    return
  end

  local start_point = vim.fn.input("Start point (optional): ")
  local args = "add -b " .. vim.fn.shellescape(branch) .. " " .. vim.fn.shellescape(path)
  if start_point ~= "" then
    args = args .. " " .. vim.fn.shellescape(start_point)
  end

  git_worktree(args)
end

local function git_worktree_delete()
  local path = vim.fn.input("Delete worktree path: ", "", "dir")
  if path == "" then
    return
  end

  git_worktree("remove " .. vim.fn.shellescape(path))
end

map("n", "<leader>gwc", git_worktree_create, vim.tbl_extend("force", opts, { desc = "Git worktree create" }))
map("n", "<leader>gwa", git_worktree_create, vim.tbl_extend("force", opts, { desc = "Git worktree add" }))
map("n", "<leader>gwb", git_worktree_create_branch, vim.tbl_extend("force", opts, { desc = "Git worktree create branch" }))
map("n", "<leader>gwl", function()
  git_worktree("list")
end, vim.tbl_extend("force", opts, { desc = "Git worktree list" }))
map("n", "<leader>gws", git_worktree_switch, vim.tbl_extend("force", opts, { desc = "Git worktree switch" }))
map("n", "<leader>gwd", git_worktree_delete, vim.tbl_extend("force", opts, { desc = "Git worktree delete" }))
map("n", "<leader>gwr", git_worktree_delete, vim.tbl_extend("force", opts, { desc = "Git worktree remove" }))

vim.api.nvim_create_user_command("GitWorktreeSwitch", git_worktree_switch, { desc = "Switch Neovim cwd to a git worktree" })
vim.api.nvim_create_user_command("GitFetch", function()
  git_terminal("fetch --all --prune")
end, { desc = "Fetch all remotes and prune deleted refs" })
vim.api.nvim_create_user_command("GitPull", function()
  git_terminal("pull --ff-only")
end, { desc = "Pull current branch with fast-forward only" })
vim.api.nvim_create_user_command("GitPush", function()
  git_terminal("push")
end, { desc = "Push current branch" })
vim.api.nvim_create_user_command("GitCheckout", function(command)
  git_checkout_branch(command.args)
end, { nargs = "?", desc = "Checkout a git branch" })
vim.api.nvim_create_user_command("GitStash", function()
  git_terminal("stash push -u")
end, { desc = "Stash tracked and untracked changes" })
vim.api.nvim_create_user_command("GitStashList", function()
  git_terminal("stash list")
end, { desc = "List git stashes" })

map("n", "<leader>yf", "<cmd>%yank<cr>", vim.tbl_extend("force", opts, { desc = "Yank full file" }))
map("n", "<leader>pf", function()
  local clip = vim.fn.getreg("+")
  if clip == "" then
    vim.notify("System clipboard is empty.", vim.log.levels.WARN)
    return
  end

  local lines = vim.split(clip, "\n", { plain = true })
  if clip:sub(-1) == "\n" and lines[#lines] == "" then
    table.remove(lines)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("normal! gg")
end, vim.tbl_extend("force", opts, { desc = "Paste full file from clipboard" }))
map("n", "<leader>xf", function()
  vim.cmd("%yank +")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
  vim.cmd("normal! gg")
end, vim.tbl_extend("force", opts, { desc = "Cut full file to clipboard" }))
map({ "n", "v" }, "<leader>p", '"+p', vim.tbl_extend("force", opts, { desc = "Paste from clipboard" }))
map({ "n", "v" }, "<leader>P", '"+P', vim.tbl_extend("force", opts, { desc = "Paste from clipboard before cursor" }))

map("n", "<leader>sv", "<cmd>vsplit<cr>", vim.tbl_extend("force", opts, { desc = "Vertical split" }))
map("n", "<leader>sh", "<cmd>split<cr>", vim.tbl_extend("force", opts, { desc = "Horizontal split" }))
map("n", "<leader>se", "<C-w>=", vim.tbl_extend("force", opts, { desc = "Equalize splits" }))
map("n", "<leader>sx", "<cmd>close<cr>", vim.tbl_extend("force", opts, { desc = "Close split" }))
map("n", "<leader>qa", "<cmd>wqa<cr>", vim.tbl_extend("force", opts, { desc = "Save all and quit" }))
map("n", "<leader>qQ", "<cmd>qa!<cr>", vim.tbl_extend("force", opts, { desc = "Quit all without saving" }))
map("n", "<leader>th", "<cmd>split | terminal<cr>", vim.tbl_extend("force", opts, { desc = "Terminal horizontal" }))
map("n", "<leader>tv", "<cmd>vsplit | terminal<cr>", vim.tbl_extend("force", opts, { desc = "Terminal vertical" }))

map("n", "<leader>ub", function()
  require("config.theme").toggle()
end, vim.tbl_extend("force", opts, { desc = "Toggle Coral/Light theme" }))
map("n", "<leader>ut", function()
  require("config.theme").toggle_transparency()
end, vim.tbl_extend("force", opts, { desc = "Toggle transparency" }))
map("n", "<leader>uh", function()
  if vim.lsp.inlay_hint then
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))

-- Set buffer filetype (mis-detected or extensionless buffers): ft = "file type"
map("n", "<leader>ftm", function()
  vim.bo.filetype = "markdown"
end, vim.tbl_extend("force", opts, { desc = "Set filetype: Markdown" }))
map("n", "<leader>ftt", function()
  vim.bo.filetype = "toml"
end, vim.tbl_extend("force", opts, { desc = "Set filetype: TOML" }))
map("n", "<leader>fty", function()
  vim.bo.filetype = "yaml"
end, vim.tbl_extend("force", opts, { desc = "Set filetype: YAML" }))
map("n", "<leader>ftr", function()
  vim.bo.filetype = "rust"
end, vim.tbl_extend("force", opts, { desc = "Set filetype: Rust" }))

-- Find/replace (see lua/config/rust_toml_search.lua)
local rs_toml = require("config.rust_toml_search")
map("n", "<leader>sr", function()
  rs_toml.replace_in_buffer()
end, vim.tbl_extend("force", opts, { desc = "Find & replace in current buffer (any file)" }))
map("n", "<leader>sf", function()
  rs_toml.replace_in_file()
end, vim.tbl_extend("force", opts, { desc = "Find & replace in file (.rs, .toml only)" }))
map("n", "<leader>sg", function()
  rs_toml.find_in_project()
end, vim.tbl_extend("force", opts, { desc = "Grep in project: *.rs + *.toml" }))
map("n", "<leader>sR", function()
  rs_toml.replace_in_project()
end, vim.tbl_extend("force", opts, { desc = "Find & replace in all *.rs + *.toml (project)" }))
map("n", "<leader>fA", function()
  rs_toml.find_in_project_all()
end, vim.tbl_extend("force", opts, { desc = "Grep in project (all file types)" }))
map("n", "<leader>sA", function()
  rs_toml.replace_in_project_all()
end, vim.tbl_extend("force", opts, { desc = "Find & replace in all files in project" }))
