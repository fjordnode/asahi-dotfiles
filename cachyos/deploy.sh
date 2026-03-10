#!/bin/bash
# Deploy configs, scripts, themes, and templates to their proper locations
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$HOME/.local/share/dotfiles"

echo "Installing dotfiles data (themes + templates)..."
mkdir -p "$DOTFILES_DIR"
cp -r "$SCRIPT_DIR/themes" "$DOTFILES_DIR/"
cp -r "$SCRIPT_DIR/templates" "$DOTFILES_DIR/"

echo ""
echo "Copying configs..."
for dir in hypr waybar walker xremap kitty mako elephant; do
  src="$SCRIPT_DIR/config/$dir"
  dst="$HOME/.config/$dir"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    cp -rv "$src"/. "$dst"/
  fi
done

echo ""
echo "Installing scripts to ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
for script in "$SCRIPT_DIR/bin/"*; do
  install -m 755 "$script" "$HOME/.local/bin/"
  echo "  $(basename "$script")"
done

echo ""
echo "Installing systemd services..."
mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/config/systemd/"*.service "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable elephant.service

echo ""
echo "Setting up theme directories..."
mkdir -p "$HOME/.config/themes/"{current,custom,backgrounds,hooks,templates}

# Apply default theme if none set
if [[ ! -f "$HOME/.config/themes/current.name" ]]; then
  echo ""
  echo "Applying default theme (tokyo-night)..."
  export DOTFILES_DIR
  theme-set tokyo-night
fi

echo ""
echo "Done! Reload hyprland: hyprctl reload"
echo ""
echo "Usage:"
echo "  theme-set <name>   — apply a theme"
echo "  theme-pick         — interactive theme picker"
echo "  theme-bg-next      — cycle wallpapers"
echo "  theme-current      — show current theme"
