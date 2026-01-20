# This is a test none of the scripts work yet
# RetroKISS

**Retro**Pie **K**ick-start **I**nstall **S**cript **S**uite

A PiKISS-style menu-driven installer for RetroPie that makes it easy to install themes, optimizations, game ports, and utilities. All scripts are pulled from GitHub, making it simple to add new features.

![RetroKISS](https://img.shields.io/badge/RetroKISS-v1.0.0-blue)
![RetroPie](https://img.shields.io/badge/RetroPie-Compatible-green)
![License](https://img.shields.io/badge/license-MIT-orange)

## Features

### 🎨 Themes & UI Improvements
- Multiple EmulationStation themes (Carbon, Pixel, Tronkyfran, ComicBook)
- Video preview support
- Performance optimizations for ES

### ⚡ Performance Optimizations
- Safe overclock presets for Pi 3/4
- GPU memory optimization
- Service management
- Threaded video drivers
- Swap optimization

### 🎮 Game Ports & Engines
- OpenBOR (Beat 'em up games)
- Doom (PrBoom)
- Quake
- Cave Story
- Sonic Robo Blast 2
- ScummVM extras

### 🛠️ Utilities & Tools
- Skyscraper (ROM scraper)
- Kodi Media Center
- Moonlight game streaming
- Midnight Commander file manager
- Samba network shares
- RetroPie Manager web interface
- Bluetooth audio support

## Installation


```bash
# Clone the repository
git clone https://github.com/Cyborg-Taco/RetroKISS.git
cd RetroKISS

# Run the installer
sudo ./retrokiss.sh
```

## Usage

1. Run the script with `sudo ./retrokiss.sh`
2. Use arrow keys to navigate the menu
3. Press Enter to select an option
4. Follow the on-screen prompts

The script will automatically download and execute the selected installation scripts from GitHub.

## Project Structure

```
RetroKISS/
├── retrokiss.sh           # Main installer script
├── manifest.json          # Defines all available scripts
├── scripts/               # Individual installation scripts
│   ├── install_carbon_theme.sh
│   ├── install_pixel_theme.sh
│   ├── safe_overclock.sh
│   ├── install_openbor.sh
│   └── ...
└── README.md
```

## Adding New Scripts

If you don't have the expertize to do this just create a issue with the lable New Package Request
To add a new script to RetroKISS:

1. Create your script in the `scripts/` directory
2. Follow the script template (see example below)
3. Add an entry to `manifest.json` in the appropriate category
4. Commit and push to GitHub Make sure to add the New Package label so i know

### Script Template

```bash
#!/bin/bash
#
# RetroKISS Script: [Your Script Name]
# Description: [What it does]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "================================================"
echo "  Your Script Name"
echo "================================================"

# Your installation code here

exit 0
```

### Manifest Entry

Add to the appropriate category in `manifest.json`:

```json
{
  "id": "your_script.sh",
  "name": "Display Name",
  "description": "Brief description"
},
```

## Requirements

- Raspberry Pi (3, 4, or 5)
- RetroPie installed
- Internet connection
- Root access (sudo)

## Dependencies

The script automatically installs these if missing:
- dialog
- wget
- git
- curl
- jq

## Troubleshooting

### Script won't run
```bash
# Fix line endings
dos2unix retrokiss.sh

# Ensure executable
chmod +x retrokiss.sh
```

### Can't download scripts
- Check your internet connection
- Verify the GitHub repository is accessible
- Check the manifest.json for correct script paths

### Permission errors
- Always run with `sudo`
- Check that scripts have execute permissions

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add your script(s) to the `scripts/` directory
4. Update `manifest.json`
5. Submit a pull request

## Credits

Inspired by [PiKISS](https://github.com/jmcerrejon/PiKISS) by José Manuel Cerrejón

## License

MIT License - Feel free to use and modify!

## Support

- Issues: [GitHub Issues](https://github.com/Cyborg-Taco/RetroKISS/issues)
- Discussions: [GitHub Discussions](https://github.com/Cyborg-Taco/RetroKISS/discussions)

---

**Note**: Always backup your RetroPie installation before running optimization scripts. Some features may require a reboot to take effect.
