#!/bin/bash

# TuxTech Monitor V6 - Enhanced Edition with Advanced Customization
# Advanced server monitoring with Docker, services, ports, and comprehensive system analysis

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
WHITE='\033[1;37m'
PINK='\033[1;35m'
LIGHT_BLUE='\033[1;34m'
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
MAGENTA='\033[0;95m'
LIGHT_CYAN='\033[1;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
DIM='\033[2m'

# Background colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Configuration
SCAN_COMMON_PORTS=(80 443 22 21 25 3306 5432 6379 8080 8443 9000 3000 5000 8000 27017 9200 11211 15672)
LOG_FILE="/var/log/tuxtech_monitor_v6.log"
CONFIG_DIR="/etc/tuxtech"
CONFIG_FILE="${CONFIG_DIR}/visual_config.conf"

# Default configuration values
DEFAULT_LOGO_COLOR="${CYAN}"
DEFAULT_BORDER_STYLE="double"
DEFAULT_BORDER_COLOR="${CYAN}"
DEFAULT_HEADER_COLOR="${WHITE}"
DEFAULT_TEXT_COLOR="${WHITE}"
DEFAULT_HIGHLIGHT_COLOR="${YELLOW}"
DEFAULT_BOTTOM_TEXT="INTEGRATED CLOUD COMPUTING PLATFORM - ENHANCED V6"
DEFAULT_ENABLE_ANIMATIONS="false"
DEFAULT_ENABLE_EFFECTS="false"
DEFAULT_THEME="classic"
DEFAULT_PROMPT_SYMBOL=">"
DEFAULT_MENU_STYLE="numbers"
DEFAULT_DATE_FORMAT="%Y-%m-%d %H:%M:%S"
DEFAULT_ENABLE_SOUND="false"

# Initialize configuration
init_config() {
    # Create config directory if it doesn't exist
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi
    
    # Set defaults
    LOGO_COLOR="${DEFAULT_LOGO_COLOR}"
    BORDER_STYLE="${DEFAULT_BORDER_STYLE}"
    BORDER_COLOR="${DEFAULT_BORDER_COLOR}"
    HEADER_COLOR="${DEFAULT_HEADER_COLOR}"
    TEXT_COLOR="${DEFAULT_TEXT_COLOR}"
    HIGHLIGHT_COLOR="${DEFAULT_HIGHLIGHT_COLOR}"
    BOTTOM_TEXT="${DEFAULT_BOTTOM_TEXT}"
    ENABLE_ANIMATIONS="${DEFAULT_ENABLE_ANIMATIONS}"
    ENABLE_EFFECTS="${DEFAULT_ENABLE_EFFECTS}"
    CURRENT_THEME="${DEFAULT_THEME}"
    PROMPT_SYMBOL="${DEFAULT_PROMPT_SYMBOL}"
    MENU_STYLE="${DEFAULT_MENU_STYLE}"
    DATE_FORMAT="${DEFAULT_DATE_FORMAT}"
    ENABLE_SOUND="${DEFAULT_ENABLE_SOUND}"
    CUSTOM_LOGO_LINE1=""
    CUSTOM_LOGO_LINE2=""
    CUSTOM_LOGO_LINE3=""
    CUSTOM_LOGO_LINE4=""
    CUSTOM_LOGO_LINE5=""
    CUSTOM_LOGO_LINE6=""
    USE_CUSTOM_LOGO="false"
}

# Load visual configuration if exists
load_visual_config() {
    init_config
    
    if [ -f "$CONFIG_FILE" ]; then
        # Source the config file
        source "$CONFIG_FILE" 2>/dev/null || {
            echo -e "${YELLOW}Warning: Could not load config file, using defaults${NC}"
        }
    fi
}

# Save visual configuration
save_visual_config() {
    mkdir -p "$CONFIG_DIR"
    
    cat > "$CONFIG_FILE" << EOF
# TuxTech Monitor V6 Visual Configuration
# Generated: $(date)

# Colors
LOGO_COLOR="${LOGO_COLOR}"
BORDER_COLOR="${BORDER_COLOR}"
HEADER_COLOR="${HEADER_COLOR}"
TEXT_COLOR="${TEXT_COLOR}"
HIGHLIGHT_COLOR="${HIGHLIGHT_COLOR}"

# Border Style
BORDER_STYLE="${BORDER_STYLE}"

# Text
BOTTOM_TEXT="${BOTTOM_TEXT}"

# Effects
ENABLE_ANIMATIONS="${ENABLE_ANIMATIONS}"
ENABLE_EFFECTS="${ENABLE_EFFECTS}"
ENABLE_SOUND="${ENABLE_SOUND}"

# Theme
CURRENT_THEME="${CURRENT_THEME}"

# Interface
PROMPT_SYMBOL="${PROMPT_SYMBOL}"
MENU_STYLE="${MENU_STYLE}"
DATE_FORMAT="${DATE_FORMAT}"

# Custom Logo
USE_CUSTOM_LOGO="${USE_CUSTOM_LOGO}"
CUSTOM_LOGO_LINE1="${CUSTOM_LOGO_LINE1}"
CUSTOM_LOGO_LINE2="${CUSTOM_LOGO_LINE2}"
CUSTOM_LOGO_LINE3="${CUSTOM_LOGO_LINE3}"
CUSTOM_LOGO_LINE4="${CUSTOM_LOGO_LINE4}"
CUSTOM_LOGO_LINE5="${CUSTOM_LOGO_LINE5}"
CUSTOM_LOGO_LINE6="${CUSTOM_LOGO_LINE6}"
EOF
    
    echo -e "${GREEN}✓ Configuration saved to $CONFIG_FILE${NC}"
}

# Get border characters based on style
get_border_chars() {
    case $BORDER_STYLE in
        "single")
            B_TL="┌" B_TR="┐" B_BL="└" B_BR="┘" B_H="─" B_V="│"
            ;;
        "double")
            B_TL="╔" B_TR="╗" B_BL="╚" B_BR="╝" B_H="═" B_V="║"
            ;;
        "rounded")
            B_TL="╭" B_TR="╮" B_BL="╰" B_BR="╯" B_H="─" B_V="│"
            ;;
        "heavy")
            B_TL="┏" B_TR="┓" B_BL="┗" B_BR="┛" B_H="━" B_V="┃"
            ;;
        "ascii")
            B_TL="+" B_TR="+" B_BL="+" B_BR="+" B_H="-" B_V="|"
            ;;
        "dots")
            B_TL="." B_TR="." B_BL="'" B_BR="'" B_H="." B_V=":"
            ;;
        "stars")
            B_TL="*" B_TR="*" B_BL="*" B_BR="*" B_H="*" B_V="*"
            ;;
        "blocks")
            B_TL="█" B_TR="█" B_BL="█" B_BR="█" B_H="▀" B_V="█"
            ;;
        *)
            B_TL="╔" B_TR="╗" B_BL="╚" B_BR="╝" B_H="═" B_V="║"
            ;;
    esac
}

# Animation effect
animate_text() {
    local text="$1"
    if [ "$ENABLE_ANIMATIONS" = "true" ]; then
        for (( i=0; i<${#text}; i++ )); do
            echo -n "${text:$i:1}"
            sleep 0.01
        done
        echo
    else
        echo "$text"
    fi
}

# Display TuxTech ASCII logo with customization
display_logo() {
    load_visual_config
    get_border_chars
    
    # Create border line
    local border_line=""
    for i in {1..78}; do
        border_line="${border_line}${B_H}"
    done
    
    # Apply effects if enabled
    if [ "$ENABLE_EFFECTS" = "true" ]; then
        echo -e "${BLINK}"
    fi
    
    echo -e "${BORDER_COLOR}${BOLD}"
    echo "${B_TL}${border_line}${B_TR}"
    echo "${B_V}                                                                              ${B_V}"
    
    # Display logo (custom or default)
    echo -e "${LOGO_COLOR}"
    if [ "$USE_CUSTOM_LOGO" = "true" ] && [ ! -z "$CUSTOM_LOGO_LINE1" ]; then
        # Display custom logo
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ${CUSTOM_LOGO_LINE1}  ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ${CUSTOM_LOGO_LINE2}  ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ${CUSTOM_LOGO_LINE3}  ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ${CUSTOM_LOGO_LINE4}  ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ${CUSTOM_LOGO_LINE5}  ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ${CUSTOM_LOGO_LINE6}  ${BORDER_COLOR}${B_V}"
    else
        # Display default TuxTech logo
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗ ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}  ╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║ ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}     ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║ ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}     ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║ ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}     ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝ ${BORDER_COLOR}${B_V}"
        echo -e "${BORDER_COLOR}${B_V}${LOGO_COLOR}     ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝  ${BORDER_COLOR}${B_V}"
    fi
    
    echo -e "${BORDER_COLOR}"
    echo "${B_V}                                                                              ${B_V}"
    
    # Center and display bottom text
    local text_length=${#BOTTOM_TEXT}
    local padding=$(( (76 - text_length) / 2 ))
    local padded_text=""
    for i in $(seq 1 $padding); do
        padded_text="${padded_text} "
    done
    padded_text="${padded_text}${BOTTOM_TEXT}"
    
    echo -e "${B_V}  ${HEADER_COLOR}${padded_text}  ${BORDER_COLOR}${B_V}"
    echo "${B_BL}${border_line}${B_BR}"
    echo -e "${NC}"
}

# Visual customization menu
visual_customization() {
    while true; do
        clear
        echo -e "${PURPLE}${BOLD}[VISUAL CUSTOMIZATION CENTER]${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
        
        # Show current theme
        echo -e "${YELLOW}Current Theme: ${CYAN}${CURRENT_THEME}${NC}"
        echo -e "${YELLOW}Preview:${NC}"
        display_logo
        
        echo -e "${BOLD}Customization Options:${NC}"
        echo -e "  ${CYAN}1)${NC}  🎨 Change Logo Color"
        echo -e "  ${CYAN}2)${NC}  📦 Change Border Style"
        echo -e "  ${CYAN}3)${NC}  🌈 Change Border Color"
        echo -e "  ${CYAN}4)${NC}  ✏️  Edit Bottom Text"
        echo -e "  ${CYAN}5)${NC}  🎭 Load Preset Theme"
        echo -e "  ${CYAN}6)${NC}  🖼️  Custom ASCII Logo"
        echo -e "  ${CYAN}7)${NC}  ⚡ Toggle Animations (Currently: ${ENABLE_ANIMATIONS})"
        echo -e "  ${CYAN}8)${NC}  ✨ Toggle Effects (Currently: ${ENABLE_EFFECTS})"
        echo -e "  ${CYAN}9)${NC}  🎵 Toggle Sound Effects (Currently: ${ENABLE_SOUND})"
        echo -e "  ${CYAN}10)${NC} 🔧 Advanced Settings"
        echo -e "  ${CYAN}11)${NC} 💾 Export Configuration"
        echo -e "  ${CYAN}12)${NC} 📂 Import Configuration"
        echo -e "  ${CYAN}13)${NC} 🔄 Reset to Defaults"
        echo -e "  ${CYAN}14)${NC} 👁️  Preview Changes"
        echo -e "  ${CYAN}0)${NC}  💾 Save and Return\n"
        
        read -p "Select option ${PROMPT_SYMBOL} " choice
        
        case $choice in
            1) change_logo_color ;;
            2) change_border_style ;;
            3) change_border_color ;;
            4) edit_bottom_text ;;
            5) load_preset_themes ;;
            6) custom_ascii_logo ;;
            7) toggle_animations ;;
            8) toggle_effects ;;
            9) toggle_sound ;;
            10) advanced_settings ;;
            11) export_configuration ;;
            12) import_configuration ;;
            13) reset_to_defaults ;;
            14) preview_changes ;;
            0)
                save_visual_config
                echo -e "${GREEN}Configuration saved!${NC}"
                sleep 1
                return
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Change logo color
change_logo_color() {
    clear
    echo -e "${PURPLE}${BOLD}[CHANGE LOGO COLOR]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Select Logo Color:${NC}\n"
    
    local colors=(
        "1:Cyan:${CYAN}"
        "2:Green:${GREEN}"
        "3:Blue:${BLUE}"
        "4:Yellow:${YELLOW}"
        "5:Purple:${PURPLE}"
        "6:Red:${RED}"
        "7:White:${WHITE}"
        "8:Pink:${PINK}"
        "9:Light Blue:${LIGHT_BLUE}"
        "10:Light Green:${LIGHT_GREEN}"
        "11:Orange:${ORANGE}"
        "12:Gray:${GRAY}"
        "13:Magenta:${MAGENTA}"
        "14:Light Cyan:${LIGHT_CYAN}"
        "15:Dark Gray:${DARK_GRAY}"
    )
    
    for color_info in "${colors[@]}"; do
        IFS=':' read -r num name code <<< "$color_info"
        echo -e "  ${CYAN}${num})${NC} ${code}████████${NC} ${name}"
    done
    
    echo
    read -p "Select color (1-15) ${PROMPT_SYMBOL} " color_choice
    
    case $color_choice in
        1) LOGO_COLOR="${CYAN}" ;;
        2) LOGO_COLOR="${GREEN}" ;;
        3) LOGO_COLOR="${BLUE}" ;;
        4) LOGO_COLOR="${YELLOW}" ;;
        5) LOGO_COLOR="${PURPLE}" ;;
        6) LOGO_COLOR="${RED}" ;;
        7) LOGO_COLOR="${WHITE}" ;;
        8) LOGO_COLOR="${PINK}" ;;
        9) LOGO_COLOR="${LIGHT_BLUE}" ;;
        10) LOGO_COLOR="${LIGHT_GREEN}" ;;
        11) LOGO_COLOR="${ORANGE}" ;;
        12) LOGO_COLOR="${GRAY}" ;;
        13) LOGO_COLOR="${MAGENTA}" ;;
        14) LOGO_COLOR="${LIGHT_CYAN}" ;;
        15) LOGO_COLOR="${DARK_GRAY}" ;;
        *) 
            echo -e "${RED}Invalid choice${NC}"
            sleep 1
            return
            ;;
    esac
    
    echo -e "\n${GREEN}✓ Logo color updated${NC}"
    sleep 1
}

# Change border style
change_border_style() {
    clear
    echo -e "${PURPLE}${BOLD}[CHANGE BORDER STYLE]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Available Border Styles:${NC}\n"
    
    echo -e "${CYAN}1) Single Line:${NC}"
    echo "   ┌────────────┐"
    echo "   │   Sample   │"
    echo "   └────────────┘"
    
    echo -e "\n${CYAN}2) Double Line:${NC}"
    echo "   ╔════════════╗"
    echo "   ║   Sample   ║"
    echo "   ╚════════════╝"
    
    echo -e "\n${CYAN}3) Rounded:${NC}"
    echo "   ╭────────────╮"
    echo "   │   Sample   │"
    echo "   ╰────────────╯"
    
    echo -e "\n${CYAN}4) Heavy:${NC}"
    echo "   ┏━━━━━━━━━━━━┓"
    echo "   ┃   Sample   ┃"
    echo "   ┗━━━━━━━━━━━━┛"
    
    echo -e "\n${CYAN}5) ASCII:${NC}"
    echo "   +------------+"
    echo "   |   Sample   |"
    echo "   +------------+"
    
    echo -e "\n${CYAN}6) Dots:${NC}"
    echo "   .............."
    echo "   :   Sample   :"
    echo "   ''''''''''''''"
    
    echo -e "\n${CYAN}7) Stars:${NC}"
    echo "   **************"
    echo "   *   Sample   *"
    echo "   **************"
    
    echo -e "\n${CYAN}8) Blocks:${NC}"
    echo "   ██████████████"
    echo "   █   Sample   █"
    echo "   ██████████████"
    
    echo
    read -p "Select border style (1-8) ${PROMPT_SYMBOL} " border_choice
    
    case $border_choice in
        1) BORDER_STYLE="single" ;;
        2) BORDER_STYLE="double" ;;
        3) BORDER_STYLE="rounded" ;;
        4) BORDER_STYLE="heavy" ;;
        5) BORDER_STYLE="ascii" ;;
        6) BORDER_STYLE="dots" ;;
        7) BORDER_STYLE="stars" ;;
        8) BORDER_STYLE="blocks" ;;
        *) 
            echo -e "${RED}Invalid choice${NC}"
            sleep 1
            return
            ;;
    esac
    
    echo -e "\n${GREEN}✓ Border style updated to: $BORDER_STYLE${NC}"
    sleep 1
}

# Change border color
change_border_color() {
    clear
    echo -e "${PURPLE}${BOLD}[CHANGE BORDER COLOR]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Select Border Color:${NC}\n"
    
    local colors=(
        "1:Cyan:${CYAN}"
        "2:Green:${GREEN}"
        "3:Blue:${BLUE}"
        "4:Yellow:${YELLOW}"
        "5:Purple:${PURPLE}"
        "6:Red:${RED}"
        "7:White:${WHITE}"
        "8:Pink:${PINK}"
        "9:Light Blue:${LIGHT_BLUE}"
        "10:Orange:${ORANGE}"
    )
    
    for color_info in "${colors[@]}"; do
        IFS=':' read -r num name code <<< "$color_info"
        echo -e "  ${CYAN}${num})${NC} ${code}════════${NC} ${name}"
    done
    
    echo
    read -p "Select color (1-10) ${PROMPT_SYMBOL} " color_choice
    
    case $color_choice in
        1) BORDER_COLOR="${CYAN}" ;;
        2) BORDER_COLOR="${GREEN}" ;;
        3) BORDER_COLOR="${BLUE}" ;;
        4) BORDER_COLOR="${YELLOW}" ;;
        5) BORDER_COLOR="${PURPLE}" ;;
        6) BORDER_COLOR="${RED}" ;;
        7) BORDER_COLOR="${WHITE}" ;;
        8) BORDER_COLOR="${PINK}" ;;
        9) BORDER_COLOR="${LIGHT_BLUE}" ;;
        10) BORDER_COLOR="${ORANGE}" ;;
        *) 
            echo -e "${RED}Invalid choice${NC}"
            sleep 1
            return
            ;;
    esac
    
    echo -e "\n${GREEN}✓ Border color updated${NC}"
    sleep 1
}

# Edit bottom text
edit_bottom_text() {
    clear
    echo -e "${PURPLE}${BOLD}[EDIT BOTTOM TEXT]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Current bottom text:${NC}"
    echo -e "${WHITE}$BOTTOM_TEXT${NC}\n"
    
    echo -e "${CYAN}Enter new bottom text (max 74 characters):${NC}"
    read -p "${PROMPT_SYMBOL} " new_text
    
    if [ ${#new_text} -le 74 ]; then
        BOTTOM_TEXT="$new_text"
        echo -e "\n${GREEN}✓ Bottom text updated${NC}"
    else
        echo -e "\n${RED}Text too long! Maximum 74 characters.${NC}"
    fi
    
    sleep 1
}

# Load preset themes
load_preset_themes() {
    clear
    echo -e "${PURPLE}${BOLD}[PRESET THEMES]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Available Themes:${NC}\n"
    
    local themes=(
        "1:Classic Cyan:Default professional theme"
        "2:Matrix Green:Hacker style with green text"
        "3:Red Alert:Critical system monitoring"
        "4:Royal Purple:Elegant enterprise theme"
        "5:Ocean Blue:Calm water-inspired theme"
        "6:Solar Yellow:Bright energetic theme"
        "7:Midnight Dark:Dark mode with gray borders"
        "8:Neon Pink:Cyberpunk 2077 style"
        "9:Terminal Green:Classic terminal look"
        "10:Fire Orange:Warm sunset theme"
        "11:Arctic White:Clean minimalist theme"
        "12:Rainbow:Multi-colored theme"
    )
    
    for theme_info in "${themes[@]}"; do
        IFS=':' read -r num name desc <<< "$theme_info"
        echo -e "  ${CYAN}${num})${NC} ${BOLD}${name}${NC} - ${desc}"
    done
    
    echo
    read -p "Select theme (1-12) ${PROMPT_SYMBOL} " theme_choice
    
    case $theme_choice in
        1) # Classic Cyan
            LOGO_COLOR="${CYAN}"
            BORDER_COLOR="${CYAN}"
            BORDER_STYLE="double"
            HEADER_COLOR="${WHITE}"
            BOTTOM_TEXT="INTEGRATED CLOUD COMPUTING PLATFORM - ENHANCED V6"
            CURRENT_THEME="Classic Cyan"
            ;;
        2) # Matrix Green
            LOGO_COLOR="${GREEN}"
            BORDER_COLOR="${GREEN}"
            BORDER_STYLE="single"
            HEADER_COLOR="${GREEN}"
            BOTTOM_TEXT="[ SYSTEM MONITORING MATRIX - ONLINE ]"
            CURRENT_THEME="Matrix Green"
            ENABLE_EFFECTS="true"
            ;;
        3) # Red Alert
            LOGO_COLOR="${RED}"
            BORDER_COLOR="${RED}"
            BORDER_STYLE="heavy"
            HEADER_COLOR="${YELLOW}"
            BOTTOM_TEXT="⚠ CRITICAL SYSTEM MONITOR - ACTIVE ⚠"
            CURRENT_THEME="Red Alert"
            ;;
        4) # Royal Purple
            LOGO_COLOR="${PURPLE}"
            BORDER_COLOR="${PURPLE}"
            BORDER_STYLE="double"
            HEADER_COLOR="${WHITE}"
            BOTTOM_TEXT="♛ ENTERPRISE MONITORING SUITE ♛"
            CURRENT_THEME="Royal Purple"
            ;;
        5) # Ocean Blue
            LOGO_COLOR="${BLUE}"
            BORDER_COLOR="${LIGHT_BLUE}"
            BORDER_STYLE="rounded"
            HEADER_COLOR="${CYAN}"
            BOTTOM_TEXT="～ DEEP SEA MONITORING SYSTEM ～"
            CURRENT_THEME="Ocean Blue"
            ;;
        6) # Solar Yellow
            LOGO_COLOR="${YELLOW}"
            BORDER_COLOR="${ORANGE}"
            BORDER_STYLE="single"
            HEADER_COLOR="${YELLOW}"
            BOTTOM_TEXT="☀ SOLAR POWERED MONITORING ☀"
            CURRENT_THEME="Solar Yellow"
            ;;
        7) # Midnight Dark
            LOGO_COLOR="${DARK_GRAY}"
            BORDER_COLOR="${GRAY}"
            BORDER_STYLE="single"
            HEADER_COLOR="${WHITE}"
            BOTTOM_TEXT="STEALTH MODE MONITORING"
            CURRENT_THEME="Midnight Dark"
            ;;
        8) # Neon Pink
            LOGO_COLOR="${PINK}"
            BORDER_COLOR="${MAGENTA}"
            BORDER_STYLE="double"
            HEADER_COLOR="${CYAN}"
            BOTTOM_TEXT="▼ CYBERPUNK MONITOR 2077 ▼"
            CURRENT_THEME="Neon Pink"
            ENABLE_EFFECTS="true"
            ;;
        9) # Terminal Green
            LOGO_COLOR="${LIGHT_GREEN}"
            BORDER_COLOR="${GREEN}"
            BORDER_STYLE="ascii"
            HEADER_COLOR="${GREEN}"
            BOTTOM_TEXT="> TERMINAL MONITORING SYSTEM <"
            CURRENT_THEME="Terminal Green"
            ;;
        10) # Fire Orange
            LOGO_COLOR="${ORANGE}"
            BORDER_COLOR="${RED}"
            BORDER_STYLE="rounded"
            HEADER_COLOR="${YELLOW}"
            BOTTOM_TEXT="◉ SUNSET MONITORING DASHBOARD ◉"
            CURRENT_THEME="Fire Orange"
            ;;
        11) # Arctic White
            LOGO_COLOR="${WHITE}"
            BORDER_COLOR="${LIGHT_CYAN}"
            BORDER_STYLE="single"
            HEADER_COLOR="${WHITE}"
            BOTTOM_TEXT="MINIMALIST MONITORING INTERFACE"
            CURRENT_THEME="Arctic White"
            ;;
        12) # Rainbow
            LOGO_COLOR="${CYAN}"
            BORDER_COLOR="${PURPLE}"
            BORDER_STYLE="stars"
            HEADER_COLOR="${YELLOW}"
            BOTTOM_TEXT="🌈 RAINBOW MONITORING SYSTEM 🌈"
            CURRENT_THEME="Rainbow"
            ENABLE_EFFECTS="true"
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            sleep 1
            return
            ;;
    esac
    
    echo -e "\n${GREEN}✓ Theme '${CURRENT_THEME}' applied successfully${NC}"
    sleep 2
}

# Custom ASCII logo
custom_ascii_logo() {
    clear
    echo -e "${PURPLE}${BOLD}[CUSTOM ASCII LOGO]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Custom Logo Options:${NC}"
    echo -e "  ${CYAN}1)${NC} Enter custom ASCII art (6 lines)"
    echo -e "  ${CYAN}2)${NC} Generate from text (requires figlet)"
    echo -e "  ${CYAN}3)${NC} Load from file"
    echo -e "  ${CYAN}4)${NC} Use simple text banner"
    echo -e "  ${CYAN}5)${NC} Reset to default TuxTech logo"
    echo -e "  ${CYAN}0)${NC} Cancel\n"
    
    read -p "Select option ${PROMPT_SYMBOL} " logo_choice
    
    case $logo_choice in
        1)
            echo -e "\n${YELLOW}Enter your ASCII art (6 lines):${NC}"
            read -p "Line 1: " CUSTOM_LOGO_LINE1
            read -p "Line 2: " CUSTOM_LOGO_LINE2
            read -p "Line 3: " CUSTOM_LOGO_LINE3
            read -p "Line 4: " CUSTOM_LOGO_LINE4
            read -p "Line 5: " CUSTOM_LOGO_LINE5
            read -p "Line 6: " CUSTOM_LOGO_LINE6
            USE_CUSTOM_LOGO="true"
            echo -e "\n${GREEN}✓ Custom logo saved${NC}"
            ;;
        2)
            if command -v figlet &> /dev/null; then
                echo -e "\n${YELLOW}Enter text to convert:${NC}"
                read -p "${PROMPT_SYMBOL} " text_input
                
                # Generate ASCII art
                ascii_art=$(figlet -w 74 "$text_input" 2>/dev/null | head -6)
                CUSTOM_LOGO_LINE1=$(echo "$ascii_art" | sed -n '1p')
                CUSTOM_LOGO_LINE2=$(echo "$ascii_art" | sed -n '2p')
                CUSTOM_LOGO_LINE3=$(echo "$ascii_art" | sed -n '3p')
                CUSTOM_LOGO_LINE4=$(echo "$ascii_art" | sed -n '4p')
                CUSTOM_LOGO_LINE5=$(echo "$ascii_art" | sed -n '5p')
                CUSTOM_LOGO_LINE6=$(echo "$ascii_art" | sed -n '6p')
                USE_CUSTOM_LOGO="true"
                echo -e "\n${GREEN}✓ ASCII art generated${NC}"
            else
                echo -e "${YELLOW}Figlet not installed. Install with:${NC}"
                echo -e "${WHITE}sudo apt-get install figlet${NC}"
            fi
            ;;
        3)
            echo -e "\n${YELLOW}Enter path to ASCII art file:${NC}"
            read -p "${PROMPT_SYMBOL} " file_path
            if [ -f "$file_path" ]; then
                CUSTOM_LOGO_LINE1=$(sed -n '1p' "$file_path")
                CUSTOM_LOGO_LINE2=$(sed -n '2p' "$file_path")
                CUSTOM_LOGO_LINE3=$(sed -n '3p' "$file_path")
                CUSTOM_LOGO_LINE4=$(sed -n '4p' "$file_path")
                CUSTOM_LOGO_LINE5=$(sed -n '5p' "$file_path")
                CUSTOM_LOGO_LINE6=$(sed -n '6p' "$file_path")
                USE_CUSTOM_LOGO="true"
                echo -e "\n${GREEN}✓ Logo loaded from file${NC}"
            else
                echo -e "${RED}File not found${NC}"
            fi
            ;;
        4)
            echo -e "\n${YELLOW}Enter your company/project name:${NC}"
            read -p "${PROMPT_SYMBOL} " company_name
            
            # Create simple text banner
            CUSTOM_LOGO_LINE1="╔════════════════════════════════════════════════════════════════════╗"
            CUSTOM_LOGO_LINE2="║                                                                    ║"
            CUSTOM_LOGO_LINE3="║                     $company_name                                 ║"
            CUSTOM_LOGO_LINE4="║                     SERVER MONITOR                                ║"
            CUSTOM_LOGO_LINE5="║                                                                    ║"
            CUSTOM_LOGO_LINE6="╚════════════════════════════════════════════════════════════════════╝"
            USE_CUSTOM_LOGO="true"
            echo -e "\n${GREEN}✓ Simple banner created${NC}"
            ;;
        5)
            USE_CUSTOM_LOGO="false"
            echo -e "\n${GREEN}✓ Reset to default TuxTech logo${NC}"
            ;;
        0)
            return
            ;;
    esac
    
    sleep 2
}

# Toggle animations
toggle_animations() {
    if [ "$ENABLE_ANIMATIONS" = "true" ]; then
        ENABLE_ANIMATIONS="false"
        echo -e "${YELLOW}Animations disabled${NC}"
    else
        ENABLE_ANIMATIONS="true"
        echo -e "${GREEN}Animations enabled${NC}"
    fi
    sleep 1
}

# Toggle effects
toggle_effects() {
    if [ "$ENABLE_EFFECTS" = "true" ]; then
        ENABLE_EFFECTS="false"
        echo -e "${YELLOW}Effects disabled${NC}"
    else
        ENABLE_EFFECTS="true"
        echo -e "${GREEN}Effects enabled${NC}"
    fi
    sleep 1
}

# Toggle sound
toggle_sound() {
    if [ "$ENABLE_SOUND" = "true" ]; then
        ENABLE_SOUND="false"
        echo -e "${YELLOW}Sound effects disabled${NC}"
    else
        ENABLE_SOUND="true"
        echo -e "${GREEN}Sound effects enabled${NC}"
        # Play a test beep if enabled
        if command -v beep &> /dev/null; then
            beep 2>/dev/null
        else
            echo -e "\a"  # System beep
        fi
    fi
    sleep 1
}

# Advanced settings
advanced_settings() {
    clear
    echo -e "${PURPLE}${BOLD}[ADVANCED SETTINGS]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Advanced Options:${NC}"
    echo -e "  ${CYAN}1)${NC} Change prompt symbol (Current: $PROMPT_SYMBOL)"
    echo -e "  ${CYAN}2)${NC} Change date format (Current: $DATE_FORMAT)"
    echo -e "  ${CYAN}3)${NC} Change menu style (Current: $MENU_STYLE)"
    echo -e "  ${CYAN}4)${NC} Change header color"
    echo -e "  ${CYAN}5)${NC} Change text color"
    echo -e "  ${CYAN}6)${NC} Change highlight color"
    echo -e "  ${CYAN}7)${NC} Set refresh rate"
    echo -e "  ${CYAN}8)${NC} Configure startup options"
    echo -e "  ${CYAN}0)${NC} Back\n"
    
    read -p "Select option ${PROMPT_SYMBOL} " adv_choice
    
    case $adv_choice in
        1)
            echo -e "\n${YELLOW}Enter new prompt symbol:${NC}"
            read -p "Symbol: " new_symbol
            PROMPT_SYMBOL="$new_symbol"
            echo -e "${GREEN}✓ Prompt symbol updated${NC}"
            ;;
        2)
            echo -e "\n${YELLOW}Select date format:${NC}"
            echo -e "  1) %Y-%m-%d %H:%M:%S (2024-01-15 14:30:45)"
            echo -e "  2) %d/%m/%Y %H:%M (15/01/2024 14:30)"
            echo -e "  3) %b %d, %Y %I:%M %p (Jan 15, 2024 02:30 PM)"
            echo -e "  4) %A, %B %d, %Y (Monday, January 15, 2024)"
            read -p "Choice: " date_choice
            case $date_choice in
                1) DATE_FORMAT="%Y-%m-%d %H:%M:%S" ;;
                2) DATE_FORMAT="%d/%m/%Y %H:%M" ;;
                3) DATE_FORMAT="%b %d, %Y %I:%M %p" ;;
                4) DATE_FORMAT="%A, %B %d, %Y" ;;
            esac
            echo -e "${GREEN}✓ Date format updated${NC}"
            ;;
        3)
            echo -e "\n${YELLOW}Select menu style:${NC}"
            echo -e "  1) Numbers (1, 2, 3...)"
            echo -e "  2) Letters (a, b, c...)"
            echo -e "  3) Arrows (→)"
            echo -e "  4) Bullets (•)"
            read -p "Choice: " menu_choice
            case $menu_choice in
                1) MENU_STYLE="numbers" ;;
                2) MENU_STYLE="letters" ;;
                3) MENU_STYLE="arrows" ;;
                4) MENU_STYLE="bullets" ;;
            esac
            echo -e "${GREEN}✓ Menu style updated${NC}"
            ;;
        4)
            echo -e "\n${YELLOW}Select header color:${NC}"
            echo -e "  1) White  2) Cyan  3) Yellow  4) Green"
            read -p "Choice: " hcolor
            case $hcolor in
                1) HEADER_COLOR="${WHITE}" ;;
                2) HEADER_COLOR="${CYAN}" ;;
                3) HEADER_COLOR="${YELLOW}" ;;
                4) HEADER_COLOR="${GREEN}" ;;
            esac
            echo -e "${GREEN}✓ Header color updated${NC}"
            ;;
        5)
            echo -e "\n${YELLOW}Select text color:${NC}"
            echo -e "  1) White  2) Gray  3) Cyan  4) Green"
            read -p "Choice: " tcolor
            case $tcolor in
                1) TEXT_COLOR="${WHITE}" ;;
                2) TEXT_COLOR="${GRAY}" ;;
                3) TEXT_COLOR="${CYAN}" ;;
                4) TEXT_COLOR="${GREEN}" ;;
            esac
            echo -e "${GREEN}✓ Text color updated${NC}"
            ;;
        6)
            echo -e "\n${YELLOW}Select highlight color:${NC}"
            echo -e "  1) Yellow  2) Cyan  3) Green  4) Purple"
            read -p "Choice: " hlcolor
            case $hlcolor in
                1) HIGHLIGHT_COLOR="${YELLOW}" ;;
                2) HIGHLIGHT_COLOR="${CYAN}" ;;
                3) HIGHLIGHT_COLOR="${GREEN}" ;;
                4) HIGHLIGHT_COLOR="${PURPLE}" ;;
            esac
            echo -e "${GREEN}✓ Highlight color updated${NC}"
            ;;
    esac
    
    sleep 1
}

# Export configuration
export_configuration() {
    clear
    echo -e "${PURPLE}${BOLD}[EXPORT CONFIGURATION]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    local export_file="$HOME/tuxtech_config_$(date +%Y%m%d_%H%M%S).conf"
    
    save_visual_config
    cp "$CONFIG_FILE" "$export_file" 2>/dev/null && {
        echo -e "${GREEN}✓ Configuration exported to:${NC}"
        echo -e "${WHITE}$export_file${NC}\n"
        echo -e "${CYAN}You can share this file with others!${NC}"
    } || {
        echo -e "${RED}Export failed${NC}"
    }
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Import configuration
import_configuration() {
    clear
    echo -e "${PURPLE}${BOLD}[IMPORT CONFIGURATION]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Enter path to configuration file:${NC}"
    read -p "${PROMPT_SYMBOL} " import_file
    
    if [ -f "$import_file" ]; then
        cp "$import_file" "$CONFIG_FILE"
        load_visual_config
        echo -e "\n${GREEN}✓ Configuration imported successfully${NC}"
    else
        echo -e "\n${RED}File not found: $import_file${NC}"
    fi
    
    sleep 2
}

# Reset to defaults
reset_to_defaults() {
    echo -e "\n${YELLOW}Are you sure you want to reset to defaults? (y/n)${NC}"
    read -p "${PROMPT_SYMBOL} " confirm
    
    if [[ $confirm == "y" ]] || [[ $confirm == "Y" ]]; then
        init_config
        save_visual_config
        echo -e "${GREEN}✓ Reset to defaults complete${NC}"
    else
        echo -e "${YELLOW}Cancelled${NC}"
    fi
    sleep 1
}

# Preview changes
preview_changes() {
    clear
    echo -e "${PURPLE}${BOLD}[PREVIEW MODE]${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    display_logo
    
    echo -e "\n${YELLOW}Current Settings:${NC}"
    echo -e "  Theme: ${CYAN}${CURRENT_THEME}${NC}"
    echo -e "  Logo Color: ${LOGO_COLOR}████${NC}"
    echo -e "  Border Style: ${CYAN}${BORDER_STYLE}${NC}"
    echo -e "  Border Color: ${BORDER_COLOR}════${NC}"
    echo -e "  Animations: ${CYAN}${ENABLE_ANIMATIONS}${NC}"
    echo -e "  Effects: ${CYAN}${ENABLE_EFFECTS}${NC}"
    
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read
}

# Main monitoring functions (abbreviated for space)
monitor_docker() {
    echo -e "${PURPLE}${BOLD}[DOCKER CONTAINER MONITOR]${NC}"
    # ... (rest of docker monitoring code)
}

main_menu() {
    while true; do
        clear
        display_logo
        
        echo -e "${BOLD}${HEADER_COLOR}TuxTech Server Monitor V6 - Main Menu${NC}"
        echo -e "${BORDER_COLOR}════════════════════════════════════════════════════════════${NC}\n"
        
        echo -e "  ${CYAN}1)${NC}  System Overview"
        echo -e "  ${CYAN}2)${NC}  Docker Container Monitor"
        echo -e "  ${CYAN}3)${NC}  Network Port Scanner"
        echo -e "  ${CYAN}4)${NC}  Enhanced SSH Monitor"
        echo -e "  ${CYAN}5)${NC}  System Resources"
        echo -e "  ${CYAN}6)${NC}  Service Monitor"
        echo -e "  ${CYAN}7)${NC}  Database Monitor"
        echo -e "  ${CYAN}8)${NC}  Web Services Monitor"
        echo -e "  ${CYAN}9)${NC}  Log File Analysis"
        echo -e "  ${CYAN}10)${NC} Firewall Status"
        echo -e "  ${CYAN}11)${NC} Security Check"
        echo -e "  ${CYAN}12)${NC} Real-Time Monitoring"
        echo -e "  ${CYAN}13)${NC} Full System Report"
        echo -e "  ${CYAN}14)${NC} ${PINK}🎨 Visual Customization${NC} ${YELLOW}(ENHANCED!)${NC}"
        echo -e "  ${CYAN}0)${NC}  Exit"
        
        echo -e "\n${BORDER_COLOR}════════════════════════════════════════════════════════════${NC}"
        read -p "Select option ${PROMPT_SYMBOL} " choice
        
        case $choice in
            14)
                visual_customization
                ;;
            0)
                if [ "$ENABLE_SOUND" = "true" ]; then
                    echo -e "\a"  # Beep on exit
                fi
                echo -e "${GREEN}Exiting TuxTech Monitor V6...${NC}"
                echo -e "${CYAN}Thank you for using TuxTech Monitor!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Feature not shown in demo - focusing on customization${NC}"
                sleep 2
                ;;
        esac
    done
}

# Initialize and start
init_config
load_visual_config
main_menu