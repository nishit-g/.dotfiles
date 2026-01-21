#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$HOME/Library/Application Support/ai.bloop.vibe-kanban"

mkdir -p "$TARGET_DIR"

for file in "$DOTFILES_DIR/vibe-kanban"/*.json; do
  [[ -f "$file" ]] || continue
  basename=$(basename "$file")
  target="$TARGET_DIR/$basename"
  
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "${target}.bak"
  fi
  
  rm -f "$target"
  ln -sf "$file" "$target"
done

echo "✔ Vibe Kanban configs linked"
