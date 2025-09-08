# TuxTech Server Monitor V6 - Enhanced Edition 🚀

<div align="center">

```
████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗
╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║
   ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║
   ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║
   ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝
   ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝
```

**INTEGRATED CLOUD COMPUTING PLATFORM - ENHANCED V6**

[![Version](https://img.shields.io/badge/Version-6.0-blue.svg)](https://github.com/pluhman321/pluhmuntv6)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker Support](https://img.shields.io/badge/Docker-Supported-2496ED.svg)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/Platform-Linux-green.svg)](https://www.linux.org/)

</div>

## 🎯 Overview

TuxTech Monitor V6 is a **comprehensive Linux server monitoring solution** with advanced Docker container tracking, service discovery, network analysis, and real-time system monitoring. This enhanced version includes automatic detection of services like Jellyfin, Plex, Portainer, and many more.

## ✨ Key Features

### 🐳 Docker Monitoring
- **Complete Container Management** - View all running containers with IP addresses and port mappings
- **Service Auto-Detection** - Automatically identifies Jellyfin, Plex, Portainer, Grafana, and more
- **Resource Tracking** - Monitor CPU and memory usage per container
- **Network Analysis** - See all network configurations and exposed ports
- **Direct Web UI Links** - Quick access to container web interfaces

### 🔍 Network & Port Scanning
- **Comprehensive Port Scanner** - Identifies all listening services
- **Service Recognition** - Automatically identifies what's running on each port
- **Security Analysis** - Detects potentially vulnerable services
- **Connection Tracking** - Monitor all active network connections

### 📊 System Monitoring
- **Real-Time Dashboard** - Live updates of system status
- **Resource Metrics** - CPU per core, memory, disk I/O, network traffic
- **Process Analysis** - Top consumers of CPU and memory
- **Service Health** - Status of 25+ common services

### 🔐 Security Features
- **SSH Monitoring** - Track all SSH connections and login attempts
- **Failed Login Detection** - Monitor authentication failures
- **Firewall Status** - UFW and iptables configuration checking
- **Security Audit** - Check for common security issues
- **Update Detection** - Alert for available system updates

### 📈 Database Support
- MySQL/MariaDB monitoring
- PostgreSQL status checking
- Redis cache analysis
- MongoDB connection tracking
- Elasticsearch health monitoring

### 🌐 Web Service Detection
Automatically detects and monitors:
- **Jellyfin** (Port 8096) - Media server
- **Plex** (Port 32400) - Media server
- **Portainer** (Port 9000) - Container management
- **Grafana** (Port 3000) - Monitoring dashboard
- **Prometheus** (Port 9090) - Metrics collection
- **Home Assistant** (Port 8123) - Home automation
- **And 20+ more services...**

## 🚀 Installation

### Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/pluhman321/pluhmuntv6.git
cd pluhmuntv6

# Run the installer
sudo ./install.sh
```

### One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/pluhman321/pluhmuntv6/main/install.sh | sudo bash
```

## 📖 Usage

### Interactive Menu
```bash
tuxtech-monitor
# or
tuxtech-v6
```

### Command Line Options
```bash
tuxtech-monitor [OPTIONS]

Options:
  -r, --realtime    Start real-time monitoring
  -d, --docker      Show Docker container details
  -s, --services    Show all services status
  -p, --ports       Scan network ports
  -R, --report      Generate full system report
  -h, --help        Show help message
```

### Examples
```bash
# Launch interactive dashboard
tuxtech-monitor

# Monitor Docker containers
tuxtech-monitor --docker

# Real-time system monitoring
tuxtech-monitor --realtime

# Generate complete system report
tuxtech-monitor --report
```

## 📋 Menu Options

1. **System Overview** - Complete system information
2. **Docker Container Monitor** - Detailed container analysis
3. **Network Port Scanner** - Comprehensive port scanning
4. **Enhanced SSH Monitor** - SSH connection tracking
5. **System Resources** - CPU, memory, disk monitoring
6. **Service Monitor** - Status of all services
7. **Database Monitor** - Database health checks
8. **Web Services Monitor** - Web application detection
9. **Log File Analysis** - System log inspection
10. **Firewall Status** - Security configuration
11. **Security Check** - Security audit
12. **Real-Time Monitoring** - Live dashboard
13. **Full System Report** - Complete analysis

## 🛠️ System Requirements

### Minimum Requirements
- Linux-based OS (Ubuntu, Debian, CentOS, RHEL, Arch)
- Bash 4.0+
- Root/sudo access for full features
- 512MB RAM
- 50MB disk space

### Recommended
- Docker installed for container monitoring
- 1GB+ RAM
- Network tools (netstat/ss)
- System monitoring tools (htop, iotop, sysstat)

## 📦 Dependencies

The installer automatically handles dependencies:

### Core Dependencies
- `curl` - HTTP requests
- `wget` - File downloads
- `net-tools` - Network utilities
- `bc` - Calculator for scripts

### Optional (Auto-installed)
- `docker` - Container monitoring
- `htop` - Process viewer
- `iotop` - I/O monitoring
- `sysstat` - System statistics
- `fail2ban` - Security monitoring

## 🔧 Configuration

Configuration file: `/etc/tuxtech/monitor.conf`

```bash
# Edit configuration
sudo nano /etc/tuxtech/monitor.conf

# Key settings:
MONITOR_INTERVAL=5          # Refresh interval in seconds
ENABLE_DOCKER=true         # Docker monitoring
CPU_ALERT_THRESHOLD=80     # CPU alert level
MEMORY_ALERT_THRESHOLD=90  # Memory alert level
```

## 🚦 Systemd Service

### Enable automatic monitoring at boot:
```bash
# Enable service
sudo systemctl enable tuxtech-monitor

# Start service
sudo systemctl start tuxtech-monitor

# Check status
sudo systemctl status tuxtech-monitor

# View logs
journalctl -u tuxtech-monitor -f
```

## 📊 Monitored Services

The tool automatically detects and monitors:

### Container Platforms
- Docker
- Kubernetes (pods)
- LXC/LXD

### Web Servers
- Nginx
- Apache
- Caddy
- Traefik

### Databases
- MySQL/MariaDB
- PostgreSQL
- MongoDB
- Redis
- Elasticsearch

### Media Servers
- Jellyfin
- Plex
- Emby
- Kodi

### Management Tools
- Portainer
- Grafana
- Prometheus
- Jenkins

### And many more...

## 🔍 Troubleshooting

### Docker not detected
```bash
# Install Docker
curl -fsSL https://get.docker.com | sudo bash
sudo systemctl start docker
```

### Permission denied
```bash
# Run with sudo
sudo tuxtech-monitor
```

### Service not starting
```bash
# Check logs
journalctl -u tuxtech-monitor -n 50
```

## 🗑️ Uninstallation

```bash
sudo tuxtech-uninstall
```

This will:
- Remove all scripts
- Delete service files
- Optionally remove logs and configuration

## 📝 Logs

- Main log: `/var/log/tuxtech_monitor_v6.log`
- Audit log: `/var/log/tuxtech_audit.log`
- Service log: `journalctl -u tuxtech-monitor`

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

- TuxTech team for the platform
- Docker community
- Linux system administrators worldwide
- Open source contributors

## 📞 Support

- GitHub Issues: [Report bugs](https://github.com/pluhman321/pluhmuntv6/issues)
- Documentation: [Wiki](https://github.com/pluhman321/pluhmuntv6/wiki)
- Email: support@tuxtech.com

## ⭐ Star History

If you find this tool useful, please star the repository!

---

<div align="center">
Made with ❤️ by TuxTech | Enhanced V6 Edition
</div>