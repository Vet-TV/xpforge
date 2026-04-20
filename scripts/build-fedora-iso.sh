#!/bin/bash
# XPForge Fedora KDE Live ISO Builder using Kiwi
# This creates a Fedora-based XPForge ISO

set -e

echo "=============================================="
echo "   XPForge Fedora KDE ISO Builder (Kiwi)"
echo "=============================================="

ISO_NAME="xpforge-fedora-0.6-amd64.iso"
WORK_DIR="/tmp/xpforge-fedora"

sudo rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "[1/6] Installing Kiwi and dependencies..."
sudo dnf install -y kiwi kiwi-systemdeps

echo "[2/6] Creating basic Fedora KDE profile..."
mkdir -p $WORK_DIR/xpforge

cat > $WORK_DIR/xpforge/config.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<image schemaversion="7.4" name="XPForge-Fedora">
    <description type="system">
        <author>XPForge Team</author>
        <contact>github.com/Vet-TV/xpforge</contact>
        <specification>XPForge - Windows XP Recreation on Fedora KDE</specification>
    </description>
    <preferences>
        <version>0.6.0</version>
        <packagemanager>dnf</packagemanager>
        <locale>en_US</locale>
        <keytable>us</keytable>
        <timezone>UTC</timezone>
        <rpm-check-signatures>false</rpm-check-signatures>
    </preferences>
    <repository type="rpm-md" alias="fedora" priority="1">
        <source path="https://download.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/"/>
    </repository>
    <packages type="image">
        <package name="kernel"/>
        <package name="grub2"/>
        <package name="systemd"/>
        <package name="NetworkManager"/>
        <package name="dracut"/>
        <package name="bash"/>
        <package name="coreutils"/>
        <package name="dnf"/>
        <package name="fedora-release"/>
        <package name="fedora-repos"/>
        <package name="glibc"/>
        <package name="systemd-udev"/>
        <package name="kde-plasma-desktop"/>
        <package name="sddm"/>
        <package name="plasma-desktop"/>
        <package name="dolphin"/>
        <package name="konsole"/>
        <package name="firefox"/>
        <package name="flatpak"/>
        <package name="git"/>
        <package name="wget"/>
        <package name="curl"/>
        <package name="unzip"/>
        <package name="dosbox"/>
        <package name="scummvm"/>
        <package name="retroarch"/>
        <package name="qemu-kvm"/>
    </packages>
    <packages type="bootstrap">
        <package name="filesystem"/>
        <package name="glibc"/>
        <package name="rpm"/>
        <package name="dnf"/>
    </packages>
</image>
EOF

echo "[3/6] Building the ISO with Kiwi (this takes 1-3 hours)..."
sudo kiwi-ng --profile=Live system build \
    --description $WORK_DIR/xpforge \
    --target-dir $WORK_DIR/output

echo "[4/6] Moving ISO..."
mkdir -p /home/workdir/artifacts/xpforge/iso
if [ -f $WORK_DIR/output/*.iso ]; then
    mv $WORK_DIR/output/*.iso /home/workdir/artifacts/xpforge/iso/$ISO_NAME
    echo "✅ SUCCESS! Fedora XPForge ISO created!"
else
    echo "❌ ERROR: ISO not found. Check output directory."
    exit 1
fi

echo "[5/6] Creating checksum..."
cd /home/workdir/artifacts/xpforge/iso
sha256sum $ISO_NAME > $ISO_NAME.sha256

echo "[6/6] Done!"
echo "ISO location: /home/workdir/artifacts/xpforge/iso/$ISO_NAME"