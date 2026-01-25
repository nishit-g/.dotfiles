local o = vim.opt
local g = vim.g

o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.termguicolors = true
o.cursorline = true

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true

o.splitbelow = true
o.splitright = true
o.scrolloff = 5
o.sidescrolloff = 8

o.ignorecase = true
o.smartcase = true

o.updatetime = 250
o.timeoutlen = 400

o.wrap = false

o.undofile = true
o.swapfile = false  -- Disabled since we have undofile

-- Performance
o.laststatus = 3  -- Global statusline
o.smoothscroll = true  -- Smooth scrolling (0.10+)
o.splitkeep = "screen"  -- Keep content stable on splits
o.inccommand = "split"  -- Live substitution preview
o.jumpoptions = "stack"  -- Simpler jumplist

-- Better diff
o.diffopt:append("algorithm:histogram")
o.diffopt:append("linematch:60")
o.diffopt:append("indent-heuristic")

-- Faster shada
o.shada = "!,'1000,<50,s10,h"

-- Less noise
o.shortmess:append("cIWa")

-- Cleaner UI
o.fillchars = {
  eob = " ",  -- Hide ~ at end of buffer
  fold = " ",
  foldopen = "v",
  foldsep = "|",
  diff = "/",
}

g.mapleader = " "
g.maplocalleader = " "
