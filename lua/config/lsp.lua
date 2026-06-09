local M = {}

local rust_test = require("config.rust_test")

local function cmd_works(cmd)
  local result = vim.system(vim.list_extend(cmd, { "--version" }), { text = true }):wait()
  return result.code == 0
end

local function rust_analyzer_cmd()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer"
  if vim.fn.executable(mason_bin) == 1 and cmd_works({ mason_bin }) then
    return { mason_bin }
  end

  if vim.fn.executable("rust-analyzer") == 1 and cmd_works({ "rust-analyzer" }) then
    return { "rust-analyzer" }
  end

  return nil
end

function M.start_rust_analyzer(bufnr)
  bufnr = bufnr or 0
  local cmd = rust_analyzer_cmd()
  if not cmd then
    return false
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local root = M.rust_analyzer_root_dir(path)
  if not root then
    return false
  end

  local security = require("config.security")
  vim.lsp.start({
    name = "rust_analyzer",
    root_dir = root,
    cmd = cmd,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = M.on_attach,
    settings = {
      ["rust-analyzer"] = M.rust_analyzer_settings(path, security.rust_can_execute_project_code()),
    },
  })

  return true
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

local function sibling_cargo_projects(parent)
  local children = rust_test.child_cargo_roots(parent)
  if #children <= 1 then
    return nil
  end

  local projects = {}
  for _, child in ipairs(children) do
    projects[#projects + 1] = child .. "/Cargo.toml"
  end

  return projects
end

local function linked_projects_for(path)
  if not path or path == "" then
    path = vim.api.nvim_buf_get_name(0)
  end
  if path == "" then
    return sibling_cargo_projects(vim.fn.getcwd())
  end

  local root = M.rust_analyzer_root_dir(path)
  if not root then
    return nil
  end

  local parent = vim.fs.dirname(root)
  if parent and parent ~= "/" then
    local siblings = sibling_cargo_projects(parent)
    if siblings then
      return siblings
    end
  end

  return nil
end

function M.apply_rust_analyzer_settings(client, bufnr)
  if client.name ~= "rust_analyzer" then
    return
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local security = require("config.security")
  local settings = {
    ["rust-analyzer"] = M.rust_analyzer_settings(path, security.rust_can_execute_project_code()),
  }

  client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, settings)
  if client.notify then
    client.notify("workspace/didChangeConfiguration", { settings = settings })
  end
end

function M.rust_analyzer_settings(path, rust_can_execute)
  if not path or path == "" then
    path = vim.api.nvim_buf_get_name(0)
  end
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

  if client.name == "rust_analyzer" then
    M.apply_rust_analyzer_settings(client, bufnr)
  end

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

        if M.start_rust_analyzer(bufnr) then
          return
        end

        warned_missing_client[bufnr] = true
        local path = vim.api.nvim_buf_get_name(bufnr)
        local root = M.rust_analyzer_root_dir(path)
        local hint = root
          and ("Expected root: " .. root .. ". Run :Mason or `rustup component add rust-analyzer`, then :LspInfo.")
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

function M.jump_definition()
  vim.lsp.buf.definition({
    filter = function(client)
      return client.name == "rust_analyzer"
    end,
  })
end

function M.show_definition()
  vim.lsp.buf.definition({
    on_list = function(what)
      if not what.items or #what.items == 0 then
        vim.notify("No definition found", vim.log.levels.WARN)
        return
      end

      if #what.items > 1 then
        vim.fn.setloclist(0, {}, " ", what)
        vim.cmd.lopen()
        return
      end

      local item = what.items[1]
      local target_bufnr = vim.fn.bufadd(item.filename)
      vim.fn.bufload(target_bufnr)

      local encoding = "utf-8"
      if what.context and what.context.bufnr then
        local clients = vim.lsp.get_clients({ bufnr = what.context.bufnr })
        if clients[1] then
          encoding = clients[1].offset_encoding
        end
      end

      local location = {
        uri = vim.uri_from_bufnr(target_bufnr),
        range = {
          start = { line = item.lnum - 1, character = item.col - 1 },
          ["end"] = {
            line = (item.end_lnum or item.lnum) - 1,
            character = (item.end_col or item.col) - 1,
          },
        },
      }

      vim.lsp.util.show_document(location, encoding, {
        focus = false,
        border = "rounded",
        reuse_win = true,
      })
    end,
  })
end

function M.setup_commands()
  vim.api.nvim_create_user_command("JumpDefinition", function()
    M.lsp_action(M.jump_definition, "Jump to definition")()
  end, { desc = "Jump to symbol definition" })

  vim.api.nvim_create_user_command("ShowDefinition", function()
    M.show_definition()
  end, { desc = "Show symbol definition in a float" })
end

return M
