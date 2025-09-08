#!/bin/bash

# TuxTech Monitor V6 - Enhanced Installation Script
# Comprehensive installer with dependency checking and error handling

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Installation directories
INSTALL_DIR="/usr/local/bin"
PROFILE_DIR="/etc/profile.d"
LOG_DIR="/var/log"
CONFIG_DIR="/etc/tuxtech"

# Display banner
display_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
    
    ████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗
    ╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║
       ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║
       ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║
       ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝
       ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝
    
                ENHANCED MONITOR V6 - INSTALLATION SCRIPT
EOF
    echo -e "${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This script must be run as root (use sudo)${NC}"
        echo -e "${YELLOW}Example: sudo ./install.sh${NC}"
        exit 1
    fi
}

# Detect OS
detect_os() {
    echo -e "${BLUE}Detecting operating system...${NC}"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        ID_LIKE=$ID_LIKE
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    echo -e "${GREEN}✓ Detected: $OS $VER${NC}"
}

# Install dependencies based on OS
install_dependencies() {
    echo -e "${BLUE}Installing dependencies...${NC}"
    
    # Core dependencies
    DEPS_CORE="curl wget net-tools bc"
    
    # Optional but recommended
    DEPS_OPTIONAL="htop iotop sysstat fail2ban"
    
    # Detect package manager and install
    if command -v apt-get &> /dev/null; then
        echo -e "${YELLOW}Using APT package manager...${NC}"
        apt-get update
        
        # Install core dependencies
        for dep in $DEPS_CORE; do
            if ! command -v $dep &> /dev/null; then
                echo -e "  Installing ${CYAN}$dep${NC}..."
                apt-get install -y $dep || echo -e "${YELLOW}Warning: Failed to install $dep${NC}"
            else
                echo -e "  ${GREEN}✓${NC} $dep already installed"
            fi
        done
        
        # Install optional dependencies
        echo -e "${BLUE}Installing optional dependencies...${NC}"
        for dep in $DEPS_OPTIONAL; do
            if ! command -v $dep &> /dev/null; then
                echo -e "  Installing ${CYAN}$dep${NC}..."
                apt-get install -y $dep 2>/dev/null || echo -e "${YELLOW}Note: $dep not available${NC}"
            else
                echo -e "  ${GREEN}✓${NC} $dep already installed"
            fi
        done
        
    elif command -v yum &> /dev/null; then
        echo -e "${YELLOW}Using YUM package manager...${NC}"
        yum update -y
        
        for dep in $DEPS_CORE; do
            if ! command -v $dep &> /dev/null; then
                echo -e "  Installing ${CYAN}$dep${NC}..."
                yum install -y $dep || echo -e "${YELLOW}Warning: Failed to install $dep${NC}"
            else
                echo -e "  ${GREEN}✓${NC} $dep already installed"
            fi
        done
        
        for dep in $DEPS_OPTIONAL; do
            yum install -y $dep 2>/dev/null || true
        done
        
    elif command -v dnf &> /dev/null; then
        echo -e "${YELLOW}Using DNF package manager...${NC}"
        dnf update -y
        
        for dep in $DEPS_CORE; do
            if ! command -v $dep &> /dev/null; then
                echo -e "  Installing ${CYAN}$dep${NC}..."
                dnf install -y $dep || echo -e "${YELLOW}Warning: Failed to install $dep${NC}"
            else
                echo -e "  ${GREEN}✓${NC} $dep already installed"
            fi
        done
        
        for dep in $DEPS_OPTIONAL; do
            dnf install -y $dep 2>/dev/null || true
        done
        
    elif command -v pacman &> /dev/null; then
        echo -e "${YELLOW}Using Pacman package manager...${NC}"
        pacman -Syu --noconfirm
        
        for dep in $DEPS_CORE; do
            if ! command -v $dep &> /dev/null; then
                echo -e "  Installing ${CYAN}$dep${NC}..."
                pacman -S --noconfirm $dep || echo -e "${YELLOW}Warning: Failed to install $dep${NC}"
            else
                echo -e "  ${GREEN}✓${NC} $dep already installed"
            fi
        done
        
    else
        echo -e "${YELLOW}Package manager not detected. Please install dependencies manually:${NC}"
        echo -e "${WHITE}$DEPS_CORE${NC}"
    fi
    
    echo -e "${GREEN}✓ Dependency installation complete${NC}"
}

# Check Docker installation
check_docker() {
    echo -e "${BLUE}Checking Docker installation...${NC}"
    
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓ Docker is installed${NC}"
        docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,$//')
        echo -e "  Version: ${CYAN}$docker_version${NC}"
        
        # Check if Docker daemon is running
        if docker ps &> /dev/null; then
            echo -e "${GREEN}✓ Docker daemon is running${NC}"
        else
            echo -e "${YELLOW}⚠ Docker daemon is not running${NC}"
            echo -e "  Start with: ${CYAN}systemctl start docker${NC}"
        fi
    else
        echo -e "${YELLOW}Docker is not installed${NC}"
        read -p "Would you like to install Docker? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_docker
        else
            echo -e "${YELLOW}Docker features will be disabled${NC}"
        fi
    fi
}

# Install Docker
install_docker() {
    echo -e "${BLUE}Installing Docker...${NC}"
    
    # Docker installation script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    echo -e "${GREEN}✓ Docker installed successfully${NC}"
}

# Install main monitor script
install_monitor() {
    echo -e "${BLUE}Installing TuxTech Monitor V6...${NC}"
    
    if [ ! -f "src/tuxtech-monitor-v6.sh" ]; then
        echo -e "${RED}Error: src/tuxtech-monitor-v6.sh not found!${NC}"
        echo -e "${YELLOW}Please run this script from the repository root directory.${NC}"
        exit 1
    fi
    
    # Backup existing version if it exists
    if [ -f "$INSTALL_DIR/tuxtech-monitor" ]; then
        echo -e "${YELLOW}Backing up existing installation...${NC}"
        cp "$INSTALL_DIR/tuxtech-monitor" "$INSTALL_DIR/tuxtech-monitor.bak"
    fi
    
    # Copy main script
    cp src/tuxtech-monitor-v6.sh "$INSTALL_DIR/tuxtech-monitor"
    chmod +x "$INSTALL_DIR/tuxtech-monitor"
    
    # Create symlink for v6 specifically
    ln -sf "$INSTALL_DIR/tuxtech-monitor" "$INSTALL_DIR/tuxtech-v6"
    
    echo -e "${GREEN}✓ Monitor script installed to $INSTALL_DIR/tuxtech-monitor${NC}"
    echo -e "${GREEN}✓ Symlink created: tuxtech-v6${NC}"
}

# Install SSH banner
install_banner() {
    echo -e "${BLUE}Installing SSH login banner...${NC}"
    
    read -p "Install SSH login banner? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cat > "$PROFILE_DIR/tuxtech-banner.sh" << 'BANNER_EOF'
#!/bin/bash
# TuxTech V6 SSH Banner

# Only run for SSH sessions
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    
    # Colors
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    PURPLE='\033[0;35m'
    WHITE='\033[1;37m'
    NC='\033[0m'
    BOLD='\033[1m'
    
    clear
    
    # Display TuxTech Logo
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
    
    ████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗
    ╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║
       ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║
       ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║
       ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝
       ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝
    
           ═══ INTEGRATED CLOUD COMPUTING PLATFORM V6 ═══
EOF
    echo -e "${NC}"
    
    # Connection details
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}Welcome to TuxTech Server Infrastructure V6${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    
    # User and connection info
    echo -e "${YELLOW}▸${NC} User: ${CYAN}$USER${NC}"
    echo -e "${YELLOW}▸${NC} Hostname: ${CYAN}$(hostname -f)${NC}"
    echo -e "${YELLOW}▸${NC} Connected from: ${CYAN}${SSH_CLIENT%% *}${NC}"
    echo -e "${YELLOW}▸${NC} Login time: ${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${YELLOW}▸${NC} Server uptime:${CYAN}$(uptime -p)${NC}"
    
    # System status
    echo -e "\n${PURPLE}${BOLD}System Status:${NC}"
    echo -e "  CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "  Memory: $(free -h | awk 'NR==2{printf "%.1f/%.1fGB (%.0f%%)", $3, $2, $3*100/$2}')"
    echo -e "  Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s used)", $3, $2, $5}')"
    
    # Docker status if available
    if command -v docker &> /dev/null && docker ps &> /dev/null 2>&1; then
        container_count=$(docker ps -q | wc -l)
        echo -e "  Docker: ${GREEN}$container_count containers running${NC}"
    fi
    
    # Active users
    ACTIVE_USERS=$(who | wc -l)
    echo -e "\n${BOLD}Active users:${NC} $ACTIVE_USERS"
    
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Type ${WHITE}'tuxtech-monitor'${CYAN} or ${WHITE}'tuxtech-v6'${CYAN} to access the monitoring dashboard${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    # Log the connection
    logger -t TuxTech "SSH Login: $USER from ${SSH_CLIENT%% *}"
fi
BANNER_EOF
        
        chmod +x "$PROFILE_DIR/tuxtech-banner.sh"
        echo -e "${GREEN}✓ SSH banner installed to $PROFILE_DIR/tuxtech-banner.sh${NC}"
    else
        echo -e "${YELLOW}Skipping SSH banner installation${NC}"
    fi
}

# Create log files
create_logs() {
    echo -e "${BLUE}Creating log files...${NC}"
    
    # Create main log file
    touch "$LOG_DIR/tuxtech_monitor_v6.log"
    chmod 666 "$LOG_DIR/tuxtech_monitor_v6.log"
    
    # Create audit log
    touch "$LOG_DIR/tuxtech_audit.log"
    chmod 666 "$LOG_DIR/tuxtech_audit.log"
    
    echo -e "${GREEN}✓ Log files created${NC}"
}

# Create configuration directory
create_config() {
    echo -e "${BLUE}Creating configuration directory...${NC}"
    
    mkdir -p "$CONFIG_DIR"
    
    # Create default configuration
    cat > "$CONFIG_DIR/monitor.conf" << 'CONFIG_EOF'
# TuxTech Monitor V6 Configuration

# Monitoring Settings
MONITOR_INTERVAL=5
ENABLE_DOCKER=true
ENABLE_DATABASES=true
ENABLE_WEB_SERVICES=true
ENABLE_SECURITY_CHECKS=true

# Alert Thresholds
CPU_ALERT_THRESHOLD=80
MEMORY_ALERT_THRESHOLD=90
DISK_ALERT_THRESHOLD=85

# Network Settings
SCAN_PORTS=true
MONITOR_SSH=true
CHECK_FIREWALL=true

# Logging
LOG_LEVEL=INFO
MAX_LOG_SIZE=100M
LOG_ROTATION=7

# Features
ENABLE_COLORS=true
ENABLE_NOTIFICATIONS=false
CONFIG_EOF
    
    chmod 644 "$CONFIG_DIR/monitor.conf"
    echo -e "${GREEN}✓ Configuration file created at $CONFIG_DIR/monitor.conf${NC}"
}

# Create systemd service
create_service() {
    echo -e "${BLUE}Creating systemd service...${NC}"
    
    read -p "Create systemd service for automatic monitoring? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cat > /etc/systemd/system/tuxtech-monitor.service << EOF
[Unit]
Description=TuxTech Server Monitor V6
After=network.target docker.service
Wants=docker.service

[Service]
Type=simple
ExecStart=$INSTALL_DIR/tuxtech-monitor --realtime
Restart=always
RestartSec=10
User=root
StandardOutput=journal
StandardError=journal
Environment="TERM=xterm-256color"

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        echo -e "${GREEN}✓ Systemd service created${NC}"
        echo -e "${CYAN}Commands:${NC}"
        echo -e "  Enable auto-start: ${WHITE}systemctl enable tuxtech-monitor${NC}"
        echo -e "  Start service: ${WHITE}systemctl start tuxtech-monitor${NC}"
        echo -e "  Check status: ${WHITE}systemctl status tuxtech-monitor${NC}"
        echo -e "  View logs: ${WHITE}journalctl -u tuxtech-monitor -f${NC}"
    else
        echo -e "${YELLOW}Skipping systemd service creation${NC}"
    fi
}

# Create uninstall script
create_uninstaller() {
    echo -e "${BLUE}Creating uninstall script...${NC}"
    
    cat > "$INSTALL_DIR/tuxtech-uninstall" << 'UNINSTALL_EOF'
#!/bin/bash

# TuxTech Monitor V6 Uninstall Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Uninstalling TuxTech Monitor V6...${NC}"

# Stop and disable service if exists
if [ -f "/etc/systemd/system/tuxtech-monitor.service" ]; then
    systemctl stop tuxtech-monitor 2>/dev/null
    systemctl disable tuxtech-monitor 2>/dev/null
    rm /etc/systemd/system/tuxtech-monitor.service
    systemctl daemon-reload
    echo -e "${GREEN}✓ Removed systemd service${NC}"
fi

# Remove main script and symlinks
rm -f /usr/local/bin/tuxtech-monitor
rm -f /usr/local/bin/tuxtech-v6
echo -e "${GREEN}✓ Removed monitor scripts${NC}"

# Remove SSH banner
rm -f /etc/profile.d/tuxtech-banner.sh
echo -e "${GREEN}✓ Removed SSH banner${NC}"

# Ask about config and logs
read -p "Remove configuration files? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf /etc/tuxtech
    echo -e "${GREEN}✓ Removed configuration${NC}"
fi

read -p "Remove log files? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f /var/log/tuxtech_monitor_v6.log
    rm -f /var/log/tuxtech_audit.log
    echo -e "${GREEN}✓ Removed log files${NC}"
fi

# Remove uninstaller
rm -f /usr/local/bin/tuxtech-uninstall

echo -e "${GREEN}TuxTech Monitor V6 uninstalled successfully!${NC}"
UNINSTALL_EOF
    
    chmod +x "$INSTALL_DIR/tuxtech-uninstall"
    echo -e "${GREEN}✓ Uninstaller created${NC}"
}

# Test installation
test_installation() {
    echo -e "${BLUE}Testing installation...${NC}"
    
    # Test if monitor script is accessible
    if command -v tuxtech-monitor &> /dev/null; then
        echo -e "${GREEN}✓ Monitor script is accessible${NC}"
    else
        echo -e "${RED}✗ Monitor script not found in PATH${NC}"
    fi
    
    # Test if it runs
    if $INSTALL_DIR/tuxtech-monitor --help &> /dev/null; then
        echo -e "${GREEN}✓ Monitor script runs successfully${NC}"
    else
        echo -e "${RED}✗ Monitor script failed to run${NC}"
    fi
    
    # Check permissions
    if [ -x "$INSTALL_DIR/tuxtech-monitor" ]; then
        echo -e "${GREEN}✓ Execute permissions set correctly${NC}"
    else
        echo -e "${RED}✗ Execute permissions not set${NC}"
    fi
}

# Display post-installation information
post_install_info() {
    echo -e "\n${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}Installation completed successfully!${NC}"
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════${NC}"
    
    echo -e "\n${CYAN}${BOLD}Quick Start Guide:${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "\n${YELLOW}Launch Commands:${NC}"
    echo -e "  ${WHITE}tuxtech-monitor${NC}         - Launch interactive menu"
    echo -e "  ${WHITE}tuxtech-v6${NC}              - Launch V6 (same as above)"
    echo -e "  ${WHITE}tuxtech-monitor -r${NC}      - Start real-time monitoring"
    echo -e "  ${WHITE}tuxtech-monitor -d${NC}      - View Docker containers"
    echo -e "  ${WHITE}tuxtech-monitor -s${NC}      - Check all services"
    echo -e "  ${WHITE}tuxtech-monitor -p${NC}      - Scan network ports"
    echo -e "  ${WHITE}tuxtech-monitor -R${NC}      - Generate full report"
    echo -e "  ${WHITE}tuxtech-monitor --help${NC}  - Show all options"
    
    echo -e "\n${YELLOW}System Service:${NC}"
    if [ -f "/etc/systemd/system/tuxtech-monitor.service" ]; then
        echo -e "  ${WHITE}systemctl start tuxtech-monitor${NC}   - Start service"
        echo -e "  ${WHITE}systemctl enable tuxtech-monitor${NC}  - Enable at boot"
        echo -e "  ${WHITE}systemctl status tuxtech-monitor${NC}  - Check status"
    else
        echo -e "  Service not installed (run installer again to add)"
    fi
    
    echo -e "\n${YELLOW}Configuration:${NC}"
    echo -e "  Config file: ${WHITE}/etc/tuxtech/monitor.conf${NC}"
    echo -e "  Log file: ${WHITE}/var/log/tuxtech_monitor_v6.log${NC}"
    
    echo -e "\n${YELLOW}Uninstall:${NC}"
    echo -e "  ${WHITE}sudo tuxtech-uninstall${NC}"
    
    echo -e "\n${CYAN}${BOLD}Features Installed:${NC}"
    echo -e "  ${GREEN}✓${NC} System monitoring"
    echo -e "  ${GREEN}✓${NC} Docker container tracking"
    echo -e "  ${GREEN}✓${NC} Network port scanning"
    echo -e "  ${GREEN}✓${NC} SSH connection monitoring"
    echo -e "  ${GREEN}✓${NC} Service status checking"
    echo -e "  ${GREEN}✓${NC} Database monitoring"
    echo -e "  ${GREEN}✓${NC} Security auditing"
    echo -e "  ${GREEN}✓${NC} Real-time dashboard"
    echo -e "  ${GREEN}✓${NC} Log analysis"
    echo -e "  ${GREEN}✓${NC} Resource tracking"
    
    if command -v docker &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Docker support enabled"
    else
        echo -e "  ${YELLOW}○${NC} Docker not installed (optional)"
    fi
    
    echo -e "\n${GREEN}${BOLD}Thank you for using TuxTech Monitor V6!${NC}"
    echo -e "${CYAN}Try it now: ${WHITE}tuxtech-monitor${NC}\n"
}

# Main installation
main() {
    display_banner
    check_root
    detect_os
    
    echo -e "${GREEN}${BOLD}Starting TuxTech Monitor V6 Installation${NC}\n"
    
    install_dependencies
    check_docker
    install_monitor
    install_banner
    create_logs
    create_config
    create_service
    create_uninstaller
    test_installation
    post_install_info
}

# Run installation
main