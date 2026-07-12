local M = {}

local function env_enabled(name)
  local value = vim.env[name]
  if not value then
    return false
  end

  value = tostring(value):lower()
  return value == "1" or value == "true" or value == "yes" or value == "on"
end

M.force_mode = env_enabled("NVIM_VIM_FORCE")
M.corporate_mode = env_enabled("NVIM_CORPORATE_MODE")
M.trusted_rust_project = env_enabled("NVIM_TRUST_RUST_PROJECT")
M.light_mode = env_enabled("NVIM_LIGHT")
M.link_all_crates = env_enabled("NVIM_RA_LINK_ALL")

function M.allow_system_clipboard()
  return M.force_mode
end

function M.allow_external_completion()
  return M.force_mode
end

function M.allow_plugin_downloads()
  return M.force_mode and not M.corporate_mode
end

function M.rust_can_execute_project_code()
  if not M.force_mode then
    return false
  end
  return not M.corporate_mode or M.trusted_rust_project
end

function M.notify_restricted(feature, level)
  if not M.force_mode then
    vim.notify(
      feature .. " requires NVIM_VIM_FORCE=1 (disabled for enterprise-safe default).",
      level or vim.log.levels.INFO
    )
  end
end

function M.notify_corporate(message, level)
  if M.corporate_mode then
    vim.notify("Corporate mode: " .. message, level or vim.log.levels.INFO)
  end
end

return M
