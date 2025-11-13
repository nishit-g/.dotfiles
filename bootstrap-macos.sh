#!/usr/bin/env bash
set -euo pipefail

echo "▶ Starting macOS bootstrap..."

if [[ "$OSTYPE" != darwin* ]]; then
  echo "This script is intended for macOS only."
  exit 1
fi

# --- Homebrew -------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "▶ Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "✔ Homebrew installed (new)."
else
  echo "✔ Homebrew already installed."
fi

BREW_PREFIX="$(brew --prefix)"

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
  nnn
  broot
  lazygit
  gh
  jq
  yq
  hyperfine
  stow
)

for pkg in "${BREW_FORMULAE[@]}"; do
  if brew list --formula | grep -q "^${pkg}\$"; then
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
  if brew list --cask | grep -q "^${cask}\$"; then
    echo "  • ${cask} already installed."
  else
    echo "  • Installing ${cask}..."
    brew install --cask "${cask}"
  fi
done

# FZF key bindings (optional)
if [[ -x "${BREW_PREFIX}/opt/fzf/install" ]]; then
  echo "▶ Enabling fzf key bindings..."
  yes | "${BREW_PREFIX}/opt/fzf/install" --no-bash --no-fish --key-bindings --completion
else
  echo "▶ Skipping fzf key bindings (installer not found)."
fi

echo "▶ Linking dotfiles with stow..."

# Go to dotfiles repo root (this script should live in it)
cd "$(dirname "${BASH_SOURCE[0]}")"

# Create required directories if missing
mkdir -p "$HOME/.config"
mkdir -p "$HOME/bin"

# Stow modules if present
STOW_DIRS=(
  nvim
  zsh
  tmux
  alacritty
  bin
)

for dir in "${STOW_DIRS[@]}"; do
  if [[ -d "${dir}" ]]; then
    echo "  • Stowing ${dir}"
    stow "${dir}"
  else
    echo "  • Skipping ${dir} (directory not found in dotfiles)."
  fi
done

echo ""
echo "▶ NOTE:"
echo "  - If you want zsh as your default shell, run:"
echo "      chsh -s \"$(command -v zsh)\""
echo "  - Then restart your terminal."
echo "  - First Neovim run: open 'nvim' and run ':Lazy sync' once to install plugins."

echo ""
echo "✔ macOS bootstrap complete."
