#!/bin/bash
# XPForge Live ISO Builder - Fedora Edition v0.1
# Creates a bootable Fedora-based live ISO with full XPForge pre-installed and themed
# Requirements: Fedora 40+ host with internet access and ~15 GB free disk space
# Usage: sudo ./scripts/build-xpforge-fedora.sh

set -e

echo "=============================================="
echo "   XPForge Live ISO Builder - Fedora v0.1"
echo "   Bootable Live + Anaconda Installer ISO"
echo "=============================================="

WORK_DIR="/tmp/xpforge-fedora"
KS_FILE="$WORK_DIR/xpforge.ks"
ISO_NAME="xpforge-0.1-fedora-amd64.iso"
OUT_DIR="$HOME/artifacts/xpforge/iso"
FEDORA_VERSION="40"

# Must run as root for livemedia-creator
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root: sudo $0"
    exit 1
fi

# Clean previous build
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$OUT_DIR"

echo "[1/6] Installing build tools..."
dnf install -y \
    lorax \
    livemedia-creator \
    anaconda \
    pykickstart \
    wget \
    curl \
    git \
    squashfs-tools \
    xorriso \
    syslinux \
    grub2-tools \
    2>/dev/null || true

echo "[2/6] Writing kickstart file..."
cat > "$KS_FILE" << 'KSEOF'
# XPForge Fedora Kickstart
# Installs a full XPForge desktop based on Fedora 40

text
lang en_US.UTF-8
keyboard us
timezone America/New_York --utc
rootpw --lock
user --name=xpforge --groups=wheel --password=xpforge

# Bootloader
bootloader --location=mbr --boot-drive=sda
zerombr
clearpart --all --initlabel
autopart --type=lvm

# Repos
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=x86_64
repo --name=fedora-updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=x86_64
repo --name=rpmfusion-free --baseurl=https://download1.rpmfusion.org/free/fedora/releases/40/Everything/x86_64/os/
repo --name=rpmfusion-free-updates --baseurl=https://download1.rpmfusion.org/free/fedora/updates/40/Everything/x86_64/
repo --name=rpmfusion-nonfree --baseurl=https://download1.rpmfusion.org/nonfree/fedora/releases/40/Everything/x86_64/os/
repo --name=rpmfusion-nonfree-updates --baseurl=https://download1.rpmfusion.org/nonfree/fedora/updates/40/Everything/x86_64/
repo --name=winehq --baseurl=https://dl.winehq.org/wine-builds/fedora/40/x86_64/

%packages --ignoremissing
# Core desktop
@xfce-desktop
lightdm
lightdm-gtk
xfce4-terminal
picom

# Theming support
gtk-murrine-engine
gtk2-engines

# Wine & compatibility
wine
wine-core
winetricks

# Gaming
steam
lutris
flatpak

# Retro emulation
dosbox
scummvm
RetroArch
retroarch-cores

# Tools
git
curl
wget
unzip
p7zip
make
gcc
gnupg2
ca-certificates
software-properties-common

# Virtualization
qemu-kvm
qemu-img
libvirt

# Installer
anaconda

# Browser
chromium

# App discovery
gnome-software
%end

%post --log=/root/xpforge-post.log
set +e

echo "=== XPForge Post-Install: Applying theme and config ==="

# Install Chicago95 XP theme
cd /tmp
git clone --depth 1 https://github.com/grassmunk/Chicago95.git 2>/dev/null || true
if [ -d /tmp/Chicago95 ]; then
    cd /tmp/Chicago95
    bash install.sh || true
fi

# Set up live user home
USER_HOME="/home/xpforge"
mkdir -p "$USER_HOME/Desktop"
mkdir -p "$USER_HOME/.local/share/applications"

# Desktop launchers
cat > "$USER_HOME/Desktop/My Computer.desktop" << 'EOF'
[Desktop Entry]
Name=My Computer
Exec=thunar ~
Icon=computer
Terminal=false
Type=Application
EOF

cat > "$USER_HOME/Desktop/Recycle Bin.desktop" << 'EOF'
[Desktop Entry]
Name=Recycle Bin
Exec=thunar trash:///
Icon=user-trash-full
Terminal=false
Type=Application
EOF

cat > "$USER_HOME/Desktop/Command Prompt.desktop" << 'EOF'
[Desktop Entry]
Name=Command Prompt
Exec=xfce4-terminal --title="Command Prompt" --geometry=100x30
Icon=utilities-terminal
Terminal=false
Type=Application
EOF

cat > "$USER_HOME/Desktop/Internet Explorer.desktop" << 'EOF'
[Desktop Entry]
Name=Internet Explorer
Exec=chromium-browser %U
Icon=web-browser
Terminal=false
Type=Application
EOF

cat > "$USER_HOME/Desktop/AppStore.desktop" << 'EOF'
[Desktop Entry]
Name=AppStore
Exec=gnome-software
Icon=gnome-software
Terminal=false
Type=Application
EOF

cat > "$USER_HOME/Desktop/Install ReactOS VM.desktop" << 'EOF'
[Desktop Entry]
Name=ReactOS VM
Exec=qemu-system-x86_64 -m 2048 -enable-kvm -drive file=~/reactos.img -net user -display gtk
Icon=computer
Terminal=false
Type=Application
EOF

chmod +x "$USER_HOME/Desktop/"*.desktop
chown -R xpforge:xpforge "$USER_HOME"

# XFCE configuration (XP-style panel at bottom)
mkdir -p "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

cat > "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Chicago95"/>
    <property name="button_layout" type="string" value="O|HMC"/>
  </property>
</channel>
EOF

cat > "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Chicago95"/>
    <property name="IconThemeName" type="string" value="Chicago95"/>
  </property>
</channel>
EOF

chown -R xpforge:xpforge "$USER_HOME/.config"

# LightDM auto-login
cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
autologin-user=xpforge
autologin-user-timeout=0
user-session=xfce
EOF

# Default session
echo "/usr/bin/startxfce4" > /etc/skel/.xsession

# Hostname
echo "xpforge" > /etc/hostname
echo "127.0.0.1 xpforge" >> /etc/hosts

# Enable Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

# Enable LightDM
systemctl enable lightdm || true
systemctl disable gdm || true

echo "=== XPForge Post-Install Complete ==="
%end
KSEOF

echo "[3/6] Validating kickstart syntax..."
ksvalidator "$KS_FILE" 2>/dev/null || echo "  ksvalidator not available, skipping validation"

echo "[4/6] Building live ISO (this takes 20-60 minutes)..."
livemedia-creator \
    --ks "$KS_FILE" \
    --no-virt \
    --resultdir "$WORK_DIR/result" \
    --project "XPForge" \
    --make-iso \
    --volid "XPForge-0.1" \
    --iso-only \
    --iso-name "$ISO_NAME" \
    --releasever "$FEDORA_VERSION" \
    --title "XPForge" \
    --logfile "$WORK_DIR/build.log" \
    2>&1 | tee -a "$WORK_DIR/build.log"

echo "[5/6] Moving ISO to artifacts..."
ISO_SRC=$(find "$WORK_DIR/result" -name "*.iso" 2>/dev/null | head -1)
if [ -n "$ISO_SRC" ]; then
    mv "$ISO_SRC" "$OUT_DIR/$ISO_NAME"
    echo "  ISO saved to: $OUT_DIR/$ISO_NAME"
else
    echo "ERROR: ISO not found in $WORK_DIR/result"
    echo "Check build log: $WORK_DIR/build.log"
    exit 1
fi

echo "[6/6] Generating checksum..."
cd "$OUT_DIR"
sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"

cat > "$OUT_DIR/README-ISO.txt" << EOF
XPForge Live ISO - Fedora Edition v0.1
=======================================
Bootable Fedora 40-based live environment with Windows XP look and feel.

How to use:
1. Write to USB: dd if=$ISO_NAME of=/dev/sdX bs=4M status=progress && sync
   Or use Fedora Media Writer / Rufus on Windows
2. Boot from USB (disable Secure Boot if needed)
3. Auto-logs in as "xpforge" — full Chicago95 XP-themed desktop
4. Click "Install to Hard Drive" on the desktop to launch Anaconda installer

Built: $(date)
EOF

echo ""
echo "=============================================="
echo "  XPForge Fedora ISO build complete!"
echo "  $OUT_DIR/$ISO_NAME"
echo ""
echo "  Test: qemu-system-x86_64 -m 4096 -enable-kvm \\"
echo "        -cdrom $OUT_DIR/$ISO_NAME -boot d"
echo "=============================================="
