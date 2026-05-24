local vendor_lazy = vim.fn.stdpath("config") .. "/vendor/lazy/lazy.nvim"
local data_lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local lazypath = vendor_lazy
if not vim.uv.fs_stat(lazypath) then
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
  install = { colorscheme = { "habamax" } },
  ui = {
    border = "rounded",
    backdrop = 100,
  },
})
