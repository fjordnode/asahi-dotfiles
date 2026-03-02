#!/bin/bash
set -e

BUILD_DIR="$HOME/hyprland-build"
mkdir -p "$BUILD_DIR"

echo "=== Step 1: Build & install xkbcommon 1.11.0 ==="
cd "$BUILD_DIR"
if [ ! -d libxkbcommon ]; then
    git clone --depth 1 --branch xkbcommon-1.11.0 https://github.com/xkbcommon/libxkbcommon.git
fi
cd libxkbcommon
rm -rf build
meson setup build -Dprefix=/usr -Denable-docs=false -Denable-wayland=true -Denable-x11=true
ninja -C build
sudo ninja -C build install
sudo ldconfig

echo "=== Step 2: Clone & patch Hyprland 0.54.0 ==="
cd "$BUILD_DIR"
if [ ! -d Hyprland ]; then
    git clone --recursive https://github.com/hyprwm/Hyprland.git
fi
cd Hyprland
git checkout v0.54.0
git submodule update --init --recursive

# Patch: fix null pointer crash with Apple GPU DRM modifiers
sed -i 's/std::string name = n;/std::string name = n ? n : "UNKNOWN";/' src/helpers/Format.cpp
echo "Applied Apple GPU DRM modifier fix to Format.cpp"

echo "=== Step 3: Build Hyprland ==="
rm -rf build
cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DNO_NIX=1
ninja -C build Hyprland hyprctl hyprpm

echo ""
echo "=== Build complete! ==="
echo "To install: sudo ninja -C $BUILD_DIR/Hyprland/build install"
echo "Then log out and back in."
