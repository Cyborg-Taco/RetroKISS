#!/bin/bash
#
# RetroKISS Script: Skyscraper
# Description: Install Skyscraper ROM scraper
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Skyscraper Installer"
ACTUAL_USER="${SUDO_USER:-$USER}"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "Skyscraper is an advanced ROM scraper for RetroPie"
log "It downloads artwork, descriptions, and metadata for your games"
echo ""

if command -v Skyscraper >/dev/null 2>&1; then
    warn "Skyscraper is already installed"
    read -p "Reinstall? (y/n): " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
fi

log "Installing via RetroPie-Setup..."

if [ ! -d "/home/$ACTUAL_USER/RetroPie-Setup" ]; then
    error "RetroPie-Setup not found. Please install RetroPie first."
fi

cd "/home/$ACTUAL_USER/RetroPie-Setup"

log "Running RetroPie package installer..."
sudo -u "$ACTUAL_USER" ./retropie_packages.sh skyscraper

if command -v Skyscraper >/dev/null 2>&1; then
    success "Skyscraper installed successfully!"
    echo ""
    echo "Usage examples:"
    echo "  Skyscraper -p nes           # Scrape NES games"
    echo "  Skyscraper -p snes -s arcadedb  # Scrape SNES from ArcadeDB"
    echo "  Skyscraper -p all           # Scrape all systems"
    echo ""
    echo "You can also run Skyscraper from the RetroPie menu"
else
    error "Installation completed but Skyscraper not found"
fi

exit 0
