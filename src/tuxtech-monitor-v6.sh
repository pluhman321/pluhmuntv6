#!/bin/bash

# TuxTech Monitor V6 - Complete Working Version
# All features included and functional

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Configuration
SCAN_COMMON_PORTS=(80 443 22 21 25 3306 5432 6379 8080 8443 9000 3000 5000 8000 27017 9200 11211 15672)
LOG_FILE="/var/log/tuxtech_monitor_v6.log"
CONFIG_DIR="/etc/tuxtech"
CONFIG_FILE="${CONFIG_DIR}/visual_config.conf"

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR" 2>/dev/null || true
fi

# Default configuration values
LOGO_COLOR="${CYAN}"
BORDER_STYLE="double"
BOTTOM_TEXT="INTEGRATED CLOUD COMPUTING PLATFORM - ENHANCED V6"
THEME_NAME="Default"

# Function to save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# TuxTech Monitor V6 Configuration
LOGO_COLOR="${LOGO_COLOR}"
BORDER_STYLE="${BORDER_STYLE}"
BOTTOM_TEXT="${BOTTOM_TEXT}"
THEME_NAME="${THEME_NAME}"
EOF
    echo -e "${GREEN}Configuration saved!${NC}"
}

# Function to load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE" 2>/dev/null || true
    fi
}

# Load configuration at startup
load_config

# Function to display TuxTech ASCII logo
display_logo() {
    # Determine border characters based on style
    case $BORDER_STYLE in
        "single")
            TL="┌" TR="┐" BL="└" BR="┘" H="─" V="│"
            ;;
        "double")
            TL="╔" TR="╗" BL="╚" BR="╝" H="═" V="║"
            ;;
        "rounded")
            TL="╭" TR="╮" BL="╰" BR="╯" H="─" V="│"
            ;;
        "heavy")
            TL="┏" TR="┓" BL="┗" BR="┛" H="━" V="┃"
            ;;
        "ascii")
            TL="+" TR="+" BL="+" BR="+" H="-" V="|"
            ;;
        *)
            TL="╔" TR="╗" BL="╚" BR="╝" H="═" V="║"
            ;;
    esac
    
    # Create horizontal line
    HLINE=""
    for i in {1..78}; do HLINE="${HLINE}${H}"; done
    
    echo -e "${LOGO_COLOR}${BOLD}"
    echo "${TL}${HLINE}${TR}"
    echo "${V}                                                                              ${V}"
    echo "${V}  ████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗ ${V}"
    echo "${V}  ╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║ ${V}"
    echo "${V}     ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║ ${V}"
    echo "${V}     ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║ ${V}"
    echo "${V}     ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝ ${V}"
    echo "${V}     ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝  ${V}"
    echo "${V}                                                                              ${V}"
    
    # Center the bottom text
    local text_len=${#BOTTOM_TEXT}
    local padding=$(( (76 - text_len) / 2 ))
    local padded=""
    for i in $(seq 1 $padding); do padded="${padded} "; done
    
    echo "${V}  ${padded}${BOTTOM_TEXT}  ${V}"
    echo "${BL}${HLINE}${BR}"
    echo -e "${NC}"
}

# Enhanced server information display
display_enhanced_server_info() {
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}Enhanced Server Information:${NC}"
    
    echo -e "${YELLOW}▸${NC} Hostname: ${CYAN}$(hostname -f 2>/dev/null || hostname)${NC}"
    echo -e "${YELLOW}▸${NC} Kernel: ${CYAN}$(uname -r)${NC}"
    echo -e "${YELLOW}▸${NC} OS: ${CYAN}$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || uname -s)${NC}"
    echo -e "${YELLOW}▸${NC} Primary IP: ${CYAN}$(hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A")${NC}"
    echo -e "${YELLOW}▸${NC} Uptime:${CYAN}$(uptime -p 2>/dev/null || uptime)${NC}"
    echo -e "${YELLOW}▸${NC} CPU Cores: ${CYAN}$(nproc 2>/dev/null || echo "N/A")${NC}"
    echo -e "${YELLOW}▸${NC} Memory: ${CYAN}$(free -h 2>/dev/null | awk 'NR==2{printf "%s/%s (%.0f%%)", $3, $2, $3*100/$2}' || echo "N/A")${NC}"
    echo -e "${YELLOW}▸${NC} Time: ${CYAN}$(date '+%Y-%m-%d %H:%M:%S %Z')${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
}

# Docker monitoring function
monitor_docker() {
    echo -e "${PURPLE}${BOLD}[DOCKER CONTAINER MONITOR]${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker is not installed on this system${NC}"
        return
    fi
    
    if ! docker ps &> /dev/null; then
        echo -e "${YELLOW}Docker daemon is not running or you need sudo privileges${NC}"
        return
    fi
    
    echo -e "${BLUE}Active Docker Containers:${NC}\n"
    
    # Get all running containers with detailed info
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | while IFS= read -r line; do
        if [[ $line == *"CONTAINER"* ]]; then
            echo -e "${UNDERLINE}${WHITE}$line${NC}"
        else
            echo -e "${GREEN}$line${NC}"
        fi
    done
    
    echo -e "\n${BLUE}Container Network Details:${NC}"
    docker ps -q 2>/dev/null | while read container_id; do
        if [ ! -z "$container_id" ]; then
            container_name=$(docker inspect --format='{{.Name}}' $container_id 2>/dev/null | sed 's/^\/*//')
            container_image=$(docker inspect --format='{{.Config.Image}}' $container_id 2>/dev/null)
            
            # Get all network interfaces
            networks=$(docker inspect $container_id --format='{{range $key, $value := .NetworkSettings.Networks}}{{$key}}:{{.IPAddress}} {{end}}' 2>/dev/null)
            
            # Get exposed ports
            ports=$(docker inspect $container_id --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}}->{{if $conf}}{{(index $conf 0).HostPort}}{{else}}closed{{end}} {{end}}' 2>/dev/null)
            
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║${NC} ${BOLD}Container:${NC} ${GREEN}$container_name${NC}"
            echo -e "${CYAN}║${NC} ${BOLD}Image:${NC} ${YELLOW}$container_image${NC}"
            echo -e "${CYAN}║${NC} ${BOLD}Networks:${NC} ${WHITE}$networks${NC}"
            echo -e "${CYAN}║${NC} ${BOLD}Port Mappings:${NC} ${ORANGE}${ports:-No ports exposed}${NC}"
            
            # Check for common services
            if [[ $container_name == *"jellyfin"* ]] || [[ $container_image == *"jellyfin"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Media Server (Jellyfin)${NC}"
                echo -e "${CYAN}║${NC} ${BOLD}Web UI:${NC} ${UNDERLINE}${BLUE}http://$(hostname -I | awk '{print $1}'):8096${NC}"
            elif [[ $container_name == *"plex"* ]] || [[ $container_image == *"plex"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Media Server (Plex)${NC}"
                echo -e "${CYAN}║${NC} ${BOLD}Web UI:${NC} ${UNDERLINE}${BLUE}http://$(hostname -I | awk '{print $1}'):32400/web${NC}"
            elif [[ $container_name == *"portainer"* ]] || [[ $container_image == *"portainer"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Container Management${NC}"
                echo -e "${CYAN}║${NC} ${BOLD}Web UI:${NC} ${UNDERLINE}${BLUE}http://$(hostname -I | awk '{print $1}'):9000${NC}"
            fi
            
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        fi
    done
    
    # Docker system info
    echo -e "\n${BLUE}Docker System Information:${NC}"
    echo -e "${YELLOW}▸${NC} Docker Version: ${CYAN}$(docker --version 2>/dev/null | cut -d' ' -f3 | sed 's/,$//')${NC}"
    echo -e "${YELLOW}▸${NC} Total Containers: ${CYAN}$(docker ps -a 2>/dev/null | tail -n +2 | wc -l)${NC}"
    echo -e "${YELLOW}▸${NC} Running: ${GREEN}$(docker ps -q 2>/dev/null | wc -l)${NC}"
    echo -e "${YELLOW}▸${NC} Images: ${CYAN}$(docker images 2>/dev/null | tail -n +2 | wc -l)${NC}"
}

# Advanced port scanning
scan_network_ports() {
    echo -e "${PURPLE}${BOLD}[NETWORK PORT SCANNER]${NC}"
    echo -e "${BLUE}Scanning for open ports...${NC}\n"
    
    echo -e "${YELLOW}Listening Services:${NC}"
    
    # Use ss if available, fallback to netstat
    if command -v ss &> /dev/null; then
        ss -tulpn 2>/dev/null | grep LISTEN | while read line; do
            port=$(echo $line | grep -oP ':\K[0-9]+' | head -1)
            if [ ! -z "$port" ]; then
                # Try to identify service
                case $port in
                    80) service_name="HTTP Web Server" ;;
                    443) service_name="HTTPS Web Server" ;;
                    22) service_name="SSH Server" ;;
                    3306) service_name="MySQL Database" ;;
                    5432) service_name="PostgreSQL Database" ;;
                    6379) service_name="Redis Cache" ;;
                    8080) service_name="HTTP Alternate" ;;
                    8096) service_name="Jellyfin Media Server" ;;
                    32400) service_name="Plex Media Server" ;;
                    9000) service_name="Portainer/PHP-FPM" ;;
                    *) service_name="Unknown Service" ;;
                esac
                
                echo -e "  ${GREEN}●${NC} Port ${CYAN}$port${NC}: ${WHITE}$service_name${NC}"
            fi
        done
    elif command -v netstat &> /dev/null; then
        netstat -tulpn 2>/dev/null | grep LISTEN | while read line; do
            echo -e "  ${GREEN}●${NC} $line"
        done
    else
        echo -e "  ${YELLOW}Install net-tools for port scanning${NC}"
    fi
}

# Enhanced SSH monitoring
monitor_ssh_enhanced() {
    echo -e "${PURPLE}${BOLD}[ENHANCED SSH MONITOR]${NC}"
    echo -e "${BLUE}SSH Connection Analysis...${NC}\n"
    
    # SSH Configuration
    echo -e "${YELLOW}SSH Configuration:${NC}"
    if [ -f /etc/ssh/sshd_config ]; then
        ssh_port=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "22")
        echo -e "  ${YELLOW}▸${NC} SSH Port: ${CYAN}$ssh_port${NC}"
    fi
    
    # Current SSH sessions
    echo -e "\n${YELLOW}Current SSH Sessions:${NC}"
    if command -v ss &> /dev/null; then
        ss -tn state established '( dport = :22 or sport = :22 )' 2>/dev/null | grep -v State | while read line; do
            remote_addr=$(echo $line | awk '{print $4}')
            echo -e "  ${GREEN}➤${NC} Connected from: ${CYAN}$remote_addr${NC}"
        done
    fi
    
    # Active users
    echo -e "\n${YELLOW}Active Users:${NC}"
    who 2>/dev/null | while read line; do
        user=$(echo $line | awk '{print $1}')
        tty=$(echo $line | awk '{print $2}')
        echo -e "  ${CYAN}◆${NC} User: ${GREEN}$user${NC} on ${YELLOW}$tty${NC}"
    done
}

# System resource monitoring
monitor_system_resources() {
    echo -e "${PURPLE}${BOLD}[SYSTEM RESOURCE MONITOR]${NC}"
    
    # CPU Information
    echo -e "\n${YELLOW}CPU Information:${NC}"
    echo -e "  ${CYAN}Cores:${NC} $(nproc 2>/dev/null || echo "N/A")"
    echo -e "  ${CYAN}Load Average:${NC} $(uptime | awk -F'load average:' '{print $2}')"
    
    # Memory Information
    echo -e "\n${YELLOW}Memory Information:${NC}"
    free -h 2>/dev/null | while IFS= read -r line; do
        if [[ $line == *"Mem:"* ]]; then
            total=$(echo $line | awk '{print $2}')
            used=$(echo $line | awk '{print $3}')
            free=$(echo $line | awk '{print $4}')
            echo -e "  ${CYAN}Total:${NC} $total"
            echo -e "  ${CYAN}Used:${NC} $used"
            echo -e "  ${CYAN}Free:${NC} $free"
        fi
    done
    
    # Disk Information
    echo -e "\n${YELLOW}Disk Usage:${NC}"
    df -h 2>/dev/null | grep -E '^/dev/' | head -5 | while read line; do
        filesystem=$(echo $line | awk '{print $1}')
        size=$(echo $line | awk '{print $2}')
        used=$(echo $line | awk '{print $3}')
        mount=$(echo $line | awk '{print $6}')
        echo -e "  ${CYAN}$mount${NC}: ${WHITE}$used/$size${NC}"
    done
}

# Service monitoring
monitor_services_enhanced() {
    echo -e "${PURPLE}${BOLD}[ENHANCED SERVICE MONITOR]${NC}"
    
    echo -e "\n${YELLOW}System Services Status:${NC}"
    
    services=("ssh" "nginx" "apache2" "mysql" "mariadb" "postgresql" "docker" "redis" "mongodb")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo -e "  ${GREEN}● RUNNING${NC} - ${WHITE}$service${NC}"
        elif systemctl list-units --all --type=service 2>/dev/null | grep -q "$service.service"; then
            echo -e "  ${RED}○ STOPPED${NC} - ${WHITE}$service${NC}"
        fi
    done
}

# Visual customization menu
visual_customization() {
    while true; do
        clear
        echo -e "${PURPLE}${BOLD}[VISUAL CUSTOMIZATION]${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
        
        echo -e "${YELLOW}Current Settings:${NC}"
        echo -e "  Theme: ${CYAN}${THEME_NAME}${NC}"
        echo -e "  Logo Color: ${LOGO_COLOR}████████${NC}"
        echo -e "  Border Style: ${CYAN}${BORDER_STYLE}${NC}"
        echo -e "  Bottom Text: ${WHITE}${BOTTOM_TEXT}${NC}\n"
        
        echo -e "${BOLD}Customization Options:${NC}"
        echo -e "  ${CYAN}1)${NC}  Change Logo Color"
        echo -e "  ${CYAN}2)${NC}  Change Border Style"
        echo -e "  ${CYAN}3)${NC}  Edit Bottom Text"
        echo -e "  ${CYAN}4)${NC}  Load Preset Theme"
        echo -e "  ${CYAN}5)${NC}  Preview Current Design"
        echo -e "  ${CYAN}6)${NC}  Reset to Defaults"
        echo -e "  ${CYAN}0)${NC}  Save and Return to Main Menu\n"
        
        read -p "Select option: " choice
        
        case $choice in
            1)
                clear
                echo -e "${PURPLE}${BOLD}[CHANGE LOGO COLOR]${NC}"
                echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
                
                echo -e "${YELLOW}Available Colors:${NC}"
                echo -e "  ${CYAN}1) Cyan ████${NC}"
                echo -e "  ${GREEN}2) Green ████${NC}"
                echo -e "  ${BLUE}3) Blue ████${NC}"
                echo -e "  ${YELLOW}4) Yellow ████${NC}"
                echo -e "  ${PURPLE}5) Purple ████${NC}"
                echo -e "  ${RED}6) Red ████${NC}"
                echo -e "  ${WHITE}7) White ████${NC}\n"
                
                read -p "Select color (1-7): " color_choice
                
                case $color_choice in
                    1) LOGO_COLOR="${CYAN}" ;;
                    2) LOGO_COLOR="${GREEN}" ;;
                    3) LOGO_COLOR="${BLUE}" ;;
                    4) LOGO_COLOR="${YELLOW}" ;;
                    5) LOGO_COLOR="${PURPLE}" ;;
                    6) LOGO_COLOR="${RED}" ;;
                    7) LOGO_COLOR="${WHITE}" ;;
                    *) echo -e "${RED}Invalid choice${NC}" ;;
                esac
                
                echo -e "\n${GREEN}✓ Logo color updated${NC}"
                sleep 2
                ;;
            2)
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
                
                echo
                read -p "Select border style (1-5): " border_choice
                
                case $border_choice in
                    1) BORDER_STYLE="single" ;;
                    2) BORDER_STYLE="double" ;;
                    3) BORDER_STYLE="rounded" ;;
                    4) BORDER_STYLE="heavy" ;;
                    5) BORDER_STYLE="ascii" ;;
                    *) echo -e "${RED}Invalid choice${NC}" ;;
                esac
                
                echo -e "\n${GREEN}✓ Border style updated${NC}"
                sleep 2
                ;;
            3)
                clear
                echo -e "${PURPLE}${BOLD}[EDIT BOTTOM TEXT]${NC}"
                echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
                
                echo -e "${YELLOW}Current text:${NC}"
                echo -e "${WHITE}$BOTTOM_TEXT${NC}\n"
                
                echo -e "${CYAN}Enter new bottom text (max 74 characters):${NC}"
                read -p "> " new_text
                
                if [ ${#new_text} -le 74 ] && [ ! -z "$new_text" ]; then
                    BOTTOM_TEXT="$new_text"
                    echo -e "\n${GREEN}✓ Bottom text updated${NC}"
                else
                    echo -e "\n${RED}Text too long or empty!${NC}"
                fi
                
                sleep 2
                ;;
            4)
                clear
                echo -e "${PURPLE}${BOLD}[PRESET THEMES]${NC}"
                echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
                
                echo -e "${YELLOW}Available Themes:${NC}"
                echo -e "  ${CYAN}1)${NC} Classic Cyan - Default professional"
                echo -e "  ${CYAN}2)${NC} Matrix Green - Hacker style"
                echo -e "  ${CYAN}3)${NC} Red Alert - Critical monitoring"
                echo -e "  ${CYAN}4)${NC} Royal Purple - Enterprise theme"
                echo -e "  ${CYAN}5)${NC} Ocean Blue - Calm theme"
                echo -e "  ${CYAN}6)${NC} Solar Yellow - Bright theme\n"
                
                read -p "Select theme (1-6): " theme_choice
                
                case $theme_choice in
                    1)
                        LOGO_COLOR="${CYAN}"
                        BORDER_STYLE="double"
                        BOTTOM_TEXT="INTEGRATED CLOUD COMPUTING PLATFORM - ENHANCED V6"
                        THEME_NAME="Classic Cyan"
                        ;;
                    2)
                        LOGO_COLOR="${GREEN}"
                        BORDER_STYLE="single"
                        BOTTOM_TEXT="[ SYSTEM MONITORING MATRIX - ONLINE ]"
                        THEME_NAME="Matrix Green"
                        ;;
                    3)
                        LOGO_COLOR="${RED}"
                        BORDER_STYLE="heavy"
                        BOTTOM_TEXT="⚠ CRITICAL SYSTEM MONITOR - ACTIVE ⚠"
                        THEME_NAME="Red Alert"
                        ;;
                    4)
                        LOGO_COLOR="${PURPLE}"
                        BORDER_STYLE="double"
                        BOTTOM_TEXT="♛ ENTERPRISE MONITORING SUITE ♛"
                        THEME_NAME="Royal Purple"
                        ;;
                    5)
                        LOGO_COLOR="${BLUE}"
                        BORDER_STYLE="rounded"
                        BOTTOM_TEXT="～ DEEP SEA MONITORING SYSTEM ～"
                        THEME_NAME="Ocean Blue"
                        ;;
                    6)
                        LOGO_COLOR="${YELLOW}"
                        BORDER_STYLE="single"
                        BOTTOM_TEXT="☀ SOLAR POWERED MONITORING ☀"
                        THEME_NAME="Solar Yellow"
                        ;;
                    *)
                        echo -e "${RED}Invalid choice${NC}"
                        ;;
                esac
                
                echo -e "\n${GREEN}✓ Theme applied: ${THEME_NAME}${NC}"
                sleep 2
                ;;
            5)
                clear
                display_logo
                echo -e "${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            6)
                LOGO_COLOR="${CYAN}"
                BORDER_STYLE="double"
                BOTTOM_TEXT="INTEGRATED CLOUD COMPUTING PLATFORM - ENHANCED V6"
                THEME_NAME="Default"
                echo -e "${GREEN}✓ Reset to defaults${NC}"
                sleep 2
                ;;
            0)
                save_config
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

# Real-time monitoring
realtime_monitor() {
    echo -e "${RED}${BOLD}[REAL-TIME MONITORING MODE]${NC}"
    echo -e "${YELLOW}Monitoring all services...${NC}"
    echo -e "${CYAN}Press Ctrl+C to stop${NC}\n"
    
    while true; do
        clear
        display_logo
        display_enhanced_server_info
        
        echo -e "${PURPLE}${BOLD}[LIVE DASHBOARD]${NC}"
        echo -e "${WHITE}$(date '+%Y-%m-%d %H:%M:%S')${NC}\n"
        
        # Quick stats
        echo -e "${YELLOW}System Status:${NC}"
        echo -e "  CPU Load: ${CYAN}$(uptime | awk -F'load average:' '{print $2}')${NC}"
        echo -e "  Memory: ${CYAN}$(free -h 2>/dev/null | awk 'NR==2{printf "%.1f/%.1fGB (%.0f%%)", $3, $2, $3*100/$2}')${NC}"
        echo -e "  Processes: ${CYAN}$(ps aux | wc -l)${NC}"
        
        echo -e "\n${YELLOW}Active Services:${NC}"
        for service in ssh nginx apache2 mysql docker redis; do
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                echo -e "  ${GREEN}●${NC} $service"
            fi
        done
        
        echo -e "\n${YELLOW}Network Connections:${NC}"
        echo -e "  SSH: ${CYAN}$(ss -tn state established 2>/dev/null | grep -c ':22' || echo "0")${NC}"
        
        if command -v docker &> /dev/null && docker ps &> /dev/null; then
            echo -e "\n${YELLOW}Docker Containers:${NC}"
            docker ps --format "  ${GREEN}●${NC} {{.Names}} ({{.Status}})" 2>/dev/null | head -5
        fi
        
        sleep 5
    done
}

# Main menu
main_menu() {
    while true; do
        clear
        display_logo
        display_enhanced_server_info
        
        echo -e "${BOLD}${WHITE}TuxTech Server Monitor V6 - Main Menu${NC}"
        echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
        
        echo -e "  ${CYAN}1)${NC}  System Overview"
        echo -e "  ${CYAN}2)${NC}  Docker Container Monitor"
        echo -e "  ${CYAN}3)${NC}  Network Port Scanner"
        echo -e "  ${CYAN}4)${NC}  Enhanced SSH Monitor"
        echo -e "  ${CYAN}5)${NC}  System Resources"
        echo -e "  ${CYAN}6)${NC}  Service Monitor"
        echo -e "  ${CYAN}7)${NC}  Real-Time Monitoring"
        echo -e "  ${CYAN}8)${NC}  Visual Customization"
        echo -e "  ${CYAN}0)${NC}  Exit"
        
        echo -e "\n${GREEN}════════════════════════════════════════════════════════════${NC}"
        read -p "Select option: " choice
        
        case $choice in
            1)
                clear
                display_logo
                display_enhanced_server_info
                monitor_services_enhanced
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            2)
                clear
                display_logo
                monitor_docker
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            3)
                clear
                display_logo
                scan_network_ports
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            4)
                clear
                display_logo
                monitor_ssh_enhanced
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            5)
                clear
                display_logo
                monitor_system_resources
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            6)
                clear
                display_logo
                monitor_services_enhanced
                echo -e "\n${CYAN}Press Enter to continue...${NC}"
                read
                ;;
            7)
                clear
                display_logo
                realtime_monitor
                ;;
            8)
                visual_customization
                ;;
            0)
                echo -e "${GREEN}Exiting TuxTech Monitor V6...${NC}"
                echo -e "${CYAN}Thank you for using TuxTech Monitor!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 2
                ;;
        esac
    done
}

# Script entry point
case "$1" in
    --realtime|-r)
        display_logo
        realtime_monitor
        ;;
    --docker|-d)
        display_logo
        monitor_docker
        ;;
    --services|-s)
        display_logo
        monitor_services_enhanced
        ;;
    --ports|-p)
        display_logo
        scan_network_ports
        ;;
    --customize|-c)
        visual_customization
        ;;
    --help|-h)
        display_logo
        echo "TuxTech Monitor V6 - Complete Version"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -r, --realtime    Start real-time monitoring"
        echo "  -d, --docker      Show Docker container details"
        echo "  -s, --services    Show all services status"
        echo "  -p, --ports       Scan network ports"
        echo "  -c, --customize   Visual customization menu"
        echo "  -h, --help        Show this help message"
        echo "  (no options)      Launch interactive menu"
        ;;
    *)
        main_menu
        ;;
esac