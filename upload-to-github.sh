#!/bin/bash

# TuxTech Monitor V6 - GitHub Upload Helper
# This script helps you upload the repository to GitHub

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}"
cat << "EOF"

████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗
╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║
   ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║
   ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║
   ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝
   ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝

                    GITHUB REPOSITORY UPLOADER
EOF
echo -e "${NC}"

# Check if we're in the right directory
if [ ! -f "install.sh" ] || [ ! -d "src" ]; then
    echo -e "${RED}Error: Not in pluhmuntv6 directory${NC}"
    echo -e "${YELLOW}Please run this from the pluhmuntv6 folder${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found pluhmuntv6 repository${NC}\n"

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Git is not installed${NC}"
    echo -e "${YELLOW}Install git first:${NC}"
    echo -e "  Ubuntu/Debian: ${WHITE}sudo apt-get install git${NC}"
    echo -e "  CentOS/RHEL: ${WHITE}sudo yum install git${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Git is installed${NC}\n"

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo -e "${BLUE}Initializing Git repository...${NC}"
    git init
    echo -e "${GREEN}✓ Git initialized${NC}\n"
else
    echo -e "${GREEN}✓ Git already initialized${NC}\n"
fi

# Get GitHub username
echo -e "${YELLOW}Enter your GitHub username:${NC}"
read -p "> " github_username

if [ -z "$github_username" ]; then
    echo -e "${RED}Username cannot be empty${NC}"
    exit 1
fi

# Repository name
repo_name="pluhmuntv6"

echo -e "\n${CYAN}Repository will be: ${WHITE}https://github.com/$github_username/$repo_name${NC}\n"

# Check if remote already exists
if git remote | grep -q origin; then
    echo -e "${YELLOW}Remote 'origin' already exists${NC}"
    read -p "Remove existing remote? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
        echo -e "${GREEN}✓ Removed existing remote${NC}\n"
    fi
fi

# Add all files
echo -e "${BLUE}Adding all files to Git...${NC}"
git add .
echo -e "${GREEN}✓ Files added${NC}\n"

# Commit
echo -e "${BLUE}Creating commit...${NC}"
git commit -m "Initial commit - TuxTech Monitor V6 Enhanced Edition" 2>/dev/null || {
    echo -e "${YELLOW}Nothing to commit or already committed${NC}\n"
}

# Set branch to main
git branch -M main

# Instructions for GitHub
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${WHITE}${BOLD}           NEXT STEPS TO UPLOAD TO GITHUB${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}1. Create repository on GitHub:${NC}"
echo -e "   ${BLUE}https://github.com/new${NC}"
echo -e "   • Repository name: ${WHITE}$repo_name${NC}"
echo -e "   • Make it ${WHITE}Public${NC}"
echo -e "   • ${RED}DON'T${NC} initialize with README"
echo -e "   • Click ${WHITE}'Create repository'${NC}\n"

echo -e "${YELLOW}2. Get a Personal Access Token:${NC}"
echo -e "   ${BLUE}https://github.com/settings/tokens${NC}"
echo -e "   • Click ${WHITE}'Generate new token (classic)'${NC}"
echo -e "   • Name it: ${WHITE}TuxTech Monitor V6${NC}"
echo -e "   • Select scope: ${WHITE}☑ repo${NC}"
echo -e "   • Click ${WHITE}'Generate token'${NC}"
echo -e "   • ${RED}COPY THE TOKEN${NC} (looks like: ghp_xxxxxxxxxxxx)\n"

echo -e "${YELLOW}3. Run these commands:${NC}"
echo -e "${WHITE}git remote add origin https://github.com/$github_username/$repo_name.git${NC}"
echo -e "${WHITE}git push -u origin main${NC}\n"

echo -e "${YELLOW}When prompted:${NC}"
echo -e "   Username: ${WHITE}$github_username${NC}"
echo -e "   Password: ${WHITE}[PASTE YOUR TOKEN HERE]${NC}\n"

echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"

# Offer to set remote
read -p "Add remote origin now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git remote add origin "https://github.com/$github_username/$repo_name.git"
    echo -e "${GREEN}✓ Remote added${NC}\n"
    
    echo -e "${YELLOW}Ready to push!${NC}"
    echo -e "Run: ${WHITE}git push -u origin main${NC}"
    echo -e "Remember to use your ${RED}TOKEN${NC} as password!\n"
fi

# Show repository structure
echo -e "${CYAN}${BOLD}Your repository structure:${NC}"
echo -e "${WHITE}"
tree -L 2 2>/dev/null || {
    ls -la
    echo
    echo "src/"
    ls -la src/
    echo
    echo "docs/"
    ls -la docs/
}
echo -e "${NC}"

echo -e "${GREEN}${BOLD}Repository is ready to upload!${NC}"
echo -e "${CYAN}After uploading, people can install with:${NC}"
echo -e "${WHITE}curl -sSL https://raw.githubusercontent.com/$github_username/$repo_name/main/quick-install.sh | sudo bash${NC}\n"