#!/bin/bash
#
# RetroKISS - RetroPie Kick-start Install Script Suite
# A PiKISS-style menu-driven installer for RetroPie enhancements
#
# Usage: sudo ./retrokiss.sh
#

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/retrokiss.log"
RETROPIE_HOME="/opt/retropie"
RETROPIE_CONFIGS="/opt/retropie/configs"
ROMS_DIR="$HOME/RetroPie/roms"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Get actual user (not root when using sudo)
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Banner function
show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              RetroKISS - RetroPie Enhanced                 ║"
    echo "║         Kick-start Install Script Suite v1.0              ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Progress spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Success/Error messages
success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
    log "SUCCESS: $1"
}

error_msg() {
    echo -e "${RED}✗ $1${NC}"
    log "ERROR: $1"
}

info_msg() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warning_msg() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Pause function
pause() {
    echo ""
    read -p "Press [Enter] to continue..."
}

# Check dependencies
check_dependencies() {
    local deps=("dialog" "wget" "git" "curl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        info_msg "Installing missing dependencies: ${missing[*]}"
        apt-get update -qq
        apt-get install -y "${missing[@]}" > /dev/null 2>&1
        success_msg "Dependencies installed"
    fi
}

###############################################################################
# THEMES AND UI IMPROVEMENTS
###############################################################################

install_es_theme() {
    local theme_name=$1
    local theme_url=$2
    local theme_dir="/etc/emulationstation/themes/$theme_name"
    
    info_msg "Installing theme: $theme_name"
    
    if [ -d "$theme_dir" ]; then
        warning_msg "Theme already exists. Updating..."
        rm -rf "$theme_dir"
    fi
    
    mkdir -p "/etc/emulationstation/themes"
    git clone --depth 1 "$theme_url" "$theme_dir" > /dev/null 2>&1 &
    spinner $!
    
    if [ $? -eq 0 ]; then
        success_msg "Theme $theme_name installed successfully"
    else
        error_msg "Failed to install theme"
        return 1
    fi
}

themes_menu() {
    while true; do
        show_banner
        echo -e "${MAGENTA}${BOLD}THEMES & UI IMPROVEMENTS${NC}"
        echo ""
        echo "1) Install Carbon Theme (Clean, modern)"
        echo "2) Install Pixel Theme (Retro pixel art)"
        echo "3) Install Tronkyfran Theme (Sleek, minimalist)"
        echo "4) Install ComicBook Theme (Comic style)"
        echo "5) Install Epic Noir Theme (Dark, elegant)"
        echo "6) Install Video View Support"
        echo "7) Optimize EmulationStation Performance"
        echo ""
        echo "0) Back to Main Menu"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1)
                install_es_theme "carbon" "https://github.com/RetroPie/es-theme-carbon.git"
                pause
                ;;
            2)
                install_es_theme "pixel" "https://github.com/ehettervik/es-theme-pixel.git"
                pause
                ;;
            3)
                install_es_theme "tronkyfran" "https://github.com/HerbFargus/es-theme-tronkyfran.git"
                pause
                ;;
            4)
                install_es_theme "ComicBook" "https://github.com/TMNTturtleguy/es-theme-ComicBook.git"
                pause
                ;;
            5)
                install_es_theme "epic-noir" "https://github.com/c64-dev/es-theme-epicnoir.git"
                pause
                ;;
            6)
                info_msg "Enabling video view support..."
                # Enable video support in ES
                if [ -f "/opt/retropie/configs/all/emulationstation/es_settings.cfg" ]; then
                    sed -i 's/<bool name="VideoAudio" value="false"\/>/<bool name="VideoAudio" value="true"\/>/' \
                        /opt/retropie/configs/all/emulationstation/es_settings.cfg
                    sed -i 's/<bool name="EnableVideos" value="false"\/>/<bool name="EnableVideos" value="true"\/>/' \
                        /opt/retropie/configs/all/emulationstation/es_settings.cfg
                    success_msg "Video support enabled"
                else
                    warning_msg "ES settings file not found"
                fi
                pause
                ;;
            7)
                info_msg "Optimizing EmulationStation..."
                # Disable unwanted ES features for performance
                cat > /tmp/es_optimize.sh << 'EOF'
# Disable transitions
sed -i 's/<string name="TransitionStyle" value=".*"\/>/<string name="TransitionStyle" value="instant"\/>/' \
    /opt/retropie/configs/all/emulationstation/es_settings.cfg 2>/dev/null || true
EOF
                bash /tmp/es_optimize.sh
                rm /tmp/es_optimize.sh
                success_msg "EmulationStation optimized"
                pause
                ;;
            0)
                break
                ;;
            *)
                error_msg "Invalid option"
                pause
                ;;
        esac
    done
}

###############################################################################
# PERFORMANCE OPTIMIZATIONS
###############################################################################

performance_menu() {
    while true; do
        show_banner
        echo -e "${MAGENTA}${BOLD}PERFORMANCE OPTIMIZATIONS${NC}"
        echo ""
        echo "1) Overclock Raspberry Pi (Safe presets)"
        echo "2) Optimize Memory Split"
        echo "3) Disable Unnecessary Services"
        echo "4) Enable Threaded Video Driver"
        echo "5) Optimize Swap Settings"
        echo "6) Full Performance Package (All above)"
        echo ""
        echo "0) Back to Main Menu"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1)
                info_msg "Applying safe overclock settings..."
                warning_msg "This will modify /boot/config.txt"
                read -p "Continue? (y/n): " confirm
                if [[ $confirm == [yY] ]]; then
                    # Backup config
                    cp /boot/config.txt /boot/config.txt.backup
                    
                    # Add overclock settings for Pi 4
                    if grep -q "Raspberry Pi 4" /proc/cpuinfo; then
                        cat >> /boot/config.txt << EOF

# RetroKISS Overclock Settings (Pi 4)
over_voltage=6
arm_freq=2000
gpu_freq=750
EOF
                        success_msg "Overclock applied (Pi 4)"
                    else
                        cat >> /boot/config.txt << EOF

# RetroKISS Overclock Settings (Pi 3)
over_voltage=2
arm_freq=1350
core_freq=500
sdram_freq=500
EOF
                        success_msg "Overclock applied (Pi 3)"
                    fi
                    warning_msg "Reboot required for changes to take effect"
                fi
                pause
                ;;
            2)
                info_msg "Optimizing GPU memory split..."
                # Set GPU memory to 256MB for better emulation
                if grep -q "^gpu_mem=" /boot/config.txt; then
                    sed -i 's/^gpu_mem=.*/gpu_mem=256/' /boot/config.txt
                else
                    echo "gpu_mem=256" >> /boot/config.txt
                fi
                success_msg "GPU memory set to 256MB"
                warning_msg "Reboot required"
                pause
                ;;
            3)
                info_msg "Disabling unnecessary services..."
                systemctl disable bluetooth.service 2>/dev/null || true
                systemctl disable triggerhappy.service 2>/dev/null || true
                systemctl disable avahi-daemon.service 2>/dev/null || true
                success_msg "Services disabled"
                pause
                ;;
            4)
                info_msg "Enabling threaded video driver in RetroArch..."
                find /opt/retropie/configs -name "retroarch.cfg" -exec sed -i 's/video_threaded = "false"/video_threaded = "true"/' {} \;
                success_msg "Threaded video enabled"
                pause
                ;;
            5)
                info_msg "Optimizing swap settings..."
                if [ -f /etc/dphys-swapfile ]; then
                    sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=512/' /etc/dphys-swapfile
                    systemctl restart dphys-swapfile
                    success_msg "Swap optimized to 512MB"
                else
                    warning_msg "Swap configuration not found"
                fi
                pause
                ;;
            6)
                warning_msg "This will apply ALL performance optimizations"
                read -p "Continue? (y/n): " confirm
                if [[ $confirm == [yY] ]]; then
                    info_msg "Applying full performance package..."
                    
                    # Run all optimizations
                    cp /boot/config.txt /boot/config.txt.backup
                    echo "gpu_mem=256" >> /boot/config.txt
                    systemctl disable bluetooth.service 2>/dev/null || true
                    systemctl disable triggerhappy.service 2>/dev/null || true
                    find /opt/retropie/configs -name "retroarch.cfg" -exec sed -i 's/video_threaded = "false"/video_threaded = "true"/' {} \;
                    
                    success_msg "All optimizations applied"
                    warning_msg "Reboot recommended"
                fi
                pause
                ;;
            0)
                break
                ;;
            *)
                error_msg "Invalid option"
                pause
                ;;
        esac
    done
}

###############################################################################
# GAME PORTS
###############################################################################

ports_menu() {
    while true; do
        show_banner
        echo -e "${MAGENTA}${BOLD}GAME PORTS & ENGINES${NC}"
        echo ""
        echo "1) Install OpenBOR (Beat 'em up engine)"
        echo "2) Install additional ScummVM games support"
        echo "3) Install Doom (PrBoom)"
        echo "4) Install Quake (Tyrquake)"
        echo "5) Install Cave Story"
        echo "6) Install Sonic Robo Blast 2"
        echo ""
        echo "0) Back to Main Menu"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1)
                info_msg "Installing OpenBOR..."
                if [ -d "/opt/retropie/supplementary/openbor" ]; then
                    warning_msg "OpenBOR already installed"
                else
                    cd /home/$ACTUAL_USER/RetroPie-Setup
                    sudo -u $ACTUAL_USER ./retropie_packages.sh openbor
                    success_msg "OpenBOR installed"
                    info_msg "Place .pak files in: $ROMS_DIR/ports/openbor"
                fi
                pause
                ;;
            2)
                info_msg "ScummVM is already part of RetroPie"
                info_msg "Installing additional dependencies..."
                apt-get install -y scummvm-data 2>/dev/null || true
                success_msg "Additional ScummVM support installed"
                info_msg "Place game folders in: $ROMS_DIR/scummvm"
                pause
                ;;
            3)
                info_msg "Installing Doom (PrBoom)..."
                apt-get install -y prboom-plus 2>/dev/null || true
                mkdir -p "$ROMS_DIR/ports/doom"
                success_msg "Doom support installed"
                info_msg "Place .wad files in: $ROMS_DIR/ports/doom"
                pause
                ;;
            4)
                info_msg "Installing Quake..."
                cd /home/$ACTUAL_USER/RetroPie-Setup
                sudo -u $ACTUAL_USER ./retropie_packages.sh tyrquake
                success_msg "Quake installed"
                pause
                ;;
            5)
                info_msg "Installing Cave Story..."
                cd /home/$ACTUAL_USER/RetroPie-Setup
                sudo -u $ACTUAL_USER ./retropie_packages.sh cavestory
                success_msg "Cave Story installed"
                pause
                ;;
            6)
                info_msg "Installing Sonic Robo Blast 2..."
                cd /home/$ACTUAL_USER/RetroPie-Setup
                sudo -u $ACTUAL_USER ./retropie_packages.sh srb2
                success_msg "SRB2 installed"
                pause
                ;;
            0)
                break
                ;;
            *)
                error_msg "Invalid option"
                pause
                ;;
        esac
    done
}

###############################################################################
# UTILITIES AND TOOLS
###############################################################################

utilities_menu() {
    while true; do
        show_banner
        echo -e "${MAGENTA}${BOLD}UTILITIES & TOOLS${NC}"
        echo ""
        echo "1) Install Skyscraper (ROM scraper)"
        echo "2) Install Kodi Media Center"
        echo "3) Install Moonlight Game Streaming"
        echo "4) Install File Manager (Midnight Commander)"
        echo "5) Setup Samba Shares (Network file access)"
        echo "6) Install Retropie Manager (Web interface)"
        echo "7) Install Bluetooth Audio Support"
        echo ""
        echo "0) Back to Main Menu"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1)
                info_msg "Installing Skyscraper..."
                cd /home/$ACTUAL_USER/RetroPie-Setup
                sudo -u $ACTUAL_USER ./retropie_packages.sh skyscraper
                success_msg "Skyscraper installed"
                info_msg "Run from RetroPie menu or use: Skyscraper -p [system]"
                pause
                ;;
            2)
                info_msg "Installing Kodi..."
                cd /home/$ACTUAL_USER/RetroPie-Setup
                sudo -u $ACTUAL_USER ./retropie_packages.sh kodi
                success_msg "Kodi installed"
                pause
                ;;
            3)
                info_msg "Installing Moonlight..."
                cd /home/$ACTUAL_USER/RetroPie-Setup
                sudo -u $ACTUAL_USER ./retropie_packages.sh moonlight
                success_msg "Moonlight installed"
                pause
                ;;
            4)
                info_msg "Installing Midnight Commander..."
                apt-get install -y mc
                success_msg "File manager installed. Run with: mc"
                pause
                ;;
            5)
                info_msg "Setting up Samba shares..."
                cd /home/$ACTUAL_USER/RetroPie-Setup
                sudo -u $ACTUAL_USER ./retropie_packages.sh samba depends
                sudo -u $ACTUAL_USER ./retropie_packages.sh samba install_share
                success_msg "Samba configured"
                info_msg "Access via: \\\\retropie (Windows) or smb://retropie (Linux/Mac)"
                pause
                ;;
            6)
                info_msg "Installing RetroPie Manager..."
                wget -O - https://raw.githubusercontent.com/botolo78/RetroPie-Manager/master/install.sh | bash
                success_msg "RetroPie Manager installed"
                info_msg "Access at: http://$(hostname -I | awk '{print $1}'):8000"
                pause
                ;;
            7)
                info_msg "Installing Bluetooth audio support..."
                apt-get install -y pulseaudio pulseaudio-module-bluetooth bluez-tools
                success_msg "Bluetooth audio installed"
                info_msg "Pair devices with: bluetoothctl"
                pause
                ;;
            0)
                break
                ;;
            *)
                error_msg "Invalid option"
                pause
                ;;
        esac
    done
}

###############################################################################
# MAIN MENU
###############################################################################

main_menu() {
    while true; do
        show_banner
        echo -e "${BOLD}MAIN MENU${NC}"
        echo ""
        echo "1) Themes & UI Improvements"
        echo "2) Performance Optimizations"
        echo "3) Game Ports & Engines"
        echo "4) Utilities & Tools"
        echo ""
        echo "5) System Information"
        echo "6) View Log File"
        echo ""
        echo "0) Exit"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1)
                themes_menu
                ;;
            2)
                performance_menu
                ;;
            3)
                ports_menu
                ;;
            4)
                utilities_menu
                ;;
            5)
                show_banner
                echo -e "${BOLD}SYSTEM INFORMATION${NC}"
                echo ""
                echo "Hostname: $(hostname)"
                echo "IP Address: $(hostname -I | awk '{print $1}')"
                echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
                echo "Kernel: $(uname -r)"
                echo "Model: $(cat /proc/device-tree/model 2>/dev/null || echo 'Unknown')"
                echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
                echo "Disk Space: $(df -h / | awk 'NR==2 {print $4}') free"
                echo ""
                pause
                ;;
            6)
                if [ -f "$LOG_FILE" ]; then
                    less "$LOG_FILE"
                else
                    warning_msg "No log file found"
                    pause
                fi
                ;;
            0)
                echo ""
                info_msg "Thanks for using RetroKISS!"
                exit 0
                ;;
            *)
                error_msg "Invalid option"
                pause
                ;;
        esac
    done
}

###############################################################################
# STARTUP
###############################################################################

# Initialize
log "RetroKISS started"
check_dependencies
main_menu
