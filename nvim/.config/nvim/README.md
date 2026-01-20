# Neovim Configuration

A modern, modular, and feature-rich Neovim configuration designed for speed and productivity.

## Features

- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP**: Native LSP with [Mason](https://github.com/williamboman/mason.nvim) for easy installation.
- **Completion**: [blink.cmp](https://github.com/saghen/blink.cmp) for blazing fast completion.
- **Formatting**: [conform.nvim](https://github.com/stevearc/conform.nvim)
- **Linting**: [nvim-lint](https://github.com/mfussenegger/nvim-lint)
- **Debugging**: [nvim-dap](https://github.com/mfussenegger/nvim-dap) with UI.
- **Testing**: [neotest](https://github.com/nvim-neotest/neotest)
- **Navigation**: [Harpoon](https://github.com/ThePrimeagen/harpoon) and [Telescope](https://github.com/nvim-telescope/telescope.nvim) (via fzf-lua).
- **UI**: [Noice](https://github.com/folke/noice.nvim), [Lualine](https://github.com/nvim-lualine/lualine.nvim), [Dashboard](https://github.com/nvimdev/dashboard-nvim).
- **Git**: [Gitsigns](https://github.com/lewis6991/gitsigns.nvim) and [Fugitive](https://github.com/tpope/vim-fugitive).

## Installation

1.  Backup your existing configuration:
    ```bash
    mv ~/.config/nvim ~/.config/nvim.bak
    mv ~/.local/share/nvim ~/.local/share/nvim.bak
    ```
2.  Clone this repository:
    ```bash
    git clone <your-repo-url> ~/.config/nvim
    ```
3.  Start Neovim:
    ```bash
    nvim
    ```

## Keymaps Cheat Sheet

### General
- `<Space>`: Leader key
- `<leader>w`: Save file
- `<leader>q`: Quit buffer
- `<leader>e`: Toggle File Explorer
- `<leader>y`: Yank to system clipboard

### Navigation
- `<C-h/j/k/l>`: Navigate between windows (or Harpoon files if configured)
- `<leader>ff`: Find files
- `<leader>fg`: Live grep
- `<leader>a`: Add file to Harpoon
- `<C-e>`: Toggle Harpoon menu

### Window Management
- `<leader>w-`: Split horizontal
- `<leader>w|`: Split vertical
- `<leader>wd`: Close window
- `<leader>ww`: Switch window

### LSP & Coding
- `gd`: Go to definition
- `gr`: Go to references
- `K`: Hover documentation
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action
- `<leader>mp`: Format file

### Debugging
- `<leader>db`: Toggle breakpoint
- `<leader>dc`: Continue
- `<leader>du`: Toggle Debug UI

### Testing
- `<leader>tt`: Run nearest test
- `<leader>tf`: Run file

## Customization

- **Plugins**: Add new plugins in `lua/plugins/`.
- **Keymaps**: Edit `lua/keymaps.lua`.
- **Options**: Edit `lua/options.lua`.
