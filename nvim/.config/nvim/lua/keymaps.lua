-- lua/keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-----------------------------------------------------------------------
-- Leader
-----------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-----------------------------------------------------------------------
-- General editing
-----------------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)
map("i", "jj", "<Esc>", opts)

map("n", "<leader>w", "<cmd>w<CR>", opts)
map("n", "<leader>q", "<cmd>q<CR>", opts)
map("n", "<leader>Q", "<cmd>qa!<CR>", opts)

map("n", "Y", "y$", opts)

-- Move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-----------------------------------------------------------------------
-- Windows & splits
-----------------------------------------------------------------------
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

map("n", "<C-Up>", "<cmd>resize -2<CR>", opts)
map("n", "<C-Down>", "<cmd>resize +2<CR>", opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

map("n", "<leader>sv", "<cmd>vsplit<CR>", opts)
map("n", "<leader>sh", "<cmd>split<CR>", opts)

-----------------------------------------------------------------------
-- Buffers (with bufferline + mini.bufremove)
-----------------------------------------------------------------------
map("n", "<S-l>", "<cmd>bnext<CR>", opts)
map("n", "<S-h>", "<cmd>bprevious<CR>", opts)

map("n", "<leader>bd", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if ok then
    bufremove.delete(0, false)
  else
    vim.cmd("bdelete")
  end
end, { silent = true, desc = "Close buffer" })

map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { silent = true, desc = "Close other buffers" })

-----------------------------------------------------------------------
-- Fuzzy finding: fzf-lua
-----------------------------------------------------------------------
map("n", "<leader>ff", function() require("fzf-lua").files() end,
  { silent = true, desc = "Find files" })

map("n", "<leader>fg", function() require("fzf-lua").live_grep() end,
  { silent = true, desc = "Live grep" })

map("n", "<leader>fb", function() require("fzf-lua").buffers() end,
  { silent = true, desc = "Buffers" })

map("n", "<leader>fh", function() require("fzf-lua").help_tags() end,
  { silent = true, desc = "Help tags" })

map("n", "<leader>fr", function() require("fzf-lua").oldfiles() end,
  { silent = true, desc = "Recent files" })

-----------------------------------------------------------------------
-- Diagnostics
-----------------------------------------------------------------------
map("n", "[d", vim.diagnostic.goto_prev, { silent = true, desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })
map("n", "<leader>ld", vim.diagnostic.open_float, { silent = true, desc = "Line diagnostics" })
map("n", "<leader>lq", vim.diagnostic.setloclist, { silent = true, desc = "Diagnostics loclist" })

-----------------------------------------------------------------------
-- LSP (generic; on_attach adds buffer-local too)
-----------------------------------------------------------------------
map("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "Goto definition" })
map("n", "gD", vim.lsp.buf.declaration, { silent = true, desc = "Goto declaration" })
map("n", "gi", vim.lsp.buf.implementation, { silent = true, desc = "Goto implementation" })
map("n", "gr", vim.lsp.buf.references, { silent = true, desc = "Goto references" })
map("n", "K", vim.lsp.buf.hover, { silent = true, desc = "Hover" })

map("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { silent = true, desc = "Code action" })

map("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "LSP format" })

-----------------------------------------------------------------------
-- Git: gitsigns toggle + fugitive
-----------------------------------------------------------------------
map("n", "<leader>ht", function()
  require("gitsigns").toggle_signs()
end, { silent = true, desc = "Toggle git signs" })

map("n", "<leader>gs", "<cmd>Git<CR>", { silent = true, desc = "Git status" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { silent = true, desc = "Git blame" })
map("n", "<leader>gl", "<cmd>Git log<CR>", { silent = true, desc = "Git log" })
map("n", "<leader>gD", "<cmd>Gvdiffsplit<CR>", { silent = true, desc = "Git diff vsplit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { silent = true, desc = "Git push" })

-----------------------------------------------------------------------
-- Lint / Format helpers
-----------------------------------------------------------------------
map("n", "<leader>ml", function()
  local ok, lint = pcall(require, "lint")
  if ok then
    lint.try_lint()
  else
    vim.notify("nvim-lint not available", vim.log.levels.WARN)
  end
end, { silent = true, desc = "Run linter" })
-- NOTE: <leader>mp is defined in conform.nvim config.

-----------------------------------------------------------------------
-- Code outline: aerial.nvim
-----------------------------------------------------------------------
map("n", "<leader>ls", "<cmd>AerialToggle!<CR>", { silent = true, desc = "Symbols outline (aerial)" })

-----------------------------------------------------------------------
-- Trouble: diagnostics / references / lists
-----------------------------------------------------------------------
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", {
  silent = true,
  desc = "Diagnostics (workspace)",
})

map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", {
  silent = true,
  desc = "Diagnostics (buffer)",
})

map("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", {
  silent = true,
  desc = "LSP references (Trouble)",
})

map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", {
  silent = true,
  desc = "Quickfix (Trouble)",
})

map("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", {
  silent = true,
  desc = "Loclist (Trouble)",
})

-----------------------------------------------------------------------
-- Project root helper (cd to git root)
-----------------------------------------------------------------------
map("n", "<leader>pr", function()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if root and root ~= "" then
    vim.cmd("cd " .. root)
    vim.notify("cd " .. root)
  else
    vim.notify("Not a git repo", vim.log.levels.WARN)
  end
end, { silent = true, desc = "cd to project root (git)" })

-----------------------------------------------------------------------
-- (Optional) Tmux integration – keep commented until you want it
-----------------------------------------------------------------------
-- map("n", "<leader><C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", opts)
