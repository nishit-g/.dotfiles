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
REPO_URL="https://github.com/nishit-g/dotfiles.git"
BRANCH="v2"

if [[ ! -d "$DOTFILES" ]]; then
    git clone -b "$BRANCH" "$REPO_URL" "$DOTFILES"
else
    cd "$DOTFILES" && git pull origin "$BRANCH"
fi

info "Setting up dev command..."
mkdir -p ~/bin ~/.config/dev
cp "$DOTFILES/bin/bin/dev" ~/bin/dev
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
echo "========================================="
echo "        NEXT STEPS (do these now)"
echo "========================================="
echo ""
echo "1. Install Tailscale from Play Store:"
echo "   https://play.google.com/store/apps/details?id=com.tailscale.ipn"
echo ""
echo "2. Login with SAME account as your Mac"
echo ""
echo "3. Copy SSH key to your Mac:"
echo "   ssh-copy-id nishit.gupta@YOUR_MAC_TAILSCALE_IP"
echo ""
echo "4. Edit hosts config:"
echo "   dev --edit"
echo "   (replace 100.x.x.x with your Mac's Tailscale IP)"
echo ""
echo "5. Connect:"
echo "   dev"
echo ""
echo "========================================="
echo "Your SSH public key (copy this if needed):"
echo "========================================="
cat ~/.ssh/id_ed25519.pub 2>/dev/null || echo "(no key found)"
echo ""
