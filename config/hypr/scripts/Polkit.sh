#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# This script starts the first available Polkit agent from a list of possible locations

# List of potential Polkit agent file paths
polkit=(
  "/usr/bin/hyprpolkitagent"
  "/usr/libexec/lxqt-policykit-agent"
  "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
  "/usr/libexec/hyprpolkitagent"
  "/usr/lib/hyprpolkitagent"
  "/usr/lib/hyprpolkitagent/hyprpolkitagent"
  "/usr/lib/polkit-kde-authentication-agent-1"
  "/usr/lib/polkit-gnome-authentication-agent-1"
  "/usr/libexec/polkit-gnome-authentication-agent-1"
  "/usr/libexec/polkit-mate-authentication-agent-1"
  "/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1"
  "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
)

# Do nothing if an auth agent is already running.
if pgrep -f 'hyprpolkitagent|lxqt-policykit-agent|polkit-gnome-authentication-agent-1|polkit-mate-authentication-agent-1|polkit-kde-authentication-agent-1' >/dev/null 2>&1; then
  exit 0
fi

# Loop through the list of paths
for file in "${polkit[@]}"; do
  if [ -x "$file" ] && [ ! -d "$file" ]; then
    exec "$file"
  fi
done

# Fallback message if nothing executable was found.
notify-send "Polkit agent missing" "Install hyprpolkitagent, lxqt-policykit, or polkit-gnome-authentication-agent."
