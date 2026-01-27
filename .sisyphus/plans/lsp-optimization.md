# Neovim Deep Optimization (LSP, Options, Editor)

## Context

### Original Request
Fix LSP performance issues: duplicate servers, CPU spikes, aggressive linting, UI freezes.

### Current State Analysis
- **mason-lspconfig**: Missing `setup_handlers` pattern (risk of duplicate servers)
- **tailwindcss**: No debouncing (CPU spike on typing)
- **conform.nvim**: `async = false` freezes UI for up to 3 seconds
- **nvim-lint**: `BufEnter` triggers on every buffer switch (unnecessary)
- **lua_ls**: Missing workspace settings (duplicate warnings)
- **ts_ls**: No `single_file_support = false` (starts for standalone files)

### Research Findings
- Neovim 0.11+ supports `vim.lsp.config()` natively but mason-lspconfig still works
- `setup_handlers` pattern ensures each server is configured exactly once
- Debounce of 1000ms for tailwindcss is common practice
- `BufEnter` should be removed from lint triggers - only `BufWritePost` and `InsertLeave` needed

---

## Work Objectives

### Core Objective
Optimize LSP configuration to prevent duplicate servers, reduce CPU usage, and improve responsiveness.

### Concrete Deliverables
- Refactored lsp.lua with proper `setup_handlers` pattern
- Debouncing for heavy servers (tailwindcss)
- Async formatting in conform.nvim
- Optimized nvim-lint triggers
- Enhanced options.lua with performance settings
- Optimized editor.lua (treesitter, remove redundant plugins)
- Faster nvim-tree settings in ui.lua

### Definition of Done
- [x] No duplicate LSP servers when opening multiple TS files
- [x] No CPU spike when typing in tailwindcss files
- [x] Manual format doesn't freeze UI
- [x] Buffer switching doesn't trigger linting
- [x] All existing LSP functionality preserved
- [x] options.lua has all performance settings
- [x] Treesitter indent disabled
- [x] mini.comment removed (native gc)
- [x] nvim-tree optimized

---

## ADDITIONAL TODOs

- [x] 5. Enhance options.lua with performance settings

  **What to do**:
  - Add missing performance and UX options
  - Keep all existing options

  **Add after line 28 (after undofile)**:
  ```lua
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
    foldopen = "",
    foldclose = "",
    diff = "╱",
  }
  ```

  **Must NOT do**:
  - Do NOT remove existing options
  - Do NOT change mapleader

  **Parallelizable**: YES (different file)

  **References**:
  - `nvim/.config/nvim/lua/options.lua` - Current options
  - Research: Power user options from dotfiles

  **Acceptance Criteria**:
  - [ ] All new options added
  - [ ] `nvim --headless -c 'qa'` exits 0
  - [ ] Global statusline visible (laststatus = 3)

  **Commit**: YES
  - Message: `perf(nvim): add performance options (smoothscroll, splitkeep, etc.)`
  - Files: `nvim/.config/nvim/lua/options.lua`

---

- [x] 6. Optimize editor.lua (treesitter, remove redundant)

  **What to do**:
  - Disable treesitter indent (line 59)
  - Remove mini.comment (Neovim 0.10+ has native gc)
  - Keep mini.indentscope, remove ibl (or vice versa)

  **Changes**:
  
  1. **Treesitter indent** (line 59):
  ```lua
  -- Change from:
  indent = { enable = true },
  -- To:
  indent = { enable = false },  -- Use native indent (TS indent is CPU-heavy)
  ```

  2. **Remove mini.comment** (line 9):
  ```lua
  -- DELETE this line:
  require("mini.comment").setup()
  -- Neovim 0.10+ has native gc/gcc commenting
  ```

  3. **Optional: Remove indent-blankline** (lines 139-151):
  Since you have mini.indentscope, you can remove ibl entirely OR keep ibl and remove mini.indentscope. Recommendation: Keep mini.indentscope (lighter).

  **Must NOT do**:
  - Do NOT remove other mini.* modules
  - Do NOT remove treesitter highlight

  **Parallelizable**: YES (different file)

  **References**:
  - `nvim/.config/nvim/lua/plugins/editor.lua:59` - treesitter indent
  - `nvim/.config/nvim/lua/plugins/editor.lua:9` - mini.comment
  - `nvim/.config/nvim/lua/plugins/editor.lua:139-151` - indent-blankline

  **Acceptance Criteria**:
  - [ ] Treesitter indent disabled
  - [ ] mini.comment removed
  - [ ] `gc` still works (native commenting)
  - [ ] Indent guides still work (mini.indentscope)

  **Commit**: YES
  - Message: `perf(nvim): optimize treesitter and remove redundant plugins`
  - Files: `nvim/.config/nvim/lua/plugins/editor.lua`

---

- [x] 7. Optimize nvim-tree settings

  **What to do**:
  - Disable git highlights (slow in large repos)
  - Change highlight_opened_files from "all" to "none"

  **Current code (ui.lua lines 21-34)**:
  Find and change:
  ```lua
  highlight_git = true,  -- Change to false
  highlight_opened_files = "all",  -- Change to "none"
  ```

  **Must NOT do**:
  - Do NOT change keymaps
  - Do NOT remove nvim-tree

  **Parallelizable**: YES (different file)

  **References**:
  - `nvim/.config/nvim/lua/plugins/ui.lua:21-34` - nvim-tree git config

  **Acceptance Criteria**:
  - [ ] highlight_git = false
  - [ ] highlight_opened_files = "none"
  - [ ] nvim-tree still works
  - [ ] Faster navigation in large repos

  **Commit**: YES
  - Message: `perf(nvim): optimize nvim-tree for large repos`
  - Files: `nvim/.config/nvim/lua/plugins/ui.lua`
