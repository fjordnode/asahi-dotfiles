# Omarchy menu overrides for Fedora Asahi Linux.
# This file is sourced by omarchy-menu to customize menus for Fedora.

# Keep local Fedora wrappers ahead of upstream Omarchy scripts.
export PATH="$HOME/.local/bin:$PATH"

# Override the install menu: keep core daily install flows only
show_install_menu() {
  case $(menu "Install" "󰣇  Package\n󰏓  Flatpak\n  Web App\n  TUI\n  Terminal\n  Gaming") in
  *Package*) terminal omarchy-pkg-install ;;
  *Flatpak*) terminal omarchy-flatpak-install ;;
  *Web*) present_terminal omarchy-webapp-install ;;
  *TUI*) present_terminal omarchy-tui-install ;;
  *Terminal*) show_install_terminal_menu ;;
  *Gaming*) show_install_gaming_menu ;;
  *) show_main_menu ;;
  esac
}

# Override update menu: keep only low-risk maintenance actions
show_update_menu() {
  case $(menu "Update" "  Config\n  Firmware\n  Password\n  Timezone\n  Time") in
  *Config*) show_update_config_menu ;;
  *Firmware*) present_terminal omarchy-update-firmware ;;
  *Timezone*) present_terminal omarchy-tz-select ;;
  *Time*) present_terminal omarchy-update-time ;;
  *Password*) show_update_password_menu ;;
  *) show_main_menu ;;
  esac
}

# Override gaming menu: remove Windows VM (not applicable on aarch64)
show_install_gaming_menu() {
  case $(menu "Install" "  Steam\n  RetroArch\n󰖺  Xbox Controller") in
  *Steam*) present_terminal omarchy-install-steam ;;
  *RetroArch*) present_terminal "flatpak install -y flathub org.libretro.RetroArch; omarchy-refresh-applications >/dev/null 2>&1 || true" ;;
  *Xbox*) present_terminal omarchy-install-xbox-controllers ;;
  *) show_install_menu ;;
  esac
}

# Override remove menu: remove Windows VM, Dictation
show_remove_menu() {
  case $(menu "Remove" "󰣇  Package\n  Web App\n  TUI\n󰵮  Development\n󰏓  Preinstalls\n󰸌  Theme\n󰈷  Fingerprint\n  Fido2") in
  *Package*) terminal omarchy-pkg-remove ;;
  *Web*) present_terminal omarchy-webapp-remove ;;
  *TUI*) present_terminal omarchy-tui-remove ;;
  *Development*) show_remove_development_menu ;;
  *Preinstalls*) present_terminal omarchy-remove-preinstalls ;;
  *Theme*) present_terminal omarchy-theme-remove ;;
  *Fingerprint*) present_terminal "omarchy-setup-fingerprint --remove" ;;
  *Fido2*) present_terminal "omarchy-setup-fido2 --remove" ;;
  *) show_main_menu ;;
  esac
}

# Override style menu: keep About action in terminal (fastfetch)
show_style_menu() {
  case $(menu "Style" "󰸌  Theme\n󰌚  Font\n󰅒  Background\n󰕆  Hyprland\n󱄄  Screensaver\n󰋽  About") in
  *Theme*) show_theme_menu ;;
  *Font*) show_font_menu ;;
  *Background*) show_background_menu ;;
  *Hyprland*) open_in_editor ~/.config/hypr/looknfeel.conf ;;
  *Screensaver*) open_in_editor ~/.config/omarchy/branding/screensaver.txt ;;
  *About*) show_about ;;
  *) show_main_menu ;;
  esac
}
