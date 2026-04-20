# XPForge - Open Source Windows XP Recreation for Modern & Retro Computing

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20ReactOS%20VM-green)](https://reactos.org/)

**XPForge** is a new open-source project that brings back the beloved Windows XP experience in 2026 and beyond. It uses a modern open-source Linux foundation (Ubuntu/Debian-based) with the authentic **Luna** theme and UI elements to recreate the classic XP desktop, while providing **world-class compatibility** for:

- **Modern games and software** via Proton, Wine 11+, Lutris, and Heroic.
- **Retro games** from the 80s-2000s via RetroArch, DOSBox-Staging, ScummVM, and more.
- **MS-DOS** with seamless integration and classic launcher.
- **Native Windows XP/NT binaries** optionally via integrated ReactOS VM or dual-boot.

Perfect for nostalgia enthusiasts, retro gamers, developers testing legacy software, and anyone who misses the simplicity and beauty of Windows XP — now running on modern hardware with full security, updates, and Steam Deck-level gaming performance.

## Why XPForge?

- **ReactOS** is amazing for native Windows driver/app compatibility but remains in alpha with limited modern DirectX/Vulkan support for today's AAA titles.
- Pure Linux with **Proton** (Wine 11 + NTSYNC + VKD3D) runs thousands of modern Windows games at near-native performance (often better than Windows on some hardware).
- **Chicago95** and community themes provide pixel-perfect XP recreation without the security nightmares of real XP.
- One unified environment: Boot once, play *Cyberpunk 2077* via Proton, then launch *Doom* or *Windows 98* games in DOSBox, all with XP chrome.

No more dual-booting or fragile VMs. XPForge is your daily driver for the XP era — enhanced for 2026.

## Key Features

### 🎨 Authentic Windows XP Desktop
- **Luna Blue theme** (or Classic/ Olive variants) using extended Chicago95 + custom XFCE panel profiles.
- Classic taskbar with Start orb (green "Start" button), quick launch, window list, system tray.
- Desktop icons: My Computer, My Documents, Recycle Bin, Network Neighborhood — fully functional.
- XP-style file explorer, right-click menus, sounds (open-source recreations or user-provided), cursors, and fonts (Tahoma, etc.).
- Login screen with classic XP wallpaper and user icons.
- HiDPI support and modern compositor (Picom/Compton) for smooth animations.

### 🎮 Modern Games & Software
- **Steam + Proton** pre-configured (latest Proton-GE, NTSYNC kernel module enabled for massive performance gains in 2026).
- **Lutris** + **Heroic Games Launcher** for Epic, GOG, Amazon, itch.io — thousands of titles playable.
- **Wine 11.6+** with Bottles for sandboxed Windows apps (Office, Photoshop legacy, etc.).
- Automatic detection and optimal settings for popular titles (see `docs/compatibility.md`).
- Vulkan/DXVK/VKD3D translation layers — run DirectX 9-12 and Vulkan games flawlessly.
- Example: *Elden Ring*, *Baldur's Gate 3*, *Starfield* run great; older modern games like *Skyrim Special Edition* are buttery smooth.

### 🕹️ Retro Games & MS-DOS
- **DOSBox-Staging** + **DOSBox-X** with pre-mounted drives, auto-exec for classic .exe/.bat.
- **RetroArch** with cores for NES, SNES, Genesis, PS1, N64, Dreamcast, and more — shader support for CRT look.
- **ScummVM** for point-and-click adventures (Monkey Island, Day of the Tentacle, etc.).
- **PCem** / **86Box** for accurate old PC emulation (Windows 3.1/95 inside DOSBox or standalone).
- Custom "Retro Games" Start menu folder with categorized launchers.
- MS-DOS prompt accessible from desktop or Start menu — feels just like the real thing.

### 🔄 ReactOS Integration (Optional)
- One-click QEMU/KVM script to download and run the latest ReactOS nightly in a windowed VM.
- Shared folders between host (Linux) and ReactOS for easy file transfer.
- Test native Windows drivers/apps that Wine struggles with.
- Future: Tighter integration (e.g., ReactOS as a "subsystem" via WSL-like or unikernel experiments).

### 🛠️ Developer & Power User Friendly
- Full terminal access (bash/zsh with oh-my-zsh + MS-DOS-inspired prompt option).
- Easy theming tools: Chicago95 Plus! for installing real Windows .theme files.
- Scriptable launchers and "XP Shortcuts" system.
- Docker support for containerized legacy environments.
- Built on Ubuntu 24.04 LTS — rock-solid, secure, with 5+ years support.

## Installation

### Quick Start (Recommended: Ubuntu 24.04 LTS or Debian 12/13)

1. **Download or clone this repo**:
   ```bash
   git clone https://github.com/xpforge/xpforge.git  # (placeholder - actual repo coming soon)
   cd xpforge
   ```

2. **Run the installer** (takes 15-30 minutes):
   ```bash
   chmod +x scripts/install.sh
   ./scripts/install.sh
   ```

   The script will:
   - Update system and install XFCE4, LightDM, required packages.
   - Clone and install **Chicago95** for core theming.
   - Install **Wine 11**, **Steam**, **Lutris**, **Heroic**, **DOSBox-Staging**, **RetroArch**, **ScummVM**.
   - Apply XP panel layout, icons, wallpapers (public domain recreations + placeholders).
   - Configure Proton, create "My Games", "Retro" folders on desktop.
   - Set up optional ReactOS VM downloader.

3. **Log out and select "XFCE Session"** (or LightDM with XP theme) at login.

4. **Post-install**:
   - Run `scripts/post-install.sh` for final tweaks (sounds, ReactOS VM).
   - Launch Steam → enable Proton for all games.
   - Add your game library — it just works!

### Advanced / Custom Builds
- **Live ISO**: Use `scripts/build-iso.sh` (based on Cubic or live-build) to create a bootable XPForge USB.
- **ReactOS VM only**: `scripts/setup-reactos-vm.sh`
- **Minimal install**: Edit `configs/packages.txt` to select components.
- **Theme variants**: Run `chicago95-plus` to install authentic XP themes from your collection.

### Hardware Requirements
- Modern CPU (Intel 8th gen+ or AMD Ryzen, or any with good Vulkan support)
- 8GB+ RAM (16GB recommended for gaming + emulation)
- Dedicated GPU (NVIDIA/AMD/Intel with Vulkan) for best modern game performance
- 50GB+ disk space

## Screenshots & Demos

*(Screenshots to be added — imagine a perfect XP desktop with Steam overlay, DOSBox running Commander Keen, and modern game running in background.)*

See `docs/screenshots/` (placeholder) or visit our (future) website.

## Compatibility

See `docs/compatibility.md` for detailed lists:
- **Modern Games**: 90%+ of Steam library via Proton (check ProtonDB).
- **Legacy Windows Apps**: Excellent via Wine; native in ReactOS VM.
- **DOS/Retro**: Near-perfect with our pre-configs.
- Known issues: Some anti-cheat (Easy Anti-Cheat in some titles) may require workarounds; ReactOS still alpha for complex drivers.

## Roadmap

- **v0.1** (Current): Core installer, theming, basic compatibility layers.
- **v0.2**: Custom XP-like file manager (fork of Thunar or PCManFM with XP skin), improved sounds.
- **v0.3**: ReactOS deep integration (shared clipboard, better VM performance), Steam Deck / handheld optimized image.
- **v1.0**: Full live ISO, AppImage/Flatpak versions, community theme gallery, "XPera Store" for curated legacy software.
- Long-term: Contribute improvements back to Chicago95, Wine, ReactOS, and create a true "open Windows XP" kernel module experiments.

## Contributing

We welcome contributions!
- Improve themes: Submit to Chicago95 or our `themes/` folder.
- Add game profiles: PRs to `configs/lutris/` or `docs/`.
- Test on real hardware and report bugs.
- ReactOS enhancements: Upstream to https://reactos.org/ or our VM scripts.
- Translations, documentation, artwork (open-source only — no copyrighted Microsoft assets).

Fork, star, and join the Discord/Matrix (links TBD).

## Credits & Acknowledgments

- **Chicago95** (https://github.com/grassmunk/Chicago95) — The foundation of our theming.
- **LinuxXP** (https://github.com/NickMatthews-1/LinuxXP) — Inspiration for Cinnamon/XP scripts.
- **ReactOS Project** (https://reactos.org/) — For the dream of open Windows NT.
- **Wine / Proton / Valve** — Making modern Windows gaming on Linux possible.
- **DOSBox-Staging, RetroArch, ScummVM, Lutris, Heroic** — Retro and multi-platform magic.
- Community: r/windowsxp, r/linux_gaming, r/reactos, VOGONS, and all the tinkerers keeping XP alive.

**Important Legal Note**: XPForge uses only open-source recreations and public-domain assets. Original Windows XP themes, sounds, and icons are copyrighted by Microsoft. Users are responsible for any personal backups or licenses. This project does not distribute proprietary Microsoft software.

## License

GPLv3 — Free as in freedom (and as in "free to run your favorite old games forever").

---

**"It just works... like XP, but better."** — The XPForge Team, 2026

For issues, feature requests, or to get involved: Open an issue or PR on GitHub (repo to be created at github.com/xpforge/xpforge).

*This project was created as a demonstration of what a modern open-source XP recreation can be.*

---

## 📸 Preview Screenshots

Beautiful photorealistic previews of the XPForge desktop (generated with Grok Imagine):

- **01-clean-xp-desktop.jpg** — Classic XP Luna desktop with taskbar, icons, and green hills wallpaper
- **02-start-menu-open.jpg** — Start menu fully open with All Programs, Steam & DOSBox windows
- **03-modern-retro-gaming.jpg** — Side-by-side: Elden Ring (Proton) + Doom (DOSBox) on XP-themed desktop
- **04-login-screen.jpg** — Authentic Windows XP logon screen recreation

All previews are in the `previews/` folder.

## 💿 Live ISO (Live Session + Easy Installer)

**New in v0.3**: The ISO is now a full **live environment + one-click installer** using Calamares.

```bash
./scripts/build-live-iso.sh
```

The resulting `iso/xpforge-0.1-amd64.iso` (~3.5–4 GB) gives you:

- **Live Session**: Boot and instantly enjoy the full XPForge desktop (themed exactly like Windows XP Luna, all apps pre-installed: Steam+Proton, Wine, DOSBox, RetroArch, etc.)
- **Easy Installation**: Double-click the **"Install XPForge to Hard Drive"** icon on the desktop → launches **Calamares** (modern graphical installer)
- Calamares is pre-configured with:
  - XPForge branding (classic XP blue sidebar + real generated logo/welcome/slideshow images)
  - Automatic package selection (Steam + Proton 11, Lutris, Flatpak, Wine, DOSBox, RetroArch, Microsoft Edge, etc.)
  - Post-install hook that automatically applies the full XPForge theme, desktop icons, "Command Prompt", and "Internet Explorer" launcher after installation
- Special launchers (live & installed):
  - **Command Prompt** (renamed terminal with classic XP feel)
  - **Internet Explorer** (Microsoft Edge running under the old IE name & icon)
  - **AppStore** (Windows Store-style blue shopping bag icon, opens Discover for easy Flatpak app & game installation)
- After installation, your new system will boot straight into the beautiful XP recreation with everything working (Linux Kernel 7.0+ included)

**Test in QEMU**:
```bash
qemu-system-x86_64 -m 4096 -enable-kvm -cdrom iso/xpforge-0.1-amd64.iso -boot d
```

This is the perfect way for users to try XPForge risk-free and then install it permanently with a few clicks.

## 🚀 GitHub Ready

This entire project is packaged and ready for GitHub:

```bash
./prepare-github-repo.sh
```

Then push to your new repo at `github.com/yourname/xpforge`.

Includes:
- Full source + scripts
- Previews
- Live ISO builder
- LICENSE (GPLv3)
- CONTRIBUTING.md
- .gitignore
- Comprehensive docs

---

**XPForge — The best of 2001 meets the best of 2026.**