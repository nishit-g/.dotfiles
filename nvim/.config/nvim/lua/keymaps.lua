local map = vim.keymap.set
local opts = { silent = true, noremap = true }

-- Better defaults
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)
map("n", "x", '"_x', opts)

-- Window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Resize splits
map("n", "<C-Up>", ":resize -2<CR>", opts)
map("n", "<C-Down>", ":resize +2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", opts)
map("n", "<leader>q", "<cmd>q<CR>", opts)

-- Fzf-lua
map("n", "<leader>ff", function() require("fzf-lua").files() end, opts)
map("n", "<leader>fg", function() require("fzf-lua").live_grep() end, opts)
map("n", "<leader>fb", function() require("fzf-lua").buffers() end, opts)
map("n", "<leader>fh", function() require("fzf-lua").help_tags() end, opts)

-- Gitsigns
map("n", "<leader>gs", "<cmd>Gitsigns toggle_signs<CR>", opts)
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>", opts)

-- mini.files (file explorer)
map("n", "<leader>e", function() require("mini.files").open() end, opts)
