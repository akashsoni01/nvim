return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "swift", "json", "markdown", "yaml" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      -- Support both old and new nvim-treesitter module layouts.
      local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
      if ok_configs then
        configs.setup(opts)
        return
      end
      require("nvim-treesitter").setup(opts)
    end,
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "SmiteshP/nvim-navic",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local navic = require("nvim-navic")

      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end

        if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature help" })
      end

      local util = require("lspconfig.util")

      local function sourcekit_cmd()
        if vim.fn.has("mac") == 1 and vim.fn.executable("xcrun") == 1 then
          return { "xcrun", "sourcekit-lsp" }
        end
        return { "sourcekit-lsp" }
      end

      local sourcekit_cfg = {
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = sourcekit_cmd(),
        filetypes = { "swift" },
        single_file_support = true,
        root_dir = function(fname)
          return util.root_pattern(
            "Package.swift",
            "buildServer.json",
            "compile_commands.json",
            "contents.xcworkspacedata",
            ".git",
            "*.xcodeproj",
            "*.xcworkspace"
          )(fname) or util.find_git_ancestor(fname) or vim.fn.fnamemodify(fname, ":h")
        end,
      }

      if vim.lsp.config and vim.lsp.enable then
        vim.lsp.config("sourcekit", sourcekit_cfg)
        vim.lsp.enable("sourcekit")
      else
        local lspconfig = require("lspconfig")
        lspconfig.sourcekit.setup(sourcekit_cfg)
      end
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local has_fd = vim.fn.executable("fd") == 1
      local has_fdfind = vim.fn.executable("fdfind") == 1
      local has_rg = vim.fn.executable("rg") == 1

      local find_command = { "find", ".", "-type", "f" }
      if has_fd then
        find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" }
      elseif has_fdfind then
        find_command = { "fdfind", "--type", "f", "--hidden", "--exclude", ".git" }
      elseif has_rg then
        find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" }
      end

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          prompt_prefix = "   ",
          selection_caret = " ",
        },
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
        },
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function lsp_name()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return "LSP:off"
        end
        return "LSP:" .. clients[1].name
      end

      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = "|",
          section_separators = "",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "filename" },
          lualine_c = { lsp_name },
          lualine_x = { "diagnostics" },
          lualine_y = { "filetype" },
          lualine_z = { "location", "progress" },
        },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        show_close_icon = false,
      },
    },
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local function is_executable_file(path)
        return path ~= nil
          and path ~= ""
          and vim.fn.isdirectory(path) == 0
          and vim.fn.filereadable(path) == 1
          and vim.fn.executable(path) == 1
      end

      local local_lldb_dap = vim.fn.stdpath("config") .. "/bin/lldb-dap"
      local candidates = {
        vim.fn.filereadable(local_lldb_dap) == 1 and local_lldb_dap or "",
        vim.fn.exepath("codelldb"),
        vim.fn.exepath("lldb-dap"),
        vim.fn.exepath("lldb-vscode"),
      }

      local lldb_exec = nil
      for _, path in ipairs(candidates) do
        if path ~= nil and path ~= "" then
          lldb_exec = path
          break
        end
      end

      local function spm_debug_default()
        local cwd = vim.fn.getcwd()
        local project_name = vim.fn.fnamemodify(cwd, ":t")
        return cwd .. "/.build/debug/" .. project_name
      end

      dap.configurations.swift = {
        {
          name = "Launch Swift (SPM debug)",
          type = "lldb",
          request = "launch",
          program = function()
            local selected = vim.fn.input("Path to executable: ", spm_debug_default(), "file")
            if selected == nil or selected == "" then
              return nil
            end
            local absolute = vim.fn.fnamemodify(selected, ":p")
            if vim.fn.isdirectory(absolute) == 1 then
              vim.notify("DAP: path is a directory, not a binary. Build with: swift build", vim.log.levels.ERROR)
              return nil
            end
            if not is_executable_file(absolute) then
              vim.notify("DAP: not executable. Build with: swift build", vim.log.levels.ERROR)
              return nil
            end
            return absolute
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
          args = {},
        },
      }

      if lldb_exec then
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_exec,
          name = "lldb",
        }
      else
        vim.notify("No LLDB adapter (codelldb / lldb-dap / lldb-vscode). Debugging disabled until installed.", vim.log.levels.WARN)
      end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "SmiteshP/nvim-navic",
    opts = {
      highlight = true,
      separator = " > ",
      depth_limit = 5,
    },
  },
  {
    "utilyre/barbecue.nvim",
    version = "*",
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight-moon")
      require("config.theme").apply("coral")
    end,
  },
}
