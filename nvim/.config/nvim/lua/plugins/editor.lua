return {
  -- Mini.nvim (excluding statusline)
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.surround").setup()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.bufremove").setup()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.indentscope").setup({
        symbol = "│",
        draw = { delay = 50 },
        options = { try_as_border = true },
      })
    end,
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup({})
    end,
  },

  -- Auto Tag
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },

  -- Treesitter
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

  -- Git Signs
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

  -- Fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gblame" },
  },

  -- Todo Comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    branch = "main",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      use_diagnostic_signs = true,
    },
  },

  -- Aerial
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

  -- Flash
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
}
