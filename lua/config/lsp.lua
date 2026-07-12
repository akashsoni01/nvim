-- jdtls LSP navigation helpers (Java).
local M = {}

local ms = vim.lsp.protocol.Methods
local security = require("config.security")
local telescope_grep = require("config.telescope_grep")

local DEFINITION_TIMEOUT_MS = security.light_mode and 5000 or 12000
local ATTACH_WAIT_MS = security.light_mode and 1000 or 3000

M.jdtls_indexing = false

function M.jdtls_client(bufnr)
  bufnr = bufnr or 0
  for _, name in ipairs({ "jdtls", "jdt.ls" }) do
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = name })
    if clients[1] then
      return clients[1]
    end
  end
  return nil
end

function M.wait_for_jdtls(bufnr, timeout_ms)
  bufnr = bufnr or 0
  timeout_ms = timeout_ms or ATTACH_WAIT_MS
  local client = M.jdtls_client(bufnr)
  if client then
    return client
  end
  vim.wait(timeout_ms, function()
    return M.jdtls_client(bufnr) ~= nil
  end, 50)
  return M.jdtls_client(bufnr)
end

function M.lsp_action(fn, label)
  return function(...)
    if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
      vim.notify(label .. " needs jdtls. Open a Java file and run :LspInfo.", vim.log.levels.WARN)
      return
    end
    fn(...)
  end
end

local function jumpable_window(winid)
  if not winid or winid == 0 or vim.api.nvim_win_get_config(winid).relative ~= "" then
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
    vim.notify(
      M.jdtls_indexing and "Definition timed out — jdtls is still importing. Try :GrepWord."
        or "Definition timed out. Try :GrepWord or :LspRestart.",
      vim.log.levels.WARN
    )
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
  local client = M.wait_for_jdtls(bufnr)
  if not client then
    vim.notify("jdtls not attached. Open a Java file and run :LspInfo.", vim.log.levels.WARN)
    return
  end

  request_definition(client, bufnr, function(result, encoding)
    if not result or (vim.islist(result) and #result == 0) then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    local items = vim.lsp.util.locations_to_items(vim.islist(result) and result or { result }, encoding)
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
  local client = M.wait_for_jdtls(bufnr)
  if not client then
    return
  end

  request_definition(client, bufnr, function(result, encoding)
    if not result or (vim.islist(result) and #result == 0) then
      vim.notify("No definition found", vim.log.levels.WARN)
      return
    end
    local items = vim.lsp.util.locations_to_items(vim.islist(result) and result or { result }, encoding)
    if #items == 0 or #items > 1 then
      if #items > 1 then
        vim.fn.setloclist(0, {}, " ", { title = "LSP locations", items = items })
        vim.cmd.lopen()
      end
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

function M.setup_handlers()
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 90,
  })
end

function M.setup_autocmds()
  local progress_active = 0
  vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or (client.name ~= "jdtls" and client.name ~= "jdt.ls") then
        return
      end
      local value = args.data.params.value
      if value and value.kind == "begin" then
        progress_active = progress_active + 1
        M.jdtls_indexing = true
      elseif value and value.kind == "end" then
        progress_active = math.max(0, progress_active - 1)
        M.jdtls_indexing = progress_active > 0
      end
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
  vim.api.nvim_create_user_command("GrepWord", function()
    telescope_grep.grep_word()
  end, { desc = "Telescope grep word under cursor" })
  vim.api.nvim_create_user_command("LspIndexing", function()
    vim.notify("jdtls: " .. (M.jdtls_indexing and "indexing" or "idle"), vim.log.levels.INFO)
  end, { desc = "Show whether jdtls is still indexing" })
end

return M
