#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step() {
  echo ""
  echo -e "${GREEN}=== $1 ===${NC}"
  echo -e "${YELLOW}$2${NC}"
  read -rp "Press Enter to run, 's' to skip: " choice
  [[ "$choice" == "s" ]] && echo "Skipped." && return 1
  return 0
}

info() { echo -e "${GREEN}  $1${NC}"; }
warn() { echo -e "${YELLOW}  $1${NC}"; }

echo "=========================================="
echo "  Asahi Fedora + Omarchy Restore Script"
echo "=========================================="
echo ""
echo "This will restore your full system config."
echo "Run this AFTER installing Fedora Asahi Remix + Omarchy base."
echo ""

# -----------------------------------------------------------
# 1. COPR Repos
# -----------------------------------------------------------
if step "Step 1: Enable COPR repositories" "Will enable $(wc -l < "$REPO_DIR/copr-repos.txt") COPR repos"; then
  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    info "Enabling $repo..."
    sudo dnf copr enable -y "$repo" 2>/dev/null || warn "Already enabled or failed: $repo"
  done < "$REPO_DIR/copr-repos.txt"
fi

# -----------------------------------------------------------
# 2. DNF Packages
# -----------------------------------------------------------
if step "Step 2: Install DNF packages" "Will install packages from packages.txt ($(wc -l < "$REPO_DIR/packages.txt") packages)"; then
  # Filter out packages that are already installed
  TO_INSTALL=()
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    if ! rpm -q "$pkg" &>/dev/null; then
      TO_INSTALL+=("$pkg")
    fi
  done < "$REPO_DIR/packages.txt"

  if [[ ${#TO_INSTALL[@]} -gt 0 ]]; then
    info "Installing ${#TO_INSTALL[@]} missing packages..."
    sudo dnf install -y "${TO_INSTALL[@]}" || warn "Some packages may have failed"
  else
    info "All packages already installed."
  fi
fi

# -----------------------------------------------------------
# 3. Cargo Tools
# -----------------------------------------------------------
if step "Step 3: Install Cargo tools" "Will install: $(cat "$REPO_DIR/cargo-tools.txt")"; then
  if ! command -v cargo &>/dev/null; then
    warn "Cargo not found. Install Rust first: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  else
    while IFS= read -r tool; do
      [[ -z "$tool" ]] && continue
      for t in $tool; do
        if command -v "$t" &>/dev/null; then
          info "$t already installed"
        else
          info "Installing $t..."
          cargo install "$t" || warn "Failed to install $t"
        fi
      done
    done < "$REPO_DIR/cargo-tools.txt"
  fi
fi

# -----------------------------------------------------------
# 4. Flatpaks
# -----------------------------------------------------------
if step "Step 4: Install Flatpaks" "Will install: $(cat "$REPO_DIR/flatpaks.txt" | tr '\n' ' ')"; then
  while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    if flatpak info "$app" &>/dev/null; then
      info "$app already installed"
    else
      info "Installing $app..."
      flatpak install -y flathub "$app" || warn "Failed: $app"
    fi
  done < "$REPO_DIR/flatpaks.txt"
fi

# -----------------------------------------------------------
# 5. Config Files
# -----------------------------------------------------------
if step "Step 5: Restore config files" "Will copy configs to ~/.config/ (hypr, waybar, kitty, pipewire, etc.)"; then
  # Copy config directories, preserving structure
  for dir in "$REPO_DIR"/config/*/; do
    dirname="$(basename "$dir")"
    target="$HOME/.config/$dirname"
    info "Restoring $dirname..."
    mkdir -p "$target"
    cp -r "$dir"* "$target/" 2>/dev/null || true
  done

  # Recreate elephant menu symlinks
  OMARCHY_SHARE="$HOME/.local/share/omarchy"
  if [[ -d "$OMARCHY_SHARE/default/elephant" ]]; then
    mkdir -p "$HOME/.config/elephant/menus"
    ln -sf "$OMARCHY_SHARE/default/elephant/omarchy_background_selector.lua" "$HOME/.config/elephant/menus/"
    ln -sf "$OMARCHY_SHARE/default/elephant/omarchy_themes.lua" "$HOME/.config/elephant/menus/"
    info "Recreated elephant menu symlinks"
  fi

  # Remove the SYMLINKS.txt helper file from live config
  rm -f "$HOME/.config/elephant/menus/SYMLINKS.txt"
fi

# -----------------------------------------------------------
# 6. Custom Scripts
# -----------------------------------------------------------
if step "Step 6: Restore custom scripts" "Will copy scripts to ~/.local/bin/ and recreate symlinks"; then
  mkdir -p "$HOME/.local/bin"

  # Copy custom scripts
  cp "$REPO_DIR"/local-bin/* "$HOME/.local/bin/" 2>/dev/null || true
  chmod +x "$HOME/.local/bin/"*
  info "Copied $(ls "$REPO_DIR/local-bin/" | wc -l) scripts"

  # Recreate symlinks
  OMARCHY_BIN="$HOME/.local/share/omarchy/bin"
  count=0
  while IFS='|' read -r name target; do
    [[ -z "$name" ]] && continue
    # Skip claude symlink (managed separately)
    [[ "$name" == "claude" ]] && continue
    # Expand $HOME in targets
    target="${target/\/home\/hugo/$HOME}"
    if [[ -e "$target" || -d "$(dirname "$target")" ]]; then
      ln -sf "$target" "$HOME/.local/bin/$name"
      ((count++))
    else
      warn "Symlink target missing for $name: $target"
    fi
  done < "$REPO_DIR/local-bin-symlinks.txt"
  info "Recreated $count symlinks"
fi

# -----------------------------------------------------------
# 7. Omarchy-Fedora Helpers
# -----------------------------------------------------------
if step "Step 7: Restore omarchy-fedora helpers" "Will copy pkg-map and pkg-helpers.sh to ~/.local/share/omarchy-fedora/"; then
  mkdir -p "$HOME/.local/share/omarchy-fedora"
  cp -r "$REPO_DIR"/local-share/omarchy-fedora/* "$HOME/.local/share/omarchy-fedora/"
  info "Done"
fi

# -----------------------------------------------------------
# 8. Zshrc
# -----------------------------------------------------------
if step "Step 8: Restore .zshrc" "Will copy zshrc to ~/.zshrc (existing backed up to ~/.zshrc.bak)"; then
  if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
    info "Backed up existing .zshrc"
  fi
  cp "$REPO_DIR/zshrc" "$HOME/.zshrc"
  info "Restored .zshrc"
fi

# -----------------------------------------------------------
# 9. System Files (requires sudo)
# -----------------------------------------------------------
if step "Step 9: Install system files" "Will install udev rules, NM config, SDDM theme, versionlock (sudo required)"; then
  # Udev rules
  sudo cp "$REPO_DIR/system/etc/udev/rules.d/"* /etc/udev/rules.d/
  sudo udevadm control --reload-rules
  info "Udev rules installed"

  # NetworkManager iwd backend
  sudo mkdir -p /etc/NetworkManager/conf.d
  sudo cp "$REPO_DIR/system/etc/NetworkManager/conf.d/iwd.conf" /etc/NetworkManager/conf.d/
  info "NM iwd config installed"

  # SDDM theme
  if [[ -d /usr/share/sddm/themes/omarchy ]]; then
    sudo cp "$REPO_DIR/system/sddm/themes/omarchy/Main.qml" /usr/share/sddm/themes/omarchy/
    info "SDDM theme Main.qml installed (Qt6 fix)"
  else
    warn "SDDM omarchy theme dir not found — install omarchy first"
  fi

  # DNF versionlock
  sudo cp "$REPO_DIR/system/dnf/versionlock.toml" /etc/dnf/versionlock.toml
  info "DNF versionlock installed"
fi

# -----------------------------------------------------------
# 10. Systemd User Services
# -----------------------------------------------------------
if step "Step 10: Enable systemd user services" "Will enable elephant.service"; then
  systemctl --user daemon-reload
  systemctl --user enable elephant.service
  info "elephant.service enabled"
fi

# -----------------------------------------------------------
# 11. Snapper
# -----------------------------------------------------------
if step "Step 11: Set up snapper" "Will create root + home snapshot configs"; then
  if ! snapper list-configs 2>/dev/null | grep -q root; then
    sudo snapper -c root create-config /
    info "Created snapper root config"
  else
    info "Snapper root config already exists"
  fi
  if ! snapper list-configs 2>/dev/null | grep -q home; then
    sudo snapper -c home create-config /home
    info "Created snapper home config"
  else
    info "Snapper home config already exists"
  fi
fi

# -----------------------------------------------------------
# 12. Build from Source
# -----------------------------------------------------------
if step "Step 12: Build Hyprland from source" "Will run build script (takes ~10 min, applies Apple GPU patch)"; then
  bash "$REPO_DIR/build/build-hyprland.sh"
fi

# -----------------------------------------------------------
# 13. CPU Frequency Fix
# -----------------------------------------------------------
if step "Step 13: Uncap CPU frequencies" "Will set scaling_max_freq to hardware max for all policies"; then
  for p in /sys/devices/system/cpu/cpufreq/policy*/; do
    max=$(cat "${p}cpuinfo_max_freq")
    sudo sh -c "echo $max > ${p}scaling_max_freq"
    info "$(basename "$p"): set to ${max}kHz"
  done
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  Restore complete!"
echo "==========================================${NC}"
echo ""
echo "Post-install checklist:"
echo "  1. Reboot"
echo "  2. Run 'omarchy-theme-set <theme>' to initialize theme system"
echo "  3. Verify CPU freq: cat /sys/devices/system/cpu/cpufreq/policy*/scaling_max_freq"
echo "  4. Test audio: speaker-test -c 2 -t wav"
echo "  5. Test walker: Super key"
echo "  6. Select Pro Audio profile in pavucontrol for speakers"
echo ""
