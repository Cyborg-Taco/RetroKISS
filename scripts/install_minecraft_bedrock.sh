#!/bin/bash
#
# RetroKISS Script: Minecraft Bedrock Launcher
# Description: Install Minecraft Bedrock Edition via Flatpak
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Minecraft Bedrock Launcher"
ACTUAL_USER="${SUDO_USER:-$USER}"
PORTS_DIR="/home/$ACTUAL_USER/RetroPie/roms/ports"
LAUNCHER_SCRIPT="$PORTS_DIR/Minecraft-Bedrock.sh"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "This will install Minecraft Bedrock Edition launcher"
echo ""

# Check if flatpak is installed
if ! command -v flatpak >/dev/null 2>&1; then
    log "Flatpak not found. Installing Flatpak..."
    apt-get update -qq
    apt-get install -y flatpak
    success "Flatpak installed"
fi

# Add Flathub repository if not already added
log "Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Minecraft Bedrock Launcher
log "Installing Minecraft Bedrock Launcher..."
log "This may take several minutes depending on your connection..."

if flatpak list | grep -q "io.mrarm.mcpelauncher"; then
    warn "Minecraft Bedrock Launcher is already installed"
    read -p "Reinstall? (y/n): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        log "Removing existing installation..."
        flatpak uninstall -y io.mrarm.mcpelauncher
    else
        log "Skipping installation"
    fi
fi

if ! flatpak list | grep -q "io.mrarm.mcpelauncher"; then
    flatpak install -y flathub io.mrarm.mcpelauncher
    success "Minecraft Bedrock Launcher installed!"
else
    success "Minecraft Bedrock Launcher already installed!"
fi

# Create ports directory if it doesn't exist
mkdir -p "$PORTS_DIR"

# Create launcher script for EmulationStation
log "Creating RetroPie port launcher..."

cat > "$LAUNCHER_SCRIPT" << 'EOF'
#!/bin/bash
# Minecraft Bedrock Launcher for RetroPie

# Launch Minecraft Bedrock
flatpak run io.mrarm.mcpelauncher

# Return to EmulationStation
exit 0
EOF

# Make launcher executable
chmod +x "$LAUNCHER_SCRIPT"
chown "$ACTUAL_USER:$ACTUAL_USER" "$LAUNCHER_SCRIPT"

success "Port launcher created!"
echo ""
echo "Installation complete!"
echo ""
echo "How to play:"
echo "  1. Restart EmulationStation"
echo "  2. Go to 'Ports' section"
echo "  3. Select 'Minecraft-Bedrock'"
echo ""
echo "Or run from terminal:"
echo "  flatpak run io.mrarm.mcpelauncher"
echo ""
echo "Notes:"
echo "  - You'll need to log in with your Microsoft account"
echo "  - Make sure you own Minecraft Bedrock Edition"
echo "  - Controller support may vary"
echo ""
echo "Launcher location: $LAUNCHER_SCRIPT"

read -p "Would you like to restart EmulationStation now? (y/n): " restart
if [[ $restart =~ ^[Yy]$ ]]; then
    log "Restarting EmulationStation..."
    pkill -f emulationstation || true
    success "EmulationStation will restart automatically"
fi

exit 0
