local M = {}

local rust_test = require("config.rust_test")

local function rust_analyzer_cmd()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer"
  if vim.fn.executable(mason_bin) == 1 then
    return { mason_bin }
  end

  if vim.fn.executable("rust-analyzer") == 1 then
    return { "rust-analyzer" }
  end

  return nil
end

function M.rust_analyzer_cmd()
  return rust_analyzer_cmd()
end

function M.rust_analyzer_root_dir(path)
  if not path or path == "" then
    return rust_test.project_root()
  end

  local root = vim.fs.root(path, "Cargo.toml")
  if root then
    return root
  end

  local dir = vim.fs.dirname(path)
  while dir and dir ~= "/" do
    for _, child in ipairs(rust_test.child_cargo_roots(dir)) do
      if path:find(child, 1, true) == 1 then
        return child
      end
    end
    dir = vim.fs.dirname(dir)
  end

  return rust_test.project_root()
end

local function linked_projects_for(path)
  if not path or path == "" then
    return nil
  end

  local dir = vim.fs.dirname(path)
  while dir and dir ~= "/" do
    local children = rust_test.child_cargo_roots(dir)
    if #children > 1 then
      local projects = {}
      for _, child in ipairs(children) do
        projects[#projects + 1] = child .. "/Cargo.toml"
      end
      return projects
    end

    if vim.uv.fs_stat(dir .. "/Cargo.toml") then
      return nil
    end

    dir = vim.fs.dirname(dir)
  end

  return nil
end

function M.rust_analyzer_settings(path, rust_can_execute)
  local settings = {
    cargo = { allFeatures = true },
    checkOnSave = rust_can_execute,
    check = { command = "clippy" },
    procMacro = { enable = rust_can_execute },
    completion = {
      callable = { snippets = "fill_arguments" },
    },
    diagnostics = {
      enable = true,
    },
    inlayHints = {
      bindingModeHints = { enable = true },
      closureReturnTypeHints = { enable = "always" },
      lifetimeElisionHints = { enable = "skip_trivial" },
      reborrowHints = { enable = "always" },
    },
    imports = {
      granularity = { group = "module" },
      prefix = "self",
    },
    assist = {
      importEnforceGranularity = true,
      importPrefix = "self",
    },
  }

  local linked = linked_projects_for(path)
  if linked then
    settings.linkedProjects = linked
  end

  return settings
end

function M.on_attach(client, bufnr)
  local navic = require("nvim-navic")

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  local map_opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", map_opts, { desc = "Signature help" }))
end

function M.setup_handlers()
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 90,
  })
end

function M.setup_autocmds()
  local warned_missing_cmd = false
  local warned_missing_client = {}

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then
        return
      end

      M.on_attach(client, args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
    callback = function(args)
      local bufnr = args.buf
      if vim.bo[bufnr].filetype ~= "rust" then
        return
      end

      if not rust_analyzer_cmd() and not warned_missing_cmd then
        warned_missing_cmd = true
        vim.notify(
          "rust-analyzer not found. Install with :Mason or `rustup component add rust-analyzer`.",
          vim.log.levels.ERROR
        )
        return
      end

      if #vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" }) > 0 then
        warned_missing_client[bufnr] = nil
        return
      end

      if warned_missing_client[bufnr] then
        return
      end

      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "rust" then
          return
        end

        if #vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" }) > 0 then
          return
        end

        warned_missing_client[bufnr] = true
        local path = vim.api.nvim_buf_get_name(bufnr)
        local root = M.rust_analyzer_root_dir(path)
        local hint = root
          and ("Expected root: " .. root .. ". Run :LspInfo and :checkhealth vim.lsp.")
          or "Open a file inside a Cargo project (or parent folder with child crates)."
        vim.notify("rust-analyzer did not attach. " .. hint, vim.log.levels.WARN)
      end, 2000)
    end,
  })
end

function M.lsp_action(fn, label)
  return function(...)
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
      vim.notify(
        label .. " needs an attached LSP. Open a Rust file in a Cargo project and run :LspInfo.",
        vim.log.levels.WARN
      )
      return
    end

    fn(...)
  end
end

return M
