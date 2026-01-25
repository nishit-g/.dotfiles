return {
  -- Mini.nvim
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.surround").setup()
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
    keys = {
      { "<C-e>", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<M-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<M-j>", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
      { "<M-k>", function() require("harpoon"):list():select(3) end, desc = "Harpoon 3" },
      { "<M-l>", function() require("harpoon"):list():select(4) end, desc = "Harpoon 4" },
    },
    config = function()
      require("harpoon").setup({})
    end,
  },

  -- Auto Tag
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "bash", "javascript", "typescript", "tsx",
          "json", "yaml", "html", "css", "markdown",
        },
        highlight = { enable = true },
        indent = { enable = false },  -- Use native indent (TS indent is CPU-heavy)
      })
    end,
  },

  -- Git Signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
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

          map("n", "]h", function()
            if vim.wo.diff then return "]h" end
            vim.schedule(gs.next_hunk)
          end, { expr = true })

          map("n", "[h", function()
            if vim.wo.diff then return "[h" end
            vim.schedule(gs.prev_hunk)
          end, { expr = true })

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

  -- Diffview
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diffview open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Diffview branch history" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Diffview close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_mixed" },
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = { "help", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "notify", "toggleterm" },
      },
    },
  },

  -- Todo Comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    branch = "main",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      use_diagnostic_signs = true,
    },
  },

  -- Aerial
  {
    "stevearc/aerial.nvim",
    event = "LspAttach",
    keys = {
      { "<leader>la", "<cmd>AerialToggle<CR>", desc = "Aerial toggle" },
    },
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
