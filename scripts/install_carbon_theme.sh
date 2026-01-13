#!/bin/bash
#
# RetroKISS Script: Install Carbon Theme
# This is an example of how to structure your scripts
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script info
SCRIPT_NAME="Carbon Theme Installer"
THEME_NAME="carbon"
THEME_URL="https://github.com/RetroPie/es-theme-carbon.git"
THEME_DIR="/etc/emulationstation/themes/$THEME_NAME"

# Logging
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Main installation
echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "Starting installation..."

# Check if theme already exists
if [ -d "$THEME_DIR" ]; then
    warn "Theme already exists at $THEME_DIR"
    read -p "Do you want to reinstall? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log "Installation cancelled"
        exit 0
    fi
    log "Removing existing theme..."
    rm -rf "$THEME_DIR"
fi

# Create themes directory if it doesn't exist
mkdir -p "/etc/emulationstation/themes"

# Clone the theme
log "Downloading theme from GitHub..."
if git clone --depth 1 "$THEME_URL" "$THEME_DIR" > /dev/null 2>&1; then
    success "Theme installed successfully!"
    echo ""
    echo "Theme location: $THEME_DIR"
    echo "To use this theme, restart EmulationStation and select it from:"
    echo "UI Settings -> Theme Set -> $THEME_NAME"
    echo ""
else
    error "Failed to download theme"
    exit 1
fi

# Ask to restart ES
read -p "Would you like to restart EmulationStation now? (y/n): " restart
if [[ $restart =~ ^[Yy]$ ]]; then
    log "Restarting EmulationStation..."
    pkill -f emulationstation
    success "EmulationStation will restart automatically"
fi

exit 0
