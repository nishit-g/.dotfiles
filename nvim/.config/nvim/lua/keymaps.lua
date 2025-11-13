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
-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- Better escape from insert
map("i", "jj", "<Esc>", opts)

-- Save / quit
map("n", "<leader>w", "<cmd>w<CR>", opts)
map("n", "<leader>q", "<cmd>q<CR>", opts)
map("n", "<leader>Q", "<cmd>qa!<CR>", opts)

-- Yank till end of line (like old config)
map("n", "Y", "y$", opts)

-- Move selected lines up/down (visual) – from your old setup
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-----------------------------------------------------------------------
-- Windows & splits
-----------------------------------------------------------------------
-- Navigate splits with Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Resize splits with arrows
map("n", "<C-Up>", "<cmd>resize -2<CR>", opts)
map("n", "<C-Down>", "<cmd>resize +2<CR>", opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

-- Split shortcuts
map("n", "<leader>sv", "<cmd>vsplit<CR>", opts)
map("n", "<leader>sh", "<cmd>split<CR>", opts)

-----------------------------------------------------------------------
-- Buffers (works great with bufferline + mini.bufremove)
-----------------------------------------------------------------------
-- Next / previous buffer (your classic <S-l>/<S-h>)
map("n", "<S-l>", "<cmd>bnext<CR>", opts)
map("n", "<S-h>", "<cmd>bprevious<CR>", opts)

-- Close buffer (keep window)
map("n", "<leader>bd", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if ok then
    bufremove.delete(0, false)
  else
    vim.cmd("bdelete")
  end
end, { silent = true, desc = "Close buffer" })

-- Close all other buffers
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { silent = true, desc = "Close other buffers" })

-----------------------------------------------------------------------
-- File explorer: mini.files (our nvim-tree replacement)
-----------------------------------------------------------------------
local function open_mini_files(path)
  local mf = require("mini.files")

  -- If already open, just focus / update root
  if mf.close() then
    mf.open(path, true)
  else
    mf.open(path, true)
  end
end

-- <leader>e : explorer at current file's directory
map("n", "<leader>E", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    open_mini_files(nil)
  else
    open_mini_files(bufname)
  end
end, { silent = true, desc = "Explorer (file dir)" })

-- <leader>E : explorer at project root (cwd)
map("n", "<leader>e", function()
  open_mini_files(vim.loop.cwd())
end, { silent = true, desc = "Explorer (project root)" })

-----------------------------------------------------------------------
-- Fuzzy finding: fzf-lua (files, grep, buffers, help)
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
-- Diagnostics (LSP + nvim-lint)
-----------------------------------------------------------------------
map("n", "[d", vim.diagnostic.goto_prev, { silent = true, desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })
map("n", "<leader>ld", vim.diagnostic.open_float, { silent = true, desc = "Line diagnostics" })
map("n", "<leader>lq", vim.diagnostic.setloclist, { silent = true, desc = "Diagnostics loclist" })

-----------------------------------------------------------------------
-- LSP general (fallback – on top of on_attach mappings)
-----------------------------------------------------------------------
map("n", "gd", vim.lsp.buf.definition, { silent = true, desc = "Goto definition" })
map("n", "gD", vim.lsp.buf.declaration, { silent = true, desc = "Goto declaration" })
map("n", "gi", vim.lsp.buf.implementation, { silent = true, desc = "Goto implementation" })
map("n", "gr", vim.lsp.buf.references, { silent = true, desc = "References" })
map("n", "K", vim.lsp.buf.hover, { silent = true, desc = "Hover" })

map("n", "<leader>rn", vim.lsp.buf.rename, { silent = true, desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { silent = true, desc = "Code action" })

-- Format via LSP fallback (you also have <leader>mp from Conform config)
map("n", "<leader>lf", function()
  vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "LSP format" })

-----------------------------------------------------------------------
-- Git: gitsigns (hunts) + fugitive (porcelain)
-----------------------------------------------------------------------
-- Gitsigns hunk navigation & actions are set in its on_attach,
-- but we add a couple of global helpers here too.

-- Toggle git signs
map("n", "<leader>ht", function()
  require("gitsigns").toggle_signs()
end, { silent = true, desc = "Toggle git signs" })

-- Full Git porcelain: Fugitive
map("n", "<leader>gs", "<cmd>Git<CR>", { silent = true, desc = "Git status" })
map("n", "<leader>gb", "<cmd>Git blame<CR>", { silent = true, desc = "Git blame" })
map("n", "<leader>gl", "<cmd>Git log<CR>", { silent = true, desc = "Git log" })
map("n", "<leader>gD", "<cmd>Gvdiffsplit<CR>", { silent = true, desc = "Git diff vsplit" })
map("n", "<leader>gp", "<cmd>Git push<CR>", { silent = true, desc = "Git push" })

-----------------------------------------------------------------------
-- Lint / Format (extra mappings to complement plugin configs)
-----------------------------------------------------------------------
-- Conform already defines <leader>mp in its config; we keep that.
-- Here we add a quick "lint now" helper (in case plugin didn't add one).

map("n", "<leader>ml", function()
  local ok, lint = pcall(require, "lint")
  if ok then
    lint.try_lint()
  else
    vim.notify("nvim-lint not available", vim.log.levels.WARN)
  end
end, { silent = true, desc = "Run linter" })

-----------------------------------------------------------------------
-- Tmux integration (optional, can reuse your old sessionizer)
-----------------------------------------------------------------------
-- If you keep a tmux-sessionizer script in PATH:
-- map("n", "<leader><C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", opts)
