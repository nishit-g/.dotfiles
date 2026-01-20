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
├── bin/          # Custom scripts (dev command)
├── dev/          # Dev connection manager config
├── git/          # Global git config & ignore
├── karabiner/    # Karabiner-Elements JSON
├── mise/         # Runtime manager (mise) config
├── nvim/         # Neovim (LazyVim) setup
├── scripts/      # Setup scripts (termux, macos, ssh)
├── sesh/         # Sesh session manager config
├── ssh/          # SSH client config
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

## Mobile Development (Android/Termux)

Access your Mac dev environment from anywhere using your phone.

### Stack

| Tool | Purpose |
| :--- | :--- |
| **Tailscale** | Zero-config VPN mesh (WireGuard) |
| **Mosh** | Mobile-resilient SSH (survives network switches) |
| **dev** | fzf-powered connection manager |

### Setup (Termux)

```bash
curl -sL https://raw.githubusercontent.com/nishit-g/dotfiles/v2/scripts/termux-setup.sh | bash
```

### Setup (Mac - Enable SSH)

```bash
# Enable Remote Login
sudo systemsetup -setremotelogin on

# Run hardening guide
./scripts/mac-ssh-harden.sh
```

### Usage

```bash
# Interactive picker
dev

# Direct connect
dev mac-home

# Edit hosts
dev --edit
```

### Host Configuration

Edit `~/.config/dev/hosts.toml`:

```toml
[hosts.mac-home]
host = "100.x.x.x"  # Tailscale IP
user = "your-username"
desc = "MacBook via Tailscale"
mosh = true
```

### Workflow

1. Install **Tailscale** on both Mac and Android (Play Store)
2. Login to same Tailscale account
3. Get Mac's Tailscale IP: `tailscale ip -4`
4. Add to `hosts.toml`
5. Copy SSH key: `ssh-copy-id user@100.x.x.x`
6. Run `dev` → pick session → you're in

### Bidirectional: Mac → Android

You can also SSH from Mac into your Android:

**On Termux (Android):**
```bash
pkg install openssh -y
sshd                           # Start SSH server
whoami                         # Note your username (e.g., u0_a521)

# Add Mac's public key
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "YOUR_MAC_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Auto-start sshd (optional)
sv-enable sshd
```

**On Mac, add to `~/.config/dev/hosts.toml`:**
```toml
[hosts.android]
host = "100.x.x.x"    # Android's Tailscale IP
user = "u0_aXXX"      # From 'whoami' in Termux
port = 8022
desc = "Android via Tailscale"
mosh = false
```

Then: `dev android`

### Troubleshooting

| Issue | Fix |
| :--- | :--- |
| Tailscale not connecting | Disable battery optimization for Tailscale on Android |
| SSH permission denied | Check `~/.ssh/authorized_keys` permissions (600) |
| Mosh not found | Install mosh: `brew install mosh` (Mac) or `pkg install mosh` (Termux) |
| sshd not running | Run `sshd` in Termux, or `sv-enable sshd` for auto-start |
