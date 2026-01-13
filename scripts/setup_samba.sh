#!/bin/bash
#
# RetroKISS Script: Samba Network Shares
# Description: Setup Samba for network ROM access
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Samba Network Shares Setup"
ACTUAL_USER="${SUDO_USER:-$USER}"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "Samba allows you to access ROMs over your network"
echo ""

if systemctl is-active --quiet smbd 2>/dev/null || systemctl is-active --quiet samba 2>/dev/null; then
    warn "Samba appears to be already installed"
    read -p "Reconfigure anyway? (y/n): " confirm
    [[ ! $confirm =~ ^[Yy]$ ]] && exit 0
fi

log "Installing Samba..."
apt-get update -qq
apt-get install -y samba samba-common-bin

log "Configuring Samba shares..."

# Backup existing config
if [ -f /etc/samba/smb.conf ]; then
    cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
fi

# Add RetroPie shares
cat >> /etc/samba/smb.conf << EOF

[retropie]
   comment = RetroPie
   path = /home/$ACTUAL_USER/RetroPie
   writeable = yes
   guest ok = yes
   create mask = 0644
   directory mask = 0755
   force user = $ACTUAL_USER

[roms]
   comment = ROMs
   path = /home/$ACTUAL_USER/RetroPie/roms
   writeable = yes
   guest ok = yes
   create mask = 0644
   directory mask = 0755
   force user = $ACTUAL_USER

[bios]
   comment = BIOS Files
   path = /home/$ACTUAL_USER/RetroPie/BIOS
   writeable = yes
   guest ok = yes
   create mask = 0644
   directory mask = 0755
   force user = $ACTUAL_USER
EOF

log "Restarting Samba service..."
systemctl restart smbd 2>/dev/null || systemctl restart samba 2>/dev/null

success "Samba configured successfully!"
echo ""
echo "Access your RetroPie files from another computer:"
echo ""
echo "Windows:"
echo "  \\\\$(hostname -I | awk '{print $1}')\\retropie"
echo "  \\\\$(hostname -I | awk '{print $1}')\\roms"
echo ""
echo "Mac/Linux:"
echo "  smb://$(hostname -I | awk '{print $1}')/retropie"
echo "  smb://$(hostname -I | awk '{print $1}')/roms"
echo ""
echo "Or browse to: $(hostname)"

exit 0
