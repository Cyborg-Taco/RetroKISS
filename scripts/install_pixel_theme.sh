#!/bin/bash
#
# RetroKISS Script: Pixel Theme
# Description: Install the Pixel theme for EmulationStation
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Pixel Theme Installer"
THEME_NAME="pixel"
THEME_URL="https://github.com/ehettervik/es-theme-pixel.git"
THEME_DIR="/etc/emulationstation/themes/$THEME_NAME"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "Starting installation..."

if [ -d "$THEME_DIR" ]; then
    warn "Theme already exists"
    read -p "Reinstall? (y/n): " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
    rm -rf "$THEME_DIR"
fi

mkdir -p "/etc/emulationstation/themes"

log "Downloading Pixel theme..."
if git clone --depth 1 "$THEME_URL" "$THEME_DIR"; then
    success "Pixel theme installed!"
    echo ""
    echo "To activate: UI Settings -> Theme Set -> $THEME_NAME"
else
    error "Failed to download theme"
fi

read -p "Restart EmulationStation? (y/n): " restart
[[ $restart =~ ^[Yy]$ ]] && pkill -f emulationstation || true

exit 0
