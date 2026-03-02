# Asahi Fedora + Omarchy - Disaster Recovery

Full restore guide for M1 MacBook Air running Fedora Asahi Remix with Hyprland/Omarchy.

## Prerequisites

1. **Install Fedora Asahi Remix** — https://asahilinux.org/
   - Select 16K kernel variant during install
   - After install: `sudo dnf upgrade --refresh`

2. **Install Omarchy** — https://omarchy.com/
   - Follow their install guide (installs Hyprland, Waybar, SDDM, walker, themes, etc.)
   - This provides `~/.local/share/omarchy/` which many scripts depend on

3. **Install Rust/Cargo** — `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

4. **Clone this repo**
   ```bash
   git clone <this-repo> ~/asahi-dotfiles
   cd ~/asahi-dotfiles
   ./install.sh
   ```

## What install.sh does

Each step is interactive (Enter to run, 's' to skip):

| Step | What | Details |
|------|------|---------|
| 1 | COPR repos | Enables 13 COPR repos (hyprland, swayosd, walker, ghostty, etc.) |
| 2 | DNF packages | Installs ~293 packages (skips already-installed) |
| 3 | Cargo tools | Installs bluetui, impala, xremap, battop |
| 4 | Flatpaks | Installs Vesktop, Calculator, LocalSend |
| 5 | Config files | Copies all ~/.config/ customizations |
| 6 | Custom scripts | Copies ~72 scripts to ~/.local/bin/ + recreates ~42 symlinks |
| 7 | Omarchy-Fedora | Installs Fedora port helpers (pkg-map, dnf wrappers) |
| 8 | .zshrc | Restores shell config (backs up existing) |
| 9 | System files | Udev rules, NM iwd config, SDDM Qt6 fix, DNF versionlock |
| 10 | Systemd | Enables elephant.service (walker data provider) |
| 11 | Snapper | Creates btrfs snapshot configs for root + home |
| 12 | Hyprland build | Builds Hyprland 0.54.0 from source with Apple GPU patch |
| 13 | CPU freq | Uncaps CPU frequency (fixes 600MHz clamping issue) |

## Things that need manual attention

### Audio setup

The default Asahi audio DSP is bypassed for cleaner sound:

1. Open `pavucontrol` → Configuration tab
2. Set the audio device to **Pro Audio** profile
3. In Output Devices, select **Pro 1** (raw speakers)
4. Custom PipeWire EQ is auto-loaded from `~/.config/pipewire/pipewire.conf.d/user-eq.conf`

Details:
- HPF at 80Hz protects laptop speakers from sub-bass
- `speakersafetyd` still provides hardware-level protection
- **Caveat**: Pro Audio profile may not auto-switch to headphones — test this
- **Do NOT install EasyEffects** — it crashes and corrupts WirePlumber state

### Hyprland from source (Apple GPU fix)

The COPR binary crashes on Apple GPU because `drmGetFormatModifierName()` returns NULL for Apple DRM modifiers. The fix is a one-line null check in `src/helpers/Format.cpp`:

```cpp
// Before (crashes):
std::string name = n;
// After (fixed):
std::string name = n ? n : "UNKNOWN";
```

This was merged upstream in PR #13416 (commit 4206421). **Check if the COPR package version is newer than 0.54.0** before rebuilding from source — the fix may already be included:

```bash
dnf check-update hyprland
```

The build script also compiles xkbcommon 1.11.0 (system has 1.8.1) and patches out a Nix-only dependency.

Build prerequisites (installed by step 2):
- cmake, meson, ninja-build, gcc-c++, golang
- hyprland-protocols-devel, hyprlang-devel, hyprutils-devel, etc.
- Full list in `build/build-hyprland.sh`

### Walker / Elephant (app launcher)

Walker uses Elephant as a data provider. The COPR elephant package has a protobuf plugin crash, so it was rebuilt from source:

```bash
# Clone and build with matching Go toolchain
git clone https://github.com/nicholasgasior/elephant
cd elephant
GOSUMDB=sum.golang.org CGO_LDFLAGS="-fuse-ld=bfd" GOTOOLCHAIN=auto make build
sudo cp elephant /usr/bin/elephant
# Build plugins with same env and copy to /etc/xdg/elephant/providers/
```

Key: COPR Go plugins must be built with the same toolchain as the main binary (protobuf registration conflict).

### Custom XKB keyboard layout

`~/.config/xkb/symbols/nobrackets` — Norwegian layout with bracket remaps:
- `ø → (`, `æ → )`, `Shift+ø → [`, `Shift+æ → ]`
- AltGr+ø/æ for original characters
- Referenced in `input.conf` as `kb_layout = nobrackets`

### Snapper / btrfs snapshots

- Use `--ambit classic` flag when doing rollbacks (Fedora requirement)
- btrfs default subvolume is 256 (root)
- fstab mounts by `subvol=root` (safe for rollbacks)
- `system-snapshot` wrapper script handles both root + home

### DNF versionlock

Hyprland and hypridle are version-locked to prevent COPR updates from overwriting the custom build:

```bash
# Check locks
dnf5 versionlock list
# Remove locks when COPR has fixed version
sudo dnf5 versionlock delete hyprland
sudo dnf5 versionlock delete hypridle
```

### xremap (per-app key remapping)

Provides macOS-like shortcuts in Brave (Super as Ctrl). Built from cargo with `hypr` feature:

```bash
cargo install xremap --features hypr
```

Config: `~/.config/xremap/config.yml`
Udev rule: `/etc/udev/rules.d/99-xremap.rules` (grants uinput access)

### Power management

- Udev rule auto-switches governor: `performance` on AC, `schedutil` on battery
- Also resets `scaling_max_freq` to hardware max on each power state change
- hypridle: lock 5min, screen off 5min, suspend 10min
- **s2idle only** (~1.4%/hr drain during suspend — Asahi firmware limitation)
- Hibernate is not possible on Asahi (firmware state can't be saved)

### Theme integration

Theme switching (`omarchy-theme-set`) triggers a hook that updates:
- Starship prompt (template at `~/.config/omarchy/themed/starship.toml.tpl`)
- OpenCode TUI theme (written to `~/.config/opencode/tui.json` + `~/.local/state/opencode/kv.json`)
- Neovim colorscheme (polled every 3s via `vim.fn.timer_start`)
- Zsh prompt (reloaded via FIFO, not SIGUSR1 — that kills tmux/TUIs)

### SDDM login screen

The omarchy SDDM theme needs a Qt6 import fix:
- `Main.qml`: uses `Qt5Compat.GraphicalEffects` (not `QtGraphicalEffects 1.0`)
- `omarchy-sddm-theme-guard` script auto-detects and fixes regressions
- Guard runs at Hypr startup via autostart.conf

## Known issues

- **s2idle only**: ~1.4%/hr battery drain during suspend (Asahi limitation)
- **No hibernate**: firmware state can't be saved on Apple Silicon
- **Headphone auto-switch**: untested with Pro Audio profile
- **Brave maximize on open**: Hyprland windowrule doesn't support this cleanly

## Updating this repo

When you make config changes, update this repo:

```bash
cd ~/asahi-dotfiles

# Quick sync of most-changed files
cp -r ~/.config/hypr/ config/hypr/
cp -r ~/.config/waybar/config.jsonc config/waybar/
cp ~/.config/waybar/style.css config/waybar/
cp ~/.zshrc zshrc

# Or sync everything (re-run relevant parts of the initial copy)
# Then commit
git add -A && git commit -m "Update configs"
git push
```

Consider running `system-snapshot` before and after major changes.
