#!/bin/bash
# CachyOS package installer — run once on fresh system
set -eu

# Core Hyprland stack (CachyOS ships hyprland, but ensure deps)
PKGS=(
  hyprland
  hypridle
  hyprlock
  hyprpicker
  xdg-desktop-portal-hyprland

  # Bar & notifications
  waybar
  dunst                 # notification daemon
  swayosd-git          # AUR: on-screen display for vol/brightness

  # Launcher
  walker-bin            # AUR: app launcher
  elephant              # AUR: data provider for walker
  elephant-desktopapplications  # AUR: .desktop file provider
  elephant-clipboard    # AUR: clipboard provider
  elephant-providerlist # AUR: provider list
  elephant-menus        # AUR: Lua menu provider (theme picker etc)
  fuzzel                # dmenu fallback

  # Clipboard
  cliphist
  wl-clipboard
  wtype                 # synthetic keypresses for paste

  # Wallpaper
  swww

  # Terminal & shell
  kitty
  zsh
  starship

  # Browser
  brave-bin             # AUR

  # File manager
  dolphin
  dolphin-plugins

  # TUI tools
  btop
  lazydocker            # AUR

  # WiFi / Bluetooth TUI
  impala                # AUR (or cargo install impala)
  bluetui               # AUR (or cargo install bluetui)

  # Key remapping
  xremap-hypr-bin       # AUR: xremap for Hyprland

  # Screenshot / recording
  grim
  slurp
  wf-recorder
  satty                 # AUR: screenshot annotation

  # Media
  playerctl
  pavucontrol
  pamixer

  # Fonts
  ttf-jetbrains-mono-nerd

  # Misc
  jq
  fzf
  ripgrep
  fd
  bat
  go                    # needed for yoink
  github-cli            # gh auth for dotfiles repo

  # Polkit
  polkit-kde-agent
)

echo "Installing packages..."
paru -S --needed --noconfirm "${PKGS[@]}"

# Ensure cargo TUI tools if AUR versions unavailable
for tool in impala bluetui; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Installing $tool via cargo..."
    cargo install "$tool"
  fi
done

# Install yoink clipboard manager
if ! command -v yoink >/dev/null 2>&1; then
  echo "Installing yoink clipboard manager..."
  go install github.com/fjordnode/yoink@latest
  cp ~/go/bin/yoink ~/.local/bin/yoink
fi

echo ""
echo "Done! Next steps:"
echo "  1. Copy configs:  ./deploy.sh"
echo "  2. Log out and select Hyprland session"
