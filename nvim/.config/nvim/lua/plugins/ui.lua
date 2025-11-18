return {
  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- File Explorer
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
        filters = { dotfiles = false },
        git = { enable = true },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
    end,
  },

  -- Bufferline
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
          indicator = { icon = "▎", style = "icon" },
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

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "gruvbox-flat",
        globalstatus = true,
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  -- UI Enhancements (Noice)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    },
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local logo = [[
           ██╗      ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗
           ██║     ██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║
           ██║     ██║   ██║██████╔╝██████╔╝██║██╔██╗ ██║
           ██║     ██║   ██║██╔══██╗██╔══██╗██║██║╚██╗██║
           ███████╗╚██████╔╝██║  ██║██║  ██║██║██║ ╚████║
           ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          center = {
            { action = "Telescope find_files", desc = " Find File", icon = " ", key = "f" },
            { action = "ene | startinsert", desc = " New File", icon = " ", key = "n" },
            { action = "Telescope oldfiles", desc = " Recent Files", icon = " ", key = "r" },
            { action = "Telescope live_grep", desc = " Find Text", icon = " ", key = "g" },
            { action = "e $MYVIMRC", desc = " Config", icon = " ", key = "c" },
            { action = 'require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
            { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
            { action = "qa", desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      return opts
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
  },
}
