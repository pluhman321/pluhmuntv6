#!/bin/bash

# TuxTech Monitor V6 - Quick Installation Script
# This script can be run directly from the web for quick installation
# Usage: curl -sSL https://raw.githubusercontent.com/pluhman321/pluhmuntv6/main/quick-install.sh | sudo bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Display banner
echo -e "${CYAN}${BOLD}"
cat << "EOF"

████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗
╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║
   ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║
   ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║
   ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝
   ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝

            QUICK INSTALLER - ENHANCED MONITOR V6
EOF
echo -e "${NC}"

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   echo -e "${YELLOW}Please run: sudo bash $0${NC}"
   exit 1
fi

echo -e "${GREEN}Starting TuxTech Monitor V6 Quick Installation...${NC}"

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

echo -e "${BLUE}Downloading TuxTech Monitor V6...${NC}"

# Download the repository
if command -v git &> /dev/null; then
    git clone https://github.com/pluhman321/pluhmuntv6.git
    cd pluhmuntv6
elif command -v wget &> /dev/null; then
    wget https://github.com/pluhman321/pluhmuntv6/archive/main.zip
    unzip -q main.zip
    cd pluhmuntv6-main
elif command -v curl &> /dev/null; then
    curl -L https://github.com/pluhman321/pluhmuntv6/archive/main.zip -o main.zip
    unzip -q main.zip
    cd pluhmuntv6-main
else
    echo -e "${RED}Error: git, wget, or curl is required${NC}"
    exit 1
fi

# Run the installer
if [ -f "install.sh" ]; then
    chmod +x install.sh
    ./install.sh
else
    echo -e "${RED}Error: install.sh not found${NC}"
    exit 1
fi

# Cleanup
cd /
rm -rf $TEMP_DIR

echo -e "${GREEN}${BOLD}Quick installation completed!${NC}"
echo -e "${CYAN}Run 'tuxtech-monitor' to start${NC}"