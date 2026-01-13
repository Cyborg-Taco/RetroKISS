#!/bin/bash
#
# RetroKISS Script Generator
# Quickly create new installation scripts
#

echo "================================================"
echo "  RetroKISS Script Generator"
echo "================================================"
echo ""

# Get script details
read -p "Script name (e.g., install_awesome_app): " script_id
read -p "Display name (e.g., Awesome App): " display_name
read -p "Description: " description
read -p "Category (themes/performance/ports/utilities): " category

# Sanitize script name
script_id="${script_id// /_}"
script_id="${script_id}.sh"

# Create script
cat > "scripts/$script_id" << 'EOFSCRIPT'
#!/bin/bash
#
# RetroKISS Script: DISPLAY_NAME_PLACEHOLDER
# Description: DESCRIPTION_PLACEHOLDER
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script info
SCRIPT_NAME="DISPLAY_NAME_PLACEHOLDER"

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Main installation
echo "================================================"
echo "  $SCRIPT_NAME Installer"
echo "================================================"
echo ""

log "Starting installation..."

# TODO: Add your installation code here
# Example:
# log "Downloading package..."
# apt-get install -y your-package
# success "Package installed!"

# TODO: Add configuration steps
# log "Configuring..."
# cp config.file /destination/
# success "Configuration complete!"

# Completion message
echo ""
success "Installation completed successfully!"
echo ""
echo "Additional info:"
echo "  - Add any important notes here"
echo "  - Usage instructions"
echo "  - Where files are located"
echo ""

# Optional: Ask to restart something
read -p "Would you like to restart [service] now? (y/n): " restart
if [[ $restart =~ ^[Yy]$ ]]; then
    log "Restarting [service]..."
    # systemctl restart your-service
    success "[Service] restarted"
fi

exit 0
EOFSCRIPT

# Replace placeholders
sed -i "s/DISPLAY_NAME_PLACEHOLDER/$display_name/g" "scripts/$script_id"
sed -i "s/DESCRIPTION_PLACEHOLDER/$description/g" "scripts/$script_id"

# Make executable
chmod +x "scripts/$script_id"

echo ""
echo "Script created: scripts/$script_id"
echo ""
echo "Now add this entry to manifest.json in the '$category' category:"
echo ""
echo "{"
echo "  \"id\": \"$script_id\","
echo "  \"name\": \"$display_name\","
echo "  \"description\": \"$description\""
echo "}"
echo ""
echo "Don't forget to edit the script and add your installation code!"
