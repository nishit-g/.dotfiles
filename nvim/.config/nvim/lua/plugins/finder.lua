return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>fk", "<cmd>FzfLua keymaps<CR>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>FzfLua commands<CR>", desc = "Commands" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep word" },
      { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Git commits" },
      { "<leader>gC", "<cmd>FzfLua git_bcommits<CR>", desc = "Git buffer commits" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({})
    end,
  },
}
