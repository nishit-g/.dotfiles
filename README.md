# .dotfiles

An enterprise-grade macOS development environment optimized for performance, productivity, and aesthetics.

## Quick Start

Experience the full setup with a single command:

```bash
curl -sL https://raw.githubusercontent.com/nishit-gupta/dotfiles/v2/install.sh | bash
```

## Features

- **Blazing Fast Shell**: Zsh with `zinit` turbo-loading, achieving ~80ms startup time.
- **Tiling Window Management**: `Aerospace` for a keyboard-driven workflow.
- **Session Management**: `tmux` paired with `sesh` for seamless project switching.
- **Modern CLI Stack**: Rust-powered tools (`eza`, `bat`, `fd`, `ripgrep`, `zoxide`).
- **Smart History**: `Atuin` for fuzzy-searchable, synchronized shell history.
- **Advanced Editor**: `Neovim` (LazyVim) configured for high-performance coding.
- **Keyboard Optimization**: `Karabiner` mapping CapsLock to Hyper/Escape.

## Tool Stack

| Tool | Purpose | Config Location |
| :--- | :--- | :--- |
| **Alacritty** | GPU-accelerated terminal | `alacritty/.config/alacritty/` |
| **Aerospace** | Tiling window manager | `aerospace/.config/aerospace/` |
| **Zsh** | Interactive shell | `zsh/.zshrc` |
| **Tmux** | Terminal multiplexer | `tmux/.tmux.conf` |
| **Neovim** | Text editor | `nvim/.config/nvim/` |
| **Sesh** | Session manager | `sesh/.config/sesh/` |
| **Atuin** | Shell history | `atuin/.config/atuin/` |
| **Yazi** | Terminal file manager | `yazi/.config/yazi/` |
| **Mise** | Runtime manager | `mise/.config/mise/` |
| **Karabiner** | Keyboard customizer | `karabiner/.config/karabiner/` |

## Keybindings

### Aerospace (Window Management)

| Binding | Action |
| :--- | :--- |
| `Alt + 1-4` | Switch to workspace 1-4 |
| `Alt + Shift + 1-4` | Move window to workspace 1-4 |
| `Alt + H/J/K/L` | Focus window Left/Down/Up/Right |
| `Alt + Shift + H/J/K/L` | Move window Left/Down/Up/Right |
| `Alt + Enter` | Open Alacritty |
| `Alt + F` | Toggle Fullscreen |
| `Alt + T` | Toggle Floating/Tiling |
| `Alt + Q` | Close focused window |
| `Alt + R` | Enter Resize Mode (Esc to exit) |

### Tmux

| Binding | Action |
| :--- | :--- |
| `Ctrl + A` | Prefix key |
| `Prefix + |` | Split window horizontally |
| `Prefix + -` | Split window vertically |
| `Prefix + H/J/K/L` | Select pane Left/Down/Up/Right |
| `Prefix + F` | Launch `sesh` session picker |
| `Prefix + L` | Switch to last session |
| `Prefix + Tab` | Switch to last window |

### Shell & CLI

| Binding | Action |
| :--- | :--- |
| `Ctrl + F` | `sesh` session picker (Zsh) |
| `Ctrl + R` | `Atuin` history search |
| `y` | Launch `Yazi` (with CWD sync) |
| `nv` | Alias for `nvim` |
| `lg` | Alias for `lazygit` |
| `c` | Alias for `zoxide` (z) |

### Karabiner (Physical)

- **CapsLock (Hold)**: `Hyper` (Cmd + Opt + Ctrl + Shift)
- **CapsLock (Tap)**: `Escape`

## Directory Structure

```text
.
├── aerospace/    # Aerospace WM config
├── alacritty/    # Terminal emulator settings
├── atuin/        # Shell history config
├── bat/          # bat (cat clone) themes & config
├── git/          # Global git config & ignore
├── karabiner/    # Karabiner-Elements JSON
├── mise/         # Runtime manager (mise) config
├── nvim/         # Neovim (LazyVim) setup
├── scripts/      # Maintenance & macOS default scripts
├── sesh/         # Sesh session manager config
├── tmux/         # Tmux configuration
├── yazi/         # Yazi file manager config
└── zsh/          # Zsh aliases, functions, & plugins
```

## Maintenance Commands

Managed via `Makefile`:

| Command | Description |
| :--- | :--- |
| `make install` | Full installation (brew + apps + link + macos) |
| `make update` | Pull latest changes and reinstall |
| `make link` | Symlink configurations using `stow` |
| `make unlink` | Remove symlinks |
| `make brew` | Install Homebrew formulae |
| `make apps` | Install GUI applications (Casks) |
| `make macos` | Apply macOS system defaults |

## Customization

Keep your local changes separate:

- **Zsh**: Add custom settings to `~/.zshrc.local`
- **P10K**: Configure the prompt in `~/.p10k.zsh`
- **Git**: Personal identities should go in `~/.gitconfig` or a local include

## Requirements

- **Operating System**: macOS (Intel or Apple Silicon)
- **Permissions**: Accessibility access for Aerospace and Karabiner-Elements

## Post-Installation

1. **Restart Terminal**: Source your new `.zshrc`.
2. **Permissions**: Go to `System Settings → Privacy & Security → Accessibility` and enable **Aerospace** and **Karabiner-Elements**.
3. **Raycast**: Open Raycast and set `Cmd + Space` as the global hotkey.
4. **Font**: Ensure **JetBrainsMono Nerd Font** is installed (handled by brew).
5. **Prompt**: Run `p10k configure` if the prompt looks broken.
