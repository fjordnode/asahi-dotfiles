#!/bin/bash
# Install only the theme system (themes, templates, scripts)
# Safe to run on top of an existing deploy
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.local/share/dotfiles}"

echo "Installing themes and templates..."
mkdir -p "$DOTFILES_DIR"
cp -r "$SCRIPT_DIR/themes" "$DOTFILES_DIR/"
cp -r "$SCRIPT_DIR/templates" "$DOTFILES_DIR/"

echo "Installing theme scripts..."
mkdir -p "$HOME/.local/bin"
for script in "$SCRIPT_DIR/bin/theme-"*; do
  install -m 755 "$script" "$HOME/.local/bin/"
  echo "  $(basename "$script")"
done

echo "Setting up directories..."
mkdir -p "$HOME/.config/themes/"{current,custom,backgrounds,hooks,templates}

if [[ ! -f "$HOME/.config/themes/current.name" ]]; then
  echo ""
  read -rp "Apply a default theme? [tokyo-night]: " theme
  theme="${theme:-tokyo-night}"
  export DOTFILES_DIR
  theme-set "$theme"
else
  echo ""
  echo "Current theme: $(theme-current)"
  echo "Run 'theme-set <name>' or 'theme-pick' to change"
fi
