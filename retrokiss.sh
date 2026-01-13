#!/bin/bash
#
# RetroKISS - RetroPie Kick-start Install Script Suite
# A modular installer that pulls scripts from GitHub
#
# Usage: sudo ./retrokiss.sh
#

set -e

# Configuration
GITHUB_REPO="https://raw.githubusercontent.com/Cyborg-Taco/RetroKISS/main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$SCRIPT_DIR/.retrokiss_cache"
CONFIG_FILE="$SCRIPT_DIR/retrokiss.conf"
LOG_FILE="$SCRIPT_DIR/retrokiss.log"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Get actual user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

# Create cache directory
mkdir -p "$CACHE_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check dependencies
check_dependencies() {
    local deps=("dialog" "wget" "git" "curl" "jq")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" > /dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Installing missing dependencies: ${missing[*]}"
        apt-get update -qq
        apt-get install -y "${missing[@]}" > /dev/null 2>&1
    fi
}

# Download manifest from GitHub
download_manifest() {
    local manifest_url="$GITHUB_REPO/manifest.json"
    local manifest_file="$CACHE_DIR/manifest.json"
    
    wget -q -O "$manifest_file" "$manifest_url" 2>/dev/null || {
        dialog --title "Error" --msgbox "Failed to download manifest from GitHub.\nCheck your internet connection." 8 50
        return 1
    }
    
    echo "$manifest_file"
}

# Parse manifest and build menu
parse_manifest() {
    local manifest_file=$1
    local category=$2
    
    if [ ! -f "$manifest_file" ]; then
        return 1
    fi
    
    # Extract items for the category
    jq -r ".categories[] | select(.name==\"$category\") | .items[] | \"\(.id)|\(.name)|\(.description)\"" "$manifest_file"
}

# Download and execute script
run_script() {
    local script_name=$1
    local script_url="$GITHUB_REPO/scripts/$script_name"
    local script_file="$CACHE_DIR/$script_name"
    
    # Show progress
    dialog --title "Downloading" --infobox "Downloading $script_name..." 5 50
    
    # Download script
    wget -q -O "$script_file" "$script_url" 2>/dev/null || {
        dialog --title "Error" --msgbox "Failed to download script: $script_name" 8 50
        return 1
    }
    
    # Make executable
    chmod +x "$script_file"
    
    # Execute script
    clear
    bash "$script_file"
    local exit_code=$?
    
    # Show result
    if [ $exit_code -eq 0 ]; then
        dialog --title "Success" --msgbox "Script completed successfully!" 6 40
    else
        dialog --title "Error" --msgbox "Script failed with exit code: $exit_code" 8 50
    fi
    
    return $exit_code
}

# Build dynamic menu from manifest
show_category_menu() {
    local category=$1
    local title=$2
    local manifest_file="$CACHE_DIR/manifest.json"
    
    while true; do
        local menu_items=()
        local counter=1
        
        # Parse manifest for this category
        while IFS='|' read -r id name description; do
            menu_items+=("$counter" "$name")
            counter=$((counter + 1))
        done < <(parse_manifest "$manifest_file" "$category")
        
        # Add back option
        menu_items+=("0" "Back to Main Menu")
        
        # Show menu
        local choice=$(dialog --clear --title "$title" \
            --menu "Select an option:" 20 70 15 \
            "${menu_items[@]}" \
            2>&1 >/dev/tty)
        
        clear
        
        # Handle selection
        if [ $? -ne 0 ] || [ "$choice" = "0" ]; then
            break
        fi
        
        # Get the selected item
        local selected_line=$(parse_manifest "$manifest_file" "$category" | sed -n "${choice}p")
        local script_id=$(echo "$selected_line" | cut -d'|' -f1)
        
        # Run the script
        run_script "$script_id"
    done
}

# Main menu
main_menu() {
    local manifest_file=$(download_manifest)
    
    if [ ! -f "$manifest_file" ]; then
        echo "Failed to load manifest. Exiting."
        exit 1
    fi
    
    while true; do
        local choice=$(dialog --clear --title "RetroKISS - RetroPie Enhancement Suite" \
            --menu "Choose a category:" 20 70 10 \
            1 "Themes & UI Improvements" \
            2 "Performance Optimizations" \
            3 "Game Ports & Engines" \
            4 "Utilities & Tools" \
            5 "Update RetroKISS" \
            6 "System Information" \
            0 "Exit" \
            2>&1 >/dev/tty)
        
        clear
        
        case $choice in
            1)
                show_category_menu "themes" "Themes & UI Improvements"
                ;;
            2)
                show_category_menu "performance" "Performance Optimizations"
                ;;
            3)
                show_category_menu "ports" "Game Ports & Engines"
                ;;
            4)
                show_category_menu "utilities" "Utilities & Tools"
                ;;
            5)
                dialog --title "Update" --infobox "Updating RetroKISS from GitHub..." 5 50
                cd "$SCRIPT_DIR"
                git pull origin main 2>/dev/null || {
                    wget -q -O retrokiss.sh "$GITHUB_REPO/retrokiss.sh"
                    chmod +x retrokiss.sh
                }
                dialog --title "Success" --msgbox "RetroKISS updated! Please restart the script." 6 50
                exit 0
                ;;
            6)
                local sysinfo="Hostname: $(hostname)\n"
                sysinfo+="IP Address: $(hostname -I | awk '{print $1}')\n"
                sysinfo+="OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2)\n"
                sysinfo+="Kernel: $(uname -r)\n"
                if [ -f /proc/device-tree/model ]; then
                    sysinfo+="Model: $(cat /proc/device-tree/model)\n"
                fi
                sysinfo+="Memory: $(free -h | awk '/^Mem:/ {print $2}')\n"
                sysinfo+="Disk Free: $(df -h / | awk 'NR==2 {print $4}')"
                
                dialog --title "System Information" --msgbox "$sysinfo" 15 60
                ;;
            0|*)
                dialog --title "Goodbye" --infobox "Thanks for using RetroKISS!" 5 40
                sleep 2
                clear
                exit 0
                ;;
        esac
    done
}

# Startup
log "RetroKISS started"
check_dependencies
main_menu
