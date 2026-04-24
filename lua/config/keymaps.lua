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

map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
map("n", "<leader>fm", function()
  vim.lsp.buf.format({ async = true })
end, vim.tbl_extend("force", opts, { desc = "Format buffer" }))

map("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
map("n", "<leader>dc", function()
  require("dap").continue()
end, vim.tbl_extend("force", opts, { desc = "Debug continue" }))
map("n", "<leader>do", function()
  require("dap").step_over()
end, vim.tbl_extend("force", opts, { desc = "Debug step over" }))
map("n", "<leader>di", function()
  require("dap").step_into()
end, vim.tbl_extend("force", opts, { desc = "Debug step into" }))

map("n", "<leader>tt", function()
  local ok, neotest = pcall(require, "neotest")
  if ok then
    neotest.run.run()
    return
  end
  local test_name = vim.fn.expand("<cword>")
  vim.cmd("split | terminal cargo test " .. test_name)
end, vim.tbl_extend("force", opts, { desc = "Run test under cursor" }))
map("n", "<leader>ta", function()
  local ok, neotest = pcall(require, "neotest")
  if ok then
    neotest.run.run(vim.fn.getcwd())
    return
  end
  vim.cmd("split | terminal cargo test")
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
map("n", "<leader>tr", "<cmd>split | terminal cargo run<cr>", vim.tbl_extend("force", opts, { desc = "Run cargo run" }))

map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", vim.tbl_extend("force", opts, { desc = "Git status" }))
map("n", "<leader>gl", "<cmd>Telescope git_commits<cr>", vim.tbl_extend("force", opts, { desc = "Git log" }))
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", vim.tbl_extend("force", opts, { desc = "Git diff" }))

map("n", "<leader>sv", "<cmd>vsplit<cr>", vim.tbl_extend("force", opts, { desc = "Vertical split" }))
map("n", "<leader>sh", "<cmd>split<cr>", vim.tbl_extend("force", opts, { desc = "Horizontal split" }))
map("n", "<leader>se", "<C-w>=", vim.tbl_extend("force", opts, { desc = "Equalize splits" }))
map("n", "<leader>sx", "<cmd>close<cr>", vim.tbl_extend("force", opts, { desc = "Close split" }))

map("n", "<leader>ub", function()
  require("config.theme").toggle()
end, vim.tbl_extend("force", opts, { desc = "Toggle Coral/B&W theme" }))
map("n", "<leader>ut", function()
  require("config.theme").toggle_transparency()
end, vim.tbl_extend("force", opts, { desc = "Toggle transparency" }))
map("n", "<leader>uh", function()
  if vim.lsp.inlay_hint then
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
