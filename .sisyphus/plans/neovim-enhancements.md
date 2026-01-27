# Neovim Enhancements: Performance + Snacks.nvim + Keybindings

## Context

### Original Request
User wants to:
1. Add `vim.loader.enable()` for free startup performance gain
2. Add `snacks.nvim` (folke's new all-in-one plugin)
3. Change `<leader>x` to close buffer (smart close)
4. Change file explorer toggle from `<leader>e` to `<C-n>`

### Current State
- `init.lua`: Missing `vim.loader.enable()` at top
- `ui.lua`: nvim-tree uses `<leader>e` for toggle
- `keymaps.lua`: Has `<C-x>` for buffer close, but not `<leader>x`
- No snacks.nvim installed

---

## Work Objectives

### Core Objective
Enhance Neovim config with performance optimization, modern plugin (snacks.nvim), and improved keybindings.

### Concrete Deliverables
- `init.lua` with `vim.loader.enable()` at top
- New `lua/plugins/snacks.lua` with snacks.nvim configuration
- Updated keymaps: `<leader>x` closes buffer, `<C-n>` toggles file explorer

### Definition of Done
- [x] Neovim starts without errors
- [x] `:Lazy` shows snacks.nvim loaded
- [x] `<C-n>` opens/closes file explorer
- [x] `<leader>x` closes current buffer
- [x] Startup time improved (check with dashboard footer)

### Must Have
- vim.loader.enable() at very top of init.lua
- snacks.nvim with dashboard, notifier, terminal enabled
- `<leader>x` for buffer close
- `<C-n>` for file explorer toggle

### Must NOT Have (Guardrails)
- Do NOT remove existing functionality
- Do NOT break lazy loading
- Do NOT duplicate keymaps (remove old ones when adding new)
- Do NOT enable snacks features that conflict with existing plugins (e.g., keep indent disabled since mini.indentscope exists)

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: Manual testing
- **User wants tests**: Manual verification
- **QA approach**: Launch Neovim, verify keybindings and plugin loading

---

## TODOs

- [x] 1. Add vim.loader.enable() to init.lua

  **What to do**:
  - Add bytecode caching at the VERY TOP of `init.lua` (before any requires)
  - Use conditional check for compatibility

  **Code to add at line 1**:
  ```lua
  -- Enable bytecode caching for faster startup
  if vim.loader then
    vim.loader.enable()
  end
  ```

  **Must NOT do**:
  - Do NOT place after any `require()` calls
  - Do NOT remove existing code

  **Parallelizable**: YES (with 2, 3)

  **References**:
  - `nvim/.config/nvim/init.lua` - Current file, add at top before line 1

  **Acceptance Criteria**:
  - [ ] `init.lua` starts with `vim.loader.enable()` block
  - [ ] Neovim starts without errors: `nvim --headless -c 'qa'` exits 0
  - [ ] Check enabled: `:lua print(vim.loader.enabled)` returns `true`

  **Commit**: YES
  - Message: `feat(nvim): enable vim.loader for faster startup`
  - Files: `nvim/.config/nvim/init.lua`

---

- [x] 2. Create snacks.nvim plugin configuration

  **What to do**:
  - Create new file `lua/plugins/snacks.lua`
  - Configure snacks.nvim with useful features
  - Keep dashboard disabled (existing dashboard-nvim is customized)
  - Keep indent disabled (mini.indentscope exists)
  - Enable: notifier, terminal, scratch, quickfile, statuscolumn, words

  **File to create**: `nvim/.config/nvim/lua/plugins/snacks.lua`

  **Content**:
  ```lua
  return {
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {
        -- Disable features that conflict with existing plugins
        dashboard = { enabled = false },  -- Using dashboard-nvim
        indent = { enabled = false },      -- Using mini.indentscope
        
        -- Enable useful features
        notifier = { enabled = true },     -- Better notifications
        quickfile = { enabled = true },    -- Fast file opening
        statuscolumn = { enabled = true }, -- Better status column
        words = { enabled = true },        -- Word highlighting
        scratch = { enabled = true },      -- Scratch buffers
        terminal = { enabled = true },     -- Terminal improvements
        
        -- Git browse (open in browser)
        gitbrowse = { enabled = true },
      },
      keys = {
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
        { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
        { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      },
    },
  }
  ```

  **Must NOT do**:
  - Do NOT enable dashboard (conflicts with dashboard-nvim)
  - Do NOT enable indent (conflicts with mini.indentscope)
  - Do NOT enable scope (conflicts with mini.indentscope)

  **Parallelizable**: YES (with 1, 3)

  **References**:
  - `nvim/.config/nvim/lua/plugins/` - Plugin directory pattern
  - `nvim/.config/nvim/lua/plugins/editor.lua` - Example plugin structure

  **Acceptance Criteria**:
  - [ ] File exists: `nvim/.config/nvim/lua/plugins/snacks.lua`
  - [ ] Neovim starts without errors
  - [ ] `:Lazy` shows `snacks.nvim` as loaded
  - [ ] `<leader>.` opens scratch buffer
  - [ ] `<leader>n` shows notification history

  **Commit**: YES
  - Message: `feat(nvim): add snacks.nvim for enhanced UX`
  - Files: `nvim/.config/nvim/lua/plugins/snacks.lua`

---

- [x] 3. Update keybindings: leader+x and Ctrl+n

  **What to do**:
  - In `keymaps.lua`: Add `<leader>x` mapping for buffer close (same function as `<C-x>`)
  - In `ui.lua`: Change nvim-tree toggle from `<leader>e` to `<C-n>`

  **Changes in keymaps.lua** (add after the `<C-x>` mapping around line 100):
  ```lua
  map("n", "<leader>x", function()
    local ok, bufremove = pcall(require, "mini.bufremove")
    if ok then
      bufremove.delete(0, false)
    else
      vim.cmd("bdelete")
    end
  end, { silent = true, desc = "Close buffer" })
  ```

  **Changes in ui.lua** (line 9-12):
  Change:
  ```lua
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
    { "<leader>E", "<cmd>NvimTreeFocus<CR>", desc = "Focus NvimTree" },
  },
  ```
  To:
  ```lua
  keys = {
    { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
    { "<leader>E", "<cmd>NvimTreeFocus<CR>", desc = "Focus NvimTree" },
  },
  ```

  **Must NOT do**:
  - Do NOT remove `<C-x>` mapping (keep both)
  - Do NOT remove `<leader>E` mapping

  **Parallelizable**: YES (with 1, 2)

  **References**:
  - `nvim/.config/nvim/lua/keymaps.lua:93-100` - Existing `<C-x>` buffer close pattern
  - `nvim/.config/nvim/lua/plugins/ui.lua:9-12` - nvim-tree keys config

  **Acceptance Criteria**:
  - [ ] `<leader>x` closes current buffer
  - [ ] `<C-n>` toggles nvim-tree
  - [ ] `<C-x>` still works for buffer close
  - [ ] `<leader>E` still focuses nvim-tree
  - [ ] `:map <leader>x` shows the mapping

  **Commit**: YES
  - Message: `feat(nvim): improve keybindings - leader+x close, C-n explorer`
  - Files: `nvim/.config/nvim/lua/keymaps.lua`, `nvim/.config/nvim/lua/plugins/ui.lua`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `feat(nvim): enable vim.loader for faster startup` | init.lua | nvim --headless -c 'qa' |
| 2 | `feat(nvim): add snacks.nvim for enhanced UX` | lua/plugins/snacks.lua | :Lazy shows loaded |
| 3 | `feat(nvim): improve keybindings - leader+x close, C-n explorer` | keymaps.lua, ui.lua | Test keys work |

---

## Success Criteria

### Verification Commands
```bash
# Test Neovim starts without errors
nvim --headless -c 'qa'

# Check vim.loader is enabled
nvim --headless -c 'lua print(vim.loader.enabled)' -c 'qa'
```

### Manual Verification
1. Open Neovim: `nvim`
2. Press `<C-n>` - File explorer should toggle
3. Open a file, press `<leader>x` - Buffer should close
4. Press `<leader>.` - Scratch buffer should open
5. Press `<leader>n` - Notification history should show
6. Check dashboard footer for startup time (should be faster)

### Final Checklist
- [x] vim.loader.enable() at top of init.lua
- [x] snacks.nvim installed and configured
- [x] `<leader>x` closes buffer
- [x] `<C-n>` toggles file explorer
- [x] No errors on startup
- [x] All existing functionality preserved
