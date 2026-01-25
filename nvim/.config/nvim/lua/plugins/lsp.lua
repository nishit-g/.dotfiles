return {
  -- LazyDev (Better Lua Dev)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true },

  -- Mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },

  -- Mason Tool Installer
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua-language-server",
        "typescript-language-server",
        "pyright",
        "json-lsp",
        "css-lsp",
        "html-lsp",
        "bash-language-server",
        "tailwindcss-language-server",
        "stylua",
        "prettierd",
        "black",
        "shfmt",
        "eslint_d",
        "shellcheck",
        "hadolint",
        "markdownlint",
        "debugpy",
      },
      auto_update = false,
      run_on_start = false,  -- Run :MasonToolsUpdate manually to check/install
    },
  },

  -- Mason LSP Config
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
          "jsonls",
          "cssls",
          "html",
          "bashls",
          "tailwindcss",
        },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

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
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },

  -- LSP Config
  { "neovim/nvim-lspconfig", lazy = true },

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
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>mp", function()
        require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 3000 })
      end, mode = { "n", "v" }, desc = "Format file or range" },
    },
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
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
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
  },

  -- Linting: nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
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

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("NvimLintAutoGroup", { clear = true }),
        callback = function()
          pcall(lint.try_lint)
        end,
      })
    end,
  },
}
