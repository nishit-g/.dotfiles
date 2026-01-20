#!/usr/bin/env bash
set -euo pipefail

echo "▶ Starting macOS bootstrap..."

if [[ "$OSTYPE" != darwin* ]]; then
  echo "This script is intended for macOS only."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "▶ Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "✔ Homebrew installed (new)."
else
  echo "✔ Homebrew already installed."
fi

BREW_PREFIX="$(brew --prefix)"

echo "▶ Adding taps..."
brew tap joshmedeski/sesh

echo "▶ Installing CLI tools..."
BREW_FORMULAE=(
  git
  zsh
  tmux
  neovim
  fzf
  ripgrep
  ugrep
  fd
  eza
  zoxide
  lazygit
  gh
  jq
  yq
  hyperfine
  stow
  sesh
  mise
  atuin
  git-delta
  bat
  yazi
  ffmpegthumbnailer
  poppler
  direnv
  tldr
)

for pkg in "${BREW_FORMULAE[@]}"; do
  if brew list --formula | grep -q "^${pkg}$"; then
    echo "  • ${pkg} already installed."
  else
    echo "  • Installing ${pkg}..."
    brew install "${pkg}"
  fi
done

echo "▶ Installing GUI apps (if not present)..."
BREW_CASKS=(
  alacritty
)

for cask in "${BREW_CASKS[@]}"; do
  if brew list --cask | grep -q "^${cask}$"; then
    echo "  • ${cask} already installed."
  else
    echo "  • Installing ${cask}..."
    brew install --cask "${cask}"
  fi
done

echo "▶ Installing zinit (zsh plugin manager)..."
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  echo "✔ zinit installed."
else
  echo "  • zinit already installed."
fi

echo "▶ Linking dotfiles with stow..."

cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/bin"

STOW_DIRS=(
  nvim
  zsh
  tmux
  alacritty
  git
  sesh
  atuin
  yazi
  bat
  mise
)

for dir in "${STOW_DIRS[@]}"; do
  if [[ -d "${dir}" ]]; then
    echo "  • Stowing ${dir}"
    stow --restow "${dir}"
  else
    echo "  • Skipping ${dir} (directory not found in dotfiles)."
  fi
done

echo ""
echo "▶ Cleanup (run manually if needed):"
echo "  rm -rf ~/.antidote ~/.asdf ~/.tool-versions"
echo ""
echo "▶ Post-install steps:"
echo "  1. Set zsh as default shell:"
echo "       chsh -s \"\$(command -v zsh)\""
echo "  2. Restart terminal (zinit will auto-install plugins)"
echo "  3. Run 'p10k configure' if prompt looks broken"
echo "  4. Import shell history: atuin import auto"
echo "  5. First Neovim run: nvim, then :Lazy sync"

echo ""
echo "✔ macOS bootstrap complete."
