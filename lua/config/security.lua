local M = {}

local function env_enabled(name)
  local value = vim.env[name]
  if not value then
    return false
  end

  value = tostring(value):lower()
  return value == "1" or value == "true" or value == "yes" or value == "on"
end

M.corporate_mode = env_enabled("NVIM_CORPORATE_MODE")
M.trusted_rust_project = env_enabled("NVIM_TRUST_RUST_PROJECT")

function M.rust_can_execute_project_code()
  return not M.corporate_mode or M.trusted_rust_project
end

function M.notify_corporate(message, level)
  if M.corporate_mode then
    vim.notify("Corporate mode: " .. message, level or vim.log.levels.INFO)
  end
end

return M
