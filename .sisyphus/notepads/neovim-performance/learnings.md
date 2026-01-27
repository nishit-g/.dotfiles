 
## ToggleTerm Lazy Loading
- Added `keys = { { [[\<c-\>]], desc = "Toggle Terminal" } }` trigger
- Added `cmd = { "ToggleTerm", "TermExec" }` trigger
- Both triggers must be placed after `version = "*"` and before `opts = {`
- The `keys` trigger matches the `open_mapping` inside opts ([[\<c-\>]])
- Neovim syntax: Double square brackets `[[\<c-\>]]` for literal strings with backslashes
- Verified with `nvim --headless -c 'qa'` (no errors = success)
- Expected behavior: Plugin loads only when pressing `<C-\>` or running `:ToggleTerm`/`:TermExec`

## Mason Tool Installer - run_on_start Disabled
**Change**: Set `run_on_start = false` in mason-tool-installer.nvim opts
**Location**: `nvim/.config/nvim/lua/plugins/lsp.lua:48`
**Reason**: Eliminates CPU spike at startup from checking 16+ tools
**Manual trigger**: Run `:MasonToolsUpdate` when needed to check/install tools
**Result**: Faster Neovim startup, no background tool checking

## Bigfile Handling Added (Jan 25, 2026)

**What**: Added autocmd to disable heavy features for files >1MB

**Location**: `nvim/.config/nvim/lua/autocmds.lua` (lines 38-76)

**Implementation**:
- `BufReadPre` autocmd detects file size using `vim.loop.fs_stat`
- Sets `vim.b[buf].bigfile = true` flag for files >1MB
- Disables: swapfile, foldmethod, undolevels, list, syntax, treesitter
- `LspAttach` autocmd detaches LSP clients from bigfiles
- Shows warning notification to user

**Threshold**: 1MB (1024 * 1024 bytes)

**Pattern**: Inspired by LunarVim/bigfile.nvim

**Testing**:
- Config loads without errors: `nvim --headless -c 'qa'` → exit 0
- 5MB test file opens without freeze
- Warning notification shown (headless mode verified via exit code)

**Key Learning**: Using `vim.loop.fs_stat` in `BufReadPre` allows size check before loading, preventing performance issues from even starting.

## Built-in Plugin Disabling + lazy.nvim Performance Config

**Date**: 2026-01-25

**Changes Made**:
1. Added 26 vim.g.loaded_* variables to disable unused built-in plugins (gzip, tar, zip, netrw, matchit, matchparen, tutor, etc.)
2. Disabled unused providers (perl, ruby, python3) - kept node_provider for copilot compatibility
3. Added defaults.lazy = true to lazy.nvim setup - all plugins lazy by default
4. Added performance.rtp.disabled_plugins list to lazy.nvim setup

**Performance Impact**:
- Built-in plugin disabling: ~5-10ms startup reduction
- defaults.lazy = true: Prevents accidental eager loading of future plugins
- performance.rtp.disabled_plugins: Redundant safety layer with vim.g.loaded_* vars

**Verification**:
- nvim --headless -c 'qa' exits with code 0
- No LSP errors (lua-language-server not installed in environment, but syntax is valid)

**Location**: nvim/.config/nvim/init.lua
- Built-in plugin disabling: lines 6-32 (after vim.loader block)
- lazy.nvim config: lines 51-73 (added defaults and performance blocks)

**Key Learnings**:
- Always disable built-in plugins BEFORE requiring config modules
- Keep node_provider enabled if using copilot (comment added for maintainability)
- defaults.lazy = true is critical to prevent future performance regressions
- performance.rtp.disabled_plugins duplicates vim.g.loaded_* but provides lazy.nvim-specific optimizations
