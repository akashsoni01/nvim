-- SourceKit LSP helpers (Swift).
local M = {}

local ms = vim.lsp.protocol.Methods
local security = require("config.security")
local telescope_grep = require("config.telescope_grep")
local project = require("config.project")

local DEFINITION_TIMEOUT_MS = security.light_mode and 5000 or 12000
local ATTACH_WAIT_MS = security.light_mode and 1000 or 3000

M.sourcekit_indexing = false

function M.sourcekit_cmd()
  if vim.fn.has("mac") == 1 and vim.fn.executable("xcrun") == 1 then
    return { "xcrun", "sourcekit-lsp" }
  end
  if vim.fn.executable("sourcekit-lsp") == 1 then
    return { "sourcekit-lsp" }
  end
  return nil
end

function M.sourcekit_root_dir(path)
  if not path or path == "" then
    return project.project_root()
  end
  return vim.fs.root(path, {
    "Package.swift",
    "buildServer.json",
    "compile_commands.json",
    "contents.xcworkspacedata",
    ".git",
  }) or project.project_root()
end

function M.on_attach(client, bufnr)
  local navic = require("nvim-navic")

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  if
    not security.light_mode
    and vim.lsp.inlay_hint
    and client.server_capabilities.inlayHintProvider
  then
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
  local progress_active = 0

  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name ~= "sourcekit" then
        return
      end
      local value = args.data.params.value
      if value and value.kind == "begin" then
        progress_active = progress_active + 1
        M.sourcekit_indexing = true
      elseif value and (value.kind == "end" or value.kind == "report") then
        if value.kind == "end" then
          progress_active = math.max(0, progress_active - 1)
        end
        M.sourcekit_indexing = progress_active > 0
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        M.on_attach(client, args.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
    callback = function(args)
      local bufnr = args.buf
      if vim.bo[bufnr].filetype ~= "swift" then
        return
      end

      if not M.sourcekit_cmd() and not warned_missing_cmd then
        warned_missing_cmd = true
        vim.notify(
          "sourcekit-lsp not found. Install Swift: bash ./scripts/install-swift.sh",
          vim.log.levels.ERROR
        )
        return
      end

      if M.sourcekit_client(bufnr) then
        warned_missing_client[bufnr] = nil
        return
      end

      if warned_missing_client[bufnr] then
        return
      end

      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "swift" then
          return
        end
        if M.sourcekit_client(bufnr) then
          return
        end
        warned_missing_client[bufnr] = true
        vim.notify(
          "sourcekit-lsp did not attach. Open a file inside a Package.swift project and run :LspInfo.",
          vim.log.levels.WARN
        )
      end, 3000)
    end,
  })
end

function M.lsp_action(fn, label)
  return function(...)
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
      vim.notify(label .. " needs an attached LSP. Open a Swift file and run :LspInfo.", vim.log.levels.WARN)
      return
    end
    fn(...)
  end
end

function M.sourcekit_client(bufnr)
  bufnr = bufnr or 0
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "sourcekit" })
  return clients[1]
end

function M.wait_for_sourcekit(bufnr, timeout_ms)
  bufnr = bufnr or 0
  timeout_ms = timeout_ms or ATTACH_WAIT_MS
  local client = M.sourcekit_client(bufnr)
  if client then
    return client
  end
  vim.wait(timeout_ms, function()
    return M.sourcekit_client(bufnr) ~= nil
  end, 50)
  return M.sourcekit_client(bufnr)
end

local function jumpable_window(winid)
  if not winid or winid == 0 then
    return false
  end
  if vim.api.nvim_win_get_config(winid).relative ~= "" then
    return false
  end
  return vim.bo[vim.api.nvim_win_get_buf(winid)].buftype == ""
end

local function jump_to_location_item(item, opts)
  opts = opts or {}
  local bufnr = item.bufnr or vim.fn.bufadd(item.filename)
  vim.bo[bufnr].buflisted = true
  local win = vim.api.nvim_get_current_win()
  if opts.reuse_win then
    for _, candidate in ipairs(vim.fn.win_findbuf(bufnr)) do
      if candidate ~= win and jumpable_window(candidate) then
        win = candidate
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_buf(win, bufnr)
  vim.api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
  vim._with({ win = win }, function()
    vim.cmd("normal! zv")
  end)
end

local function definition_timeout_message()
  if M.sourcekit_indexing then
    return "Definition timed out — SourceKit is still indexing. Try :GrepWord or wait and retry."
  end
  return "Definition timed out. Try :GrepWord, :LspRestart, or NVIM_LIGHT=1 nvim ."
end

local function request_definition(client, bufnr, on_result, on_timeout)
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  local finished = false
  local request_id

  local timer = vim.defer_fn(function()
    if finished then
      return
    end
    finished = true
    if request_id and client.cancel_request then
      pcall(client.cancel_request, client, request_id)
    end
    vim.notify(definition_timeout_message(), vim.log.levels.WARN)
    if on_timeout then
      on_timeout()
    end
  end, DEFINITION_TIMEOUT_MS)

  request_id = client:request(ms.textDocument_definition, params, function(err, result)
    if finished then
      return
    end
    finished = true
    pcall(vim.fn.timer_stop, timer)
    if err then
      local code = type(err) == "table" and err.code
      if code == -32802 or (type(err.message) == "string" and err.message:lower():find("cancel", 1, true)) then
        return
      end
      vim.notify(err.message or "Definition request failed", vim.log.levels.ERROR)
      return
    end
    on_result(result, client.offset_encoding)
  end, bufnr)
end

function M.jump_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local client = M.wait_for_sourcekit(bufnr)
  if not client then
    vim.notify("sourcekit-lsp not attached. Open a Swift file and run :LspInfo.", vim.log.levels.WARN)
    return
  end

  request_definition(client, bufnr, function(result, encoding)
    if not result or (vim.islist(result) and #result == 0) then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    local locations = vim.islist(result) and result or { result }
    local items = vim.lsp.util.locations_to_items(locations, encoding)
    if #items == 0 then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    if #items > 1 then
      vim.fn.setloclist(0, {}, " ", { title = "LSP locations", items = items })
      vim.cmd.lopen()
      return
    end
    jump_to_location_item(items[1], { reuse_win = false })
  end, function()
    telescope_grep.grep_word(nil, { prompt_title = "Definition fallback (grep word)" })
  end)
end

function M.show_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local client = M.wait_for_sourcekit(bufnr)
  if not client then
    vim.notify("sourcekit-lsp not attached.", vim.log.levels.WARN)
    return
  end

  request_definition(client, bufnr, function(result, encoding)
    if not result or (vim.islist(result) and #result == 0) then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    local locations = vim.islist(result) and result or { result }
    local items = vim.lsp.util.locations_to_items(locations, encoding)
    if #items == 0 then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    if #items > 1 then
      vim.fn.setloclist(0, {}, " ", { title = "LSP locations", items = items })
      vim.cmd.lopen()
      return
    end
    local item = items[1]
    local target_bufnr = item.bufnr or vim.fn.bufadd(item.filename)
    vim.lsp.util.preview_location({
      uri = vim.uri_from_bufnr(target_bufnr),
      range = {
        start = { line = item.lnum - 1, character = item.col - 1 },
        ["end"] = {
          line = (item.end_lnum or item.lnum) - 1,
          character = (item.end_col or item.col) - 1,
        },
      },
    }, { border = "rounded", focusable = true })
  end)
end

function M.setup_commands()
  vim.api.nvim_create_user_command("JumpDefinition", function()
    M.lsp_action(M.jump_definition, "Jump to definition")()
  end, { desc = "Jump to symbol definition" })

  vim.api.nvim_create_user_command("ShowDefinition", function()
    M.show_definition()
  end, { desc = "Show symbol definition in a float" })

  vim.api.nvim_create_user_command("GrepWord", function()
    telescope_grep.grep_word()
  end, { desc = "Telescope grep word under cursor" })

  vim.api.nvim_create_user_command("LspIndexing", function()
    local state = M.sourcekit_indexing and "indexing" or "idle"
    vim.notify("sourcekit-lsp: " .. state, vim.log.levels.INFO)
  end, { desc = "Show whether SourceKit is still indexing" })
end

return M
