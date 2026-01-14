#!/bin/bash
#
# RetroKISS Script Template: RetroPie Menu Entry
# Description: Template for adding an entry to the RetroPie menu
#
# This template provides:
#   - Install functionality
#   - Update functionality
#   - Remove/uninstall functionality
#   - RetroPie menu integration (appears in RetroPie system menu)
#   - Works with runcommand for proper integration
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Package Information
PACKAGE_NAME="Your Tool/Utility Name"
PACKAGE_DESC="Description of your tool or utility"
MENU_NAME="your-tool"  # Name in menu (lowercase, no spaces, use hyphens)

# Script Configuration
ACTUAL_USER="${SUDO_USER:-$USER}"
INSTALL_DIR="/opt/your-tool"
RETROPIE_MENU_DIR="/home/$ACTUAL_USER/RetroPie/retropiemenu"
MENU_SCRIPT="$RETROPIE_MENU_DIR/$MENU_NAME.sh"
MENU_PNG="$RETROPIE_MENU_DIR/icons/$MENU_NAME.png"

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if package is installed
is_installed() {
    [ -d "$INSTALL_DIR" ] && [ -f "$MENU_SCRIPT" ]
}

# Create RetroPie menu entry
create_menu_entry() {
    log "Creating RetroPie menu entry..."
    
    mkdir -p "$RETROPIE_MENU_DIR"
    mkdir -p "$RETROPIE_MENU_DIR/icons"
    
    # Create the menu launcher script
    cat > "$MENU_SCRIPT" << 'EOFMENU'
#!/bin/bash
#
# RetroPie Menu Entry for PACKAGE_NAME_PLACEHOLDER
#

INSTALL_DIR="/opt/your-tool"
TOOL_BINARY="$INSTALL_DIR/your-tool-executable"

# Check if tool exists
if [ ! -f "$TOOL_BINARY" ]; then
    dialog --title "Error" --msgbox "Tool not found at:\n$TOOL_BINARY\n\nPlease reinstall PACKAGE_NAME_PLACEHOLDER" 10 60
    exit 1
fi

# Change to tool directory
cd "$INSTALL_DIR"

# Option 1: For interactive console tools (like raspi-config style)
# Launch the tool directly
# "$TOOL_BINARY"

# Option 2: For GUI applications
# Check if X is running, start if needed
# if [ -z "$DISPLAY" ]; then
#     xinit "$TOOL_BINARY" -- :0
# else
#     "$TOOL_BINARY"
# fi

# Option 3: For tools that need dialog/whiptail menu
# dialog --title "PACKAGE_NAME_PLACEHOLDER" --menu "Choose an option:" 15 60 5 \
#     1 "Option 1" \
#     2 "Option 2" \
#     3 "Option 3" \
#     2>&1 >/dev/tty

# Option 4: For simple command-line tools
# Run the tool and pause to see output
"$TOOL_BINARY" "$@"
echo ""
read -p "Press [Enter] to return to RetroPie menu..."

exit 0
EOFMENU

    # Replace placeholder
    sed -i "s/PACKAGE_NAME_PLACEHOLDER/$PACKAGE_NAME/g" "$MENU_SCRIPT"
    
    # Make executable
    chmod +x "$MENU_SCRIPT"
    chown "$ACTUAL_USER:$ACTUAL_USER" "$MENU_SCRIPT"
    
    # Create gamelist.xml entry for EmulationStation
    local gamelist_file="$RETROPIE_MENU_DIR/gamelist.xml"
    
    # Backup existing gamelist
    if [ -f "$gamelist_file" ]; then
        cp "$gamelist_file" "${gamelist_file}.backup"
        
        # Remove closing </gameList> tag
        sed -i '/<\/gameList>/d' "$gamelist_file"
    else
        # Create new gamelist
        cat > "$gamelist_file" << 'EOFGAMELIST'
<?xml version="1.0"?>
<gameList>
EOFGAMELIST
    fi
    
    # Add our game entry
    cat >> "$gamelist_file" << EOFENTRY
    <game>
        <path>./$MENU_NAME.sh</path>
        <name>$PACKAGE_NAME</name>
        <desc>$PACKAGE_DESC</desc>
        <image>./icons/$MENU_NAME.png</image>
    </game>
</gameList>
EOFENTRY
    
    chown "$ACTUAL_USER:$ACTUAL_USER" "$gamelist_file"
    
    # Create a simple icon (optional - you can replace with actual PNG)
    log "Creating menu icon..."
    # For now, we'll create a placeholder or copy from a default
    # You should replace this with actual icon creation or download
    if [ ! -f "$MENU_PNG" ]; then
        # Try to use ImageMagick to create a simple icon
        if command -v convert >/dev/null 2>&1; then
            convert -size 128x128 xc:blue -pointsize 20 -fill white \
                -gravity center -annotate +0+0 "${PACKAGE_NAME:0:3}" \
                "$MENU_PNG" 2>/dev/null || touch "$MENU_PNG"
        else
            touch "$MENU_PNG"
        fi
        chown "$ACTUAL_USER:$ACTUAL_USER" "$MENU_PNG"
    fi
    
    success "RetroPie menu entry created"
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
    log "Installing dependencies..."
    # apt-get install -y dependency1 dependency2
    
    log "Creating installation directory..."
    mkdir -p "$INSTALL_DIR"
    
    log "Downloading tool..."
    # cd "$INSTALL_DIR"
    # wget https://example.com/tool.tar.gz
    # tar -xzf tool.tar.gz
    # rm tool.tar.gz
    
    # For apt packages:
    # apt-get install -y your-package
    
    # For Python packages:
    # pip3 install your-package
    
    log "Configuring tool..."
    # chmod +x "$INSTALL_DIR/your-tool-executable"
    # chown -R "$ACTUAL_USER:$ACTUAL_USER" "$INSTALL_DIR"
    
    # Create configuration files
    # cat > "$INSTALL_DIR/config.ini" << EOFCONFIG
    # [settings]
    # option1=value1
    # EOFCONFIG
    
    # Create the RetroPie menu entry
    create_menu_entry
    
    success "$PACKAGE_NAME installed successfully!"
    echo ""
    echo "How to access:"
    echo "  1. Press F4 or exit EmulationStation"
    echo "  2. Type: emulationstation"
    echo "  3. Navigate to 'RetroPie' in the systems menu"
    echo "  4. Select '$PACKAGE_NAME'"
    echo ""
    echo "Or restart EmulationStation to see changes immediately"
    echo ""
    echo "Installation directory: $INSTALL_DIR"
    echo "Menu launcher: $MENU_SCRIPT"
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
    # For git repositories:
    # cd "$INSTALL_DIR"
    # git pull origin main
    
    # For apt packages:
    # apt-get update && apt-get upgrade -y your-package
    
    # For Python packages:
    # pip3 install --upgrade your-package
    
    # For downloaded binaries:
    # wget https://example.com/tool-latest.tar.gz -O /tmp/update.tar.gz
    # cd "$INSTALL_DIR"
    # tar -xzf /tmp/update.tar.gz
    # rm /tmp/update.tar.gz
    
    # Recreate menu entry in case it needs updates
    create_menu_entry
    
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
    
    # Remove menu entry
    log "Removing RetroPie menu entry..."
    rm -f "$MENU_SCRIPT"
    rm -f "$MENU_PNG"
    
    # Remove from gamelist.xml
    if [ -f "$RETROPIE_MENU_DIR/gamelist.xml" ]; then
        # Create temp file without our entry
        local temp_file=$(mktemp)
        local in_our_entry=0
        
        while IFS= read -r line; do
            if [[ "$line" == *"<path>./$MENU_NAME.sh</path>"* ]]; then
                in_our_entry=1
                continue
            fi
            
            if [ $in_our_entry -eq 1 ]; then
                if [[ "$line" == *"</game>"* ]]; then
                    in_our_entry=0
                    continue
                fi
                continue
            fi
            
            echo "$line" >> "$temp_file"
        done < "$RETROPIE_MENU_DIR/gamelist.xml"
        
        mv "$temp_file" "$RETROPIE_MENU_DIR/gamelist.xml"
        chown "$ACTUAL_USER:$ACTUAL_USER" "$RETROPIE_MENU_DIR/gamelist.xml"
    fi
    
    # Remove installation directory
    log "Removing tool files..."
    rm -rf "$INSTALL_DIR"
    
    # For apt packages:
    # apt-get remove -y your-package
    
    # For Python packages:
    # pip3 uninstall -y your-package
    
    # Optional: Remove configuration
    # log "Removing configuration..."
    # rm -rf "/home/$ACTUAL_USER/.your-tool"
    
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
