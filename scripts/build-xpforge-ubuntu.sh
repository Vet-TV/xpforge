#!/bin/bash
# XPForge Live ISO Builder - Ubuntu Edition v2.0 (WSL-compatible)
# Builds directly with debootstrap + squashfs + grub-mkrescue.
# Avoids live-build entirely, which has WSL initrd/symlink issues.
#
# Requirements: Ubuntu 24.04 WSL (tools installed automatically)
# Usage:        bash ./scripts/build-xpforge-ubuntu.sh
# Output:       ~/artifacts/xpforge/iso/xpforge-0.1-amd64.iso (~4 GB)
# Time:         20-45 minutes depending on internet speed

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
WORK_DIR="/tmp/xpforge-build"
CHROOT="$WORK_DIR/chroot"
ISO_ROOT="$WORK_DIR/iso"
OUT_DIR="$HOME/artifacts/xpforge/iso"
ISO_NAME="xpforge-0.1-amd64.iso"
MIRROR="http://archive.ubuntu.com/ubuntu"
DISTRO="noble"  # Ubuntu 24.04 LTS

echo "=============================================="
echo "   XPForge ISO Builder - Ubuntu v2.0 (WSL)"
echo "=============================================="

# ── Cleanup trap (always unmounts chroot on exit) ────────────────────────────
cleanup() {
    for mp in "$CHROOT/dev/pts" "$CHROOT/dev" "$CHROOT/proc" "$CHROOT/sys" "$CHROOT/run"; do
        sudo umount -lf "$mp" 2>/dev/null || true
    done
}
trap cleanup EXIT INT TERM

# ── Step 1: Build dependencies ───────────────────────────────────────────────
echo "[1/8] Installing build tools..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    grub-common \
    mtools \
    wget \
    git \
    curl \
    ca-certificates

# ── Step 2: Bootstrap base system ────────────────────────────────────────────
echo "[2/8] Bootstrapping Ubuntu 24.04 (noble) base..."
sudo rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

sudo debootstrap \
    --arch=amd64 \
    --include=ca-certificates,curl,wget,gnupg,software-properties-common \
    "$DISTRO" \
    "$CHROOT" \
    "$MIRROR"

# ── Step 3: Configure chroot ─────────────────────────────────────────────────
echo "[3/8] Configuring chroot..."

# Full apt sources
sudo tee "$CHROOT/etc/apt/sources.list" > /dev/null << EOF
deb $MIRROR $DISTRO           main restricted universe multiverse
deb $MIRROR ${DISTRO}-updates  main restricted universe multiverse
deb $MIRROR ${DISTRO}-security main restricted universe multiverse
EOF

# Prevent services starting during install
sudo tee "$CHROOT/usr/sbin/policy-rc.d" > /dev/null << 'EOF'
#!/bin/sh
exit 101
EOF
sudo chmod +x "$CHROOT/usr/sbin/policy-rc.d"

# Bind-mount pseudo-filesystems
sudo mount -t proc  none         "$CHROOT/proc"
sudo mount -t sysfs none         "$CHROOT/sys"
sudo mount --bind   /dev         "$CHROOT/dev"
sudo mount --bind   /dev/pts     "$CHROOT/dev/pts"
sudo mount -t tmpfs none         "$CHROOT/run"

# Write the in-chroot setup script
sudo tee "$CHROOT/tmp/setup.sh" > /dev/null << 'SETUP'
#!/bin/bash
# Runs inside the chroot; set +e so one failure doesn't abort everything.
set +e
export DEBIAN_FRONTEND=noninteractive
export LANG=C
export CRYPTSETUP=n  # Suppress cryptsetup warnings in initramfs

echo "--- [chroot] Writing full apt sources (main + universe + multiverse) ---"
cat > /etc/apt/sources.list << 'SOURCES'
deb http://archive.ubuntu.com/ubuntu noble           main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates   main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-security  main restricted universe multiverse
SOURCES

apt-get update -qq

echo "--- [chroot] Enabling i386 ---"
dpkg --add-architecture i386
apt-get update -qq

echo "--- [chroot] Adding WineHQ repo ---"
mkdir -p /etc/apt/keyrings
wget -qO /etc/apt/keyrings/winehq-archive.key \
    https://dl.winehq.org/wine-builds/winehq.key
echo "deb [signed-by=/etc/apt/keyrings/winehq-archive.key] \
https://dl.winehq.org/wine-builds/ubuntu/ noble main" \
    > /etc/apt/sources.list.d/winehq.list

echo "--- [chroot] Adding Microsoft Edge repo ---"
wget -qO /tmp/ms.asc https://packages.microsoft.com/keys/microsoft.asc
gpg --dearmor < /tmp/ms.asc > /etc/apt/keyrings/microsoft.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/edge stable main" \
    > /etc/apt/sources.list.d/microsoft-edge.list

echo "--- [chroot] Adding Lutris PPA ---"
add-apt-repository -y ppa:lutris-team/lutris 2>/dev/null || true

apt-get update -qq

echo "--- [chroot] Installing kernel ---"
apt-get install -y --no-install-recommends linux-generic initramfs-tools

echo "--- [chroot] Installing casper (Ubuntu live-boot) ---"
apt-get install -y --no-install-recommends casper || \
    echo "casper failed - ISO may not boot as live system"

echo "--- [chroot] Installing XFCE desktop ---"
apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    lightdm \
    lightdm-gtk-greeter \
    thunar \
    picom \
    gtk2-engines-pixbuf \
    gtk2-engines-murrine

echo "--- [chroot] Installing Wine ---"
apt-get install -y --no-install-recommends \
    winehq-staging \
    winetricks \
    || echo "Wine install failed - skipping"

echo "--- [chroot] Installing Steam ---"
apt-get install -y --no-install-recommends \
    steam-installer \
    || echo "Steam install failed - skipping"

echo "--- [chroot] Installing Microsoft Edge ---"
apt-get install -y --no-install-recommends \
    microsoft-edge-stable \
    || echo "Edge install failed - skipping"

echo "--- [chroot] Installing Lutris ---"
apt-get install -y --no-install-recommends \
    lutris \
    || echo "Lutris install failed - skipping"

echo "--- [chroot] Installing retro/gaming tools ---"
apt-get install -y --no-install-recommends \
    flatpak \
    dosbox \
    scummvm \
    retroarch \
    qemu-system-x86 \
    qemu-utils \
    || echo "Some retro tools failed - skipping"

echo "--- [chroot] Installing Calamares ---"
apt-get install -y --no-install-recommends \
    calamares \
    || echo "Calamares install failed - skipping"

echo "--- [chroot] Installing utilities ---"
apt-get install -y --no-install-recommends \
    git curl wget unzip p7zip p7zip-full \
    build-essential network-manager || \
    apt-get install -y --no-install-recommends \
        git curl wget unzip build-essential network-manager

echo "--- [chroot] Cleaning package cache ---"
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "--- [chroot] Installing Chicago95 XP theme ---"
cd /tmp
git clone --depth 1 https://github.com/grassmunk/Chicago95.git 2>/dev/null || true
[ -d /tmp/Chicago95 ] && bash /tmp/Chicago95/install.sh 2>/dev/null || true

echo "--- [chroot] Creating live user 'xpforge' ---"
useradd -m -s /bin/bash -G sudo,video,audio,cdrom,plugdev xpforge 2>/dev/null || true
echo "xpforge:xpforge" | chpasswd
echo "xpforge ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/xpforge
chmod 0440 /etc/sudoers.d/xpforge

echo "--- [chroot] Creating desktop launchers ---"
D="/home/xpforge/Desktop"
mkdir -p "$D"

cat > "$D/My Computer.desktop" << 'EOF'
[Desktop Entry]
Name=My Computer
Exec=thunar ~
Icon=computer
Terminal=false
Type=Application
EOF

cat > "$D/Recycle Bin.desktop" << 'EOF'
[Desktop Entry]
Name=Recycle Bin
Exec=thunar trash:///
Icon=user-trash-full
Terminal=false
Type=Application
EOF

cat > "$D/Command Prompt.desktop" << 'EOF'
[Desktop Entry]
Name=Command Prompt
Exec=xfce4-terminal --title="Command Prompt" --geometry=100x30
Icon=utilities-terminal
Terminal=false
Type=Application
EOF

cat > "$D/Internet Explorer.desktop" << 'EOF'
[Desktop Entry]
Name=Internet Explorer
Exec=microsoft-edge-stable %U
Icon=web-browser
Terminal=false
Type=Application
EOF

cat > "$D/AppStore.desktop" << 'EOF'
[Desktop Entry]
Name=AppStore
Exec=flatpak run org.gnome.Software
Icon=gnome-software
Terminal=false
Type=Application
EOF

cat > "$D/Install XPForge.desktop" << 'EOF'
[Desktop Entry]
Name=Install XPForge to Hard Drive
Exec=pkexec calamares
Icon=system-installer
Terminal=false
Type=Application
EOF

cat > "$D/ReactOS VM.desktop" << 'EOF'
[Desktop Entry]
Name=ReactOS VM
Exec=qemu-system-x86_64 -m 2048 -enable-kvm -drive file=/home/xpforge/reactos.img -netdev user,id=n1 -device e1000,netdev=n1 -display gtk
Icon=computer
Terminal=false
Type=Application
EOF

chmod +x "$D/"*.desktop
chown -R xpforge:xpforge /home/xpforge

echo "--- [chroot] Configuring LightDM auto-login ---"
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
autologin-user=xpforge
autologin-user-timeout=0
user-session=xfce
greeter-session=lightdm-gtk-greeter
EOF

echo "--- [chroot] Setting hostname and default session ---"
echo "xpforge" > /etc/hostname
echo "127.0.0.1  xpforge" >> /etc/hosts
echo "/usr/bin/startxfce4" > /etc/skel/.xsession

echo "--- [chroot] Enabling Flatpak ---"
flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

echo "--- [chroot] Generating initramfs ---"
# CRYPTSETUP=n avoids cryptsetup warnings; RESUME=none skips hibernation setup
CRYPTSETUP=n RESUME=none update-initramfs -u -k all 2>/dev/null || \
    echo "WARNING: initramfs generation had errors (may still boot)"

echo "=== Chroot setup complete ==="
SETUP

sudo chmod +x "$CHROOT/tmp/setup.sh"

# ── Step 4: Run setup inside chroot ──────────────────────────────────────────
echo "[4/8] Running setup inside chroot (20-40 min)..."
sudo chroot "$CHROOT" /bin/bash /tmp/setup.sh

sudo rm -f "$CHROOT/usr/sbin/policy-rc.d"
sudo rm -f "$CHROOT/tmp/setup.sh"

# ── Step 5: Assemble ISO directory tree ──────────────────────────────────────
echo "[5/8] Assembling ISO structure..."
mkdir -p "$ISO_ROOT/casper"
mkdir -p "$ISO_ROOT/boot/grub"
mkdir -p "$ISO_ROOT/.disk"

# Find kernel and initrd (pick newest if multiple)
KERNEL=$(ls "$CHROOT/boot/vmlinuz-"* 2>/dev/null | sort -V | tail -1 || true)
INITRD=$(ls "$CHROOT/boot/initrd.img-"* 2>/dev/null | sort -V | tail -1 || true)

if [ -z "$KERNEL" ]; then
    echo "ERROR: No kernel found in chroot. Aborting."
    exit 1
fi
echo "  Kernel : $KERNEL"
echo "  Initrd : ${INITRD:-NOT FOUND}"

sudo cp "$KERNEL" "$ISO_ROOT/casper/vmlinuz"

if [ -n "$INITRD" ] && [ -f "$INITRD" ]; then
    sudo cp "$INITRD" "$ISO_ROOT/casper/initrd"
else
    echo "ERROR: initrd not found. Run 'update-initramfs' manually in the chroot."
    exit 1
fi

# Disk metadata (casper uses this)
echo "XPForge 0.1" | sudo tee "$ISO_ROOT/.disk/info"         > /dev/null
touch "$ISO_ROOT/.disk/base_installable"
echo "full_cd"    | sudo tee "$ISO_ROOT/.disk/cd_type"        > /dev/null

# GRUB menu
cat > "$ISO_ROOT/boot/grub/grub.cfg" << 'GRUBCFG'
set default=0
set timeout=10

menuentry "XPForge 0.1  -  Live Session" {
    linux  /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}
menuentry "XPForge 0.1  -  Safe Graphics (nomodeset)" {
    linux  /casper/vmlinuz boot=casper nomodeset quiet splash ---
    initrd /casper/initrd
}
menuentry "Install XPForge to Hard Drive" {
    linux  /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
    initrd /casper/initrd
}
GRUBCFG

# ── Step 6: Build squashfs ───────────────────────────────────────────────────
echo "[6/8] Building squashfs (xz compression - takes a while)..."
sudo mksquashfs "$CHROOT" "$ISO_ROOT/casper/filesystem.squashfs" \
    -comp xz \
    -noappend \
    -e boot \
    2>&1 | grep -E "^(Parallel|Creating|Time|).*" | tail -5

# Write filesystem size (bytes, used by installer)
sudo du -sx --block-size=1 "$CHROOT" | cut -f1 \
    | sudo tee "$ISO_ROOT/casper/filesystem.size" > /dev/null

# ── Step 7: Create bootable ISO ──────────────────────────────────────────────
echo "[7/8] Creating bootable ISO..."
mkdir -p "$OUT_DIR"

# grub-mkrescue handles BIOS + UEFI hybrid automatically
sudo grub-mkrescue \
    --output="$OUT_DIR/$ISO_NAME" \
    "$ISO_ROOT" \
    -- \
    -volid "XPForge-0.1" \
    -joliet \
    -rational-rock

# ── Step 8: Checksum + summary ───────────────────────────────────────────────
echo "[8/8] Generating checksum..."
cd "$OUT_DIR"
sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
SIZE=$(du -sh "$ISO_NAME" | cut -f1)

cat > README-ISO.txt << EOF
XPForge Live ISO v0.1 - Ubuntu Edition
=======================================
Bootable Ubuntu 24.04 base with Windows XP look and feel.

Features: Chicago95 XP theme, Wine, Steam+Proton, Lutris,
          DOSBox, RetroArch, ScummVM, QEMU/ReactOS, Calamares installer.

Usage:
  USB:  dd if=$ISO_NAME of=/dev/sdX bs=4M status=progress && sync
        (or use Rufus / balenaEtcher on Windows)
  VM:   qemu-system-x86_64 -m 4096 -enable-kvm -cdrom $ISO_NAME -boot d

Built: $(date)
SHA256: $(cat "$ISO_NAME.sha256" | cut -d' ' -f1)
EOF

echo ""
echo "=============================================="
echo "  Build complete!"
echo "  $OUT_DIR/$ISO_NAME  ($SIZE)"
echo ""
echo "  Test with QEMU:"
echo "  qemu-system-x86_64 -m 4096 -enable-kvm \\"
echo "    -cdrom \"$OUT_DIR/$ISO_NAME\" -boot d"
echo "=============================================="
