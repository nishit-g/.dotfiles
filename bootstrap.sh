#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/scripts/utils.sh"

readonly BREW_TAPS=(
  joshmedeski/sesh
  nikitabobko/tap
  homebrew/cask-fonts
)

readonly BREW_FORMULAE=(
  git zsh tmux neovim stow
  fzf ripgrep fd eza zoxide bat
  lazygit gh jq yq
  sesh mise atuin git-delta
  yazi ffmpegthumbnailer poppler unar imagemagick
  direnv tldr hyperfine ugrep mosh
)

readonly BREW_CASKS=(
  alacritty
  aerospace
  karabiner-elements
  raycast
  font-jetbrains-mono-nerd-font
)

readonly STOW_PACKAGES=(
  nvim zsh tmux alacritty git
  sesh atuin yazi bat mise
  aerospace karabiner dev
)

install_homebrew() {
  if command_exists brew; then
    return 0
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  success "Homebrew installed"
}

install_taps() {
  for tap in "${BREW_TAPS[@]}"; do
    brew tap "$tap" 2>/dev/null || true
  done
}

install_formulae() {
  info "Installing CLI tools..."
  local to_install=()
  for pkg in "${BREW_FORMULAE[@]}"; do
    if ! brew list --formula 2>/dev/null | grep -q "^${pkg}$"; then
      to_install+=("$pkg")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    brew install "${to_install[@]}"
  fi
  success "CLI tools ready"
}

install_casks() {
  info "Installing apps..."
  local to_install=()
  for cask in "${BREW_CASKS[@]}"; do
    if ! brew list --cask 2>/dev/null | grep -q "^${cask}$"; then
      to_install+=("$cask")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    brew install --cask "${to_install[@]}"
  fi
  success "Apps ready"
}

install_zinit() {
  local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
  if [[ -d "$zinit_home" ]]; then
    return 0
  fi
  info "Installing zinit..."
  mkdir -p "$(dirname "$zinit_home")"
  git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"
  success "zinit installed"
}

link_configs() {
  info "Linking configs..."
  mkdir -p "$HOME/.config" "$HOME/bin"
  for pkg in "${STOW_PACKAGES[@]}"; do
    stow_package "$pkg" "$DOTFILES_DIR"
  done
  success "Configs linked"
}

apply_macos_defaults() {
  if [[ -f "$DOTFILES_DIR/scripts/macos.sh" ]]; then
    bash "$DOTFILES_DIR/scripts/macos.sh"
  fi
}

show_post_install() {
  echo ""
  echo -e "${BOLD}Installation complete!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your terminal"
  echo "  2. Grant accessibility permissions:"
  echo "     System Settings → Privacy → Accessibility"
  echo "     Enable: Aerospace, Karabiner-Elements"
  echo "  3. Open Raycast and set Cmd+Space as hotkey"
  echo "  4. Run 'p10k configure' if prompt looks broken"
  echo ""
}

main() {
  is_macos || die "This script only supports macOS"
  
  local cmd="${1:-all}"
  
  case "$cmd" in
    brew)
      install_homebrew
      install_taps
      install_formulae
      ;;
    apps)
      install_casks
      ;;
    link)
      link_configs
      ;;
    macos)
      apply_macos_defaults
      ;;
    zinit)
      install_zinit
      ;;
    all)
      install_homebrew
      install_taps
      install_formulae
      install_casks
      install_zinit
      link_configs
      apply_macos_defaults
      show_post_install
      ;;
    *)
      echo "Usage: $0 [brew|apps|link|macos|zinit|all]"
      exit 1
      ;;
  esac
}

main "$@"
