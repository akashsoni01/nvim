local security = require("config.security")

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
      ensure_installed = { "lua", "vim", "vimdoc", "rust", "toml", "json", "markdown", "yaml" },
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
    lazy = false,
    priority = 100,
    cmd = "Mason",
    opts = {},
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "rust_analyzer" },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "SmiteshP/nvim-navic",
    },
    config = function()
      local security = require("config.security")
      local lsp = require("config.lsp")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local rust_can_execute = security.rust_can_execute_project_code()
      local cmd = lsp.rust_analyzer_cmd()

      if not cmd then
        vim.notify(
          "rust-analyzer not found. Run :Mason to install it, or `rustup component add rust-analyzer`.",
          vim.log.levels.ERROR
        )
      end

      lsp.setup_handlers()
      lsp.setup_autocmds()
      lsp.setup_commands()

      local rust_analyzer_cfg = {
        cmd = cmd,
        capabilities = capabilities,
        on_attach = lsp.on_attach,
        root_markers = { "Cargo.toml", "rust-toolchain.toml", "rust-project.json" },
        root_dir = function(bufnr, on_dir)
          local path = vim.api.nvim_buf_get_name(bufnr)
          local root = lsp.rust_analyzer_root_dir(path)
          if root then
            on_dir(root)
          end
        end,
        settings = {
          ["rust-analyzer"] = lsp.rust_analyzer_settings(nil, rust_can_execute),
        },
      }

      if not security.force_mode then
        security.notify_restricted("rust-analyzer proc macros and check-on-save")
      elseif security.corporate_mode and not security.trusted_rust_project then
        security.notify_corporate("rust-analyzer proc macros and check-on-save are disabled until NVIM_TRUST_RUST_PROJECT=1")
      end

      if security.light_mode then
        vim.notify(
          "NVIM_LIGHT=1: low-memory rust-analyzer (single crate, no inlay hints). Use NVIM_RA_LINK_ALL=1 for cross-crate gd.",
          vim.log.levels.INFO
        )
      end

      if vim.lsp.config and vim.lsp.enable then
        vim.lsp.config("rust_analyzer", rust_analyzer_cfg)
        vim.lsp.enable("rust_analyzer")
      else
        -- Fallback for older Neovim versions (< 0.11).
        local lspconfig = require("lspconfig")
        rust_analyzer_cfg.settings = {
          ["rust-analyzer"] = lsp.rust_analyzer_settings(nil, rust_can_execute),
        }
        lspconfig.rust_analyzer.setup(rust_analyzer_cfg)
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
    dependencies = vim.tbl_extend(
      "keep",
      {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "L3MON4D3/LuaSnip",
      },
      security.allow_external_completion() and { "hrsh7th/cmp-path" } or {}
    ),
    config = function()
      local security = require("config.security")
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
      }
      if security.allow_external_completion() then
        table.insert(sources, { name = "crates" })
        table.insert(sources, { name = "path" })
      end

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
        sources = cmp.config.sources(sources),
      })
    end,
  },

  {
    "saecki/crates.nvim",
    enabled = security.allow_external_completion(),
    event = { "BufRead Cargo.toml" },
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = function()
      local security = require("config.security")
      return {
        popup = { border = "rounded" },
        completion = {
          cmp = { enabled = security.allow_external_completion() },
        },
      }
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    module = "telescope",
    keys = {
      {
        "<leader>ul",
        function()
          require("config.theme").pick()
        end,
        desc = "Select theme",
      },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
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
      local identity = require("config.identity")

      local function lsp_name()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return "LSP:off"
        end
        return "LSP:" .. clients[1].name
      end

      local function copyright_label()
        return identity.format_chrome_copyright_label(os.date("%Y"))
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
          lualine_z = { copyright_label, "location", "progress" },
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

      local function rust_binary_default()
        local cwd = vim.fn.getcwd()
        local project_name = vim.fn.fnamemodify(cwd, ":t")
        local candidates = {
          cwd .. "/target/debug/" .. project_name,
          cwd .. "/target/debug/" .. project_name:gsub("%-", "_"),
        }

        for _, candidate in ipairs(candidates) do
          if is_executable_file(candidate) then
            return candidate
          end
        end

        return cwd .. "/target/debug/" .. project_name
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

      dap.configurations.rust = {
        {
          name = "Launch Rust binary",
          type = "lldb",
          request = "launch",
          program = function()
            local selected = vim.fn.input("Path to executable: ", rust_binary_default(), "file")
            if selected == nil or selected == "" then
              return nil
            end

            local absolute = vim.fn.fnamemodify(selected, ":p")
            if vim.fn.isdirectory(absolute) == 1 then
              vim.notify("DAP launch cancelled: selected path is a directory, not a binary.", vim.log.levels.ERROR)
              return nil
            end

            if not is_executable_file(absolute) then
              vim.notify(
                "DAP launch cancelled: selected file is not executable. Build first with `cargo build`.",
                vim.log.levels.ERROR
              )
              return nil
            end

            return absolute
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
          args = {},
          initCommands = {
            "settings set target.process.thread.step-avoid-regexp ^(std::|core::|alloc::|tokio::|mio::|polling::|parking_lot::|hashbrown::|serde::|anyhow::|thiserror::)",
          },
        },
      }

      if lldb_exec then
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_exec,
          name = "lldb",
        }
      else
        vim.notify("No LLDB adapter found (codelldb/lldb-dap/lldb-vscode). Rust DAP disabled.", vim.log.levels.WARN)
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
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "rouge8/neotest-rust",
    },
    config = function()
      local neotest_rust_opts = {
        args = { "--no-capture" },
      }

      local ok_dap, dap = pcall(require, "dap")
      if ok_dap and dap.adapters and dap.adapters.lldb then
        neotest_rust_opts.dap_adapter = "lldb"
      end

      require("neotest").setup({
        adapters = {
          require("neotest-rust")(neotest_rust_opts),
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
      require("config.theme").apply_default()
    end,
  },
}
