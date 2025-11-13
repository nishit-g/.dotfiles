local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local general = augroup("General", {})

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

-- Open help vertically
autocmd("FileType", {
  group = general,
  pattern = "help",
  command = "wincmd L",
})
