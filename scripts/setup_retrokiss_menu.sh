#!/bin/bash
#
# RetroKISS Script: Add RetroKISS to RetroPie Menu
# Description: Create a launcher for RetroKISS in the Ports menu
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="RetroKISS Menu Launcher Setup"
ACTUAL_USER="${SUDO_USER:-$USER}"
PORTS_DIR="/home/$ACTUAL_USER/RetroPie/roms/ports"
RETROKISS_LAUNCHER="$PORTS_DIR/RetroKISS.sh"
RETROKISS_SCRIPT="/home/$ACTUAL_USER/RetroKISS/retrokiss.sh"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "This will add RetroKISS to your Ports menu"
echo ""

# Check if RetroKISS exists
if [ ! -f "$RETROKISS_SCRIPT" ]; then
    warn "RetroKISS not found at $RETROKISS_SCRIPT"
    log "Downloading RetroKISS..."
    
    mkdir -p "/home/$ACTUAL_USER/RetroKISS"
    cd "/home/$ACTUAL_USER/RetroKISS"
    
    wget -q https://raw.githubusercontent.com/Cyborg-Taco/RetroKISS/main/retrokiss.sh -O retrokiss.sh
    
    if [ $? -eq 0 ]; then
        chmod +x retrokiss.sh
        chown -R "$ACTUAL_USER:$ACTUAL_USER" "/home/$ACTUAL_USER/RetroKISS"
        success "RetroKISS downloaded successfully"
    else
        error "Failed to download RetroKISS"
    fi
fi

# Create ports directory if it doesn't exist
mkdir -p "$PORTS_DIR"

# Create launcher script
log "Creating port launcher..."

cat > "$RETROKISS_LAUNCHER" << 'EOFLAUNCH'
#!/bin/bash
#
# RetroKISS Launcher for EmulationStation
#

RETROKISS_DIR="/home/$(whoami)/RetroKISS"
RETROKISS_SCRIPT="$RETROKISS_DIR/retrokiss.sh"

# Check if RetroKISS exists
if [ ! -f "$RETROKISS_SCRIPT" ]; then
    dialog --title "RetroKISS Not Found" --msgbox "RetroKISS script not found at:\n$RETROKISS_SCRIPT\n\nPlease install RetroKISS first." 10 60
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    # Not root, use sudo
    cd "$RETROKISS_DIR"
    sudo bash "$RETROKISS_SCRIPT"
else
    # Already root
    cd "$RETROKISS_DIR"
    bash "$RETROKISS_SCRIPT"
fi

# Return to EmulationStation
exit 0
EOFLAUNCH

# Make launcher executable
chmod +x "$RETROKISS_LAUNCHER"
chown "$ACTUAL_USER:$ACTUAL_USER" "$RETROKISS_LAUNCHER"

# Create .txt file for EmulationStation metadata (optional but nice)
cat > "$PORTS_DIR/RetroKISS.txt" << 'EOFMETA'
RetroKISS - RetroPie Kick-start Install Script Suite

A menu-driven installer for RetroPie enhancements including:
- Themes and UI improvements
- Performance optimizations
- Game ports and engines
- Utilities and tools

All scripts are pulled from GitHub for easy updates.
EOFMETA

chown "$ACTUAL_USER:$ACTUAL_USER" "$PORTS_DIR/RetroKISS.txt"

success "RetroKISS launcher created!"
echo ""
echo "Installation complete!"
echo ""
echo "How to use:"
echo "  1. Restart EmulationStation (or press F4 and type 'emulationstation')"
echo "  2. Navigate to 'Ports'"
echo "  3. Select 'RetroKISS'"
echo "  4. The installer menu will appear"
echo ""
echo "Launcher location: $RETROKISS_LAUNCHER"
echo "RetroKISS location: $RETROKISS_SCRIPT"
echo ""

read -p "Would you like to restart EmulationStation now? (y/n): " restart
if [[ $restart =~ ^[Yy]$ ]]; then
    log "Restarting EmulationStation..."
    pkill -f emulationstation || true
    success "EmulationStation will restart automatically"
fi

exit 0
