local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -------------------------------------------------
  -- Theme: Gruvbox Flat
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
  -- mini.nvim: core editing / UI
  -------------------------------------------------
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Files (explorer)
      require("mini.files").setup({
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 70,
        },
        options = {
          use_as_default_explorer = true,
        },
      })

      -- Surround / commenting / pairs / buffers / statusline
      require("mini.surround").setup()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.bufremove").setup()
      require("mini.statusline").setup()

      -- Indent guides (replacement for indent-blankline)
      require("mini.indentscope").setup({
        symbol = "│",
        draw = {
          delay = 50,
        },
        options = {
          try_as_border = true,
        },
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
          "json", "yaml", "html", "css",
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
  -- Git: gitsigns
  -------------------------------------------------
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

          -- Navigation between hunks
          map("n", "]h", function()
            if vim.wo.diff then return "]h" end
            vim.schedule(function() gs.next_hunk() end)
          end, { expr = true })

          map("n", "[h", function()
            if vim.wo.diff then return "[h" end
            vim.schedule(function() gs.prev_hunk() end)
          end, { expr = true })

          -- Stage / reset / preview
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

          -- Toggle signs / linehl
          map("n", "<leader>ht", gs.toggle_signs, { desc = "Toggle git signs" })
          map("n", "<leader>hl", gs.toggle_linehl, { desc = "Toggle git linehl" })
        end,
      })
    end,
  },

  -------------------------------------------------
  -- LSP / Mason
  -------------------------------------------------
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = { "lua_ls", "ts_ls" },
      })

      local lspconfig = require("lspconfig")

      -- Basic on_attach
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end
        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "K", vim.lsp.buf.hover)
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>ca", vim.lsp.buf.code_action)
      end

      mason_lspconfig.setup_handlers({
        function(server)
          lspconfig[server].setup({
            on_attach = on_attach,
          })
        end,
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
  },

  -------------------------------------------------
  -- Completion: blink.cmp
  -------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
    },
  },
  -------------------------------------------------
  -- Formatting: conform.nvim (PrettierD, Stylua, Black)
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

      -- Format on save ONLY when safe
      format_on_save = function(bufnr)
        local disable_ft = { "sql", "txt", "markdown" }
        local ft = vim.bo[bufnr].filetype
        if vim.tbl_contains(disable_ft, ft) then return end
        return { timeout_ms = 3000, lsp_format = "fallback" }
      end,
    },

    config = function(_, opts)
      require("conform").setup(opts)

      -- Manual format keybinding
      vim.keymap.set({ "n", "v" }, "<leader>mp",
        function()
          require("conform").format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 3000,
          })
        end,
        { desc = "Format file or range" })
    end
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
        -- JS / TS ecosystem
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        vue = { "eslint_d" },

        -- Shell scripts
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },

        -- Docker
        dockerfile = { "hadolint" },

        -- Markdown
        markdown = { "markdownlint" },

        -- NOTE: Python – using Black via Conform (formatter only),
        -- no python linter wired here for now.
      }

      -- Auto-run linting on common events
      vim.api.nvim_create_augroup("NvimLintAutoGroup", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = "NvimLintAutoGroup",
        callback = function()
          -- Try to lint current buffer, ignore errors if linter missing
          pcall(lint.try_lint)
        end,
      })

      -- Manual lint command
      vim.keymap.set("n", "<leader>ml", function()
        lint.try_lint()
      end, { desc = "Run linter for current file" })
    end,
  },
  -------------------------------------------------
  -- Git porcelain: vim-fugitive
  -------------------------------------------------
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gblame" },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local ok, bufferline = pcall(require, "bufferline")
      if not ok then
        return
      end

      bufferline.setup({
        options = {
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,

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
          max_prefix_length = 30,
          tab_size = 21,

          diagnostics = false, -- set to "nvim_lsp" if you want diagnostics in tabs
          diagnostics_update_in_insert = false,

          offsets = {
            { filetype = "NvimTree", text = "", padding = 1 },
            { filetype = "neo-tree", text = "", padding = 1 },
          },

          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "thin",
          enforce_regular_tabs = true,
          always_show_bufferline = true,
        },
      })
    end,
  }

})
