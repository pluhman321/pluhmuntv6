# TuxTech Monitor V6 - Troubleshooting Guide

## 🔧 Common Issues and Solutions

### Installation Issues

#### Permission Denied During Installation
**Problem:** Getting "Permission denied" error
```bash
bash: ./install.sh: Permission denied
```

**Solution:**
```bash
# Make script executable
chmod +x install.sh

# Run with sudo
sudo ./install.sh
```

#### Package Manager Not Found
**Problem:** Installation fails with package manager errors

**Solution:**
```bash
# For Ubuntu/Debian:
sudo apt-get update
sudo apt-get install -y curl wget net-tools bc

# For CentOS/RHEL:
sudo yum update
sudo yum install -y curl wget net-tools bc

# For Arch:
sudo pacman -Syu
sudo pacman -S curl wget net-tools bc
```

#### Installation Script Not Found
**Problem:** Can't find install.sh

**Solution:**
```bash
# Ensure you're in the correct directory
cd pluhmuntv6
ls -la

# If missing, re-download
git clone https://github.com/pluhman321/pluhmuntv6.git
cd pluhmuntv6
```

---

### Docker Monitoring Issues

#### Docker Not Detected
**Problem:** Docker features show "Docker is not installed"

**Solution:**
```bash
# Check if Docker is installed
docker --version

# If not installed:
curl -fsSL https://get.docker.com | sudo bash
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (optional)
sudo usermod -aG docker $USER
# Log out and back in for group change to take effect
```

#### Docker Daemon Not Running
**Problem:** "Docker daemon is not running" message

**Solution:**
```bash
# Start Docker service
sudo systemctl start docker

# Check status
sudo systemctl status docker

# If failed, check logs
sudo journalctl -u docker -n 50
```

#### No Docker Containers Showing
**Problem:** Docker section shows no containers despite having some

**Solution:**
```bash
# Check if containers are actually running
docker ps

# Need sudo for Docker commands?
sudo docker ps

# Start stopped containers
docker ps -a  # List all containers
docker start [container_name]
```

---

### Network and Port Scanning Issues

#### No Network Information
**Problem:** Network stats show as unavailable

**Solution:**
```bash
# Install net-tools
sudo apt-get install -y net-tools  # Debian/Ubuntu
sudo yum install -y net-tools      # CentOS/RHEL

# Alternative: use ss command
ss -tulpn
```

#### Port Scanning Shows No Results
**Problem:** Port scanner returns empty results

**Solution:**
```bash
# Need root privileges for full port info
sudo tuxtech-monitor --ports

# Check if services are actually listening
sudo netstat -tulpn
# or
sudo ss -tulpn
```

#### Can't Connect to Web Services
**Problem:** Web UI links don't work

**Solution:**
```bash
# Check firewall rules
sudo ufw status
sudo iptables -L

# Allow specific port (example for Jellyfin)
sudo ufw allow 8096

# Check if service is actually running
curl http://localhost:8096
```

---

### SSH Monitoring Issues

#### No SSH Sessions Showing
**Problem:** SSH monitor shows no active sessions

**Solution:**
```bash
# Check who's logged in
who
w

# Check SSH service status
sudo systemctl status ssh
# or
sudo systemctl status sshd

# View auth log manually
sudo tail -f /var/log/auth.log      # Debian/Ubuntu
sudo tail -f /var/log/secure        # CentOS/RHEL
```

#### Can't See Failed Login Attempts
**Problem:** Failed login section is empty

**Solution:**
```bash
# Need root access to read auth logs
sudo tuxtech-monitor

# Check log file exists
ls -la /var/log/auth.log
ls -la /var/log/secure

# Manually check for failures
sudo grep "Failed password" /var/log/auth.log
```

---

### Service Monitoring Issues

#### Services Not Detected
**Problem:** Known services don't appear in service list

**Solution:**
```bash
# Check service name variations
systemctl list-units --type=service --all | grep [service_name]

# Service might use different name
# MySQL could be:
systemctl status mysql
systemctl status mysqld
systemctl status mariadb
```

#### Wrong Service Status
**Problem:** Service shows as stopped when it's running

**Solution:**
```bash
# Verify actual status
systemctl status [service_name]

# Restart the monitor
tuxtech-monitor

# Check using alternative method
ps aux | grep [service_name]
pgrep [service_name]
```

---

### Performance Issues

#### Monitor Running Slowly
**Problem:** Interface is laggy or slow to respond

**Solution:**
```bash
# Check system resources
top
htop

# Reduce monitoring features in config
sudo nano /etc/tuxtech/monitor.conf
# Set ENABLE_DOCKER=false if not needed
# Increase MONITOR_INTERVAL

# Check for high disk I/O
iotop
```

#### High CPU Usage
**Problem:** Monitor uses too much CPU

**Solution:**
```bash
# Use less frequent updates
tuxtech-monitor  # Then choose options with less real-time data

# Avoid real-time mode on weak systems
# Don't use: tuxtech-monitor --realtime

# Check what's consuming CPU
top -p $(pgrep tuxtech)
```

---

### Display Issues

#### Colors Not Showing
**Problem:** Output is monochrome

**Solution:**
```bash
# Check terminal support
echo $TERM

# Set proper terminal
export TERM=xterm-256color

# For SSH sessions
ssh -t user@server  # Force pseudo-terminal

# In screen/tmux
export TERM=screen-256color
```

#### ASCII Art Broken
**Problem:** Logo appears corrupted

**Solution:**
```bash
# Check locale settings
locale

# Set UTF-8 locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# For permanent fix
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

---

### System Service Issues

#### Systemd Service Won't Start
**Problem:** `systemctl start tuxtech-monitor` fails

**Solution:**
```bash
# Check service status
sudo systemctl status tuxtech-monitor

# View detailed logs
sudo journalctl -u tuxtech-monitor -n 50

# Verify script exists
ls -la /usr/local/bin/tuxtech-monitor

# Reload systemd
sudo systemctl daemon-reload
sudo systemctl restart tuxtech-monitor
```

#### Service Not Starting at Boot
**Problem:** Monitor doesn't start automatically

**Solution:**
```bash
# Enable service
sudo systemctl enable tuxtech-monitor

# Verify it's enabled
systemctl is-enabled tuxtech-monitor

# Check for errors in boot log
journalctl -b -u tuxtech-monitor
```

---

### Database Monitoring Issues

#### Can't Connect to MySQL
**Problem:** MySQL shows as not running when it is

**Solution:**
```bash
# Check MySQL service name
systemctl status mysql
systemctl status mysqld
systemctl status mariadb

# Test connection manually
mysql -u root -p -e "SELECT 1"
mysqladmin ping

# Check socket location
find /var -name mysql.sock 2>/dev/null
```

#### Redis/MongoDB Not Detected
**Problem:** Database services not showing

**Solution:**
```bash
# Check if actually installed
which redis-cli
which mongod

# Check if running
ps aux | grep redis
ps aux | grep mongo

# Test connections
redis-cli ping
mongo --eval "db.version()"
```

---

### General Troubleshooting Steps

1. **Check Requirements**
   ```bash
   bash --version  # Should be 4.0+
   uname -a       # Check Linux kernel
   ```

2. **Reinstall**
   ```bash
   sudo tuxtech-uninstall
   cd pluhmuntv6
   sudo ./install.sh
   ```

3. **Check Logs**
   ```bash
   # Monitor logs
   sudo tail -f /var/log/tuxtech_monitor_v6.log
   
   # System logs
   sudo journalctl -f
   ```

4. **Run in Debug Mode**
   ```bash
   bash -x /usr/local/bin/tuxtech-monitor
   ```

5. **Verify Installation**
   ```bash
   which tuxtech-monitor
   ls -la /usr/local/bin/tuxtech*
   ```

---

## 🆘 Getting Help

If issues persist:

1. **Check GitHub Issues**
   - https://github.com/pluhman321/pluhmuntv6/issues

2. **Create New Issue** with:
   - OS version: `cat /etc/os-release`
   - Kernel: `uname -a`
   - Docker version: `docker --version`
   - Error messages
   - Steps to reproduce

3. **Collect Debug Info**
   ```bash
   # Create debug report
   tuxtech-monitor --report > debug_report.txt 2>&1
   sudo journalctl -u tuxtech-monitor -n 100 >> debug_report.txt
   ```

4. **Community Support**
   - Check existing solutions
   - Ask in discussions
   - Share your fix if you find one!

---

## 🔄 Complete Reset

If all else fails, perform a complete reset:

```bash
# 1. Uninstall completely
sudo tuxtech-uninstall

# 2. Remove all traces
sudo rm -rf /usr/local/bin/tuxtech*
sudo rm -rf /etc/tuxtech
sudo rm -f /var/log/tuxtech*
sudo rm -f /etc/profile.d/tuxtech*
sudo rm -f /etc/systemd/system/tuxtech*

# 3. Reinstall fresh
git clone https://github.com/pluhman321/pluhmuntv6.git
cd pluhmuntv6
sudo ./install.sh
```

---

Remember: Most issues are related to permissions or missing dependencies. When in doubt, run with `sudo` and ensure all dependencies are installed!