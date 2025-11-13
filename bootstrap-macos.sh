#!/usr/bin/env bash
set -euo pipefail

echo "▶ Starting macOS bootstrap..."

# ---------- Homebrew ----------
if ! command -v brew >/dev/null 2>&1; then
  echo "▶ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✔ Homebrew already installed."
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ---------- CLI tools ----------
echo "▶ Installing CLI tools..."
brew install \
  git \
  zsh \
  tmux \
  neovim \
  fzf \
  ripgrep \
  ugrep \
  fd \
  eza \
  zoxide \
  nnn \
  broot \
  lazygit \
  gh \
  jq \
  yq \
  hyperfine \
  stow

# ---------- Fonts & terminal ----------
echo "▶ Installing fonts and terminal apps..."
brew install --cask font-jetbrains-mono-nerd-font || true
brew install --cask alacritty

# ---------- Antidote for zsh ----------
if [[ ! -d "${ZDOTDIR:-$HOME}/.antidote" ]]; then
  echo "▶ Installing Antidote (zsh plugin manager)..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-$HOME}"/.antidote
else
  echo "✔ Antidote already present."
fi

# ---------- Backup existing dotfiles (once, non-destructive) ----------
backup() {
  local file="$1"
  if [[ -e "$file" && ! -L "$file" ]]; then
    echo "  → Backing up $file to ${file}.backup"
    mv "$file" "${file}.backup"
  fi
}

echo "▶ Backing up existing dotfiles (if any)..."
backup "$HOME/.zshrc"
backup "$HOME/.tmux.conf"
backup "$HOME/.gitconfig"
backup "$HOME/.config/alacritty"

mkdir -p "$HOME/.config"

# ---------- Stow dotfiles ----------
echo "▶ Symlinking dotfiles with stow..."
cd "$HOME/dotfiles"

stow zsh tmux alacritty git macos

# ---------- macOS defaults ----------
if [[ -x "$HOME/dotfiles/macos/.macos" ]]; then
  echo "▶ Applying macOS defaults..."
  "$HOME/dotfiles/macos/.macos" || true
fi

echo "✅ Bootstrap complete. Open Alacritty and enjoy your new setup."
