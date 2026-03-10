#!/bin/bash
# Deploy configs and scripts to their proper locations
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Linking configs..."
for dir in hypr waybar walker xremap kitty; do
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
echo "Done! Reload hyprland: hyprctl reload"
