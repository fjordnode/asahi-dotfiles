# Shared helpers for Fedora package management wrappers.
# Source this file, don't execute it.

PKG_MAP="$HOME/.local/share/omarchy-fedora/pkg-map"

# Translate an Arch package name to its Fedora equivalent.
# Returns: the mapped name, "SKIP" if no equivalent, or "FLATPAK:id" for flatpak.
# Unmapped names pass through unchanged.
map_pkg() {
  local arch_name="$1"
  local mapped

  if [[ -f "$PKG_MAP" ]]; then
    mapped=$(grep -m1 "^${arch_name}=" "$PKG_MAP" 2>/dev/null | cut -d= -f2-)
  fi

  if [[ -n "$mapped" ]]; then
    echo "$mapped"
  else
    echo "$arch_name"
  fi
}

# Check if a single package is installed (by its Fedora name).
is_pkg_installed() {
  rpm -q "$1" &>/dev/null
}

# Translate a list of Arch package names to Fedora names.
# Filters out SKIP packages (prints warning). Handles FLATPAK separately.
# Sets: DNF_PKGS (array), FLATPAK_PKGS (array), SKIPPED_PKGS (array)
translate_pkgs() {
  DNF_PKGS=()
  FLATPAK_PKGS=()
  SKIPPED_PKGS=()

  for pkg in "$@"; do
    local mapped
    mapped=$(map_pkg "$pkg")

    if [[ "$mapped" == "SKIP" ]]; then
      SKIPPED_PKGS+=("$pkg")
    elif [[ "$mapped" == FLATPAK:* ]]; then
      FLATPAK_PKGS+=("${mapped#FLATPAK:}")
    else
      # mapped might be multiple packages (space-separated, e.g. base-devel)
      read -ra parts <<< "$mapped"
      DNF_PKGS+=("${parts[@]}")
    fi
  done
}
