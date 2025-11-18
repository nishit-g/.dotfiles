return {
  -- LazyDev (Better Lua Dev)
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings

  -- Mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason LSP Config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls" },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      -- Set global defaults for all LSP servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- LspAttach autocommand for keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Goto definition")
          map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
          map("n", "gr", vim.lsp.buf.references, "Goto references")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
  },

  -- Completion: blink.cmp
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "default" },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
      completion = {
        keyword = { range = "full" },
      },
    },
  },

  -- Formatting: conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        yaml = { "prettierd", "prettier" },
        markdown = { "prettierd", "prettier" },
        python = { "black" },
      },
      format_on_save = function(bufnr)
        local disable_ft = { "sql", "txt" }
        local ft = vim.bo[bufnr].filetype
        if vim.tbl_contains(disable_ft, ft) then
          return
        end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },
    config = function(_, opts)
      require("conform").setup(opts)
      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
        require("conform").format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 3000,
        })
      end, { desc = "Format file or range" })
    end,
  },

  -- Linting: nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },

        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },

        dockerfile = { "hadolint" },

        markdown = { "markdownlint" },
      }

      local group = vim.api.nvim_create_augroup("NvimLintAutoGroup", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = group,
        callback = function()
          pcall(lint.try_lint)
        end,
      })
    end,
  },
}
