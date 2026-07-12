local security = require("config.security")
local vendor_lazy = vim.fn.stdpath("config") .. "/vendor/lazy/lazy.nvim"
local data_lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local lazypath = vendor_lazy
if not vim.uv.fs_stat(lazypath) then
  if security.corporate_mode then
    vim.notify(
      "Corporate mode: vendored lazy.nvim is required. Run reviewed vendoring before starting Neovim.",
      vim.log.levels.ERROR
    )
    return
  end

  lazypath = data_lazy
  if not vim.uv.fs_stat(lazypath) then
    vim.notify(
      "lazy.nvim is missing. Run: scripts/vendor-plugins.sh (or connect internet once for bootstrap).",
      vim.log.levels.ERROR
    )
    return
  end
end

vim.opt.rtp:prepend(lazypath)

local function with_vendor_dirs(spec)
  if type(spec) == "string" and spec:find("/") then
    local plugin_name = spec:match("/([^/]+)$")
    local vendor_dir = vim.fn.stdpath("config") .. "/vendor/plugins/" .. plugin_name
    if vim.uv.fs_stat(vendor_dir) then
      return { dir = vendor_dir }
    end
    if security.corporate_mode then
      vim.notify("Corporate mode: missing vendored plugin " .. plugin_name, vim.log.levels.ERROR)
      return { name = plugin_name, dir = vendor_dir, enabled = false }
    end
    return spec
  end

  if type(spec) ~= "table" then
    return spec
  end

  local copied = vim.deepcopy(spec)
  local repo = copied[1]
  if type(repo) == "string" and repo:find("/") and not copied.dir then
    local plugin_name = repo:match("/([^/]+)$")
    local vendor_dir = vim.fn.stdpath("config") .. "/vendor/plugins/" .. plugin_name
    if vim.uv.fs_stat(vendor_dir) then
      copied.dir = vendor_dir
      copied[1] = nil
    elseif security.corporate_mode then
      vim.notify("Corporate mode: missing vendored plugin " .. plugin_name, vim.log.levels.ERROR)
      copied.name = copied.name or plugin_name
      copied.dir = vendor_dir
      copied[1] = nil
      copied.enabled = false
    end
  end

  if type(copied.dependencies) == "table" then
    local mapped = {}
    for _, dep in ipairs(copied.dependencies) do
      table.insert(mapped, with_vendor_dirs(dep))
    end
    copied.dependencies = mapped
  end

  return copied
end

local plugin_specs = require("plugins")
for i, spec in ipairs(plugin_specs) do
  plugin_specs[i] = with_vendor_dirs(spec)
end

require("lazy").setup(plugin_specs, {
  change_detection = { notify = false },
  checker = { enabled = false },
  install = { colorscheme = { "habamax" }, missing = security.allow_plugin_downloads() },
  rocks = { enabled = security.allow_plugin_downloads() },
  ui = {
    border = "rounded",
    backdrop = 100,
  },
})
