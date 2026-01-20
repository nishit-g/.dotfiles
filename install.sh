#!/usr/bin/env bash
set -euo pipefail

REPO="nishit-g/.dotfiles"
BRANCH="v2"
DOTFILES_DIR="$HOME/dotfiles"

info()    { echo -e "\033[0;34m▶\033[0m $*"; }
success() { echo -e "\033[0;32m✔\033[0m $*"; }
error()   { echo -e "\033[0;31m✖\033[0m $*" >&2; exit 1; }

[[ "$OSTYPE" == darwin* ]] || error "This installer only supports macOS"

info "Installing dotfiles..."

if [[ -d "$DOTFILES_DIR" ]]; then
  info "Updating existing dotfiles..."
  git -C "$DOTFILES_DIR" pull --rebase origin "$BRANCH"
else
  info "Cloning dotfiles..."
  git clone -b "$BRANCH" "https://github.com/$REPO.git" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

if [[ -f "Makefile" ]]; then
  make install
else
  ./bootstrap.sh
fi

success "Dotfiles installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Grant accessibility permissions to Aerospace & Karabiner"
echo "  3. Run 'p10k configure' if prompt looks broken"
