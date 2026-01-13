#!/bin/bash
#
# RetroKISS Script: Kodi Media Center
# Description: Install Kodi for video/music playback
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Kodi Media Center Installer"
ACTUAL_USER="${SUDO_USER:-$USER}"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "Kodi is a media center for playing videos, music, and photos"
echo ""

if [ -d "/opt/retropie/supplementary/kodi" ]; then
    warn "Kodi appears to be already installed"
    read -p "Continue anyway? (y/n): " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
fi

log "Installing via RetroPie-Setup..."
log "This may take several minutes..."

if [ ! -d "/home/$ACTUAL_USER/RetroPie-Setup" ]; then
    error "RetroPie-Setup not found"
fi

cd "/home/$ACTUAL_USER/RetroPie-Setup"
sudo -u "$ACTUAL_USER" ./retropie_packages.sh kodi

if [ -d "/opt/retropie/supplementary/kodi" ]; then
    success "Kodi installed successfully!"
    echo ""
    echo "To launch Kodi:"
    echo "  - From EmulationStation: Go to 'Ports' and select 'Kodi'"
    echo "  - From terminal: kodi"
    echo ""
    echo "Configuration:"
    echo "  Kodi settings: /opt/retropie/configs/ports/kodi"
    echo "  User data: ~/.kodi/"
else
    error "Installation failed"
fi

exit 0
