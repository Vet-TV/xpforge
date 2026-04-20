#!/bin/bash
# XPForge Installer v0.1
# Sets up a complete Windows XP recreation environment on Ubuntu/Debian-based Linux
# Run with: chmod +x scripts/install.sh && ./scripts/install.sh
# Requires: Ubuntu 22.04/24.04 or Debian 12+ , sudo access, ~30GB free space

set -e  # Exit on error

echo "=============================================="
echo "   XPForge - Windows XP Recreation Installer"
echo "   Version 0.1 | April 2026"
echo "=============================================="
echo ""
echo "This will transform your system into a nostalgic yet powerful XP-like desktop."
echo "It installs XFCE + Chicago95 theme, Wine/Proton, Steam, Lutris, DOSBox, RetroArch, etc."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
else
    echo "Cannot detect distro. Assuming Ubuntu/Debian."
    DISTRO="ubuntu"
fi

echo "Detected: $DISTRO $VERSION"
echo ""

# Update system
echo "[1/12] Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install base desktop
echo "[2/12] Installing XFCE desktop environment and LightDM..."
sudo apt install -y xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xfce4-panel-profiles \
    picom compton xfce4-whiskermenu-plugin xfce4-appmenu-plugin

# Install build essentials and git
echo "[3/12] Installing development tools..."
sudo apt install -y build-essential git curl wget unzip p7zip-full \
    software-properties-common apt-transport-https ca-certificates gnupg

# Add Wine repository (for latest Wine 11+)
echo "[4/12] Adding WineHQ repository for Wine 11..."
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/winehq.list
sudo apt update -y
sudo apt install -y --install-recommends winehq-staging winetricks

# Install Steam
echo "[5/12] Installing Steam (with Proton support)..."
sudo apt install -y steam

# Install Lutris and Heroic
echo "[6/12] Installing Lutris (game manager) and Heroic Games Launcher..."
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo apt update -y
sudo apt install -y lutris

# Heroic via AppImage or flatpak (simpler)
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.heroicgameslauncher.hgl

# Install Retro gaming tools
echo "[7/12] Installing retro emulation suite (DOSBox, RetroArch, ScummVM)..."
sudo apt install -y dosbox-staging dosbox-x scummvm retroarch \
    libretro-core-info libretro-beetle-psx libretro-mupen64plus libretro-snes9x \
    libretro-genesis-plus-gx libretro-fbneo

# Install Chicago95 theme (core of XP look)
echo "[8/12] Installing Chicago95 - Windows 95/98/XP theme for XFCE..."
cd /tmp
git clone https://github.com/grassmunk/Chicago95.git
cd Chicago95
sudo ./install.sh   # Follows their installer

# Additional XP icons, cursors, sounds (open source recreations)
echo "[9/12] Installing additional XP assets and customizations..."
sudo apt install -y xfce4-theme-switcher
# Create XP-specific directories
mkdir -p ~/.icons ~/.themes ~/.local/share/applications
# Note: Chicago95 already provides most; we add tweaks below

# Configure XFCE for XP look
echo "[10/12] Applying XP panel layout and desktop settings..."
# Backup current config
xfce4-panel --quit
cp -r ~/.config/xfce4 ~/.config/xfce4.bak.$(date +%s) 2>/dev/null || true

# Use Chicago95 recommended panel profile (they provide one)
# For demo, we create a simple XP-like layout via commands
xfconf-query -c xfce4-panel -p /panels/panel-0/position -s "p=8;x=0;y=0"  # Top? No, bottom for taskbar
# Actually, Chicago95 installer usually handles this. We add extras:
xfconf-query -c xfwm4 -p /general/theme -s "Chicago95"
xfconf-query -c xsettings -p /Net/ThemeName -s "Chicago95"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Chicago95"
xfconf-query -c xfwm4 -p /general/button_layout -s "O|HMC"  # Minimize, Maximize, Close like XP

# Set wallpaper (use a public domain XP-like or Chicago95 default)
# For now, set a solid color or note user to add their own
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "/usr/share/backgrounds/xfce/xfce-blue.jpg" 2>/dev/null || true

# Install custom launchers and menu items
echo "[11/12] Creating XP-style Start Menu items and desktop icons..."
cat > ~/.local/share/applications/my-computer.desktop << EOF
[Desktop Entry]
Name=My Computer
Comment=Browse your files and drives
Exec=thunar ~
Icon=computer
Terminal=false
Type=Application
Categories=System;
EOF

cat > ~/.local/share/applications/recycle-bin.desktop << EOF
[Desktop Entry]
Name=Recycle Bin
Comment=View deleted files
Exec=thunar trash:///
Icon=user-trash-full
Terminal=false
Type=Application
Categories=Utility;
EOF

# Add to desktop
cp ~/.local/share/applications/my-computer.desktop ~/Desktop/
cp ~/.local/share/applications/recycle-bin.desktop ~/Desktop/
chmod +x ~/Desktop/*.desktop

# Create Retro Games and My Games folders
mkdir -p ~/Desktop/Retro\ Games ~/Desktop/My\ Games
echo "Add your retro ISOs and DOS games here!" > ~/Desktop/Retro\ Games/README.txt
echo "Add modern Windows games or shortcuts here!" > ~/Desktop/My\ Games/README.txt

# Configure DOSBox
echo "[12/12] Finalizing DOSBox and ReactOS VM setup..."
mkdir -p ~/dosbox
cat > ~/dosbox/dosbox.conf << 'EOF'
# XPForge DOSBox config - Classic MS-DOS feel
[sdl]
fullscreen=false
fulldouble=false
fullresolution=original
windowresolution=1024x768
output=opengl
autolock=false

[dosbox]
machine=svga_s3
memsize=64

[render]
frameskip=0
aspect=true
scaler=normal2x

[cpu]
core=normal
cputype=auto
cycles=auto

[mixer]
nosound=false
rate=44100
blocksize=1024
prebuffer=20

[autoexec]
mount C ~/dosbox
C:
dir
EOF

# Optional ReactOS VM script (creates launcher)
cat > ~/Desktop/ReactOS-VM.desktop << EOF
[Desktop Entry]
Name=ReactOS VM (Native XP Compatibility)
Comment=Run latest ReactOS in QEMU for true Windows NT apps
Exec=qemu-system-x86_64 -m 2048 -smp 2 -enable-kvm -cpu host -drive file=~/reactos/reactos.img,format=raw -net nic -net user -usb -device usb-tablet -vga std -display gtk
Icon=computer
Terminal=false
Type=Application
Categories=System;
EOF
chmod +x ~/Desktop/ReactOS-VM.desktop

# Create post-install note
cat > ~/Desktop/XPForge-PostInstall-README.txt << EOF
XPForge Post-Installation Notes
================================

1. Log out and back in (select XFCE session if prompted).
2. Right-click desktop → "Desktop Settings" to tweak wallpaper (add your XP wallpaper).
3. Launch Steam: Steam → Settings → Steam Play → Enable Proton for all titles.
   - Use Proton-GE for best results (install via ProtonUp-QT from Discover/Flathub).
4. For retro games: Add ROMs to ~/Retro Games or use RetroArch GUI.
5. DOS games: Put .exe in ~/dosbox and run 'dosbox' from terminal or use the config.
6. ReactOS VM: Install QEMU if not present: sudo apt install qemu-kvm
   Then download ReactOS ISO/nightly from reactos.org and update the .desktop file.
7. To switch themes: Menu → Settings → Appearance → Chicago95 variants.
8. For even more authentic XP: Install "Windows XP sounds" pack (legally from your own XP install or free recreations).

Enjoy the nostalgia! Report issues at github.com/xpforge/xpforge
EOF

echo ""
echo "=============================================="
echo "   Installation Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "1. Log out of your current session."
echo "2. At login screen, select 'XFCE Session'."
echo "3. Enjoy your new Windows XP desktop!"
echo ""
echo "See ~/Desktop/XPForge-PostInstall-README.txt for more tips."
echo ""
echo "Thank you for using XPForge. Long live the blue taskbar!"
echo ""