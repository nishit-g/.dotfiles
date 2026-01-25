-- lua/keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-----------------------------------------------------------------------
-- General editing
-----------------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)
map("i", "jj", "<Esc>", opts)

map("n", "<leader>w", "<cmd>w<CR>", opts)

-- Smart quit (close buffer if multiple, quit if last)
map("n", "<leader>q", function()
  local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
  if buf_count > 1 then
    local ok, bufremove = pcall(require, "mini.bufremove")
    if ok then
      bufremove.delete(0, false)
    else
      vim.cmd("bdelete")
    end
  else
    vim.cmd("quit")
  end
end, { desc = "Smart quit" })

map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

map("n", "Y", "y$", opts)

-- Move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Better Join (keeps cursor in place)
map("n", "J", "mzJ`z", opts)

-- Half page jumping (centered)
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

-- Search terms (centered)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- Paste without losing register
map("x", "<leader>p", [["_dP]], opts)

-- System Clipboard
map({ "n", "v" }, "<leader>y", [["+y]], opts)
map("n", "<leader>Y", [["+Y]], opts)

-- Delete to void register
map({ "n", "v" }, "<leader>d", [["_d]], opts)

-- Inc-Rename (uses noice integration)
map("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "Rename (IncRename)" })

-----------------------------------------------------------------------
-- Windows & splits
-----------------------------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- Window management
map("n", "<leader>w-", "<C-w>s", { desc = "Split Horizontal" })
map("n", "<leader>w|", "<C-w>v", { desc = "Split Vertical" })
map("n", "<leader>wd", "<C-w>c", { desc = "Close Window" })
map("n", "<leader>ww", "<C-w>w", { desc = "Other Window" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close Other Windows" })
map("n", "<leader>wh", "<C-w>h", { desc = "Window Left" })
map("n", "<leader>wj", "<C-w>j", { desc = "Window Down" })
map("n", "<leader>wk", "<C-w>k", { desc = "Window Up" })
map("n", "<leader>wl", "<C-w>l", { desc = "Window Right" })

map("n", "<C-Up>", "<cmd>resize -2<CR>", opts)
map("n", "<C-Down>", "<cmd>resize +2<CR>", opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

-----------------------------------------------------------------------
-- Buffers (with bufferline + mini.bufremove)
-----------------------------------------------------------------------
map("n", "<S-l>", "<cmd>bnext<CR>", opts)
map("n", "<S-h>", "<cmd>bprevious<CR>", opts)
map("n", "<leader><Tab>", "<cmd>e #<CR>", { desc = "Switch to last buffer" })
map("n", "<C-x>", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if ok then
    bufremove.delete(0, false)
  else
    vim.cmd("bdelete")
  end
end, { silent = true, desc = "Close buffer" })

map("n", "<leader>x", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if ok then
    bufremove.delete(0, false)
  else
    vim.cmd("bdelete")
  end
end, { silent = true, desc = "Close buffer" })

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

map("n", "<leader>fk", function() require("fzf-lua").keymaps() end,
  { silent = true, desc = "Keymaps" })

map("n", "<leader>fc", function() require("fzf-lua").commands() end,
  { silent = true, desc = "Commands" })

map("n", "<leader>fw", function() require("fzf-lua").grep_cword() end,
  { silent = true, desc = "Grep word under cursor" })

map("n", "<leader>gc", function() require("fzf-lua").git_commits() end,
  { silent = true, desc = "Git commits" })

map("n", "<leader>gC", function() require("fzf-lua").git_bcommits() end,
  { silent = true, desc = "Git buffer commits" })

-----------------------------------------------------------------------
-- Diagnostics
-----------------------------------------------------------------------
map("n", "[d", vim.diagnostic.goto_prev, { silent = true, desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { silent = true, desc = "Next diagnostic" })
map("n", "<leader>ld", vim.diagnostic.open_float, { silent = true, desc = "Line diagnostics" })
map("n", "<leader>lq", vim.diagnostic.setloclist, { silent = true, desc = "Diagnostics loclist" })

map("n", "[q", "<cmd>cprev<CR>zz", { silent = true, desc = "Prev quickfix" })
map("n", "]q", "<cmd>cnext<CR>zz", { silent = true, desc = "Next quickfix" })
map("n", "[l", "<cmd>lprev<CR>zz", { silent = true, desc = "Prev loclist" })
map("n", "]l", "<cmd>lnext<CR>zz", { silent = true, desc = "Next loclist" })

map("n", "[t", function() require("todo-comments").jump_prev() end, { silent = true, desc = "Prev todo" })
map("n", "]t", function() require("todo-comments").jump_next() end, { silent = true, desc = "Next todo" })

-----------------------------------------------------------------------
-- Git: fugitive
-----------------------------------------------------------------------
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

map("n", "<leader>sn", function()
  require("noice").cmd("dismiss")
end, { silent = true, desc = "Dismiss notifications" })

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
