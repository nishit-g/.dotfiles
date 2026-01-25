return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { [[<c-\>]], desc = "Toggle Terminal" },
    },
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      function _G.set_terminal_keymaps()
        local topts = { buffer = 0 }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], topts)
        vim.keymap.set("t", "jk", [[<C-\><C-n>]], topts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], topts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], topts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], topts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], topts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },
}
