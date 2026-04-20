#!/bin/bash
# XPForge Live ISO Builder - Fixed Version for Ubuntu 24.04
# This version has better compatibility with current live-build

set -e

echo "=============================================="
echo "   XPForge Live ISO Builder (Fixed v0.6)"
echo "   Bootable Live + Calamares Installer"
echo "=============================================="

WORK_DIR="/tmp/xpforge-live"
ISO_NAME="xpforge-0.6-amd64.iso"
ARCH="amd64"
DISTRO="noble"

sudo rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "[1/7] Installing live-build tools..."
sudo apt update -y
sudo apt install -y live-build debootstrap squashfs-tools xorriso syslinux-utils

echo "[2/7] Creating live-build configuration..."
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

echo "[3/7] Adding package list..."
cat > config/package-lists/xpforge.list.chroot << EOF
xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xfce4-panel-profiles picom xfce4-terminal
gtk2-engines-pixbuf gtk2-engines-murrine
flatpak
dosbox-staging dosbox-x scummvm retroarch
qemu-kvm qemu-utils git curl wget unzip
calamares
EOF

echo "[4/7] Adding chroot hook..."
mkdir -p config/hooks/normal
cat > config/hooks/normal/01-xpforge-install.chroot << 'HOOKEOF'
#!/bin/bash
set -e
echo "=== XPForge Live Hook ==="

# Add necessary repositories
add-apt-repository -y ppa:lutris-team/lutris || true
add-apt-repository -y ppa:cappelikan/ppa || true
apt update -y

# Install packages (using available ones)
apt install -y --no-install-recommends \
    xfce4 xfce4-goodies lightdm-gtk-greeter xfce4-panel-profiles picom \
    flatpak lutris dosbox-staging dosbox-x scummvm retroarch \
    qemu-kvm qemu-utils git curl wget calamares

# Install Chicago95 theme
cd /tmp
git clone --depth 1 https://github.com/grassmunk/Chicago95.git || true
cd Chicago95 && ./install.sh || true

# Create desktop launchers
mkdir -p /home/xpforge/Desktop
cat > /home/xpforge/Desktop/Install-XPForge.desktop << 'EOD'
[Desktop Entry]
Name=Install XPForge
Comment=Install to hard drive
Exec=pkexec calamares
Icon=system-installer
Terminal=false
Type=Application
EOD
chmod +x /home/xpforge/Desktop/*.desktop
chown -R xpforge:xpforge /home/xpforge
HOOKEOF
chmod +x config/hooks/normal/01-xpforge-install.chroot

echo "[5/7] Building the ISO (this takes a long time)..."
sudo lb build 2>&1 | tee build.log

echo "[6/7] Moving ISO..."
mkdir -p /home/workdir/artifacts/xpforge/iso
if [ -f binary/live-image-amd64.hybrid.iso ]; then
    mv binary/live-image-amd64.hybrid.iso /home/workdir/artifacts/xpforge/iso/$ISO_NAME
    echo "ISO created successfully!"
else
    echo "ERROR: ISO file not found. Check build.log for details."
    exit 1
fi

echo "[7/7] Done!"
echo "ISO location: /home/workdir/artifacts/xpforge/iso/$ISO_NAME"