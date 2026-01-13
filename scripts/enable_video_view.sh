#!/bin/bash
#
# RetroKISS Script: Enable Video Previews
# Description: Enable video preview support in EmulationStation
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Video Preview Enabler"
ES_SETTINGS="/opt/retropie/configs/all/emulationstation/es_settings.cfg"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

if [ ! -f "$ES_SETTINGS" ]; then
    error "EmulationStation settings file not found"
fi

log "Enabling video preview support..."

# Enable video support
sed -i 's/<bool name="VideoAudio" value="false"\/>/<bool name="VideoAudio" value="true"\/>/' "$ES_SETTINGS" 2>/dev/null || true
sed -i 's/<bool name="EnableVideos" value="false"\/>/<bool name="EnableVideos" value="true"\/>/' "$ES_SETTINGS" 2>/dev/null || true

# If settings don't exist, add them
if ! grep -q "VideoAudio" "$ES_SETTINGS"; then
    sed -i 's/<\/config>/<bool name="VideoAudio" value="true" \/>\n<bool name="EnableVideos" value="true" \/>\n<\/config>/' "$ES_SETTINGS"
fi

success "Video preview support enabled!"
echo ""
echo "To use video previews:"
echo "  1. Scrape your ROMs with video support"
echo "  2. Videos will play automatically when browsing games"
echo ""
echo "Performance tips:"
echo "  - Videos work best on Pi 4 and Pi 5"
echo "  - Use .mp4 format for best compatibility"
echo "  - Keep videos under 30 seconds"

read -p "Restart EmulationStation to apply changes? (y/n): " restart
if [[ $restart =~ ^[Yy]$ ]]; then
    log "Restarting EmulationStation..."
    pkill -f emulationstation || true
fi

exit 0
