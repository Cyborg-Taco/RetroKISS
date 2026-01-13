#!/bin/bash
#
# RetroKISS Script: Moonlight Game Streaming
# Description: Install Moonlight for streaming PC games
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Moonlight Game Streaming Installer"
ACTUAL_USER="${SUDO_USER:-$USER}"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "Moonlight streams games from your gaming PC to RetroPie"
echo ""

if command -v moonlight >/dev/null 2>&1; then
    warn "Moonlight is already installed"
    read -p "Reinstall? (y/n): " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
fi

log "Installing via RetroPie-Setup..."

if [ ! -d "/home/$ACTUAL_USER/RetroPie-Setup" ]; then
    error "RetroPie-Setup not found"
fi

cd "/home/$ACTUAL_USER/RetroPie-Setup"
sudo -u "$ACTUAL_USER" ./retropie_packages.sh moonlight

if command -v moonlight >/dev/null 2>&1; then
    success "Moonlight installed successfully!"
    echo ""
    echo "Setup instructions:"
    echo "  1. Install GeForce Experience or Sunshine on your PC"
    echo "  2. Enable GameStream in GeForce Experience settings"
    echo "  3. Run Moonlight from the Ports menu in EmulationStation"
    echo "  4. Pair with your PC using the on-screen PIN"
    echo ""
    echo "Requirements:"
    echo "  - NVIDIA GPU (GTX 600 series or newer)"
    echo "  - Or use Sunshine (works with any GPU)"
    echo "  - Both devices on same network"
    echo ""
    echo "For best performance:"
    echo "  - Use wired ethernet connection"
    echo "  - 5GHz WiFi if using wireless"
else
    error "Installation failed"
fi

exit 0
