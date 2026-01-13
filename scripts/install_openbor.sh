#!/bin/bash
#
# RetroKISS Script: OpenBOR
# Description: Install OpenBOR beat 'em up game engine
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="OpenBOR Installer"
ACTUAL_USER="${SUDO_USER:-$USER}"
ROMS_DIR="/home/$ACTUAL_USER/RetroPie/roms/ports/openbor"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "OpenBOR is an engine for beat 'em up games"
echo ""

if [ -d "/opt/retropie/ports/openbor" ]; then
    warn "OpenBOR appears to be already installed"
    read -p "Reinstall? (y/n): " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
fi

log "Installing via RetroPie-Setup..."
log "This may take a few minutes..."

if [ ! -d "/home/$ACTUAL_USER/RetroPie-Setup" ]; then
    error "RetroPie-Setup not found"
fi

cd "/home/$ACTUAL_USER/RetroPie-Setup"
sudo -u "$ACTUAL_USER" ./retropie_packages.sh openbor

# Create ROMs directory
mkdir -p "$ROMS_DIR"
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ROMS_DIR"

success "OpenBOR installed successfully!"
echo ""
echo "How to add games:"
echo "  1. Place .pak files in: $ROMS_DIR"
echo "  2. Restart EmulationStation"
echo "  3. Find OpenBOR in the Ports section"
echo ""
echo "Where to get games:"
echo "  - OpenBOR community forums"
echo "  - Archive.org (search 'OpenBOR')"
echo "  - Create your own using OpenBOR editor"
echo ""
echo "Popular OpenBOR games:"
echo "  - Streets of Rage Remake"
echo "  - Double Dragon"
echo "  - Final Fight"
echo "  - Golden Axe"

exit 0
