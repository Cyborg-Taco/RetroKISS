#!/bin/bash
#
# RetroKISS Script: Safe Overclock
# Description: Apply safe overclock settings for Raspberry Pi
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_NAME="Safe Overclock"

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

echo "================================================"
echo "  $SCRIPT_NAME"
echo "================================================"
echo ""

warn "This will modify /boot/config.txt"
warn "A backup will be created at /boot/config.txt.backup"
echo ""
read -p "Continue with overclock? (y/n): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    log "Overclock cancelled"
    exit 0
fi

log "Creating backup..."
cp /boot/config.txt /boot/config.txt.backup

log "Detecting Raspberry Pi model..."

if grep -q "Raspberry Pi 5" /proc/cpuinfo; then
    log "Detected: Raspberry Pi 5"
    echo "" >> /boot/config.txt
    echo "# RetroKISS Safe Overclock (Pi 5)" >> /boot/config.txt
    echo "over_voltage=2" >> /boot/config.txt
    echo "arm_freq=2600" >> /boot/config.txt
    success "Pi 5 overclock applied (2.6 GHz)"
elif grep -q "Raspberry Pi 4" /proc/cpuinfo; then
    log "Detected: Raspberry Pi 4"
    echo "" >> /boot/config.txt
    echo "# RetroKISS Safe Overclock (Pi 4)" >> /boot/config.txt
    echo "over_voltage=6" >> /boot/config.txt
    echo "arm_freq=2000" >> /boot/config.txt
    echo "gpu_freq=750" >> /boot/config.txt
    success "Pi 4 overclock applied (2.0 GHz)"
elif grep -q "Raspberry Pi 3" /proc/cpuinfo; then
    log "Detected: Raspberry Pi 3"
    echo "" >> /boot/config.txt
    echo "# RetroKISS Safe Overclock (Pi 3)" >> /boot/config.txt
    echo "over_voltage=2" >> /boot/config.txt
    echo "arm_freq=1350" >> /boot/config.txt
    echo "core_freq=500" >> /boot/config.txt
    echo "sdram_freq=500" >> /boot/config.txt
    success "Pi 3 overclock applied (1.35 GHz)"
else
    error "Could not detect Pi model"
fi

echo ""
warn "IMPORTANT: You must reboot for changes to take effect!"
echo ""
echo "To monitor temperature after reboot:"
echo "  vcgencmd measure_temp"
echo ""
echo "If system is unstable, restore backup:"
echo "  sudo cp /boot/config.txt.backup /boot/config.txt"
echo ""

read -p "Reboot now? (y/n): " reboot
if [[ $reboot =~ ^[Yy]$ ]]; then
    log "Rebooting in 5 seconds..."
    sleep 5
    reboot
fi

exit 0
