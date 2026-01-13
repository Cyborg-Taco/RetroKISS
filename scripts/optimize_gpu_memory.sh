#!/bin/bash
#
# RetroKISS Script: Optimize GPU Memory
# Description: Set optimal GPU memory split for RetroPie
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="GPU Memory Optimizer"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

log "Current GPU memory split:"
vcgencmd get_mem gpu

echo ""
echo "Recommended GPU memory settings:"
echo "  256MB - Best for most emulators"
echo "  512MB - For N64, PSP, Dreamcast"
echo "  128MB - If you have limited RAM"
echo ""

read -p "Enter GPU memory amount (128/256/512) [256]: " gpu_mem
gpu_mem=${gpu_mem:-256}

if [[ ! "$gpu_mem" =~ ^(128|256|512)$ ]]; then
    error "Invalid value. Must be 128, 256, or 512"
fi

log "Setting GPU memory to ${gpu_mem}MB..."

if grep -q "^gpu_mem=" /boot/config.txt; then
    sed -i "s/^gpu_mem=.*/gpu_mem=$gpu_mem/" /boot/config.txt
    log "Updated existing gpu_mem setting"
else
    echo "gpu_mem=$gpu_mem" >> /boot/config.txt
    log "Added gpu_mem setting"
fi

success "GPU memory set to ${gpu_mem}MB"
echo ""
warn "Reboot required for changes to take effect"

read -p "Reboot now? (y/n): " reboot
if [[ $reboot =~ ^[Yy]$ ]]; then
    log "Rebooting..."
    sleep 2
    reboot
fi

exit 0
