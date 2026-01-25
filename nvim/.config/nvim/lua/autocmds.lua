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

-- Disable mini.indentscope in certain filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = general,
  pattern = {
    "help",
    "lazy",
    "mason",
    "fzf",
    "markdown",
    "gitcommit",
    "toggleterm",
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

-- Bigfile handling: disable heavy features for large files
local bigfile = augroup("BigFile", {})
local bigfile_size = 1024 * 1024 -- 1MB

autocmd("BufReadPre", {
  group = bigfile,
  callback = function(args)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > bigfile_size then
      vim.b[args.buf].bigfile = true
      
      -- Disable features that slow down large files
      vim.opt_local.swapfile = false
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = -1
      vim.opt_local.undoreload = 0
      vim.opt_local.list = false
      
      -- Disable syntax and treesitter
      vim.cmd("syntax clear")
      vim.treesitter.stop(args.buf)
      
      -- Notify user
      vim.notify("Large file detected. Heavy features disabled.", vim.log.levels.WARN)
    end
  end,
})

-- Detach LSP from large files
autocmd("LspAttach", {
  group = bigfile,
  callback = function(args)
    if vim.b[args.buf].bigfile then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, args.data.client_id)
      end)
    end
  end,
})
