# XPForge Compatibility Guide (2026 Edition)

This document tracks what works great, what needs tweaks, and known limitations in the XPForge environment.

## Modern Games (via Proton / Wine)

**Excellent (Platinum on ProtonDB - runs out of the box):**
- Most Steam Deck verified titles (Elden Ring, Baldur's Gate 3, Cyberpunk 2077 with FSR, Hogwarts Legacy, etc.)
- Older modern games: Skyrim SE, Fallout 4, Witcher 3, GTA V (with tweaks)
- Indie hits: Hades, Celeste, Stardew Valley, Hollow Knight

**Good (Gold/Silver - minor fixes):**
- Many DirectX 11/12 titles with Proton-GE + latest VKD3D
- Anti-cheat titles: Valorant may not work (kernel-level), but most others do with Proton Experimental

**Use These Tools:**
- **Proton-GE** (via ProtonUp-QT): Best for cutting-edge titles and mods.
- **Lutris** runners: Wine-GE, Proton-GE custom.
- **Bottles**: For non-Steam apps like older Adobe Suite or Visual Studio 2010.

**Performance Tips (2026):**
- Enable NTSYNC kernel module for 10-30% FPS gains in many titles.
- Use `gamemoderun %command%` in Steam launch options.
- For NVIDIA: Latest proprietary drivers + DXVK.
- Vulkan titles often outperform Windows.

## Legacy Windows XP/2000/98 Software

**Via Wine (host):**
- Most 32-bit XP-era apps run perfectly: Office 2003/2007, Photoshop CS2, older IDEs.
- Games: Half-Life 1/2, Counter-Strike 1.6, Age of Empires 2, SimCity 4, etc. — often better than native XP due to modern fixes.

**Via ReactOS VM (recommended for problematic drivers/apps):**
- Native Windows drivers (especially older hardware).
- Apps that rely on undocumented NT APIs.
- Install ReactOS nightly, share `~/shared` folder.
- Performance: Good for 2D/office; 3D limited (software rendering or basic DirectX).

**Known Good in ReactOS (from community tests 2025-2026):**
- 3D Pinball Space Cadet, many Win32 strategy games, emulators, Office XP.

## Retro & MS-DOS

**DOSBox-Staging (default):**
- Perfect for 90s DOS games: Doom, Duke Nukem 3D, Commander Keen, Wolfenstein 3D, Monkey Island.
- Pre-configured with 64MB RAM, SVGA, soundblaster.
- Mount your game folders: `mount C ~/dosbox/games`

**DOSBox-X:**
- For more accurate hardware (Sound Blaster 16, Voodoo cards emulation).
- Great for Windows 3.1/95 inside DOS (nostalgia within nostalgia).

**RetroArch + Cores:**
- NES/SNES/Genesis/PS1/N64/Dreamcast/PS2 (up to playable).
- Shaders: CRT-Royale, easymode, etc. for authentic look.
- Netplay supported for multiplayer classics.

**Other:**
- ScummVM: All supported adventures (LucasArts, Sierra, etc.) run flawlessly.
- 86Box/PCem: For running full old PCs (Windows 95/98 inside) with period-accurate hardware.

## ReactOS Specific Notes

ReactOS 0.4.15+ (as of 2026) has made major strides:
- Better NT6 compatibility in progress.
- Many games from 2000-2005 run (see ReactOS forum compatibility list).
- Audio/video drivers improving.
- **Limitation**: Modern AAA games (post-2010) generally do not run well due to incomplete DirectX 9/10/11 and no Vulkan. Use Proton on Linux host instead.

**When to use ReactOS VM vs Wine:**
- Use **ReactOS** for: Hardware drivers, low-level tools, specific XP-only software, testing.
- Use **Wine/Proton** for: Almost everything else, especially games and modern apps.

## Hardware Compatibility

- **GPUs**: NVIDIA (best with proprietary + Proton), AMD (excellent open-source), Intel (good for integrated).
- **CPUs**: Any x86_64 from 2015+ recommended. Older works but slower for emulation.
- **Sound**: PulseAudio/PipeWire works great; DOSBox emulates Sound Blaster perfectly.
- **Input**: Full controller support via SDL2/RetroArch (Xbox, PlayStation, 8BitDo, etc.).

## Limitations & Workarounds

1. **Anti-Cheat / Kernel-level software**: Some online games block Wine/Proton. Workaround: Dual-boot real Windows or use cloud gaming.
2. **DirectX 12 Ultimate / Ray Tracing**: Improving rapidly in 2026 with VKD3D-Proton; many titles now playable.
3. **Microsoft Store / UWP apps**: Not supported (use web versions or alternatives).
4. **Real XP hardware passthrough**: For ultra-accurate retro, use 86Box with period hardware config.
5. **Theming fidelity**: Chicago95 is 95%+ accurate; some 3rd-party apps may look "Linux-y". Use `winecfg` to set XP theme in Wine apps.

## Reporting Issues

- Game-specific: Check ProtonDB.com first, then open issue here with `protontricks` logs.
- Theme bugs: Upstream to Chicago95 GitHub.
- ReactOS issues: https://reactos.org/forum or our VM script issues.
- General: Create GitHub issue with `inxi -Fxxxz` output.

**Last Updated**: April 2026 | XPForge Team

*Many titles that "don't work on XP anymore" now run better on XPForge thanks to modern compatibility layers!*