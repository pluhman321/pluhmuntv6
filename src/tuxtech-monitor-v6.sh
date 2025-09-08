#!/bin/bash

# TuxTech Monitor V6 - Enhanced Edition
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
NC='\033[0m' # No Color
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Configuration
SCAN_COMMON_PORTS=(80 443 22 21 25 3306 5432 6379 8080 8443 9000 3000 5000 8000 27017 9200 11211 15672)
LOG_FILE="/var/log/tuxtech_monitor_v6.log"

# Function to display TuxTech ASCII logo
display_logo() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║  ████████╗██╗   ██╗██╗  ██╗████████╗███████╗ ██████╗██╗  ██╗  ██╗   ██╗ ███╗ ║
║  ╚══██╔══╝██║   ██║╚██╗██╔╝╚══██╔══╝██╔════╝██╔════╝██║  ██║  ██║   ██║████║ ║
║     ██║   ██║   ██║ ╚███╔╝    ██║   █████╗  ██║     ███████║  ██║   ██║█╔██║ ║
║     ██║   ██║   ██║ ██╔██╗    ██║   ██╔══╝  ██║     ██╔══██║  ╚██╗ ██╔╝████║ ║
║     ██║   ╚██████╔╝██╔╝ ██╗   ██║   ███████╗╚██████╗██║  ██║   ╚████╔╝ ╚██╔╝ ║
║     ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═══╝   ╚═╝  ║
║                                                                          ║
║            INTEGRATED CLOUD COMPUTING PLATFORM - ENHANCED V6            ║
╚══════════════════════════════════════════════════════════════════════════╗
EOF
    echo -e "${NC}"
}

# Enhanced server information display
display_enhanced_server_info() {
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}Enhanced Server Information:${NC}"
    
    # Basic Info
    echo -e "${YELLOW}▸${NC} Hostname: ${CYAN}$(hostname -f)${NC}"
    echo -e "${YELLOW}▸${NC} Kernel: ${CYAN}$(uname -r)${NC}"
    echo -e "${YELLOW}▸${NC} OS: ${CYAN}$(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/*release | grep PRETTY_NAME | cut -d'"' -f2 | head -1)${NC}"
    
    # Network Info
    echo -e "${YELLOW}▸${NC} Primary IP: ${CYAN}$(hostname -I | awk '{print $1}')${NC}"
    echo -e "${YELLOW}▸${NC} Public IP: ${CYAN}$(curl -s ifconfig.me 2>/dev/null || echo "Unable to detect")${NC}"
    
    # System Uptime & Load
    echo -e "${YELLOW}▸${NC} Uptime:${CYAN}$(uptime -p)${NC}"
    echo -e "${YELLOW}▸${NC} Load Average: ${CYAN}$(uptime | awk -F'load average:' '{print $2}')${NC}"
    
    # CPU Info
    echo -e "${YELLOW}▸${NC} CPU: ${CYAN}$(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)${NC}"
    echo -e "${YELLOW}▸${NC} CPU Cores: ${CYAN}$(nproc)${NC}"
    
    # Memory
    echo -e "${YELLOW}▸${NC} Memory: ${CYAN}$(free -h | awk 'NR==2{printf "%s/%s (%.0f%%)", $3, $2, $3*100/$2}')${NC}"
    
    # Disk
    echo -e "${YELLOW}▸${NC} Root Disk: ${CYAN}$(df -h / | awk 'NR==2{printf "%s/%s (%s used)", $3, $2, $5}')${NC}"
    
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
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | while IFS= read -r line; do
        if [[ $line == *"CONTAINER"* ]]; then
            echo -e "${UNDERLINE}${WHITE}$line${NC}"
        else
            echo -e "${GREEN}$line${NC}"
        fi
    done
    
    echo -e "\n${BLUE}Container Network Details:${NC}"
    docker ps -q | while read container_id; do
        if [ ! -z "$container_id" ]; then
            container_name=$(docker inspect --format='{{.Name}}' $container_id | sed 's/^\/*//')
            container_image=$(docker inspect --format='{{.Config.Image}}' $container_id)
            
            # Get all network interfaces
            networks=$(docker inspect $container_id --format='{{range $key, $value := .NetworkSettings.Networks}}{{$key}}:{{.IPAddress}} {{end}}')
            
            # Get exposed ports
            ports=$(docker inspect $container_id --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}}->{{if $conf}}{{(index $conf 0).HostPort}}{{else}}closed{{end}} {{end}}')
            
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
            elif [[ $container_name == *"nginx"* ]] || [[ $container_image == *"nginx"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Web Server${NC}"
            elif [[ $container_name == *"mysql"* ]] || [[ $container_image == *"mysql"* ]] || [[ $container_image == *"mariadb"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Database Server${NC}"
            elif [[ $container_name == *"postgres"* ]] || [[ $container_image == *"postgres"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}PostgreSQL Database${NC}"
            elif [[ $container_name == *"redis"* ]] || [[ $container_image == *"redis"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Cache Server${NC}"
            elif [[ $container_name == *"mongo"* ]] || [[ $container_image == *"mongo"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}MongoDB Database${NC}"
            elif [[ $container_name == *"elastic"* ]] || [[ $container_image == *"elastic"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Elasticsearch${NC}"
            elif [[ $container_name == *"grafana"* ]] || [[ $container_image == *"grafana"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Monitoring Dashboard${NC}"
                echo -e "${CYAN}║${NC} ${BOLD}Web UI:${NC} ${UNDERLINE}${BLUE}http://$(hostname -I | awk '{print $1}'):3000${NC}"
            elif [[ $container_name == *"prometheus"* ]] || [[ $container_image == *"prometheus"* ]]; then
                echo -e "${CYAN}║${NC} ${BOLD}Service Type:${NC} ${PURPLE}Metrics Collection${NC}"
                echo -e "${CYAN}║${NC} ${BOLD}Web UI:${NC} ${UNDERLINE}${BLUE}http://$(hostname -I | awk '{print $1}'):9090${NC}"
            fi
            
            # Container resource usage
            stats=$(docker stats --no-stream --format "CPU: {{.CPUPerc}} | MEM: {{.MemUsage}} ({{.MemPerc}})" $container_id 2>/dev/null)
            if [ ! -z "$stats" ]; then
                echo -e "${CYAN}║${NC} ${BOLD}Resources:${NC} $stats"
            fi
            
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        fi
    done
    
    # Docker system info
    echo -e "\n${BLUE}Docker System Information:${NC}"
    echo -e "${YELLOW}▸${NC} Docker Version: ${CYAN}$(docker --version | cut -d' ' -f3 | sed 's/,$//')${NC}"
    echo -e "${YELLOW}▸${NC} Total Containers: ${CYAN}$(docker ps -a | tail -n +2 | wc -l)${NC}"
    echo -e "${YELLOW}▸${NC} Running: ${GREEN}$(docker ps -q | wc -l)${NC} | Stopped: ${RED}$(docker ps -aq | wc -l)${NC}"
    echo -e "${YELLOW}▸${NC} Images: ${CYAN}$(docker images | tail -n +2 | wc -l)${NC}"
    echo -e "${YELLOW}▸${NC} Volumes: ${CYAN}$(docker volume ls | tail -n +2 | wc -l)${NC}"
    echo -e "${YELLOW}▸${NC} Networks: ${CYAN}$(docker network ls | tail -n +2 | wc -l)${NC}"
    
    # Disk usage
    if command -v docker &> /dev/null; then
        docker_disk=$(docker system df 2>/dev/null | tail -n +2 | head -n 4)
        if [ ! -z "$docker_disk" ]; then
            echo -e "\n${BLUE}Docker Disk Usage:${NC}"
            echo "$docker_disk" | while IFS= read -r line; do
                echo -e "  ${CYAN}$line${NC}"
            done
        fi
    fi
}

# Advanced port scanning
scan_network_ports() {
    echo -e "${PURPLE}${BOLD}[NETWORK PORT SCANNER]${NC}"
    echo -e "${BLUE}Scanning for open ports...${NC}\n"
    
    local host=${1:-"127.0.0.1"}
    
    echo -e "${YELLOW}Listening Services:${NC}"
    
    # Use ss if available, fallback to netstat
    if command -v ss &> /dev/null; then
        ss -tulpn 2>/dev/null | grep LISTEN | while read line; do
            port=$(echo $line | grep -oP ':\K[0-9]+' | head -1)
            service=$(echo $line | awk '{print $NF}')
            proto=$(echo $line | awk '{print $1}')
            
            if [ ! -z "$port" ]; then
                # Try to identify service
                case $port in
                    80) service_name="HTTP Web Server" ;;
                    443) service_name="HTTPS Web Server" ;;
                    22) service_name="SSH Server" ;;
                    21) service_name="FTP Server" ;;
                    25) service_name="SMTP Mail Server" ;;
                    3306) service_name="MySQL Database" ;;
                    5432) service_name="PostgreSQL Database" ;;
                    6379) service_name="Redis Cache" ;;
                    8080) service_name="HTTP Alternate" ;;
                    8096) service_name="Jellyfin Media Server" ;;
                    32400) service_name="Plex Media Server" ;;
                    9000) service_name="Portainer/PHP-FPM" ;;
                    3000) service_name="Node.js/Grafana" ;;
                    5000) service_name="Flask/Docker Registry" ;;
                    8000) service_name="Django/HTTP Alternate" ;;
                    27017) service_name="MongoDB Database" ;;
                    9200) service_name="Elasticsearch" ;;
                    11211) service_name="Memcached" ;;
                    15672) service_name="RabbitMQ Management" ;;
                    *) service_name="Unknown Service" ;;
                esac
                
                echo -e "  ${GREEN}●${NC} Port ${CYAN}$port${NC}/${YELLOW}$proto${NC}: ${WHITE}$service_name${NC} $service"
            fi
        done
    elif command -v netstat &> /dev/null; then
        netstat -tulpn 2>/dev/null | grep LISTEN | while read line; do
            echo -e "  ${GREEN}●${NC} $line"
        done
    fi
    
    # Check specific services
    echo -e "\n${YELLOW}Service Availability Check:${NC}"
    
    # Web servers
    for port in 80 443 8080 8443; do
        if nc -z localhost $port 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Web service on port ${CYAN}$port${NC} is ${GREEN}ACTIVE${NC}"
            # Try to get server header
            if [ $port -eq 80 ] || [ $port -eq 8080 ]; then
                server_header=$(curl -sI http://localhost:$port 2>/dev/null | grep -i "server:" | cut -d' ' -f2-)
                [ ! -z "$server_header" ] && echo -e "    ${YELLOW}→${NC} Server: ${WHITE}$server_header${NC}"
            fi
        fi
    done
    
    # Database servers
    echo -e "\n${YELLOW}Database Services:${NC}"
    
    # MySQL/MariaDB
    if nc -z localhost 3306 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} MySQL/MariaDB on port ${CYAN}3306${NC} is ${GREEN}ACTIVE${NC}"
        if command -v mysql &> /dev/null; then
            mysql_version=$(mysql --version 2>/dev/null | cut -d' ' -f6)
            [ ! -z "$mysql_version" ] && echo -e "    ${YELLOW}→${NC} Version: ${WHITE}$mysql_version${NC}"
        fi
    else
        echo -e "  ${RED}✗${NC} MySQL/MariaDB on port ${CYAN}3306${NC} is ${RED}INACTIVE${NC}"
    fi
    
    # PostgreSQL
    if nc -z localhost 5432 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} PostgreSQL on port ${CYAN}5432${NC} is ${GREEN}ACTIVE${NC}"
        if command -v psql &> /dev/null; then
            pg_version=$(psql --version 2>/dev/null | cut -d' ' -f3)
            [ ! -z "$pg_version" ] && echo -e "    ${YELLOW}→${NC} Version: ${WHITE}$pg_version${NC}"
        fi
    else
        echo -e "  ${RED}✗${NC} PostgreSQL on port ${CYAN}5432${NC} is ${RED}INACTIVE${NC}"
    fi
    
    # Redis
    if nc -z localhost 6379 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Redis on port ${CYAN}6379${NC} is ${GREEN}ACTIVE${NC}"
        if command -v redis-cli &> /dev/null; then
            redis_version=$(redis-cli --version 2>/dev/null | cut -d' ' -f2)
            [ ! -z "$redis_version" ] && echo -e "    ${YELLOW}→${NC} Version: ${WHITE}$redis_version${NC}"
        fi
    else
        echo -e "  ${RED}✗${NC} Redis on port ${CYAN}6379${NC} is ${RED}INACTIVE${NC}"
    fi
    
    # MongoDB
    if nc -z localhost 27017 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} MongoDB on port ${CYAN}27017${NC} is ${GREEN}ACTIVE${NC}"
    else
        echo -e "  ${RED}✗${NC} MongoDB on port ${CYAN}27017${NC} is ${RED}INACTIVE${NC}"
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
        ssh_root=$(grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "unknown")
        ssh_password=$(grep "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "yes")
        
        echo -e "  ${YELLOW}▸${NC} SSH Port: ${CYAN}$ssh_port${NC}"
        echo -e "  ${YELLOW}▸${NC} Root Login: ${CYAN}$ssh_root${NC}"
        echo -e "  ${YELLOW}▸${NC} Password Auth: ${CYAN}$ssh_password${NC}"
    fi
    
    # Current SSH sessions
    echo -e "\n${YELLOW}Current SSH Sessions:${NC}"
    if command -v ss &> /dev/null; then
        ss -tn state established '( dport = :22 or sport = :22 )' 2>/dev/null | grep -v State | while read line; do
            local_addr=$(echo $line | awk '{print $3}')
            remote_addr=$(echo $line | awk '{print $4}')
            echo -e "  ${GREEN}➤${NC} ${WHITE}$remote_addr${NC} → ${CYAN}$local_addr${NC}"
        done
    fi
    
    # Active users with details
    echo -e "\n${YELLOW}Active Users:${NC}"
    w -h | while read line; do
        user=$(echo $line | awk '{print $1}')
        tty=$(echo $line | awk '{print $2}')
        from=$(echo $line | awk '{print $3}')
        login=$(echo $line | awk '{print $4}')
        idle=$(echo $line | awk '{print $5}')
        
        echo -e "  ${CYAN}◆${NC} User: ${GREEN}$user${NC} | TTY: ${YELLOW}$tty${NC} | From: ${WHITE}$from${NC}"
        echo -e "    Login: ${PURPLE}$login${NC} | Idle: ${ORANGE}$idle${NC}"
    done
    
    # SSH key information
    echo -e "\n${YELLOW}SSH Keys:${NC}"
    if [ -d ~/.ssh ]; then
        key_count=$(ls -1 ~/.ssh/*.pub 2>/dev/null | wc -l)
        echo -e "  ${YELLOW}▸${NC} Authorized keys: ${CYAN}$([ -f ~/.ssh/authorized_keys ] && wc -l < ~/.ssh/authorized_keys || echo "0")${NC}"
        echo -e "  ${YELLOW}▸${NC} Public keys found: ${CYAN}$key_count${NC}"
    fi
    
    # Recent SSH activity
    echo -e "\n${YELLOW}Recent SSH Activity (last 10):${NC}"
    if [ -f /var/log/auth.log ]; then
        grep "sshd.*Accepted" /var/log/auth.log 2>/dev/null | tail -10 | while read line; do
            timestamp=$(echo $line | awk '{print $1" "$2" "$3}')
            details=$(echo $line | grep -oP 'Accepted \K.*')
            echo -e "  ${PURPLE}[$timestamp]${NC} ${WHITE}$details${NC}"
        done
    elif [ -f /var/log/secure ]; then
        grep "sshd.*Accepted" /var/log/secure 2>/dev/null | tail -10 | while read line; do
            echo -e "  ${WHITE}$line${NC}"
        done
    fi
    
    # Failed login attempts
    echo -e "\n${YELLOW}Recent Failed Login Attempts:${NC}"
    if [ -f /var/log/auth.log ]; then
        failed_count=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
        echo -e "  ${RED}▸${NC} Total failed attempts: ${RED}$failed_count${NC}"
        grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 | while read line; do
            echo -e "  ${RED}✗${NC} $(echo $line | awk '{print $1" "$2" "$3}') - $(echo $line | grep -oP 'from \K[^ ]*')"
        done
    fi
}

# System resource monitoring
monitor_system_resources() {
    echo -e "${PURPLE}${BOLD}[SYSTEM RESOURCE MONITOR]${NC}"
    
    # CPU Information
    echo -e "\n${YELLOW}CPU Information:${NC}"
    echo -e "  ${CYAN}Model:${NC} $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo -e "  ${CYAN}Cores:${NC} $(nproc) cores"
    echo -e "  ${CYAN}Architecture:${NC} $(uname -m)"
    echo -e "  ${CYAN}CPU MHz:${NC} $(lscpu | grep 'CPU MHz' | cut -d':' -f2 | xargs)"
    
    # CPU Usage per core
    echo -e "\n${YELLOW}CPU Usage by Core:${NC}"
    if command -v mpstat &> /dev/null; then
        mpstat -P ALL 1 1 | grep -E "^Average|CPU" | while read line; do
            if [[ $line == *"CPU"* ]]; then
                echo -e "  ${UNDERLINE}$line${NC}"
            else
                usage=$(echo $line | awk '{print 100-$NF}')
                core=$(echo $line | awk '{print $2}')
                if (( $(echo "$usage > 80" | bc -l) )); then
                    color=$RED
                elif (( $(echo "$usage > 50" | bc -l) )); then
                    color=$YELLOW
                else
                    color=$GREEN
                fi
                echo -e "  Core ${CYAN}$core${NC}: ${color}${usage}%${NC}"
            fi
        done
    else
        echo -e "  ${YELLOW}Install sysstat for detailed CPU statistics${NC}"
    fi
    
    # Memory Information
    echo -e "\n${YELLOW}Memory Information:${NC}"
    free -h | while IFS= read -r line; do
        if [[ $line == *"Mem:"* ]]; then
            total=$(echo $line | awk '{print $2}')
            used=$(echo $line | awk '{print $3}')
            free=$(echo $line | awk '{print $4}')
            available=$(echo $line | awk '{print $7}')
            
            echo -e "  ${CYAN}Total:${NC} $total"
            echo -e "  ${CYAN}Used:${NC} $used"
            echo -e "  ${CYAN}Free:${NC} $free"
            echo -e "  ${CYAN}Available:${NC} $available"
        elif [[ $line == *"Swap:"* ]]; then
            echo -e "\n${YELLOW}Swap:${NC}"
            total=$(echo $line | awk '{print $2}')
            used=$(echo $line | awk '{print $3}')
            free=$(echo $line | awk '{print $4}')
            
            echo -e "  ${CYAN}Total:${NC} $total"
            echo -e "  ${CYAN}Used:${NC} $used"
            echo -e "  ${CYAN}Free:${NC} $free"
        fi
    done
    
    # Top memory consumers
    echo -e "\n${YELLOW}Top Memory Consumers:${NC}"
    ps aux --sort=-%mem | head -6 | tail -5 | while read line; do
        user=$(echo $line | awk '{print $1}')
        mem=$(echo $line | awk '{print $4}')
        cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')
        echo -e "  ${GREEN}●${NC} ${CYAN}$mem%${NC} - ${WHITE}$cmd${NC} (${YELLOW}$user${NC})"
    done
    
    # Disk Information
    echo -e "\n${YELLOW}Disk Usage:${NC}"
    df -h | grep -E '^/dev/' | while read line; do
        filesystem=$(echo $line | awk '{print $1}')
        size=$(echo $line | awk '{print $2}')
        used=$(echo $line | awk '{print $3}')
        avail=$(echo $line | awk '{print $4}')
        use_percent=$(echo $line | awk '{print $5}' | sed 's/%//')
        mount=$(echo $line | awk '{print $6}')
        
        if [ $use_percent -gt 90 ]; then
            color=$RED
        elif [ $use_percent -gt 70 ]; then
            color=$YELLOW
        else
            color=$GREEN
        fi
        
        echo -e "  ${CYAN}$mount${NC} (${WHITE}$filesystem${NC})"
        echo -e "    Size: ${WHITE}$size${NC} | Used: ${color}$used ($use_percent%)${NC} | Free: ${GREEN}$avail${NC}"
    done
    
    # I/O Statistics
    echo -e "\n${YELLOW}Disk I/O Statistics:${NC}"
    if command -v iostat &> /dev/null; then
        iostat -x 1 2 | tail -n +4 | head -n -1 | while read line; do
            device=$(echo $line | awk '{print $1}')
            util=$(echo $line | awk '{print $NF}')
            echo -e "  ${CYAN}$device${NC}: Utilization ${YELLOW}$util%${NC}"
        done
    else
        echo -e "  ${YELLOW}Install sysstat for I/O statistics${NC}"
    fi
    
    # Network Statistics
    echo -e "\n${YELLOW}Network Statistics:${NC}"
    ip -s link | grep -A 5 "^[0-9]:" | while read line; do
        if [[ $line =~ ^[0-9]+: ]]; then
            interface=$(echo $line | cut -d':' -f2 | xargs)
            echo -e "  ${CYAN}Interface: $interface${NC}"
        elif [[ $line == *"RX:"* ]] || [[ $line == *"TX:"* ]]; then
            echo -e "    ${WHITE}$line${NC}"
        fi
    done
}

# Service monitoring
monitor_services_enhanced() {
    echo -e "${PURPLE}${BOLD}[ENHANCED SERVICE MONITOR]${NC}"
    
    # System services
    echo -e "\n${YELLOW}System Services Status:${NC}"
    
    services=(
        "ssh:SSH Server"
        "nginx:Web Server"
        "apache2:Apache Web Server"
        "mysql:MySQL Database"
        "mariadb:MariaDB Database"
        "postgresql:PostgreSQL Database"
        "docker:Docker Engine"
        "redis:Redis Cache"
        "mongodb:MongoDB Database"
        "elasticsearch:Elasticsearch"
        "kibana:Kibana"
        "grafana-server:Grafana"
        "prometheus:Prometheus"
        "jenkins:Jenkins CI"
        "gitlab-runner:GitLab Runner"
        "rabbitmq-server:RabbitMQ"
        "memcached:Memcached"
        "vsftpd:FTP Server"
        "nfs-server:NFS Server"
        "smbd:Samba Server"
        "fail2ban:Fail2ban"
        "ufw:UFW Firewall"
        "iptables:IPTables"
        "cron:Cron Scheduler"
    )
    
    for service_info in "${services[@]}"; do
        service="${service_info%%:*}"
        description="${service_info##*:}"
        
        if systemctl list-units --all --type=service | grep -q "$service.service"; then
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                status="${GREEN}● RUNNING${NC}"
                # Get additional info
                pid=$(systemctl show -p MainPID --value $service 2>/dev/null)
                memory=$(systemctl show -p MemoryCurrent --value $service 2>/dev/null)
                
                if [ "$pid" != "0" ] && [ ! -z "$pid" ]; then
                    if [ "$memory" != "[not set]" ] && [ ! -z "$memory" ]; then
                        memory_mb=$((memory / 1024 / 1024))
                        echo -e "  $status ${WHITE}$description${NC} (${CYAN}$service${NC}) [PID: ${YELLOW}$pid${NC}, Mem: ${PURPLE}${memory_mb}MB${NC}]"
                    else
                        echo -e "  $status ${WHITE}$description${NC} (${CYAN}$service${NC}) [PID: ${YELLOW}$pid${NC}]"
                    fi
                else
                    echo -e "  $status ${WHITE}$description${NC} (${CYAN}$service${NC})"
                fi
            else
                echo -e "  ${YELLOW}○ STOPPED${NC} ${WHITE}$description${NC} (${CYAN}$service${NC})"
            fi
        fi
    done
    
    # Process monitoring
    echo -e "\n${YELLOW}Top CPU Consuming Processes:${NC}"
    ps aux --sort=-%cpu | head -6 | tail -5 | while read line; do
        user=$(echo $line | awk '{print $1}')
        cpu=$(echo $line | awk '{print $3}')
        cmd=$(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}' | cut -c1-50)
        echo -e "  ${GREEN}●${NC} ${CYAN}$cpu%${NC} - ${WHITE}$cmd${NC} (${YELLOW}$user${NC})"
    done
}

# Log file monitoring
monitor_logs() {
    echo -e "${PURPLE}${BOLD}[LOG FILE MONITOR]${NC}"
    
    echo -e "\n${YELLOW}System Log Analysis:${NC}"
    
    # Check various log files
    log_files=(
        "/var/log/syslog:System Log"
        "/var/log/auth.log:Authentication Log"
        "/var/log/kern.log:Kernel Log"
        "/var/log/nginx/error.log:Nginx Error Log"
        "/var/log/apache2/error.log:Apache Error Log"
        "/var/log/mysql/error.log:MySQL Error Log"
        "/var/log/docker.log:Docker Log"
    )
    
    for log_info in "${log_files[@]}"; do
        log_file="${log_info%%:*}"
        log_name="${log_info##*:}"
        
        if [ -f "$log_file" ]; then
            size=$(du -h "$log_file" | awk '{print $1}')
            lines=$(wc -l < "$log_file")
            last_modified=$(stat -c %y "$log_file" | cut -d' ' -f1,2 | cut -d'.' -f1)
            
            echo -e "\n  ${CYAN}$log_name${NC} (${WHITE}$log_file${NC})"
            echo -e "    Size: ${YELLOW}$size${NC} | Lines: ${GREEN}$lines${NC} | Modified: ${PURPLE}$last_modified${NC}"
            
            # Show last 3 error entries if they exist
            if grep -i "error\|fail\|critical" "$log_file" 2>/dev/null | tail -3 | grep -q .; then
                echo -e "    ${RED}Recent Errors:${NC}"
                grep -i "error\|fail\|critical" "$log_file" 2>/dev/null | tail -3 | while IFS= read -r line; do
                    echo -e "      ${RED}→${NC} $(echo "$line" | cut -c1-80)..."
                done
            fi
        fi
    done
}

# Firewall status
check_firewall() {
    echo -e "${PURPLE}${BOLD}[FIREWALL STATUS]${NC}"
    
    # Check UFW
    if command -v ufw &> /dev/null; then
        echo -e "\n${YELLOW}UFW Firewall:${NC}"
        ufw_status=$(ufw status 2>/dev/null | head -1)
        echo -e "  Status: ${CYAN}$ufw_status${NC}"
        
        if [[ $ufw_status == *"active"* ]]; then
            echo -e "  ${YELLOW}Rules:${NC}"
            ufw status numbered 2>/dev/null | tail -n +4 | head -10 | while read line; do
                echo -e "    ${WHITE}$line${NC}"
            done
        fi
    fi
    
    # Check iptables
    if command -v iptables &> /dev/null && [ "$EUID" -eq 0 ]; then
        echo -e "\n${YELLOW}IPTables Rules:${NC}"
        rule_count=$(iptables -L -n | wc -l)
        echo -e "  Total rules: ${CYAN}$rule_count${NC}"
        
        # Show first few rules
        echo -e "  ${YELLOW}INPUT Chain:${NC}"
        iptables -L INPUT -n --line-numbers 2>/dev/null | head -5 | while read line; do
            echo -e "    ${WHITE}$line${NC}"
        done
    fi
}

# Database monitoring
monitor_databases() {
    echo -e "${PURPLE}${BOLD}[DATABASE MONITOR]${NC}"
    
    # MySQL/MariaDB
    if command -v mysql &> /dev/null; then
        echo -e "\n${YELLOW}MySQL/MariaDB:${NC}"
        if mysqladmin ping 2>/dev/null | grep -q "alive"; then
            echo -e "  ${GREEN}● Status: RUNNING${NC}"
            
            # Try to get database list (may need credentials)
            if mysql -e "SHOW DATABASES;" 2>/dev/null; then
                db_count=$(mysql -e "SHOW DATABASES;" 2>/dev/null | wc -l)
                echo -e "  Databases: ${CYAN}$((db_count-1))${NC}"
            fi
            
            # Get process list
            if mysql -e "SHOW PROCESSLIST;" 2>/dev/null; then
                process_count=$(mysql -e "SHOW PROCESSLIST;" 2>/dev/null | wc -l)
                echo -e "  Active connections: ${CYAN}$((process_count-1))${NC}"
            fi
        else
            echo -e "  ${RED}○ Status: NOT RUNNING${NC}"
        fi
    fi
    
    # PostgreSQL
    if command -v psql &> /dev/null; then
        echo -e "\n${YELLOW}PostgreSQL:${NC}"
        if pg_isready 2>/dev/null | grep -q "accepting connections"; then
            echo -e "  ${GREEN}● Status: RUNNING${NC}"
        else
            echo -e "  ${RED}○ Status: NOT RUNNING${NC}"
        fi
    fi
    
    # Redis
    if command -v redis-cli &> /dev/null; then
        echo -e "\n${YELLOW}Redis:${NC}"
        if redis-cli ping 2>/dev/null | grep -q "PONG"; then
            echo -e "  ${GREEN}● Status: RUNNING${NC}"
            
            # Get Redis info
            clients=$(redis-cli info clients 2>/dev/null | grep "connected_clients" | cut -d':' -f2 | tr -d '\r')
            memory=$(redis-cli info memory 2>/dev/null | grep "used_memory_human" | cut -d':' -f2 | tr -d '\r')
            
            [ ! -z "$clients" ] && echo -e "  Connected clients: ${CYAN}$clients${NC}"
            [ ! -z "$memory" ] && echo -e "  Memory usage: ${CYAN}$memory${NC}"
        else
            echo -e "  ${RED}○ Status: NOT RUNNING${NC}"
        fi
    fi
    
    # MongoDB
    if command -v mongod &> /dev/null; then
        echo -e "\n${YELLOW}MongoDB:${NC}"
        if pgrep -x mongod > /dev/null; then
            echo -e "  ${GREEN}● Status: RUNNING${NC}"
            
            # Get MongoDB status (may need auth)
            if command -v mongosh &> /dev/null; then
                mongosh --quiet --eval "db.version()" 2>/dev/null && {
                    version=$(mongosh --quiet --eval "db.version()" 2>/dev/null)
                    echo -e "  Version: ${CYAN}$version${NC}"
                }
            elif command -v mongo &> /dev/null; then
                mongo --quiet --eval "db.version()" 2>/dev/null && {
                    version=$(mongo --quiet --eval "db.version()" 2>/dev/null)
                    echo -e "  Version: ${CYAN}$version${NC}"
                }
            fi
        else
            echo -e "  ${RED}○ Status: NOT RUNNING${NC}"
        fi
    fi
}

# Web services monitoring
monitor_web_services() {
    echo -e "${PURPLE}${BOLD}[WEB SERVICES MONITOR]${NC}"
    
    # Check common web application ports
    web_ports=(
        "80:HTTP"
        "443:HTTPS"
        "3000:Node.js/React"
        "3001:Node.js"
        "4200:Angular"
        "5000:Flask/Serve"
        "5173:Vite"
        "8000:Django/HTTP"
        "8080:Tomcat/HTTP"
        "8081:HTTP Alternative"
        "8090:HTTP Alternative"
        "8096:Jellyfin"
        "8123:Home Assistant"
        "8384:Syncthing"
        "8443:HTTPS Alternative"
        "8888:Jupyter"
        "9000:Portainer"
        "9090:Prometheus"
        "9091:Transmission"
        "9117:Jackett"
        "32400:Plex"
    )
    
    echo -e "\n${YELLOW}Web Application Ports:${NC}"
    
    for port_info in "${web_ports[@]}"; do
        port="${port_info%%:*}"
        service="${port_info##*:}"
        
        if nc -z localhost $port 2>/dev/null; then
            echo -e "  ${GREEN}●${NC} Port ${CYAN}$port${NC} (${WHITE}$service${NC}): ${GREEN}OPEN${NC}"
            
            # Try to get HTTP response
            if [ $port -ne 443 ] && [ $port -ne 8443 ]; then
                response=$(curl -sI http://localhost:$port --max-time 2 2>/dev/null | head -1)
                if [ ! -z "$response" ]; then
                    echo -e "    ${YELLOW}→${NC} Response: ${WHITE}$response${NC}"
                fi
            fi
        fi
    done
}

# Security check
security_check() {
    echo -e "${PURPLE}${BOLD}[SECURITY CHECK]${NC}"
    
    echo -e "\n${YELLOW}Security Status:${NC}"
    
    # Check for root user
    if [ "$EUID" -eq 0 ]; then
        echo -e "  ${RED}⚠ Running as ROOT user${NC}"
    else
        echo -e "  ${GREEN}✓ Running as regular user${NC}"
    fi
    
    # Check SSH root login
    if [ -f /etc/ssh/sshd_config ]; then
        if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
            echo -e "  ${RED}⚠ SSH root login is ENABLED${NC}"
        else
            echo -e "  ${GREEN}✓ SSH root login is restricted${NC}"
        fi
    fi
    
    # Check for updates
    if command -v apt &> /dev/null; then
        updates=$(apt list --upgradable 2>/dev/null | grep -c "upgradable")
        if [ $updates -gt 0 ]; then
            echo -e "  ${YELLOW}⚠ $updates system updates available${NC}"
        else
            echo -e "  ${GREEN}✓ System is up to date${NC}"
        fi
    fi
    
    # Check fail2ban
    if systemctl is-active --quiet fail2ban 2>/dev/null; then
        echo -e "  ${GREEN}✓ Fail2ban is ACTIVE${NC}"
        jail_count=$(fail2ban-client status 2>/dev/null | grep "Number of jail" | awk '{print $NF}')
        [ ! -z "$jail_count" ] && echo -e "    Active jails: ${CYAN}$jail_count${NC}"
    else
        echo -e "  ${YELLOW}⚠ Fail2ban is not running${NC}"
    fi
    
    # Check for unusual network connections
    echo -e "\n${YELLOW}Network Security:${NC}"
    established=$(ss -tn state established 2>/dev/null | wc -l)
    listening=$(ss -tln 2>/dev/null | wc -l)
    echo -e "  Established connections: ${CYAN}$((established-1))${NC}"
    echo -e "  Listening ports: ${CYAN}$((listening-1))${NC}"
    
    # Check for suspicious processes
    echo -e "\n${YELLOW}Process Security:${NC}"
    suspicious_count=$(ps aux | grep -E "nc |netcat|/tmp/.*sh|wget.*sh|curl.*sh" | grep -v grep | wc -l)
    if [ $suspicious_count -gt 0 ]; then
        echo -e "  ${RED}⚠ $suspicious_count potentially suspicious processes detected${NC}"
    else
        echo -e "  ${GREEN}✓ No suspicious processes detected${NC}"
    fi
}

# Real-time monitoring
realtime_monitor_enhanced() {
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
        echo -e "${YELLOW}System Load:${NC}"
        echo -e "  CPU: ${CYAN}$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%${NC}"
        echo -e "  Memory: ${CYAN}$(free -h | awk 'NR==2{printf "%.1f/%.1fGB (%.0f%%)", $3, $2, $3*100/$2}')${NC}"
        echo -e "  Processes: ${CYAN}$(ps aux | wc -l)${NC}"
        
        echo -e "\n${YELLOW}Active Services:${NC}"
        # Check key services
        for service in ssh nginx apache2 mysql docker redis; do
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                echo -e "  ${GREEN}●${NC} $service"
            fi
        done
        
        echo -e "\n${YELLOW}Network Connections:${NC}"
        echo -e "  SSH: ${CYAN}$(ss -tn state established '( dport = :22 or sport = :22 )' 2>/dev/null | grep -v State | wc -l)${NC}"
        echo -e "  HTTP/S: ${CYAN}$(ss -tn state established '( dport = :80 or dport = :443 )' 2>/dev/null | wc -l)${NC}"
        
        # Docker containers if available
        if command -v docker &> /dev/null && docker ps &> /dev/null; then
            echo -e "\n${YELLOW}Docker Containers:${NC}"
            docker ps --format "  ${GREEN}●${NC} {{.Names}} ({{.Status}})" 2>/dev/null | head -5
        fi
        
        sleep 5
    done
}

# Main menu
main_menu() {
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
    echo -e "  ${CYAN}7)${NC}  Database Monitor"
    echo -e "  ${CYAN}8)${NC}  Web Services Monitor"
    echo -e "  ${CYAN}9)${NC}  Log File Analysis"
    echo -e "  ${CYAN}10)${NC} Firewall Status"
    echo -e "  ${CYAN}11)${NC} Security Check"
    echo -e "  ${CYAN}12)${NC} Real-Time Monitoring"
    echo -e "  ${CYAN}13)${NC} Full System Report"
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
            main_menu
            ;;
        2)
            clear
            display_logo
            monitor_docker
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        3)
            clear
            display_logo
            scan_network_ports
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        4)
            clear
            display_logo
            monitor_ssh_enhanced
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        5)
            clear
            display_logo
            monitor_system_resources
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        6)
            clear
            display_logo
            monitor_services_enhanced
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        7)
            clear
            display_logo
            monitor_databases
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        8)
            clear
            display_logo
            monitor_web_services
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        9)
            clear
            display_logo
            monitor_logs
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        10)
            clear
            display_logo
            check_firewall
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        11)
            clear
            display_logo
            security_check
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        12)
            clear
            display_logo
            realtime_monitor_enhanced
            ;;
        13)
            clear
            display_logo
            echo -e "${PURPLE}${BOLD}[GENERATING FULL SYSTEM REPORT]${NC}\n"
            display_enhanced_server_info
            monitor_docker
            echo -e "\n"
            scan_network_ports
            echo -e "\n"
            monitor_ssh_enhanced
            echo -e "\n"
            monitor_system_resources
            echo -e "\n"
            monitor_services_enhanced
            echo -e "\n"
            monitor_databases
            echo -e "\n"
            monitor_web_services
            echo -e "\n"
            check_firewall
            echo -e "\n"
            security_check
            echo -e "\n${GREEN}════════════════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}${BOLD}Full System Report Complete${NC}"
            echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
            echo -e "\n${CYAN}Press Enter to continue...${NC}"
            read
            main_menu
            ;;
        0)
            echo -e "${GREEN}Exiting TuxTech Monitor V6...${NC}"
            echo -e "${CYAN}Thank you for using TuxTech Monitor!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 2
            main_menu
            ;;
    esac
}

# Script entry point
if [ "$1" == "--realtime" ] || [ "$1" == "-r" ]; then
    display_logo
    realtime_monitor_enhanced
elif [ "$1" == "--docker" ] || [ "$1" == "-d" ]; then
    display_logo
    monitor_docker
elif [ "$1" == "--services" ] || [ "$1" == "-s" ]; then
    display_logo
    monitor_services_enhanced
elif [ "$1" == "--ports" ] || [ "$1" == "-p" ]; then
    display_logo
    scan_network_ports
elif [ "$1" == "--report" ] || [ "$1" == "-R" ]; then
    display_logo
    echo -e "${PURPLE}${BOLD}[GENERATING FULL SYSTEM REPORT]${NC}\n"
    display_enhanced_server_info
    monitor_docker
    scan_network_ports
    monitor_services_enhanced
    monitor_databases
    security_check
elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    display_logo
    echo "TuxTech Monitor V6 - Enhanced Edition"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -r, --realtime    Start real-time monitoring"
    echo "  -d, --docker      Show Docker container details"
    echo "  -s, --services    Show all services status"
    echo "  -p, --ports       Scan network ports"
    echo "  -R, --report      Generate full system report"
    echo "  -h, --help        Show this help message"
    echo "  (no options)      Launch interactive menu"
    echo ""
    echo "Examples:"
    echo "  $0              # Launch interactive menu"
    echo "  $0 --realtime   # Start real-time monitoring"
    echo "  $0 --docker     # View Docker containers"
    echo "  $0 --report     # Generate complete system report"
else
    main_menu
fi