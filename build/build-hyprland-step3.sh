#!/bin/bash
set -e
cd ~/hyprland-build/Hyprland

# Comment out the start-hyprland target (needs glaze/Nix, not needed on Fedora)
sed -i 's|^add_subdirectory(start)|#add_subdirectory(start)|' CMakeLists.txt

rm -rf build
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DNO_NIX=1
ninja -C build

echo ""
echo "=== Build complete! ==="
echo "To install: sudo ninja -C ~/hyprland-build/Hyprland/build install"
echo "Then log out and back in."
