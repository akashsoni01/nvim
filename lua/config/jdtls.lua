-- nvim-jdtls: LSP + java-debug-adapter + java-test bundles (from Mason) for DAP.
local M = {}

function M.get_bundles()
  local ok, reg = pcall(require, "mason-registry")
  if not ok then
    return {}
  end
  local bundles = {}
  local function safe_pkg(name)
    local p_ok, p = pcall(function()
      return reg.get_package(name)
    end)
    if not p_ok or not p or not p:is_installed() then
      return nil
    end
    return p
  end
  local dbg = safe_pkg("java-debug-adapter")
  if dbg then
    for _, p in ipairs(vim.fn.glob(dbg:get_install_path() .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1, 1) or {}) do
      if p and p ~= "" and vim.fn.filereadable(p) == 1 then
        table.insert(bundles, p)
      end
    end
  end
  local test = safe_pkg("java-test")
  if test then
    local pattern = test:get_install_path() .. "/extension/server/*.jar"
    for _, path in ipairs(vim.fn.glob(pattern, 1, 1) or {}) do
      if path and path ~= "" and vim.fn.filereadable(path) == 1 then
        local fname = vim.fn.fnamemodify(path, ":t")
        if
          fname ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and fname ~= "jacocoagent.jar"
        then
          table.insert(bundles, path)
        end
      end
    end
  end
  return bundles
end

function M.find_root()
  return vim.fs.root(0, {
    "mvnw",
    "gradlew",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  }) or vim.fn.getcwd()
end

function M.start_or_attach()
  local jdtls = require("jdtls")
  local root = M.find_root()
  local project = vim.fn.fnamemodify(root, ":p:h:t")
  if project == "" or project == "." then
    project = "jdtls-project"
  end
  local safe = project:gsub("[^%w%-_]+", "_")
  local workspace = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. safe
  vim.fn.mkdir(workspace, "p")

  local mason_jdtls = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
  local cmd
  if vim.fn.executable(mason_jdtls) == 1 then
    cmd = { mason_jdtls, "-data", workspace }
  elseif vim.fn.executable("jdtls") == 1 then
    cmd = { "jdtls", "-data", workspace }
  else
    vim.notify("jdtls not found. Install the Mason package 'jdtls' (:Mason) and restart Neovim.", vim.log.levels.ERROR)
    return
  end

  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local navic = require("nvim-navic")
  local bundles = M.get_bundles()

  local on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
      pcall(navic.attach, client, bufnr)
    end
    if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature help" })

    if client.name == "jdtls" or client.name == "jdt.ls" then
      pcall(function()
        jdtls.setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
      end)
    end
  end

  jdtls.start_or_attach({
    cmd = cmd,
    root_dir = root,
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      java = {
        configuration = { updateBuildConfiguration = "interactive" },
        inlayHints = { parameterNames = { enabled = "all" } },
        format = { enabled = true },
      },
    },
    init_options = { bundles = bundles },
  })
end

return M
