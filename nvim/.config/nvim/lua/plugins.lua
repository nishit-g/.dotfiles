-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -------------------------------------------------
  -- Colorscheme: Gruvbox Flat
  -------------------------------------------------
  {
    "eddyekofo94/gruvbox-flat.nvim",
    priority = 1000,
    config = function()
      vim.g.gruvbox_flat_style = "dark"
      vim.g.gruvbox_flat_background = "hard"
      vim.cmd.colorscheme("gruvbox-flat")
    end,
  },

  -------------------------------------------------
  -- Icons (shared dependency)
  -------------------------------------------------
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 32,
          side = "left",
        },
        renderer = {
          highlight_git = true,
          highlight_opened_files = "all",
          icons = {
            glyphs = {
              git = {
                unstaged = "",
                staged = "",
                untracked = "",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
        },
      })

      -- Keymap
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
    end,
  },

  -------------------------------------------------
  -- mini.nvim: core UX (files, surround, comment, pairs, bufremove, statusline, indentscope)
  -------------------------------------------------
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Editing helpers
      require("mini.surround").setup()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.bufremove").setup()

      -- Statusline
      require("mini.statusline").setup()

      -- Indent guides
      require("mini.indentscope").setup({
        symbol = "│",
        draw = { delay = 50 },
        options = { try_as_border = true },
      })
    end,
  },

  -------------------------------------------------
  -- Treesitter
  -------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "bash", "javascript", "typescript", "tsx",
          "json", "yaml", "html", "css", "markdown",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -------------------------------------------------
  -- Fuzzy finder: fzf-lua
  -------------------------------------------------
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({})
    end,
  },

  -------------------------------------------------
  -- Git: gitsigns (with rich keymaps)
  -------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, lhs, rhs, opts)
            opts = opts or {}
            opts.buffer = bufnr
            opts.silent = true
            vim.keymap.set(mode, lhs, rhs, opts)
          end

          -- Hunk navigation
          map("n", "]h", function()
            if vim.wo.diff then return "]h" end
            vim.schedule(gs.next_hunk)
          end, { expr = true })

          map("n", "[h", function()
            if vim.wo.diff then return "[h" end
            vim.schedule(gs.prev_hunk)
          end, { expr = true })

          -- Hunk actions
          map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Stage hunk (visual)" })
          map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "Reset hunk (visual)" })

          map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })

          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end, { desc = "Git blame line" })

          map("n", "<leader>ht", gs.toggle_signs, { desc = "Toggle git signs" })
          map("n", "<leader>hl", gs.toggle_linehl, { desc = "Toggle git linehl" })
        end,
      })
    end,
  },

  -------------------------------------------------
  -- Git porcelain: vim-fugitive
  -------------------------------------------------
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gblame" },
  },

  -------------------------------------------------
  -- LSP / Mason / LSPConfig
  -------------------------------------------------
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")

      mason_lspconfig.setup({
        ensure_installed = { "lua_ls", "tsserver" },
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      local on_attach = function(_, bufnr)
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
      end

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
  },

  -------------------------------------------------
  -- Completion: blink.cmp
  -------------------------------------------------
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

  -------------------------------------------------
  -- Formatting: conform.nvim (Prettierd, Black, Stylua, etc.)
  -------------------------------------------------
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

  -------------------------------------------------
  -- Linting: nvim-lint (eslint_d, shellcheck, hadolint, markdownlint)
  -------------------------------------------------
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

  -------------------------------------------------
  -- Bufferline (tabs for buffers)
  -------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local ok, bufferline = pcall(require, "bufferline")
      if not ok then return end

      bufferline.setup({
        options = {
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 30,
          tab_size = 18,
          diagnostics = false,
          show_buffer_close_icons = true,
          show_close_icon = true,
          separator_style = "thin",
          always_show_bufferline = true,
        },
      })
    end,
  },

  -------------------------------------------------
  -- which-key: discover keymaps
  -------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({})
      wk.register({
        ["<leader>f"] = { name = "+find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>l"] = { name = "+lsp" },
        ["<leader>m"] = { name = "+meta" },
        ["<leader>b"] = { name = "+buffers" },
        ["<leader>h"] = { name = "+hunks" },
        ["<leader>e"] = { name = "+explorer" },
        ["<leader>q"] = { name = "+session/quit" },
      })
    end,
  },

  -------------------------------------------------
  -- Code outline: aerial.nvim
  -------------------------------------------------
  {
    "stevearc/aerial.nvim",
    event = "LspAttach",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      backends = { "lsp", "treesitter", "markdown" },
      layout = {
        max_width = { 40, 0.2 },
        min_width = 24,
        default_direction = "right",
        placement = "edge",
      },
      highlight_mode = "split_width",
      show_guides = true,
    },
  },

  -------------------------------------------------
  -- Diagnostics / references UI: trouble.nvim
  -------------------------------------------------
  {
    "folke/trouble.nvim",
    branch = "main",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      use_diagnostic_signs = true,
    },
  },

}, {
  ui = {
    border = "rounded",
  },
})
