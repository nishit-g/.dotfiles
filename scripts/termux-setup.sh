#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}▶${NC} $1"; }
success() { echo -e "${GREEN}✔${NC} $1"; }
die() { echo -e "${RED}✗${NC} $1" >&2; exit 1; }

info "Updating packages..."
pkg update -y && pkg upgrade -y

info "Installing core tools..."
pkg install -y openssh mosh git fzf tmux neovim zsh curl wget

info "Setting up storage access..."
termux-setup-storage || true

info "Generating SSH key..."
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -C "termux@android" -N "" -f ~/.ssh/id_ed25519
    success "SSH key generated"
    echo ""
    echo "Add this to your Mac's ~/.ssh/authorized_keys:"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
else
    success "SSH key exists"
fi

info "Cloning dotfiles..."
DOTFILES="$HOME/dotfiles"
if [[ ! -d "$DOTFILES" ]]; then
    git clone https://github.com/nishit-g/.dotfiles.git "$DOTFILES"
else
    cd "$DOTFILES" && git pull
fi

info "Setting up dev command..."
mkdir -p ~/bin ~/.config/dev
cp "$DOTFILES/bin/dev" ~/bin/dev
chmod +x ~/bin/dev

if [[ ! -f ~/.config/dev/hosts.toml ]]; then
    cp "$DOTFILES/dev/.config/dev/hosts.toml" ~/.config/dev/hosts.toml
    info "Edit your hosts: dev --edit"
fi

info "Configuring shell..."
if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi

if ! grep -q 'export PATH="$HOME/bin:$PATH"' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
fi

info "Installing Tailscale..."
echo ""
echo "Tailscale for Android: Install from Play Store"
echo "https://play.google.com/store/apps/details?id=com.tailscale.ipn"
echo ""

success "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Install Tailscale app from Play Store"
echo "  2. Login to same Tailscale account as your Mac"
echo "  3. Run: dev --edit"
echo "  4. Add your Mac's Tailscale IP"
echo "  5. Run: dev"
echo ""
echo "Copy your SSH key to Mac:"
echo "  ssh-copy-id user@your-mac-tailscale-ip"
