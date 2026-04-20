# Contributing to XPForge

Thank you for your interest in XPForge! We welcome contributions from everyone who loves retro computing, open-source Windows recreation, and making modern Linux feel like 2001 again.

## How to Contribute

### Reporting Bugs
- Use the GitHub Issues tab.
- Include: Your distro/version, `inxi -Fxxxz` output, exact steps to reproduce, and screenshots if possible.
- Check existing issues first.

### Suggesting Features
- Open an issue with the label `enhancement`.
- Describe the feature, why it fits the XP nostalgia + modern compatibility vision, and any implementation ideas.

### Code Contributions
1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/amazing-xp-tweak`
3. Make your changes (follow the existing code style).
4. Test thoroughly (especially the install.sh and build-live-iso.sh scripts).
5. Commit with clear messages: `git commit -m "Add authentic XP sound theme support"`
6. Push and open a Pull Request.

### Theme & Asset Contributions
- Chicago95 is the foundation — improvements there help everyone.
- For XPForge-specific: Add to `themes/`, `configs/`, or `scripts/`.
- **Important**: Only submit original open-source work or properly licensed recreations. No copyrighted Microsoft assets.

### Documentation
- Help improve README.md, docs/, or add new guides in `docs/`.
- Screenshots and videos of your XPForge setup are highly appreciated!

### Testing the Live ISO
- Build it locally with `./scripts/build-live-iso.sh`
- Test in VirtualBox, QEMU, or real hardware.
- Report boot issues, theming glitches, or missing packages.

## Development Guidelines
- Keep the installer simple and robust (one-command experience).
- Prioritize **authenticity** of the XP look while leveraging modern Linux strengths.
- Performance for modern games (Proton) and retro (DOSBox/RetroArch) is core.
- ReactOS VM integration should remain optional and easy.

## Community
- Be respectful and inclusive.
- Join discussions on GitHub Discussions (when enabled).
- Share your setups on r/linux_gaming, r/windowsxp, r/reactos, etc.

## License
By contributing, you agree that your contributions will be licensed under the GNU GPLv3 (see LICENSE file).

Let's keep the blue taskbar alive forever! 🚀

— The XPForge Team