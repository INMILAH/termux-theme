#!/bin/bash

# ==============================================
# CONFIGURATION
# ==============================================
CONFIG_DIR="$HOME/.termux/welcome"
CONFIG_FILE="$CONFIG_DIR/config.conf"
THEMES_DIR="$CONFIG_DIR/themes"

# Create directories if they don't exist
mkdir -p "$CONFIG_DIR" "$THEMES_DIR"

# ==============================================
# DEFAULT THEMES (10 NEW THEMES)
# ==============================================
declare -A DEFAULT_THEMES=(
    # Original Themes
    ["matrix"]="\e[38;5;40m|\e[38;5;82m|\e[38;5;46m|\e[38;5;240m|big"
    ["hacker"]="\e[1;32m|\e[0;32m|\e[1;36m|\e[1;37m|block"
    ["vibrant"]="\e[1;38;5;57m|\e[1;38;5;63m|\e[1;38;5;129m|\e[1;38;5;45m|block"
    
    # New Themes
    ["dracula"]="\e[38;5;141m|\e[38;5;147m|\e[38;5;135m|\e[38;5;61m|standard"
    ["nord"]="\e[38;5;109m|\e[38;5;113m|\e[38;5;110m|\e[38;5;146m|small"
    ["solarized"]="\e[38;5;136m|\e[38;5;166m|\e[38;5;130m|\e[38;5;240m|lean"
    ["monokai"]="\e[38;5;208m|\e[38;5;197m|\e[38;5;141m|\e[38;5;248m|block"
    ["gruvbox"]="\e[38;5;214m|\e[38;5;108m|\e[38;5;175m|\e[38;5;101m|big"
    ["ocean"]="\e[38;5;27m|\e[38;5;39m|\e[38;5;45m|\e[38;5;153m|small"
    ["forest"]="\e[38;5;28m|\e[38;5;34m|\e[38;5;76m|\e[38;5;22m|block"
    ["fire"]="\e[38;5;202m|\e[38;5;208m|\e[38;5;214m|\e[38;5;124m|big"
    ["ice"]="\e[38;5;39m|\e[38;5;45m|\e[38;5;51m|\e[38;5;195m|small"
)

# ==============================================
# INITIAL SETUP
# ==============================================
function first_run_setup() {
    clear
    echo -e "\e[1;36m"
    echo "╔════════════════════════════════════════╗"
    echo "║   TERMUX ULTIMATE WELCOME SETUP        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "\e[0m"
    
    # Install dependencies
    pkg install -y figlet lolcat toilet neofetch bc termux-api jq
    
    # Get user info
    read -p "Enter your name: " name
    read -p "Choose a title for your Termux: " title
    
    # Create default config
    cat > "$CONFIG_FILE" << EOL
USER_NAME="$name"
CUSTOM_TITLE="$title"
THEME="matrix"
SHOW_CPU=true
SHOW_RAM=true
SHOW_STORAGE=true
SHOW_NETWORK=true
SHOW_BATTERY=true
SHOW_QUOTES=true
ANIMATION_SPEED=15
EOL

    echo -e "\e[1;32m✓ Setup complete! Restart Termux.\e[0m"
    sleep 2
}

# ==============================================
# THEME MANAGEMENT
# ==============================================
function load_theme() {
    local theme_name=$1
    if [[ -z "${DEFAULT_THEMES[$theme_name]}" ]]; then
        theme_name="matrix" # Fallback to matrix theme
    fi
    
    IFS='|' read -r header_color text_color accent_color info_color font <<< "${DEFAULT_THEMES[$theme_name]}"
    
    export THEME_HEADER_COLOR=$header_color
    export THEME_TEXT_COLOR=$text_color
    export THEME_ACCENT_COLOR=$accent_color
    export THEME_INFO_COLOR=$info_color
    export THEME_FONT=$font
}

# ==============================================
# SYSTEM INFO FUNCTIONS
# ==============================================
function get_cpu_usage() {
    grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage)}'
}

function get_memory_usage() {
    free | awk '/Mem/{printf("%.0f"), $3/$2*100}'
}

function get_storage_usage() {
    df -h / | awk 'NR==2{print $5}' | tr -d '%'
}

function get_network_status() {
    if ping -c 1 google.com &> /dev/null; then
        echo -e "\e[1;32m✓ ONLINE\e[0m"
    else
        echo -e "\e[1;31m✗ OFFLINE\e[0m"
    fi
}

function get_battery_status() {
    if command -v termux-battery-status &> /dev/null; then
        local bat=$(termux-battery-status | jq -r '.percentage')
        echo -e "$bat%"
    else
        echo "N/A"
    fi
}

# ==============================================
# UI COMPONENTS
# ==============================================
function show_header() {
    clear
    echo -e "$THEME_HEADER_COLOR"
    figlet -f "$THEME_FONT" " $CUSTOM_TITLE " | lolcat -a -d 1
    echo -e "\e[0m"
    
    echo -e "$THEME_ACCENT_COLOR╔══════════════════════════════════════════╗"
    echo -e "║  Welcome back, $THEME_TEXT_COLOR$USER_NAME$THEME_ACCENT_COLOR!$(printf '%*s' $((31 - ${#USER_NAME}))║"
    echo -e "╚══════════════════════════════════════════╝"
    echo -e "$THEME_INFO_COLOR$(date +"%A, %d %B %Y %H:%M:%S")\e[0m"
    echo
}

function progress_bar() {
    local width=20
    local percent=$1
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    
    printf "["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' ' '
    printf "] %3d%%" "$percent"
}

function show_system_info() {
    echo -e "$THEME_ACCENT_COLOR⚡ SYSTEM STATUS$THEME_TEXT_COLOR"
    [ "$SHOW_CPU" = true ] && echo -e " • CPU:    $(progress_bar $(get_cpu_usage))"
    [ "$SHOW_RAM" = true ] && echo -e " • RAM:    $(progress_bar $(get_memory_usage))"
    [ "$SHOW_STORAGE" = true ] && echo -e " • STORAGE: $(progress_bar $(get_storage_usage))"
    [ "$SHOW_NETWORK" = true ] && echo -e " • NETWORK: $(get_network_status)"
    [ "$SHOW_BATTERY" = true ] && echo -e " • BATTERY: $(get_battery_status)"
    echo
    
    [ "$SHOW_QUOTES" = true ] && {
        quotes=(
            "The only way to do great work is to love what you do. - Steve Jobs"
            "Innovation distinguishes between a leader and a follower. - Steve Jobs"
            "Stay hungry, stay foolish. - Steve Jobs"
        )
        echo -e "$THEME_ACCENT_COLOR\"${quotes[$RANDOM % ${#quotes[@]}]}\"\e[0m"
        echo
    }
}

# ==============================================
# DISPLAY SETTINGS MENU
# ==============================================
function display_settings_menu() {
    while true; do
        clear
        echo -e "$THEME_HEADER_COLOR"
        echo "╔════════════════════════════════════════╗"
        echo "║        DISPLAY CONFIGURATION           ║"
        echo "╚════════════════════════════════════════╝"
        echo -e "\e[0m"
        
        echo -e "$THEME_ACCENT_COLORCurrent Display Settings:$THEME_TEXT_COLOR"
        echo -e " 1. Show CPU Usage:    [\e[1;3$((SHOW_CPU ? 2 : 1))m$SHOW_CPU\e[0m]"
        echo -e " 2. Show RAM Usage:    [\e[1;3$((SHOW_RAM ? 2 : 1))m$SHOW_RAM\e[0m]"
        echo -e " 3. Show Storage:      [\e[1;3$((SHOW_STORAGE ? 2 : 1))m$SHOW_STORAGE\e[0m]"
        echo -e " 4. Show Network:      [\e[1;3$((SHOW_NETWORK ? 2 : 1))m$SHOW_NETWORK\e[0m]"
        echo -e " 5. Show Battery:      [\e[1;3$((SHOW_BATTERY ? 2 : 1))m$SHOW_BATTERY\e[0m]"
        echo -e " 6. Show Quotes:       [\e[1;3$((SHOW_QUOTES ? 2 : 1))m$SHOW_QUOTES\e[0m]"
        echo -e " 7. Animation Speed:   $ANIMATION_SPEED"
        echo -e " 8. Back to Main Menu"
        
        read -p "Select option to change: " choice
        
        case $choice in
            1) toggle_setting "SHOW_CPU" ;;
            2) toggle_setting "SHOW_RAM" ;;
            3) toggle_setting "SHOW_STORAGE" ;;
            4) toggle_setting "SHOW_NETWORK" ;;
            5) toggle_setting "SHOW_BATTERY" ;;
            6) toggle_setting "SHOW_QUOTES" ;;
            7) change_animation_speed ;;
            8) break ;;
            *) echo -e "\e[1;31mInvalid option!\e[0m"; sleep 1 ;;
        esac
    done
}

function toggle_setting() {
    local setting=$1
    if [ "${!setting}" = "true" ]; then
        sed -i "s/^$setting=.*/$setting=false/" "$CONFIG_FILE"
    else
        sed -i "s/^$setting=.*/$setting=true/" "$CONFIG_FILE"
    fi
    source "$CONFIG_FILE"
}

function change_animation_speed() {
    clear
    echo -e "$THEME_HEADER_COLOR"
    echo "╔════════════════════════════════════════╗"
    echo "║        ANIMATION SPEED CONFIG          ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "\e[0m"

    read -p "Enter new speed: " speed
    
    if [[ $speed =~ ^[0-9]+$ ]] && [ $speed -ge 1 ] && [ $speed -le 20 ]; then
        sed -i "s/^ANIMATION_SPEED=.*/ANIMATION_SPEED=$speed/" "$CONFIG_FILE"
        echo -e "\e[1;32mAnimation speed updated!\e[0m"
        ANIMATION_SPEED=$speed
    else
        echo -e "\e[1;31mInvalid speed! Must be between 1-20\e[0m"
    fi
    sleep 1
}

# ==============================================
# THEME SELECTION MENU
# ==============================================
function theme_settings_menu() {
    while true; do
        clear
        echo -e "$THEME_HEADER_COLOR"
        echo "╔════════════════════════════════════════╗"
        echo "║          THEME SELECTION               ║"
        echo "╚════════════════════════════════════════╝"
        echo -e "\e[0m"
        
        echo -e "$THEME_ACCENT_COLORCurrent Theme: $THEME"
        echo -e "Available Themes:$THEME_TEXT_COLOR"
        
        local i=1
        local theme_options=()
        for theme in "${!DEFAULT_THEMES[@]}"; do
            echo -e " $i. $theme"
            theme_options+=("$theme")
            ((i++))
        done
        
        echo -e "\n $i. Back to Main Menu"
        
        read -p "Select theme: " choice
        
        if [ $choice -eq $i ]; then
            break
        elif [ $choice -gt 0 ] && [ $choice -lt $i ]; then
            selected_theme="${theme_options[$((choice-1))]}"
            sed -i "s/^THEME=.*/THEME=\"$selected_theme\"/" "$CONFIG_FILE"
            echo -e "\e[1;32mTheme changed to $selected_theme!\e[0m"
            load_theme "$selected_theme"
            sleep 1
        else
            echo -e "\e[1;31mInvalid selection!\e[0m"
            sleep 1
        fi
    done
}

# ==============================================
# MAIN MENU
# ==============================================
function main_menu() {
    while true; do
        show_header
        show_system_info
        
        echo -e "$THEME_ACCENT_COLOR🔧 MAIN MENU:$THEME_TEXT_COLOR"
        options=(
            "System Tools"
            "Package Manager"
            "Theme Settings"
            "Display Settings"
            "Exit"
        )
        
        select opt in "${options[@]}"; do
            case $opt in
                "System Tools") system_tools_menu ;;
                "Package Manager") package_manager_menu ;;
                "Theme Settings") theme_settings_menu ;;
                "Display Settings") display_settings_menu ;;
                "Exit") 
                    echo -e "$THEME_HEADER_COLOR Goodbye, $USER_NAME!\e[0m"
                    exit 0 
                    ;;
                *) echo -e "\e[1;31mInvalid option!\e[0m" ;;
            esac
            break
        done
    done
}

# ==============================================
# SYSTEM TOOLS MENU
# ==============================================
function system_tools_menu() {
    while true; do
        clear
        echo -e "$THEME_HEADER_COLOR"
        echo "╔════════════════════════════════════════╗"
        echo "║           SYSTEM TOOLS                 ║"
        echo "╚════════════════════════════════════════╝"
        echo -e "\e[0m"
        
        options=(
            "Check System Info"
            "Disk Usage"
            "Memory Usage"
            "View Running Processes"
            "Back to Main Menu"
        )
        
        select opt in "${options[@]}"; do
            case $opt in
                "Check System Info") neofetch ;;
                "Disk Usage") df -h ;;
                "Memory Usage") free -h ;;
                "View Running Processes") ps aux ;;
                "Back to Main Menu") return ;;
                *) echo -e "\e[1;31mInvalid option!\e[0m" ;;
            esac
            read -p "Press enter to continue..."
            break
        done
    done
}

# ==============================================
# PACKAGE MANAGER MENU
# ==============================================
function package_manager_menu() {
    while true; do
        clear
        echo -e "$THEME_HEADER_COLOR"
        echo "╔════════════════════════════════════════╗"
        echo "║         PACKAGE MANAGER                ║"
        echo "╚════════════════════════════════════════╝"
        echo -e "\e[0m"
        
        options=(
            "Update Packages"
            "Upgrade Packages"
            "Install Package"
            "Remove Package"
            "List Installed Packages"
            "Back to Main Menu"
        )
        
        select opt in "${options[@]}"; do
            case $opt in
                "Update Packages") pkg update ;;
                "Upgrade Packages") pkg upgrade ;;
                "Install Package") 
                    read -p "Enter package name to install: " pkg_name
                    pkg install "$pkg_name" 
                    ;;
                "Remove Package") 
                    read -p "Enter package name to remove: " pkg_name
                    pkg uninstall "$pkg_name" 
                    ;;
                "List Installed Packages") pkg list-installed ;;
                "Back to Main Menu") return ;;
                *) echo -e "\e[1;31mInvalid option!\e[0m" ;;
            esac
            read -p "Press enter to continue..."
            break
        done
    done
}

# ==============================================
# START APPLICATION
# ==============================================
if [ ! -f "$CONFIG_FILE" ]; then
    first_run_setup
fi

source "$CONFIG_FILE"
load_theme "$THEME"
main_menu
