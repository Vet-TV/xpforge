#!/bin/bash
# XPForge Post-Install Script v0.1
# Run this AFTER the main install.sh and after first login with XFCE

echo "XPForge Post-Install: Final tweaks and ReactOS VM setup"
echo ""

# Install ProtonUp-QT for easy Proton-GE management (Flatpak or AppImage)
echo "Installing ProtonUp-QT for Proton-GE..."
flatpak install -y flathub net.davidotek.pupgui2

# Enable NTSYNC if kernel supports (2026+ Ubuntu/Debian often does)
echo "Checking for NTSYNC kernel module (huge performance boost for Proton)..."
if lsmod | grep -q ntsync; then
    echo "NTSYNC already loaded. Great!"
else
    echo "Attempting to load NTSYNC (may require kernel 6.8+ or manual compile)..."
    sudo modprobe ntsync 2>/dev/null || echo "NTSYNC not available in this kernel. Proton will still work great, but slightly slower in some titles."
fi

# Wine prefix setup for XP feel (optional)
echo "Creating a 'Windows XP' Wine prefix for legacy apps..."
WINEARCH=win32 WINEPREFIX=~/.wine-xp winetricks corefonts vcrun6 vcrun2003 directx9
echo "export WINEPREFIX=~/.wine-xp" >> ~/.bashrc

# Setup RetroArch config for nice CRT shaders
echo "Configuring RetroArch with XP-era friendly settings..."
mkdir -p ~/.config/retroarch
cat > ~/.config/retroarch/retroarch.cfg << 'EOF'
# XPForge RetroArch config - Classic CRT look
video_driver = "gl"
video_shader_enable = true
video_shader = "/usr/share/libretro/shaders/crt/crt-easymode.glsl"  # or user choice
video_filter = "nearest"
video_scale_integer = true
audio_driver = "pulse"
input_driver = "udev"
menu_driver = "xmb"  # or ozone for modern
EOF

# Create a simple "XP Games Launcher" script
cat > ~/bin/xp-games-launcher << 'EOF'
#!/bin/bash
# Quick launcher menu for XPForge games
echo "XPForge Game Launcher"
echo "1) Steam (Modern games via Proton)"
echo "2) Lutris"
echo "3) Heroic (Epic/GOG)"
echo "4) DOSBox (MS-DOS)"
echo "5) RetroArch"
echo "6) ScummVM"
echo "7) ReactOS VM"
read -p "Choose (1-7): " choice
case $choice in
    1) steam ;;
    2) lutris ;;
    3) flatpak run com.heroicgameslauncher.hgl ;;
    4) dosbox ;;
    5) retroarch ;;
    6) scummvm ;;
    7) qemu-system-x86_64 -m 2048 -enable-kvm -drive file=~/reactos/reactos.img -net user -display gtk ;;
    *) echo "Invalid choice" ;;
esac
EOF
chmod +x ~/bin/xp-games-launcher
echo "export PATH=$PATH:~/bin" >> ~/.bashrc

# Final message
echo ""
echo "Post-install complete! Reboot recommended."
echo "Run 'xp-games-launcher' from terminal for quick access."
echo "Add your own games to ~/Desktop/My Games and ~/Desktop/Retro Games"
echo ""
echo "For authentic XP sounds: Copy from your legal Windows XP install to ~/.local/share/sounds/Chicago95 or similar."
echo ""
echo "XPForge is ready. Go play some games!"