# Contributing to TuxTech Monitor V6

Thank you for your interest in contributing to TuxTech Monitor V6! This document provides guidelines and instructions for contributing to the project.

## 🎯 How Can I Contribute?

### Reporting Bugs
- Check if the bug has already been reported in [Issues](https://github.com/pluhman321/pluhmuntv6/issues)
- If not, create a new issue with:
  - Clear, descriptive title
  - Steps to reproduce
  - Expected vs actual behavior
  - System information (OS, Docker version, etc.)
  - Screenshots if applicable
  - Any error messages or logs

### Suggesting Enhancements
- Check existing [Issues](https://github.com/pluhman321/pluhmuntv6/issues) for similar suggestions
- Create a new issue with the "enhancement" label
- Include:
  - Clear description of the enhancement
  - Why this would be useful
  - Possible implementation approach

### Adding New Service Detection
To add detection for a new service:

1. Edit `src/tuxtech-monitor-v6.sh`
2. Add to the appropriate monitoring function
3. Include:
   - Port detection
   - Service identification
   - Status checking
   - Web UI link if applicable

Example:
```bash
# In monitor_docker() function
elif [[ $container_name == *"yourservice"* ]]; then
    echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Your Service Description${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}Web UI:${NC} ${UNDERLINE}${BLUE}http://$(hostname -I | awk '{print $1}'):PORT${NC}"
fi
```

### Pull Requests

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Make your changes
4. Test thoroughly on multiple Linux distributions if possible
5. Commit with clear messages:
   ```bash
   git commit -m "Add: New feature for X"
   ```
6. Push to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
7. Open a Pull Request

## 🔧 Development Setup

### Prerequisites
- Linux environment (or WSL on Windows)
- Bash 4.0+
- Docker (optional, for container features)
- Git

### Testing Your Changes

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/pluhmuntv6.git
   cd pluhmuntv6
   ```

2. Make your changes to the scripts

3. Test the installation:
   ```bash
   sudo ./install.sh
   ```

4. Test various features:
   ```bash
   # Test main menu
   tuxtech-monitor
   
   # Test Docker monitoring
   tuxtech-monitor --docker
   
   # Test services
   tuxtech-monitor --services
   
   # Test port scanning
   tuxtech-monitor --ports
   ```

## 📝 Code Style Guidelines

### Bash Script Standards
- Use 4 spaces for indentation (no tabs)
- Add comments for complex logic
- Use meaningful variable names
- Follow existing color scheme conventions
- Include error handling

### Variable Naming
```bash
# Constants in UPPERCASE
INSTALL_DIR="/usr/local/bin"

# Local variables in lowercase
local container_name="example"

# Global variables with descriptive names
monitor_interval=5
```

### Functions
- Start with verb (monitor_, check_, display_, etc.)
- Include function description comment
- Handle errors gracefully

Example:
```bash
# Function to monitor Docker containers
monitor_docker() {
    echo -e "${PURPLE}${BOLD}[DOCKER MONITOR]${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker is not installed${NC}"
        return
    fi
    
    # Function logic here
}
```

### Color Usage
- `${GREEN}` - Success, active, running
- `${RED}` - Errors, stopped, failures
- `${YELLOW}` - Warnings, headers, prompts
- `${BLUE}` - Information, section headers
- `${CYAN}` - Values, highlights
- `${PURPLE}` - Section titles
- `${WHITE}` - General text

## 🧪 Testing Checklist

Before submitting a PR, ensure:

- [ ] Script runs without syntax errors
- [ ] Installation completes successfully
- [ ] All menu options work
- [ ] New features are documented
- [ ] Error messages are helpful
- [ ] Code follows style guidelines
- [ ] Tested on at least Ubuntu/Debian
- [ ] No hardcoded paths (except system standards)

## 📚 Documentation

Update documentation for:
- New features in README.md
- New command-line options
- New configuration options
- New service detections

## 🏗️ Project Structure

```
pluhmuntv6/
├── src/
│   └── tuxtech-monitor-v6.sh    # Main monitor script
├── docs/
│   ├── CONTRIBUTING.md          # This file
│   ├── FEATURES.md              # Detailed features
│   └── TROUBLESHOOTING.md       # Common issues
├── install.sh                   # Installation script
├── quick-install.sh             # Web installer
├── README.md                    # Main documentation
├── LICENSE                      # MIT License
└── .gitignore                   # Git ignore rules
```

## 🤝 Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards others

## 📬 Communication

- GitHub Issues for bugs and features
- Pull Requests for code changes
- Keep discussions focused and on-topic

## 🎉 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

## ❓ Questions?

If you have questions about contributing:
1. Check existing documentation
2. Search closed issues
3. Open a new issue with the "question" label

Thank you for contributing to TuxTech Monitor V6!