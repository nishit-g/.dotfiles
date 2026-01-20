return {
  {
    "eddyekofo94/gruvbox-flat.nvim",
    priority = 1000,
    config = function()
      vim.g.gruvbox_flat_style = "dark"
      vim.g.gruvbox_flat_background = "hard"
      vim.cmd.colorscheme("gruvbox-flat")
    end,
  },
}
