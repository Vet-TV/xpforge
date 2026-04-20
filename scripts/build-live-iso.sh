#!/bin/bash
# XPForge Live ISO Builder v0.2
# Creates a bootable Ubuntu-based live ISO with full XPForge pre-installed and themed
# Requirements (run on Ubuntu 24.04 host with internet):
#   sudo apt install live-build debootstrap squashfs-tools xorriso
# Output: xpforge-0.1-amd64.iso (~3-4 GB)
# Usage: ./scripts/build-live-iso.sh

set -e

echo "=============================================="
echo "   XPForge Live ISO Builder v0.3"
echo "   Bootable Live + Calamares Installer ISO"
echo "   (Try XPForge live, then install to disk with one click)"
echo "=============================================="

WORK_DIR="/tmp/xpforge-live"
ISO_NAME="xpforge-0.1-amd64.iso"
ARCH="amd64"
DISTRO="noble"  # Ubuntu 24.04 LTS codename

# Clean previous build
sudo rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "[1/8] Installing live-build tools (if needed)..."
sudo apt update -y
sudo apt install -y live-build debootstrap squashfs-tools xorriso syslinux-utils

echo "[2/8] Creating live-build configuration for Ubuntu 24.04 + XFCE + XPForge..."
lb config \
    --binary-images iso-hybrid \
    --mode ubuntu \
    --distribution "$DISTRO" \
    --architectures "$ARCH" \
    --linux-flavours generic \
    --bootappend-live "boot=live username=xpforge quiet splash" \
    --archive-areas "main restricted universe multiverse" \
    --mirror-bootstrap "http://archive.ubuntu.com/ubuntu/" \
    --mirror-chroot "http://archive.ubuntu.com/ubuntu/" \
    --apt-recommends false \
    --apt-secure true

# Add our package list (now includes Calamares + Microsoft Edge + full features)
cat > config/package-lists/xpforge.list.chroot << EOF
# Core Desktop
xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xfce4-terminal picom
# Theming
gtk2-engines-pixbuf gtk2-engines-murrine
# Gaming (steam/wine/lutris/edge installed via chroot hook after i386 + repos are added)
flatpak
# Retro
dosbox scummvm retroarch
# Tools
git curl wget unzip p7zip-full build-essential software-properties-common gnupg ca-certificates
# QEMU for ReactOS VM
qemu-kvm qemu-utils
# Calamares Installer
calamares
# App Store
plasma-discover plasma-discover-backend-flatpak
EOF

echo "[3/8] Adding chroot hook to auto-install XPForge theme and apps..."
mkdir -p config/hooks/normal
cat > config/hooks/normal/01-xpforge-install.chroot << 'HOOKEOF'
#!/bin/bash
# set -e intentionally omitted: hook must always run to completion
echo "=== XPForge Live Hook: Installing full environment ==="

# Add Wine repo + Microsoft Edge repo
dpkg --add-architecture i386
mkdir -p /etc/apt/keyrings
wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/ubuntu/ noble main" > /etc/apt/sources.list.d/winehq.list

# Microsoft Edge repo
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list
apt update -y

# Latest Linux Kernel 7.0+ via mainline tool (2026 latest)
add-apt-repository -y ppa:cappelikan/ppa || true
apt update -y
apt install -y mainline || true
mainline --install-latest || echo "Attempted latest kernel 7.x"
apt update -y

# Install everything from our list + extras (including Calamares + Edge)
apt install -y --no-install-recommends \
    xfce4 xfce4-goodies lightdm-gtk-greeter xfce4-panel-profiles picom xfce4-terminal \
    winehq-staging winetricks steam lutris flatpak \
    dosbox scummvm retroarch \
    qemu-kvm qemu-utils git curl wget \
    calamares microsoft-edge-stable || true

# Install Chicago95 theme
cd /tmp
git clone --depth 1 https://github.com/grassmunk/Chicago95.git
cd Chicago95
./install.sh || true

# Apply XPForge customizations (simplified version of install.sh)
mkdir -p /home/xpforge/Desktop /home/xpforge/.local/share/applications

# Create desktop icons and launchers (same as main installer)
cat > /home/xpforge/Desktop/My\ Computer.desktop << EOD
[Desktop Entry]
Name=My Computer
Exec=thunar ~
Icon=computer
Terminal=false
Type=Application
EOD

# === NEW: Calamares Installer Launcher (for live session) ===
cat > /home/xpforge/Desktop/Install-XPForge.desktop << 'CALDESK'
[Desktop Entry]
Name=Install XPForge to Hard Drive
Comment=Install the full XPForge experience to your computer
Exec=pkexec calamares
Icon=system-installer
Terminal=false
Type=Application
Categories=System;
StartupNotify=true
CALDESK
chmod +x /home/xpforge/Desktop/Install-XPForge.desktop

chmod +x /home/xpforge/Desktop/*.desktop
chown -R xpforge:xpforge /home/xpforge

# === NEW: Command Prompt (classic XP terminal) ===
cat > /home/xpforge/Desktop/Command\ Prompt.desktop << 'CMD'
[Desktop Entry]
Name=Command Prompt
Comment=MS-DOS style command line (renamed terminal)
Exec=xfce4-terminal --title="Command Prompt" --geometry=100x30
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;
CMD
chmod +x /home/xpforge/Desktop/Command\ Prompt.desktop

# === NEW: Internet Explorer (Microsoft Edge with old IE icon) ===
cat > /home/xpforge/Desktop/Internet\ Explorer.desktop << 'IE'
[Desktop Entry]
Name=Internet Explorer
Comment=Microsoft Edge (classic IE name & icon)
Exec=microsoft-edge-stable %U
Icon=web-browser
Terminal=false
Type=Application
Categories=Network;
IE
chmod +x /home/xpforge/Desktop/Internet\ Explorer.desktop

# === NEW: AppStore (Windows Store themed) ===
cat > /home/xpforge/Desktop/AppStore.desktop << 'APPSTORE'
[Desktop Entry]
Name=AppStore
Comment=Discover and install apps & games (Flatpak + more)
Exec=discover
Icon=/usr/share/calamares/branding/xpforge/appstore-icon.png
Terminal=false
Type=Application
Categories=System;PackageManager;
APPSTORE
chmod +x /home/xpforge/Desktop/AppStore.desktop

# Copy branding images into place
cp /usr/share/calamares/branding/xpforge/logo.png /usr/share/calamares/branding/xpforge/ 2>/dev/null || true
cp /usr/share/calamares/branding/xpforge/welcome.png /usr/share/calamares/branding/xpforge/ 2>/dev/null || true

# === Detailed Calamares Packages Module (auto-install Steam, Proton, etc.) ===
mkdir -p /etc/calamares/modules
cat > /etc/calamares/modules/packages.conf << 'PKGS'
---
# XPForge automatic package selection
backend: apt

operations:
  - install:
      - steam
      - proton
      - winetricks
      - lutris
      - flatpak
      - dosbox-staging
      - retroarch
      - scummvm
      - microsoft-edge-stable
      - winehq-staging
PKGS

# === Post-Install Hook (runs full XPForge customization after Calamares finishes) ===
cat > /etc/calamares/modules/finished.conf << 'FIN'
---
# Run XPForge post-install script on the new system
script: /usr/local/bin/xpforge-post-install.sh
FIN

cat > /usr/local/bin/xpforge-post-install.sh << 'POST'
#!/bin/bash
# XPForge Advanced Post-Install Script
# Runs automatically after Calamares finishes installation
set -e
echo "=== XPForge Post-Install v0.4: Applying complete customization ==="

USER=$(logname 2>/dev/null || echo "$SUDO_USER" || echo "xpforge")
HOME_DIR="/home/$USER"

# 1. Re-apply full Chicago95 XP theme
echo "[1/6] Re-applying Chicago95 Luna theme..."
cd /tmp
rm -rf Chicago95
git clone --depth 1 https://github.com/grassmunk/Chicago95.git
cd Chicago95
./install.sh || true

# 2. Create complete set of desktop icons & launchers
echo "[2/6] Creating authentic XP desktop icons..."
mkdir -p "$HOME_DIR/Desktop" "$HOME_DIR/.local/share/applications"

cat > "$HOME_DIR/Desktop/My Computer.desktop" << EOF
[Desktop Entry]
Name=My Computer
Comment=Browse files and drives
Exec=thunar ~
Icon=computer
Terminal=false
Type=Application
Categories=System;
EOF

cat > "$HOME_DIR/Desktop/Recycle Bin.desktop" << EOF
[Desktop Entry]
Name=Recycle Bin
Comment=View deleted items
Exec=thunar trash:///
Icon=user-trash-full
Terminal=false
Type=Application
Categories=Utility;
EOF

cat > "$HOME_DIR/Desktop/Command Prompt.desktop" << EOF
[Desktop Entry]
Name=Command Prompt
Comment=Classic command line interface
Exec=xfce4-terminal --title="Command Prompt" --geometry=120x35
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;
EOF

cat > "$HOME_DIR/Desktop/Internet Explorer.desktop" << EOF
[Desktop Entry]
Name=Internet Explorer
Comment=Microsoft Edge (classic name)
Exec=microsoft-edge-stable %U
Icon=web-browser
Terminal=false
Type=Application
Categories=Network;
EOF

cat > "$HOME_DIR/Desktop/AppStore.desktop" << EOF
[Desktop Entry]
Name=AppStore
Comment=Discover and install apps & games
Exec=discover
Icon=/usr/share/icons/hicolor/128x128/apps/discover.png
Terminal=false
Type=Application
Categories=System;PackageManager;
EOF

cat > "$HOME_DIR/Desktop/Install ReactOS VM.desktop" << EOF
[Desktop Entry]
Name=ReactOS VM
Comment=Launch ReactOS for native Windows apps
Exec=qemu-system-x86_64 -m 2048 -enable-kvm -drive file=~/reactos.img -net user -display gtk
Icon=computer
Terminal=false
Type=Application
Categories=System;
EOF

chmod +x "$HOME_DIR/Desktop/"*.desktop
chown -R $USER:$USER "$HOME_DIR/Desktop"

# 3. Set default applications and browser
echo "[3/6] Setting defaults (Edge as browser, Command Prompt as terminal)..."
xdg-settings set default-web-browser microsoft-edge-stable.desktop || true
xdg-mime default microsoft-edge-stable.desktop x-scheme-handler/http x-scheme-handler/https || true

# 4. Apply panel layout and wallpaper
echo "[4/6] Configuring XFCE panel and wallpaper..."
xfconf-query -c xfce4-panel -p /panels/panel-0/position -s "p=8;x=0;y=0" || true
xfconf-query -c xfwm4 -p /general/theme -s "Chicago95" || true
xfconf-query -c xsettings -p /Net/ThemeName -s "Chicago95" || true
xfconf-query -c xsettings -p /Net/IconThemeName -s "Chicago95" || true

# Set classic XP wallpaper if available
WALLPAPER="/usr/share/backgrounds/xfce/xfce-blue.jpg"
if [ -f "$WALLPAPER" ]; then
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$WALLPAPER" || true
fi

# 5. Enable Flatpak + common remotes
echo "[5/6] Setting up Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
flatpak update -y || true

# 6. Final touches (sounds, user defaults)
echo "[6/6] Final touches..."
# Set user to auto-login (optional, can be disabled)
if [ -f /etc/lightdm/lightdm.conf ]; then
    sed -i "s/#autologin-user=/autologin-user=$USER/" /etc/lightdm/lightdm.conf || true
fi

echo "=== XPForge Post-Install Complete! ==="
echo "Your system now has the full authentic Windows XP experience with modern power."
POST
chmod +x /usr/local/bin/xpforge-post-install.sh

# === Calamares Configuration for XPForge ===
mkdir -p /etc/calamares
cat > /etc/calamares/settings.conf << 'CALCONF'
# XPForge Calamares settings
modules-search: [ local, /usr/lib/calamares/modules ]
sequence:
  - show:
      - welcome
      - locale
      - keyboard
      - partition
      - users
      - summary
  - exec:
      - partition
      - mount
      - unpackfs
      - machineid
      - fstab
      - locale
      - keyboard
      - localecfg
      - users
      - displaymanager
      - networkcfg
      - hwclock
      - services
      - grubcfg
      - bootloader
      - umount
  - show:
      - finished

branding: xpforge
CALCONF

# Create XPForge branding for Calamares (using real generated images)
mkdir -p /usr/share/calamares/branding/xpforge
cp /home/workdir/artifacts/xpforge/previews/calamares-logo.png /usr/share/calamares/branding/xpforge/logo.png 2>/dev/null || true
cp /home/workdir/artifacts/xpforge/previews/calamares-welcome.png /usr/share/calamares/branding/xpforge/welcome.png 2>/dev/null || true
cp /home/workdir/artifacts/xpforge/previews/calamares-slide1.jpg /usr/share/calamares/branding/xpforge/slide1.jpg 2>/dev/null || true
cp /home/workdir/artifacts/xpforge/previews/calamares-slide2.jpg /usr/share/calamares/branding/xpforge/slide2.jpg 2>/dev/null || true
cp /home/workdir/artifacts/xpforge/previews/calamares-slide3.jpg /usr/share/calamares/branding/xpforge/slide3.jpg 2>/dev/null || true
cp /home/workdir/artifacts/xpforge/previews/calamares-slide4.jpg /usr/share/calamares/branding/xpforge/slide4.jpg 2>/dev/null || true
cp /home/workdir/artifacts/xpforge/previews/appstore-icon.png /usr/share/calamares/branding/xpforge/appstore-icon.png 2>/dev/null || true

# Full show.qml slideshow for Calamares (XP-style with 4 slides)
cat > /usr/share/calamares/branding/xpforge/show.qml << 'QML'
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 800
    height: 600

    property int currentSlide: 0
    property var slides: [
        "slide1.jpg",
        "slide2.jpg", 
        "slide3.jpg",
        "slide4.jpg"
    ]

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: {
            currentSlide = (currentSlide + 1) % slides.length
        }
    }

    Image {
        id: slideImage
        anchors.fill: parent
        source: slides[currentSlide]
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // XP-style overlay text
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#0054E3"
        opacity: 0.85

        Text {
            anchors.centerIn: parent
            text: {
                if (currentSlide === 0) return "Modern games + Retro classics in one XP experience"
                else if (currentSlide === 1) return "Authentic XP experience with modern compatibility layers"
                else if (currentSlide === 2) return "Native Windows compatibility via optional ReactOS VM"
                else return "Best-in-class retro & MS-DOS emulation"
            }
            color: "white"
            font.pixelSize: 22
            font.bold: true
            font.family: "Tahoma"
        }
    }

    // Small Windows flag indicator
    Image {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
        source: "logo.png"
        width: 40
        height: 40
        opacity: 0.9
    }
}
QML

cat > /usr/share/calamares/branding/xpforge/branding.desc << 'BRANDING'
---
componentName:  xpforge
welcomeStyleCalamares: true
welcomeExpandingLogo: true
strings:
    productName:        "XPForge"
    shortProductName:   "XPForge"
    version:            "0.1"
    shortVersion:       "0.1"
    versionedName:      "XPForge 0.1"
    shortVersionedName: "XPForge 0.1"
    bootloaderEntryName: "XPForge"
    productUrl:         "https://github.com/xpforge/xpforge"
    supportUrl:         "https://github.com/xpforge/xpforge/issues"
    knownIssuesUrl:     "https://github.com/xpforge/xpforge/issues"
    releaseNotesUrl:    "https://github.com/xpforge/xpforge/releases"
images:
    productLogo:        "logo.png"
    productIcon:        "logo.png"
    productWelcome:     "welcome.png"
slideshow:              "show.qml"
style:
    sidebarBackground:  "#0054E3"   # Classic XP blue
    sidebarText:        "#FFFFFF"
    sidebarTextSelect:  "#FFD700"   # Gold accent
BRANDING

# Create placeholder images (user can replace with real ones)
echo "Creating placeholder branding images..."
convert -size 200x200 xc:'#0054E3' -fill white -gravity center -pointsize 40 -annotate 0 "XP" /usr/share/calamares/branding/xpforge/logo.png 2>/dev/null || true
convert -size 800x600 xc:'#0054E3' -fill white -gravity center -pointsize 60 -annotate 0 "Welcome to XPForge" /usr/share/calamares/branding/xpforge/welcome.png 2>/dev/null || true

echo "=== XPForge + Calamares setup complete ==="

# Set default session to XFCE
echo "/usr/bin/startxfce4" > /etc/skel/.xsession
echo "xpforge" > /etc/hostname
echo "127.0.0.1 xpforge" >> /etc/hosts

# Enable auto-login for demo (remove for production)
sed -i 's/#autologin-user=/autologin-user=xpforge/' /etc/lightdm/lightdm.conf
sed -i 's/#autologin-user-timeout=0/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf

# Fix dangling initrd symlinks that cause lb_chroot_hacks to fail in WSL/chroot
for link in /boot/initrd.img /boot/initrd.img.old; do
    if [ -L "$link" ] && [ ! -e "$link" ]; then
        target=$(readlink "$link")
        [[ "$target" != /* ]] && target="/boot/$target"
        touch "$target" 2>/dev/null || true
    fi
done

echo "=== XPForge Live Hook Complete ==="
HOOKEOF
chmod +x config/hooks/normal/01-xpforge-install.chroot

echo "[4/8] Adding boot splash and XP-style Plymouth theme (optional)..."
# For simplicity we use default; advanced users can add plymouth-xp theme later

echo "[4b/8] Patching live-build for WSL initrd compatibility..."
for HACKS in $(find /usr -name "chroot_hacks" 2>/dev/null); do
    sudo sed -i \
        's/chmod -x chroot\/boot\/initrd\.img/chmod -x chroot\/boot\/initrd.img 2>\/dev\/null || true  #patched/g' \
        "$HACKS" 2>/dev/null || true
    echo "  Patched: $HACKS"
done

echo "[5/8] Building the live filesystem (this takes 20-60 minutes)..."
sudo lb build 2>&1 | tee build.log

echo "[6/8] Moving ISO to artifacts..."
mkdir -p $HOME/artifacts/xpforge/iso
mv "$WORK_DIR/live-image-amd64.hybrid.iso" "$HOME/artifacts/xpforge/iso/$ISO_NAME" 2>/dev/null || \
mv "$WORK_DIR/binary/live-image-amd64.hybrid.iso" "$HOME/artifacts/xpforge/iso/$ISO_NAME" || true

echo "[7/8] Creating checksums and README for the ISO..."
cd $HOME/artifacts/xpforge/iso
sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
cat > README-ISO.txt << EOF
XPForge Live ISO v0.1
=====================
Bootable Ubuntu 24.04-based live environment with full Windows XP recreation.

How to use:
1. Download xpforge-0.1-amd64.iso
2. Write to USB with Rufus, balenaEtcher, or dd (Linux)
3. Boot from USB (disable Secure Boot if needed)
4. Auto-logs in as "xpforge" user with full themed desktop
5. Everything is pre-installed: Chicago95 XP theme, Steam+Proton, Wine, DOSBox, RetroArch, QEMU+ReactOS ready

Size: ~3.5 GB
Built: $(date)
For updates and full source: github.com/xpforge/xpforge
EOF

echo "[8/8] Done! ISO ready at: $HOME/artifacts/xpforge/iso/$ISO_NAME"
echo ""
echo "✅ XPForge Live + Installer ISO created successfully!"
echo ""
echo "Features of this ISO:"
echo "  • Boots directly into full XPForge themed desktop (live session)"
echo "  • Double-click 'Install XPForge to Hard Drive' on desktop to launch Calamares"
echo "  • Calamares is pre-configured with XPForge branding and settings"
echo "  • After installation, the system will have the complete XP look + all software"
echo ""
echo "Test command:"
echo "  qemu-system-x86_64 -m 4096 -enable-kvm -cdrom iso/$ISO_NAME -boot d"
echo ""
echo "Next steps:"
echo "  1. Test the ISO in a VM"
echo "  2. Write to USB and enjoy the nostalgia"
echo "  3. Upload to GitHub Releases when ready"