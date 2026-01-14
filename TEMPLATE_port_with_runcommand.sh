#!/bin/bash
#
# RetroKISS Script Template: Port with Runcommand
# Description: Template for creating a port that works with runcommand
#
# This template provides:
#   - Install functionality
#   - Update functionality
#   - Remove/uninstall functionality
#   - Port launcher creation (works with runcommand)
#   - EmulationStation integration
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Package Information
PACKAGE_NAME="Your Game/App Name"
PACKAGE_DESC="Description of your game or application"
PORT_NAME="YourGame"  # Name as it will appear in Ports (no spaces)

# Script Configuration
ACTUAL_USER="${SUDO_USER:-$USER}"
INSTALL_DIR="/opt/your-game"
PORTS_DIR="/home/$ACTUAL_USER/RetroPie/roms/ports"
PORT_SCRIPT="$PORTS_DIR/$PORT_NAME.sh"
RUNCOMMAND_LOG="/dev/shm/runcommand.log"

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if package is installed
is_installed() {
    [ -d "$INSTALL_DIR" ] && [ -f "$PORT_SCRIPT" ]
}

# Create port launcher script
create_port_launcher() {
    log "Creating port launcher for runcommand..."
    
    mkdir -p "$PORTS_DIR"
    
    # Create the launcher script
    cat > "$PORT_SCRIPT" << 'EOFPORT'
#!/bin/bash
#
# Port Launcher for PACKAGE_NAME_PLACEHOLDER
# This script is called by runcommand
#

INSTALL_DIR="/opt/your-game"
GAME_BINARY="$INSTALL_DIR/your-game-executable"

# Check if game exists
if [ ! -f "$GAME_BINARY" ]; then
    echo "Error: Game not found at $GAME_BINARY" >&2
    exit 1
fi

# Change to game directory
cd "$INSTALL_DIR"

# Launch the game
# Modify this based on how your game needs to be launched
"$GAME_BINARY" "$@"

# Exit with game's exit code
exit $?
EOFPORT

    # Replace placeholder
    sed -i "s/PACKAGE_NAME_PLACEHOLDER/$PACKAGE_NAME/g" "$PORT_SCRIPT"
    
    # Make executable
    chmod +x "$PORT_SCRIPT"
    chown "$ACTUAL_USER:$ACTUAL_USER" "$PORT_SCRIPT"
    
    # Create .txt file for EmulationStation description
    cat > "$PORTS_DIR/$PORT_NAME.txt" << EOFDESC
$PACKAGE_NAME

$PACKAGE_DESC

Installation directory: $INSTALL_DIR
EOFDESC
    
    chown "$ACTUAL_USER:$ACTUAL_USER" "$PORTS_DIR/$PORT_NAME.txt"
    
    success "Port launcher created at: $PORT_SCRIPT"
}

# Install function
do_install() {
    echo "================================================"
    echo "  Installing $PACKAGE_NAME"
    echo "================================================"
    echo ""
    
    if is_installed; then
        warn "$PACKAGE_NAME is already installed"
        read -p "Reinstall anyway? (y/n): " confirm
        [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
        do_remove
    fi
    
    log "Starting installation..."
    
    # TODO: Add your installation steps here
    # Example for a compiled game:
    log "Installing dependencies..."
    # apt-get install -y libsdl2-2.0-0 libsdl2-mixer-2.0-0
    
    log "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    
    log "Downloading game files..."
    # cd "$INSTALL_DIR"
    # wget https://example.com/game.tar.gz
    # tar -xzf game.tar.gz
    # rm game.tar.gz
    
    log "Setting permissions..."
    # chmod +x "$INSTALL_DIR/your-game-executable"
    # chown -R "$ACTUAL_USER:$ACTUAL_USER" "$INSTALL_DIR"
    
    # Create the port launcher
    create_port_launcher
    
    success "$PACKAGE_NAME installed successfully!"
    echo ""
    echo "How to play:"
    echo "  1. Restart EmulationStation"
    echo "  2. Navigate to 'Ports'"
    echo "  3. Select '$PORT_NAME'"
    echo ""
    echo "Installation directory: $INSTALL_DIR"
    echo "Port launcher: $PORT_SCRIPT"
    echo ""
    
    # Offer to restart EmulationStation
    read -p "Restart EmulationStation now? (y/n): " restart
    if [[ $restart =~ ^[Yy]$ ]]; then
        log "Restarting EmulationStation..."
        pkill -f emulationstation || true
    fi
    
    return 0
}

# Update function
do_update() {
    echo "================================================"
    echo "  Updating $PACKAGE_NAME"
    echo "================================================"
    echo ""
    
    if ! is_installed; then
        error "$PACKAGE_NAME is not installed. Install it first."
    fi
    
    log "Checking for updates..."
    
    # TODO: Add your update logic here
    # Example for git-based game:
    # cd "$INSTALL_DIR"
    # git pull origin main
    # make clean && make
    
    # Example for downloaded updates:
    # wget https://example.com/game-latest.tar.gz -O /tmp/game-update.tar.gz
    # cd "$INSTALL_DIR"
    # tar -xzf /tmp/game-update.tar.gz
    # rm /tmp/game-update.tar.gz
    
    # Recreate launcher in case it needs updates
    create_port_launcher
    
    success "$PACKAGE_NAME updated successfully!"
    
    return 0
}

# Remove function
do_remove() {
    echo "================================================"
    echo "  Removing $PACKAGE_NAME"
    echo "================================================"
    echo ""
    
    if ! is_installed; then
        warn "$PACKAGE_NAME is not installed"
        exit 0
    fi
    
    warn "This will remove $PACKAGE_NAME and all its data"
    read -p "Are you sure? (y/n): " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
    
    log "Removing $PACKAGE_NAME..."
    
    # Remove port launcher
    log "Removing port launcher..."
    rm -f "$PORT_SCRIPT"
    rm -f "$PORTS_DIR/$PORT_NAME.txt"
    
    # Remove installation directory
    log "Removing game files..."
    rm -rf "$INSTALL_DIR"
    
    # Optional: Remove saved games/config
    # log "Removing saved data..."
    # rm -rf "/home/$ACTUAL_USER/.your-game"
    
    success "$PACKAGE_NAME removed successfully!"
    echo ""
    echo "You may need to restart EmulationStation to see changes"
    
    return 0
}

# Main script logic
ACTION="${1:-install}"

case "$ACTION" in
    install)
        do_install
        ;;
    update)
        do_update
        ;;
    remove)
        do_remove
        ;;
    *)
        echo "Usage: $0 {install|update|remove}"
        exit 1
        ;;
esac

exit 0
