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
STATE_DIR="$SCRIPT_DIR/.retrokiss_state"
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

# Create directories
mkdir -p "$CACHE_DIR"
mkdir -p "$STATE_DIR"

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

# Check if package is installed
is_installed() {
    local script_id=$1
    [ -f "$STATE_DIR/${script_id}.installed" ]
}

# Mark package as installed
mark_installed() {
    local script_id=$1
    touch "$STATE_DIR/${script_id}.installed"
    date +%s > "$STATE_DIR/${script_id}.installed"
}

# Mark package as uninstalled
mark_uninstalled() {
    local script_id=$1
    rm -f "$STATE_DIR/${script_id}.installed"
}

# Get package info from manifest
get_package_info() {
    local manifest_file=$1
    local script_id=$2
    
    jq -r ".categories[].items[] | select(.id==\"$script_id\") | .name + \"|\" + .description" "$manifest_file"
}

# Parse manifest and build menu
parse_manifest() {
    local manifest_file=$1
    local category=$2
    
    if [ ! -f "$manifest_file" ]; then
        return 1
    fi
    
    jq -r ".categories[] | select(.name==\"$category\") | .items[] | \"\(.id)|\(.name)|\(.description)\"" "$manifest_file"
}

# Download script
download_script() {
    local script_name=$1
    local script_url="$GITHUB_REPO/scripts/$script_name"
    local script_file="$CACHE_DIR/$script_name"
    
    wget -q -O "$script_file" "$script_url" 2>/dev/null || {
        return 1
    }
    
    chmod +x "$script_file"
    echo "$script_file"
}

# Show package details and actions
show_package_menu() {
    local script_id=$1
    local manifest_file="$CACHE_DIR/manifest.json"
    
    # Get package info
    local info=$(get_package_info "$manifest_file" "$script_id")
    local name=$(echo "$info" | cut -d'|' -f1)
    local description=$(echo "$info" | cut -d'|' -f2)
    
    while true; do
        local menu_items=()
        local status_text=""
        
        if is_installed "$script_id"; then
            status_text="[INSTALLED]"
            menu_items+=("1" "Update")
            menu_items+=("2" "Remove")
        else
            status_text="[NOT INSTALLED]"
            menu_items+=("1" "Install")
        fi
        
        menu_items+=("0" "Back")
        
        local choice=$(dialog --clear --title "$name $status_text" \
            --menu "$description\n\nChoose an action:" 18 70 10 \
            "${menu_items[@]}" \
            2>&1 >/dev/tty)
        
        clear
        
        case $choice in
            1)
                if is_installed "$script_id"; then
                    # Update
                    dialog --title "Updating" --infobox "Updating $name..." 5 50
                    local script_file=$(download_script "$script_id")
                    if [ -n "$script_file" ]; then
                        clear
                        if bash "$script_file" "update"; then
                            mark_installed "$script_id"
                            dialog --title "Success" --msgbox "$name updated successfully!" 6 40
                        else
                            dialog --title "Error" --msgbox "Update failed!" 6 40
                        fi
                    else
                        dialog --title "Error" --msgbox "Failed to download update" 6 40
                    fi
                else
                    # Install
                    dialog --title "Installing" --infobox "Installing $name..." 5 50
                    local script_file=$(download_script "$script_id")
                    if [ -n "$script_file" ]; then
                        clear
                        if bash "$script_file" "install"; then
                            mark_installed "$script_id"
                            dialog --title "Success" --msgbox "$name installed successfully!" 6 40
                        else
                            dialog --title "Error" --msgbox "Installation failed!" 6 40
                        fi
                    else
                        dialog --title "Error" --msgbox "Failed to download script" 6 40
                    fi
                fi
                ;;
            2)
                # Remove
                if is_installed "$script_id"; then
                    dialog --title "Confirm" --yesno "Are you sure you want to remove $name?" 7 50
                    if [ $? -eq 0 ]; then
                        dialog --title "Removing" --infobox "Removing $name..." 5 50
                        local script_file=$(download_script "$script_id")
                        if [ -n "$script_file" ]; then
                            clear
                            if bash "$script_file" "remove"; then
                                mark_uninstalled "$script_id"
                                dialog --title "Success" --msgbox "$name removed successfully!" 6 40
                            else
                                dialog --title "Error" --msgbox "Removal failed!" 6 40
                            fi
                        fi
                    fi
                fi
                ;;
            0|*)
                break
                ;;
        esac
    done
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
            local status=""
            if is_installed "$id"; then
                status="[✓]"
            else
                status="[ ]"
            fi
            menu_items+=("$counter" "$status $name")
            counter=$((counter + 1))
        done < <(parse_manifest "$manifest_file" "$category")
        
        # Add back option
        menu_items+=("0" "Back to Main Menu")
        
        # Show menu
        local choice=$(dialog --clear --title "$title" \
            --menu "Select a package:" 20 70 15 \
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
        
        # Show package menu
        show_package_menu "$script_id"
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
