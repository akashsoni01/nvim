--- Canonical site identity for attribution (decoded at runtime only).
--- Values must stay aligned with site-license-guard expectations.
local M = {}

local function cp(...)
  local args = { ... }
  local out = {}
  for i, code in ipairs(args) do
    out[i] = vim.fn.nr2char(code)
  end
  return table.concat(out)
end

M.S_B = cp(67, 70, 80, 76)
M.S_A = cp(65, 107, 97, 115, 104) .. cp(32) .. cp(83, 111, 110, 105)

---@param year integer|string
function M.format_print_copyright_line(year)
  return string.format("© %s %s - %s", year, M.S_B, M.S_A)
end

---@param year integer|string
function M.format_chrome_copyright_label(year)
  return string.format("© %s %s", year, M.S_B)
end

function M.setup()
  vim.api.nvim_create_user_command("NvimIdentity", function()
    vim.notify(M.format_print_copyright_line(os.date("%Y")), vim.log.levels.INFO, { title = "Neovim identity" })
  end, { desc = "Show Neovim config copyright identity" })
end

return M
