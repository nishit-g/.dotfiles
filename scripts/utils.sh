#!/usr/bin/env bash
# Shared utilities for dotfiles scripts

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

info()    { echo -e "${BLUE}▶${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✖${NC} $*" >&2; }
die()     { error "$@"; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

is_macos() { [[ "$OSTYPE" == darwin* ]]; }
is_linux() { [[ "$OSTYPE" == linux* ]]; }

get_dotfiles_dir() {
  local script_path="${BASH_SOURCE[1]:-$0}"
  cd "$(dirname "$script_path")/.." && pwd
}

brew_install() {
  local pkg="$1"
  if brew list --formula 2>/dev/null | grep -q "^${pkg}$"; then
    return 0
  fi
  info "Installing $pkg..."
  brew install "$pkg"
}

brew_cask_install() {
  local cask="$1"
  if brew list --cask 2>/dev/null | grep -q "^${cask}$"; then
    return 0
  fi
  info "Installing $cask..."
  brew install --cask "$cask"
}

stow_package() {
  local pkg="$1"
  local dotfiles_dir="$2"
  if [[ -d "$dotfiles_dir/$pkg" ]]; then
    stow --dir="$dotfiles_dir" --target="$HOME" --restow "$pkg" 2>/dev/null || true
  fi
}

backup_existing() {
  local file="$1"
  if [[ -e "$file" && ! -L "$file" ]]; then
    local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$file" "$backup"
    warn "Backed up $file → $backup"
  fi
}

link_app_support() {
  local app_id="$1"
  local dotfiles_dir="$2"
  local source_dir="$3"
  local target_dir="$HOME/Library/Application Support/$app_id"
  
  mkdir -p "$target_dir"
  
  for file in "$dotfiles_dir/$source_dir"/*.json; do
    [[ -f "$file" ]] || continue
    local basename=$(basename "$file")
    local target="$target_dir/$basename"
    
    if [[ -e "$target" && ! -L "$target" ]]; then
      mv "$target" "${target}.bak"
    fi
    
    rm -f "$target"
    ln -sf "$file" "$target"
  done
}
