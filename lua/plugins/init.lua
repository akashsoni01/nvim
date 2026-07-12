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
      ensure_installed = { "lua", "vim", "vimdoc", "swift", "json", "markdown", "yaml" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
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
    opts = {},
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
      local lsp = require("config.lsp")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local cmd = lsp.sourcekit_cmd()

      if not cmd then
        vim.notify(
          "sourcekit-lsp not found. Install Swift: bash ./scripts/install-swift.sh",
          vim.log.levels.ERROR
        )
      end

      lsp.setup_handlers()
      lsp.setup_autocmds()
      lsp.setup_commands()

      local util = require("lspconfig.util")
      local sourcekit_cfg = {
        capabilities = capabilities,
        on_attach = lsp.on_attach,
        cmd = cmd or { "sourcekit-lsp" },
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

      if security.light_mode then
        vim.notify("NVIM_LIGHT=1: lighter SourceKit (no inlay hints).", vim.log.levels.INFO)
      end

      if vim.lsp.config and vim.lsp.enable then
        vim.lsp.config("sourcekit", sourcekit_cfg)
        vim.lsp.enable("sourcekit")
      else
        require("lspconfig").sourcekit.setup(sourcekit_cfg)
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
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
      }
      if security.allow_external_completion() then
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
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    module = "telescope",
    keys = {
      { "<leader>ff", desc = "Find files" },
      { "<leader>fg", desc = "Live grep" },
      { "<leader>fb", desc = "Buffers" },
      { "<leader>fh", desc = "Help tags" },
      { "<leader>fc", desc = "Search buffer" },
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
      local tg = require("config.telescope_grep")
      local vimgrep = tg.vimgrep_arguments()
      if vimgrep then
        opts.defaults = vim.tbl_extend("force", opts.defaults or {}, {
          vimgrep_arguments = vimgrep,
        })
      end
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
          lualine_z = { identity.format_chrome_copyright_label(os.date("%Y")), "location", "progress" },
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
        return path ~= nil and path ~= "" and vim.fn.isdirectory(path) == 0 and vim.fn.filereadable(path) == 1
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
        return cwd .. "/.build/debug/" .. vim.fn.fnamemodify(cwd, ":t")
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
              vim.notify("DAP: path is a directory. Build with: swift build", vim.log.levels.ERROR)
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
        dap.adapters.lldb = { type = "executable", command = lldb_exec, name = "lldb" }
      else
        vim.notify("No LLDB adapter found. Run scripts/vendor-plugins.sh", vim.log.levels.WARN)
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
      require("config.theme").apply_default()
    end,
  },
}
