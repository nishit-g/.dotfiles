#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# === Termux Powerhouse Bootstrap ===
# One-command setup for enterprise-grade mobile dev environment
#
# Usage: curl -fsSL https://raw.githubusercontent.com/nishit-g/.dotfiles/v2/scripts/termux-setup.sh | bash

readonly DOTFILES_REPO="https://github.com/nishit-g/.dotfiles.git"
readonly DOTFILES_DIR="$HOME/dotfiles"
readonly DOTFILES_BRANCH="v2"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
die()     { error "$*"; exit 1; }

check_termux() {
    [[ -d "/data/data/com.termux" ]] || die "This script must run in Termux"
    info "Termux environment detected"
}

setup_storage() {
    if [[ ! -d "$HOME/storage" ]]; then
        info "Setting up storage access..."
        termux-setup-storage
        sleep 2
        success "Storage access granted"
    else
        success "Storage already configured"
    fi
}

update_packages() {
    info "Updating package repositories..."
    pkg update -y
    pkg upgrade -y
    success "Packages updated"
}

install_packages() {
    info "Installing core packages..."
    
    local packages=(
        # Shell & Terminal
        zsh
        tmux
        openssh
        mosh
        
        # Editors
        neovim
        
        # Git & Version Control
        git
        git-delta
        
        # Modern CLI Tools
        fzf
        bat
        eza
        fd
        ripgrep
        zoxide
        jq
        yq
        
        # Network & Utils
        curl
        wget
        rsync
        tree
        htop
        
        # Termux APIs
        termux-api
        termux-tools
        
        # Build Tools (for some packages)
        make
        clang
        
        # Python (for misc scripts)
        python
    )
    
    pkg install -y "${packages[@]}"
    success "Core packages installed"
}

install_starship() {
    if ! command -v starship >/dev/null 2>&1; then
        info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$PREFIX/bin"
        success "Starship installed"
    else
        success "Starship already installed"
    fi
}

install_lazygit() {
    if ! command -v lazygit >/dev/null 2>&1; then
        info "Installing lazygit..."
        pkg install -y lazygit 2>/dev/null || {
            warn "lazygit not in pkg, skipping (optional)"
        }
    else
        success "lazygit already installed"
    fi
}

clone_dotfiles() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        info "Updating existing dotfiles..."
        cd "$DOTFILES_DIR"
        git fetch origin
        git checkout "$DOTFILES_BRANCH" 2>/dev/null || git checkout -b "$DOTFILES_BRANCH" "origin/$DOTFILES_BRANCH"
        git pull --rebase origin "$DOTFILES_BRANCH"
        success "Dotfiles updated"
    else
        info "Cloning dotfiles..."
        git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
        success "Dotfiles cloned"
    fi
}

setup_termux_config() {
    info "Setting up Termux configuration..."
    
    local termux_dir="$HOME/.termux"
    mkdir -p "$termux_dir"
    
    # Copy Termux config files
    local src_termux="$DOTFILES_DIR/termux/.termux"
    if [[ -d "$src_termux" ]]; then
        cp -f "$src_termux/termux.properties" "$termux_dir/" 2>/dev/null || true
        cp -f "$src_termux/colors.properties" "$termux_dir/" 2>/dev/null || true
    fi
    
    # Download JetBrainsMono Nerd Font
    if [[ ! -f "$termux_dir/font.ttf" ]]; then
        info "Downloading JetBrainsMono Nerd Font..."
        curl -fsSL -o "$termux_dir/font.ttf" \
            "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
    fi
    
    success "Termux config installed"
}

setup_shortcuts() {
    info "Setting up Termux:Widget shortcuts..."
    
    local shortcuts_dir="$HOME/.shortcuts"
    local tasks_dir="$HOME/.shortcuts/tasks"
    mkdir -p "$shortcuts_dir" "$tasks_dir"
    
    local src_shortcuts="$DOTFILES_DIR/termux/.shortcuts"
    if [[ -d "$src_shortcuts" ]]; then
        # Copy regular shortcuts
        for file in "$src_shortcuts"/*; do
            [[ -f "$file" ]] && cp -f "$file" "$shortcuts_dir/"
        done
        
        # Copy background tasks
        if [[ -d "$src_shortcuts/tasks" ]]; then
            for file in "$src_shortcuts/tasks"/*; do
                [[ -f "$file" ]] && cp -f "$file" "$tasks_dir/"
            done
        fi
        
        # Make all scripts executable
        chmod +x "$shortcuts_dir"/* 2>/dev/null || true
        chmod +x "$tasks_dir"/* 2>/dev/null || true
    fi
    
    success "Shortcuts installed"
}

setup_bin() {
    info "Setting up ~/bin..."
    
    mkdir -p "$HOME/bin"
    
    # Copy dev script
    local dev_src="$DOTFILES_DIR/bin/bin/dev"
    if [[ -f "$dev_src" ]]; then
        cp -f "$dev_src" "$HOME/bin/dev"
        chmod +x "$HOME/bin/dev"
    fi
    
    success "~/bin configured"
}

setup_zsh() {
    info "Setting up ZSH..."
    
    # Create .zshrc that sources our termux config
    cat > "$HOME/.zshrc" << 'EOF'
# Termux ZSH Config - Powerhouse Edition
# This file sources the modular termux zshrc

# Load termux-specific config
TERMUX_ZSHRC="$HOME/dotfiles/termux/.zshrc.termux"
[[ -f "$TERMUX_ZSHRC" ]] && source "$TERMUX_ZSHRC"

# Local overrides (not in git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
EOF
    
    # Set ZSH as default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s zsh
    fi
    
    success "ZSH configured"
}

setup_starship_config() {
    info "Setting up Starship config..."
    
    mkdir -p "$HOME/.config"
    
    local src_starship="$DOTFILES_DIR/termux/.config/starship.toml"
    if [[ -f "$src_starship" ]]; then
        cp -f "$src_starship" "$HOME/.config/starship.toml"
    fi
    
    success "Starship configured"
}

setup_ssh() {
    info "Setting up SSH..."
    
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate SSH key if none exists
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        info "Generating SSH key..."
        ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "termux@android"
        success "SSH key generated"
        echo ""
        warn "Add this public key to your Mac's ~/.ssh/authorized_keys:"
        echo ""
        cat "$HOME/.ssh/id_ed25519.pub"
        echo ""
    fi
    
    # Start SSH daemon
    sshd 2>/dev/null || true
    
    success "SSH configured (port 8022)"
}

setup_hosts_config() {
    info "Setting up dev hosts config..."
    
    local config_dir="$HOME/.config/dev"
    mkdir -p "$config_dir"
    
    # Copy template if no local config exists
    if [[ ! -f "$config_dir/hosts.toml" ]]; then
        local src_hosts="$DOTFILES_DIR/dev/.config/dev/hosts.toml"
        if [[ -f "$src_hosts" ]]; then
            cp -f "$src_hosts" "$config_dir/hosts.toml"
            warn "Edit ~/.config/dev/hosts.toml with your Tailscale IPs"
        fi
    fi
    
    success "Hosts config ready"
}

setup_git() {
    info "Setting up Git..."
    
    # Only set if not already configured
    if ! git config --global user.name >/dev/null 2>&1; then
        read -p "Git user.name: " git_name
        git config --global user.name "$git_name"
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        read -p "Git user.email: " git_email
        git config --global user.email "$git_email"
    fi
    
    git config --global core.editor "nvim"
    git config --global init.defaultBranch "main"
    git config --global pull.rebase true
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global delta.syntax-theme "gruvbox-dark"
    
    success "Git configured"
}

print_summary() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  🚀 TERMUX POWERHOUSE READY${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BLUE}Quick Commands:${NC}"
    echo "    m         → Connect to Mac (mosh + tmux)"
    echo "    v         → Neovim"
    echo "    ta        → Attach/create tmux session"
    echo "    dev --list→ List all configured hosts"
    echo ""
    echo -e "  ${BLUE}Widget Shortcuts:${NC}"
    echo "    Install Termux:Widget from F-Droid"
    echo "    Add widget → Select shortcuts from ~/.shortcuts/"
    echo ""
    echo -e "  ${BLUE}Next Steps:${NC}"
    echo "    1. Run: termux-reload-settings"
    echo "    2. Restart Termux"
    echo "    3. Edit: ~/.config/dev/hosts.toml (add your IPs)"
    echo "    4. Test: dev mac-home"
    echo ""
    echo -e "  ${YELLOW}SSH Public Key (add to Mac):${NC}"
    [[ -f "$HOME/.ssh/id_ed25519.pub" ]] && cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

main() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  TERMUX POWERHOUSE BOOTSTRAP${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    check_termux
    setup_storage
    update_packages
    install_packages
    install_starship
    install_lazygit
    clone_dotfiles
    setup_termux_config
    setup_shortcuts
    setup_bin
    setup_starship_config
    setup_zsh
    setup_ssh
    setup_hosts_config
    setup_git
    
    print_summary
}

main "$@"
