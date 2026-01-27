return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      scratch = { enabled = true },
      terminal = { enabled = true },
      gitbrowse = { enabled = true },

      lazygit = { enabled = true },
      zen = { enabled = true },
      dim = { enabled = true },
      scroll = { enabled = true, animate = { duration = { step = 15, total = 150 } } },
      
      indent = {
        enabled = true,
        char = "│",
        animate = { enabled = false },
      },
      scope = {
        enabled = true,
        char = "│",
        underline = false,
        treesitter = { enabled = true },
      },
      
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
            { icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
            { icon = " ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
            { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
          header = [[
 ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗███╗   ███╗ ██████╗ ███╗   ██╗██╗  ██╗
██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔════╝████╗ ████║██╔═══██╗████╗  ██║██║ ██╔╝
██║     ███████║███████║██║   ██║███████╗██╔████╔██║██║   ██║██╔██╗ ██║█████╔╝ 
██║     ██╔══██║██╔══██║██║   ██║╚════██║██║╚██╔╝██║██║   ██║██║╚██╗██║██╔═██╗ 
╚██████╗██║  ██║██║  ██║╚██████╔╝███████║██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║  ██╗
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝]],
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },

      picker = { enabled = false },
      input = { enabled = false },
      image = { enabled = false },
    },
    keys = {
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit File History" },
      { "<leader>z",  function() Snacks.zen() end, desc = "Zen Mode" },
      { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Zoom Window" },
      { "<leader>ud", function() Snacks.dim() end, desc = "Toggle Dim" },
      { "<c-\\>",     function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    },
  },
}
