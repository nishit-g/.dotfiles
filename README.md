# dotfiles

> ChaosMonk's development environment. macOS + Neovim + tmux + zsh + OpenCode.

## Quick Start

```bash
# One-liner install (fresh Mac)
curl -fsSL https://raw.githubusercontent.com/nishit-g/.dotfiles/v2/install.sh | bash

# Or clone and run
git clone git@github.com:nishit-g/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && make install
```

## What's Included

### Shell & Terminal
| Tool | Purpose |
|------|---------|
| **zsh + zinit** | Fast shell with turbo-loaded plugins (~96ms startup) |
| **Alacritty** | GPU-accelerated terminal with Gruvbox theme |
| **tmux + sesh** | Terminal multiplexer with session management |
| **Starship** | Cross-shell prompt (Termux) / p10k (macOS) |

### CLI Tools
| Tool | Replaces |
|------|----------|
| `eza` | `ls` |
| `bat` | `cat` |
| `fd` | `find` |
| `rg` | `grep` |
| `zoxide` | `cd` |
| `delta` | `diff` |
| `atuin` | shell history |
| `yazi` | file manager |

### Neovim (~27ms startup)
- **Plugin Manager**: lazy.nvim with aggressive lazy-loading
- **LSP**: mason + lspconfig (auto-install servers)
- **Completion**: blink.cmp
- **Fuzzy Finder**: fzf-lua
- **Git**: gitsigns + fugitive + diffview
- **Testing**: neotest
- **Debugging**: nvim-dap

### OpenCode (AI Coding Assistant)
- **Agent Framework**: oh-my-opencode with Sisyphus agent
- **Sub-agents**: Oracle, Librarian, Explore, Frontend
- **Models**: Claude, GPT-5, Gemini (configurable)
- **Notifications**: Desktop + mobile (ntfy.sh) + webhook support
- **Custom Plugin**: ChaosMonk notifier with session stats

### macOS
| Tool | Purpose |
|------|---------|
| **Aerospace** | Tiling window manager |
| **Karabiner** | CapsLock → Hyper/Escape |
| **Raycast** | Spotlight replacement |

### Mobile Development (Termux)
```bash
# One-liner Termux setup
curl -fsSL https://raw.githubusercontent.com/nishit-g/.dotfiles/v2/scripts/termux-setup.sh | bash
```

## Structure

```
~/.dotfiles/
├── Makefile           # Installation commands
├── install.sh         # One-liner bootstrap
├── bootstrap.sh       # Full setup script
├── scripts/
│   ├── utils.sh       # Shared utilities
│   ├── macos.sh       # macOS defaults
│   └── termux-setup.sh
├── nvim/.config/nvim/ # Neovim config
├── opencode/.config/opencode/
│   ├── opencode.json        # Main config
│   ├── oh-my-opencode.json  # Agent config
│   ├── notifier.json        # Notification settings
│   ├── skill/               # Custom AI skills
│   └── plugin/              # Custom plugins
├── zsh/               # Zsh config
├── tmux/              # Tmux config
├── git/               # Git config
├── alacritty/         # Terminal config
├── aerospace/         # Window manager
├── karabiner/         # Keyboard remapping
├── sesh/              # Session manager
├── yazi/              # File manager
└── ssh/               # SSH config (template)
```

## Key Bindings

### Neovim

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<C-h/j/k/l>` | Window navigation |
| `<M-h/j/k/l>` | Harpoon slots 1-4 |
| `<C-e>` | Harpoon menu |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>e` | Toggle file tree |
| `gd` | Go to definition |
| `K` | Hover docs |
| `<leader>ca` | Code actions |
| `<leader>mp` | Format |
| `<leader>gd` | Diffview open |
| `<leader>q` | Smart quit |

### tmux

| Key | Action |
|-----|--------|
| `C-a` | Prefix |
| `C-a f` | Session picker (sesh) |
| `C-a h/j/k/l` | Pane navigation |
| `C-a v` | Vertical split |
| `C-a s` | Horizontal split |

### Aerospace

| Key | Action |
|-----|--------|
| `Alt-h/j/k/l` | Focus window |
| `Alt-Shift-h/j/k/l` | Move window |
| `Alt-1/2/3/4` | Switch workspace |

### Karabiner

| Key | Action |
|-----|--------|
| `CapsLock` (tap) | Escape |
| `CapsLock` (hold) | Hyper (Ctrl+Alt+Cmd+Shift) |

## Customization

Machine-specific configs go in `.local` files (gitignored):

```bash
# Copy examples and customize
cp git/.gitconfig.local.example ~/.gitconfig.local
cp zsh/.zshrc.local.example ~/.zshrc.local
cp ssh/.ssh/config.local.example ~/.ssh/config.local
cp opencode/.config/opencode/notifier.local.json.example ~/.config/opencode/notifier.local.json
```

## OpenCode Setup

After installation, OpenCode requires additional setup:

### 1. Install OpenCode
```bash
# Via bun (recommended)
bunx opencode

# Or npm
npx opencode
```

### 2. Authenticate providers
```bash
# The config expects these auth files (not tracked in git):
# ~/.config/opencode/antigravity-accounts.json  (Antigravity OAuth)
```

### 3. Mobile notifications (optional)
Install [ntfy](https://ntfy.sh) app and subscribe to your topic:
```bash
# Default topic (change in notifier.local.json for security)
Topic: chaosmonk-oc

# For private notifications, set auth in notifier.local.json:
{
  "ntfy": {
    "topic": "your-secret-topic",
    "auth": {
      "enabled": true,
      "username": "your-username",
      "password": "your-password"
    }
  }
}
```

### 4. Notification events
| Event | Notification |
|-------|--------------|
| Session complete | ✅ Project + duration + stats |
| Error | ❌ Error message |
| Permission needed | ⚠️ Tool requesting permission |
| Question (>30s) | ❓ AI has a question |

## Make Commands

```bash
make install   # Full installation
make link      # Symlink configs only
make unlink    # Remove symlinks
make update    # Update everything
make brew      # Install Homebrew packages
make apps      # Install GUI apps
make macos     # Apply macOS defaults
make clean     # Remove broken symlinks
```

## Requirements

- macOS 13+ (Ventura or later)
- Xcode Command Line Tools
- ~2GB disk space

## Performance

| Metric | Time |
|--------|------|
| Shell startup | ~96ms |
| Neovim startup | ~27ms |

## The Stack

```
Phone (Termux) ──► Tailscale VPN ──► Mac
                        │
                        ▼
              ┌─────────────────┐
              │  Alacritty      │
              │  (96ms zsh)     │
              └────────┬────────┘
                       │
              ┌────────▼────────┐
              │  tmux + sesh    │
              └────────┬────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
         ▼                           ▼
   ┌──────────┐               ┌──────────┐
   │  Neovim  │◄─────────────►│ OpenCode │
   │  (27ms)  │               │   (AI)   │
   └──────────┘               └──────────┘
```

## License

MIT
