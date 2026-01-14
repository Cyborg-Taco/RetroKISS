#!/bin/bash
#
# RetroKISS Script Template: Basic Package
# Description: Basic install/update/remove template
#
# This template provides:
#   - Install functionality
#   - Update functionality
#   - Remove/uninstall functionality
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Package Information
PACKAGE_NAME="Your Package Name"
PACKAGE_DESC="Description of what this package does"

# Script Configuration
ACTUAL_USER="${SUDO_USER:-$USER}"
INSTALL_DIR="/opt/your-package"  # Change this to where your package installs

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check if package is installed
is_installed() {
    # Modify this check based on your package
    # Examples:
    # [ -d "$INSTALL_DIR" ]
    # command -v your-command >/dev/null 2>&1
    # dpkg -l | grep -q your-package
    
    [ -d "$INSTALL_DIR" ]
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
    fi
    
    log "Starting installation..."
    
    # TODO: Add your installation steps here
    # Examples:
    # apt-get install -y your-package
    # git clone https://github.com/user/repo.git "$INSTALL_DIR"
    # wget https://example.com/file.tar.gz && tar -xzf file.tar.gz
    # pip install your-package
    
    # Example placeholder:
    log "Downloading package..."
    # your download commands here
    
    log "Installing dependencies..."
    # apt-get install -y dependency1 dependency2
    
    log "Configuring package..."
    # your configuration commands here
    
    success "$PACKAGE_NAME installed successfully!"
    echo ""
    echo "Additional information:"
    echo "  Installation directory: $INSTALL_DIR"
    echo "  Configuration: /path/to/config"
    echo ""
    
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
    
    # TODO: Add your update steps here
    # Examples:
    # cd "$INSTALL_DIR" && git pull
    # apt-get update && apt-get upgrade -y your-package
    # pip install --upgrade your-package
    
    # Example placeholder:
    log "Downloading latest version..."
    # your update commands here
    
    log "Applying updates..."
    # your update application here
    
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
    
    # TODO: Add your removal steps here
    # Examples:
    # apt-get remove -y your-package
    # rm -rf "$INSTALL_DIR"
    # pip uninstall -y your-package
    
    # Example placeholder:
    log "Stopping services..."
    # systemctl stop your-service || true
    
    log "Removing files..."
    # rm -rf "$INSTALL_DIR"
    
    log "Cleaning up configuration..."
    # rm -rf /etc/your-package
    
    success "$PACKAGE_NAME removed successfully!"
    
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
