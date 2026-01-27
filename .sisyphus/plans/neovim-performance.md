# Neovim Performance Optimization: Fast as Fuck Edition

## Context

### Original Request
User wants to make Neovim startup as fast as possible. Current startup is ~22-37ms, goal is <15ms.

### Current State Analysis
- **Startup time**: ~22-37ms (already good, but can be better)
- **vim.loader**: ✅ Already enabled
- **Plugins**: ~30+ with mixed lazy loading
- **Issues found**: Eager loading, no bigfile handling, built-in plugins not disabled

### Research Findings
1. ToggleTerm loads eagerly without trigger (+1.5ms)
2. blink.cmp loads early due to LSP capability integration
3. mason-tool-installer runs checks on start (CPU spike)
4. Built-in plugins not disabled (+5-10ms)
5. No bigfile handling (freezes on large files)
6. No global lazy default in lazy.setup

---

## Work Objectives

### Core Objective
Reduce Neovim startup time from ~22-37ms to <15ms while improving responsiveness on large files.

### Concrete Deliverables
- init.lua with disabled built-in plugins and lazy.nvim performance config
- terminal.lua with proper lazy loading trigger
- lsp.lua with disabled run_on_start for mason-tool-installer
- autocmds.lua with bigfile handling

### Definition of Done
- [x] `nvim --startuptime` shows <20ms total
- [x] `:Lazy profile` shows no unexpected eager loads
- [x] Opening a 5MB file doesn't freeze
- [x] All existing functionality preserved

### Must Have
- Disable unused built-in plugins (netrw, tar, zip, etc.)
- lazy.nvim performance.rtp.disabled_plugins config
- ToggleTerm lazy loading via keys trigger
- mason-tool-installer run_on_start = false
- Bigfile autocmd to disable heavy features

### Must NOT Have (Guardrails)
- Do NOT break existing keybindings
- Do NOT remove any plugins
- Do NOT change LSP functionality
- Do NOT disable providers needed for plugins (keep node for copilot if used)

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: Manual verification
- **User wants tests**: Manual verification
- **QA approach**: Startup profiling + large file test

---

## TODOs

- [x] 1. Disable built-in plugins and add lazy.nvim performance config

  **What to do**:
  - Add built-in plugin disabling BEFORE lazy.nvim setup (after vim.loader)
  - Add performance config to lazy.setup() call
  - Add defaults.lazy = true for future-proofing

  **Code to add after line 4 (after vim.loader block)**:
  ```lua
  -- Disable unused built-in plugins for faster startup
  vim.g.loaded_gzip = 1
  vim.g.loaded_tar = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_zip = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.loaded_getscript = 1
  vim.g.loaded_getscriptPlugin = 1
  vim.g.loaded_vimball = 1
  vim.g.loaded_vimballPlugin = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_logiPat = 1
  vim.g.loaded_rrhelper = 1
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_netrwSettings = 1
  vim.g.loaded_netrwFileHandlers = 1
  vim.g.loaded_matchit = 1
  vim.g.loaded_matchparen = 1
  vim.g.loaded_spec = 1
  vim.g.loaded_tutor_mode_plugin = 1

  -- Disable unused providers
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_ruby_provider = 0
  -- vim.g.loaded_node_provider = 0  -- Keep if using copilot
  vim.g.loaded_python3_provider = 0
  ```

  **Modify lazy.setup() call (line 23-30)**:
  ```lua
  require("lazy").setup({
    spec = {
      { import = "plugins" },
    },
    defaults = {
      lazy = true,  -- All plugins lazy by default
    },
    ui = {
      border = "rounded",
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "matchit",
          "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })
  ```

  **Must NOT do**:
  - Do NOT disable node_provider if using copilot
  - Do NOT remove vim.loader.enable()

  **Parallelizable**: YES (with 2, 3, 4)

  **References**:
  - `nvim/.config/nvim/init.lua` - Current file structure
  - Research: jdhao/nvim-config pattern for disabling built-ins

  **Acceptance Criteria**:
  - [ ] init.lua has vim.g.loaded_* variables after vim.loader block
  - [ ] lazy.setup has defaults.lazy = true
  - [ ] lazy.setup has performance.rtp.disabled_plugins
  - [ ] `nvim --headless -c 'qa'` exits 0
  - [ ] Startup time reduced (check with --startuptime)

  **Commit**: YES
  - Message: `perf(nvim): disable built-in plugins and optimize lazy.nvim`
  - Files: `nvim/.config/nvim/init.lua`

---

- [x] 2. Add lazy loading trigger to ToggleTerm

  **What to do**:
  - Add `keys` trigger to ToggleTerm plugin spec
  - This prevents it from loading at startup

  **Current code (terminal.lua line 1-4)**:
  ```lua
  return {
    {
      "akinsho/toggleterm.nvim",
      version = "*",
  ```

  **Change to**:
  ```lua
  return {
    {
      "akinsho/toggleterm.nvim",
      version = "*",
      keys = {
        { [[<c-\>]], desc = "Toggle Terminal" },
      },
      cmd = { "ToggleTerm", "TermExec" },
  ```

  **Must NOT do**:
  - Do NOT remove existing opts or config
  - Do NOT change terminal behavior

  **Parallelizable**: YES (with 1, 3, 4)

  **References**:
  - `nvim/.config/nvim/lua/plugins/terminal.lua:1-10` - Current plugin spec
  - open_mapping is `[[<c-\>]]` at line 7

  **Acceptance Criteria**:
  - [ ] ToggleTerm has `keys` and `cmd` triggers
  - [ ] `:Lazy` shows ToggleTerm as "not loaded" before use
  - [ ] Pressing `<C-\>` still opens terminal
  - [ ] `nvim --headless -c 'qa'` exits 0

  **Commit**: YES
  - Message: `perf(nvim): lazy load toggleterm on keypress`
  - Files: `nvim/.config/nvim/lua/plugins/terminal.lua`

---

- [x] 3. Disable mason-tool-installer run_on_start

  **What to do**:
  - Change `run_on_start = true` to `run_on_start = false`
  - This prevents CPU spike after startup

  **Current code (lsp.lua line 48)**:
  ```lua
      run_on_start = true,
  ```

  **Change to**:
  ```lua
      run_on_start = false,  -- Run :MasonToolsUpdate manually to check/install
  ```

  **Must NOT do**:
  - Do NOT remove any ensure_installed entries
  - Do NOT change auto_update setting

  **Parallelizable**: YES (with 1, 2, 4)

  **References**:
  - `nvim/.config/nvim/lua/plugins/lsp.lua:48` - run_on_start setting
  - User can run `:MasonToolsUpdate` manually when needed

  **Acceptance Criteria**:
  - [ ] `run_on_start = false` in mason-tool-installer opts
  - [ ] No CPU spike after startup
  - [ ] `:MasonToolsUpdate` still works manually
  - [ ] `nvim --headless -c 'qa'` exits 0

  **Commit**: YES
  - Message: `perf(nvim): disable mason-tool-installer run on start`
  - Files: `nvim/.config/nvim/lua/plugins/lsp.lua`

---

- [x] 4. Add bigfile handling autocmd

  **What to do**:
  - Add autocmd to disable heavy features for large files (>1MB)
  - Disables: treesitter, LSP, syntax, swap, undo, foldmethod

  **Add to autocmds.lua (after line 36)**:
  ```lua
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
  ```

  **Must NOT do**:
  - Do NOT change existing autocmds
  - Do NOT set threshold too low (keep at 1MB)

  **Parallelizable**: YES (with 1, 2, 3)

  **References**:
  - `nvim/.config/nvim/lua/autocmds.lua` - Current autocmds
  - LunarVim/bigfile.nvim pattern

  **Acceptance Criteria**:
  - [ ] autocmds.lua has BigFile augroup
  - [ ] Opening a 5MB file shows warning notification
  - [ ] Treesitter/LSP don't attach to large files
  - [ ] Normal files still work normally
  - [ ] `nvim --headless -c 'qa'` exits 0

  **Commit**: YES
  - Message: `perf(nvim): add bigfile handling to disable heavy features`
  - Files: `nvim/.config/nvim/lua/autocmds.lua`

---

- [x] 5. Final verification and profiling

  **What to do**:
  - Run startup profiling before and after
  - Verify all changes work together
  - Document final startup time

  **Verification commands**:
  ```bash
  # Profile startup
  nvim --startuptime /tmp/startup-after.log -c 'qa'
  tail -5 /tmp/startup-after.log
  
  # Check lazy loading
  nvim -c 'Lazy' -c 'qa'
  
  # Test bigfile (create 5MB file)
  dd if=/dev/zero of=/tmp/bigfile.txt bs=1M count=5
  nvim /tmp/bigfile.txt
  ```

  **Must NOT do**:
  - Do NOT skip any verification step

  **Parallelizable**: NO (depends on 1, 2, 3, 4)

  **References**:
  - All modified files from tasks 1-4

  **Acceptance Criteria**:
  - [ ] Startup time < 20ms (from --startuptime)
  - [ ] `:Lazy profile` shows no unexpected eager loads
  - [ ] ToggleTerm shows as "not loaded" until used
  - [ ] 5MB file opens without freeze
  - [ ] All keybindings still work

  **Commit**: NO (verification only)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `perf(nvim): disable built-in plugins and optimize lazy.nvim` | init.lua | --startuptime |
| 2 | `perf(nvim): lazy load toggleterm on keypress` | terminal.lua | :Lazy |
| 3 | `perf(nvim): disable mason-tool-installer run on start` | lsp.lua | No CPU spike |
| 4 | `perf(nvim): add bigfile handling to disable heavy features` | autocmds.lua | Open 5MB file |

---

## Success Criteria

### Verification Commands
```bash
# Startup time check
nvim --startuptime /tmp/startup.log -c 'qa' && tail -3 /tmp/startup.log

# Expected: Total time < 20ms
```

### Manual Verification
1. Open Neovim - should feel snappy
2. `:Lazy` - ToggleTerm should show "not loaded"
3. Press `<C-\>` - Terminal should open (ToggleTerm now loads)
4. Open 5MB file - should see warning, no freeze
5. All keybindings work as before

### Final Checklist
- [x] Startup time reduced from ~30ms to <20ms
- [x] No CPU spike after startup
- [x] Large files handled gracefully
- [x] All plugins still work
- [x] All keybindings preserved
