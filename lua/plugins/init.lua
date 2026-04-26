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
      ensure_installed = { "lua", "vim", "vimdoc", "java", "json", "markdown", "yaml", "xml" },
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
    opts = {
      ensure_installed = {
        "jdtls",
        "java-debug-adapter",
        "java-test",
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "jdtls" },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "SmiteshP/nvim-navic",
    },
    config = function()
      -- jdtls is started from ftplugin/java.lua via nvim-jdtls.
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
      -- jdtls registers the "java" adapter when java-debug-adapter is bundled in ftplugin.
      dap.configurations.java = dap.configurations.java or {}
      vim.list_extend(dap.configurations.java, {
        {
          type = "java",
          request = "attach",
          name = "Attach to remote (JDWP, port 5005)",
          hostName = "127.0.0.1",
          port = 5005,
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "mfussenegger/nvim-dap" },
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
    "rcasia/neotest-java",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "mfussenegger/nvim-dap",
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "rcasia/neotest-java",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-java")({ incremental_build = true }),
        },
      })
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
