return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- Disable features that conflict with existing plugins
      dashboard = { enabled = false },  -- Using dashboard-nvim
      indent = { enabled = false },      -- Using mini.indentscope
      
      -- Enable useful features
      notifier = { enabled = true },     -- Better notifications
      quickfile = { enabled = true },    -- Fast file opening
      statuscolumn = { enabled = true }, -- Better status column
      words = { enabled = true },        -- Word highlighting
      scratch = { enabled = true },      -- Scratch buffers
      terminal = { enabled = true },     -- Terminal improvements
      
      -- Git browse (open in browser)
      gitbrowse = { enabled = true },
    },
    keys = {
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    },
  },
}
