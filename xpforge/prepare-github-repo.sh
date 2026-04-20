#!/bin/bash
# XPForge GitHub Repository Preparation Script
# Run this in the xpforge directory to initialize a clean git repo ready for GitHub

set -e

echo "Preparing XPForge for GitHub..."

# Initialize git if not already
if [ ! -d .git ]; then
    git init
    echo "Git repository initialized."
fi

# Add all files (respecting .gitignore)
git add .

# Create initial commit
git commit -m "Initial commit: XPForge v0.1 - Open Source Windows XP Recreation

- Full installer for Ubuntu/Debian with authentic Luna XP theme (Chicago95)
- Pre-configured Proton, Wine 11, Steam, Lutris, Heroic for modern games
- DOSBox-Staging, RetroArch, ScummVM for retro & MS-DOS
- Optional ReactOS QEMU VM integration
- Live ISO builder script
- Preview screenshots and comprehensive documentation
- Ready for community contributions and GitHub Releases"

echo ""
echo "✅ Repository prepared!"
echo ""
echo "Next steps to publish on GitHub:"
echo "1. Create a new repo at https://github.com/new (name: xpforge)"
echo "2. Run: git remote add origin https://github.com/YOURUSERNAME/xpforge.git"
echo "3. Run: git branch -M main"
echo "4. Run: git push -u origin main"
echo ""
echo "5. Create a release and upload the ISO from iso/ folder"
echo "6. Enable GitHub Discussions and Issues"
echo ""
echo "Your XPForge project is now GitHub-ready! 🎉"