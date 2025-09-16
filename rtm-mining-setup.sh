#!/bin/bash

# RTM (Raptoreum) Mining Setup Script - Wyvern CPU Miner
# Automated setup for Ubuntu VM with GhostRider algorithm support
# This script installs and configures the working Wyvern CPU miner

set -e

# Configuration
RTM_WALLET="RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU"  # Replace with your wallet
POOL_PRIMARY="stratum+tcp://rtm-stratum.pukkapool.com:3052"
POOL_BACKUP="stratum+tcp://pool.raptoreum.com:3333"
MINER_DIR="$HOME/cpuminer-gr-avx2"
LOG_DIR="$HOME/rtm-logs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

show_header() {
    clear
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}    RTM (Raptoreum) Mining Setup - Wyvern      ${NC}"
    echo -e "${PURPLE}        GhostRider Algorithm Support           ${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
    echo -e "${BLUE}Wallet: ${GREEN}$RTM_WALLET${NC}"
    echo -e "${BLUE}Primary Pool: ${GREEN}$POOL_PRIMARY${NC}"
    echo -e "${BLUE}Backup Pool: ${GREEN}$POOL_BACKUP${NC}"
    echo ""
}

check_system() {
    echo -e "${BLUE}Checking system compatibility...${NC}"
    
    # Check if Ubuntu/Debian
    if ! command -v apt &> /dev/null; then
        echo -e "${RED}✗ This script requires Ubuntu/Debian with apt package manager${NC}"
        exit 1
    fi
    
    # Check CPU architecture
    if [ "$(uname -m)" != "x86_64" ]; then
        echo -e "${RED}✗ x86_64 architecture required${NC}"
        exit 1
    fi
    
    # Check CPU cores and RAM
    CPU_CORES=$(nproc)
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    
    echo -e "${GREEN}✓ CPU Cores: $CPU_CORES${NC}"
    echo -e "${GREEN}✓ RAM: ${RAM_GB}GB${NC}"
    
    # Check CPU features
    CPU_INFO=$(cat /proc/cpuinfo)
    if echo "$CPU_INFO" | grep -q "sse2"; then
        echo -e "${GREEN}✓ SSE2 support${NC}"
    else
        echo -e "${RED}✗ SSE2 required${NC}"
        exit 1
    fi
    
    if echo "$CPU_INFO" | grep -q "avx2"; then
        echo -e "${GREEN}✓ AVX2 support (optimal)${NC}"
    elif echo "$CPU_INFO" | grep -q "avx"; then
        echo -e "${YELLOW}! AVX support (good)${NC}"
    else
        echo -e "${YELLOW}! No AVX support (reduced performance)${NC}"
    fi
    
    echo ""
}

install_dependencies() {
    echo -e "${BLUE}Installing dependencies...${NC}"
    
    # Update package list
    sudo apt update -qq
    
    # Install required packages
    sudo apt install -y \
        git \
        build-essential \
        cmake \
        automake \
        autoconf \
        pkg-config \
        libcurl4-openssl-dev \
        libjansson-dev \
        libssl-dev \
        libgmp-dev \
        libhwloc-dev \
        libtool \
        screen \
        htop \
        wget \
        curl \
        unzip > /dev/null 2>&1
    
    echo -e "${GREEN}✓ Dependencies installed${NC}"
    echo ""
}

download_and_build_miner() {
    echo -e "${BLUE}Setting up Wyvern CPU Miner...${NC}"
    
    # Remove old miner if exists
    if [ -d "$MINER_DIR" ]; then
        echo -e "${YELLOW}Removing old miner installation...${NC}"
        rm -rf "$MINER_DIR"
    fi
    
    # Clone Wyvern CPU miner (optimized for RTM GhostRider)
    echo -e "${BLUE}Downloading Wyvern CPU Miner...${NC}"
    git clone https://github.com/WyvernTKC/cpuminer-gr-avx2.git "$MINER_DIR" > /dev/null 2>&1
    
    cd "$MINER_DIR"
    
    # Build the miner
    echo -e "${BLUE}Building miner (this may take 5-10 minutes)...${NC}"
    ./build.sh > /dev/null 2>&1
    
    # Verify build
    if [ -f "cpuminer" ] && [ -x "cpuminer" ]; then
        echo -e "${GREEN}✓ Wyvern CPU Miner built successfully${NC}"
        
        # Test miner
        if ./cpuminer --help | grep -q "Ghost Rider"; then
            echo -e "${GREEN}✓ GhostRider algorithm support confirmed${NC}"
        else
            echo -e "${RED}✗ GhostRider algorithm not found${NC}"
            exit 1
        fi
    else
        echo -e "${RED}✗ Miner build failed${NC}"
        exit 1
    fi
    
    echo ""
}

create_config_file() {
    echo -e "${BLUE}Creating mining configuration...${NC}"
    
    # Create logs directory
    mkdir -p "$LOG_DIR"
    
    # Create config.json for easy mining
    cat > "$MINER_DIR/config.json" << EOF
{
    "url": "$POOL_PRIMARY",
    "user": "$RTM_WALLET",
    "pass": "x",
    "algo": "gr",
    "threads": 0,
    "cpu-priority": 3,
    "retry-pause": 10,
    "background": false,
    "quiet": false,
    "no-tune": false,
    "log-file": "$LOG_DIR/mining.log"
}
EOF
    
    echo -e "${GREEN}✓ Configuration file created${NC}"
    echo ""
}

create_mining_scripts() {
    echo -e "${BLUE}Creating mining control scripts...${NC}"
    
    # Create start mining script
    cat > "$MINER_DIR/start-mining.sh" << 'EOF'
#!/bin/bash

# RTM Mining Control Script
MINER_DIR="$HOME/cpuminer-gr-avx2"
LOG_DIR="$HOME/rtm-logs"
CONFIG_FILE="$MINER_DIR/config.json"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$MINER_DIR"

case "${1:-start}" in
    "start")
        echo -e "${BLUE}Starting RTM mining...${NC}"
        ./cpuminer -c "$CONFIG_FILE"
        ;;
    "screen")
        echo -e "${BLUE}Starting RTM mining in background...${NC}"
        screen -dmS rtm-mining bash -c "cd '$MINER_DIR' && ./cpuminer -c '$CONFIG_FILE'"
        echo -e "${GREEN}✓ Mining started in screen session 'rtm-mining'${NC}"
        echo "Use 'screen -r rtm-mining' to attach"
        echo "Use 'screen -list' to see all sessions"
        ;;
    "stop")
        echo -e "${BLUE}Stopping RTM mining...${NC}"
        pkill -f cpuminer || true
        screen -S rtm-mining -X quit 2>/dev/null || true
        echo -e "${GREEN}✓ Mining stopped${NC}"
        ;;
    "status")
        if pgrep -f "cpuminer" > /dev/null; then
            echo -e "${GREEN}✓ Mining is RUNNING${NC}"
            ps aux | grep cpuminer | grep -v grep
            
            if [ -f "$LOG_DIR/mining.log" ]; then
                echo ""
                echo -e "${BLUE}Recent activity:${NC}"
                tail -5 "$LOG_DIR/mining.log" | grep -E "(H/s|Accepted)" | tail -3 || echo "No recent activity"
            fi
        else
            echo -e "${YELLOW}Mining is NOT running${NC}"
        fi
        ;;
    "logs")
        if [ -f "$LOG_DIR/mining.log" ]; then
            echo -e "${BLUE}Live mining logs (Ctrl+C to exit):${NC}"
            tail -f "$LOG_DIR/mining.log"
        else
            echo -e "${YELLOW}No log file found${NC}"
        fi
        ;;
    "help"|*)
        echo "RTM Mining Control Script"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  start    - Start mining (foreground)"
        echo "  screen   - Start mining in background"
        echo "  stop     - Stop mining"
        echo "  status   - Show mining status"
        echo "  logs     - Show live mining logs"
        echo "  help     - Show this help"
        ;;
esac
EOF

    # Create quick start script
    cat > "$MINER_DIR/quick-start.sh" << EOF
#!/bin/bash
# Quick start RTM mining with optimal settings
cd "$MINER_DIR"
./cpuminer -a gr -o $POOL_PRIMARY -u $RTM_WALLET -t 0 --cpu-priority=3 2>&1 | tee $LOG_DIR/mining_\$(date +%Y%m%d_%H%M%S).log
EOF

    # Make scripts executable
    chmod +x "$MINER_DIR/start-mining.sh"
    chmod +x "$MINER_DIR/quick-start.sh"
    
    echo -e "${GREEN}✓ Mining control scripts created${NC}"
    echo ""
}

show_usage() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}           RTM Mining Setup Complete!          ${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
    echo -e "${GREEN}🚀 Ready to mine RTM with GhostRider algorithm!${NC}"
    echo ""
    echo -e "${BLUE}Mining Commands:${NC}"
    echo -e "${GREEN}  cd ~/cpuminer-gr-avx2${NC}"
    echo ""
    echo -e "${YELLOW}Option 1 - Simple start:${NC}"
    echo -e "${GREEN}  ./quick-start.sh${NC}"
    echo ""
    echo -e "${YELLOW}Option 2 - Background mining:${NC}"
    echo -e "${GREEN}  ./start-mining.sh screen${NC}"
    echo -e "${GREEN}  screen -r rtm-mining     ${NC}# to view mining"
    echo ""
    echo -e "${YELLOW}Option 3 - Full control:${NC}"
    echo -e "${GREEN}  ./cpuminer -a gr -o $POOL_PRIMARY -u $RTM_WALLET -t 0${NC}"
    echo ""
    echo -e "${BLUE}Management Commands:${NC}"
    echo -e "${GREEN}  ./start-mining.sh status   ${NC}# Check mining status"
    echo -e "${GREEN}  ./start-mining.sh logs     ${NC}# View live logs"
    echo -e "${GREEN}  ./start-mining.sh stop     ${NC}# Stop mining"
    echo ""
    echo -e "${BLUE}Performance Notes:${NC}"
    echo "• First run will auto-tune for ~154 minutes"
    echo "• Current performance: ~66.8 H/s per thread"
    echo "• Monitor CPU temperature during mining"
    echo "• Use 'htop' to monitor system resources"
    echo ""
    echo -e "${YELLOW}⚠️  Important: Replace the wallet address with your own RTM wallet!${NC}"
    echo ""
}

main() {
    local action="${1:-install}"
    
    case "$action" in
        "install")
            show_header
            check_system
            install_dependencies
            download_and_build_miner
            create_config_file
            create_mining_scripts
            show_usage
            ;;
        "start")
            if [ ! -f "$MINER_DIR/cpuminer" ]; then
                echo -e "${RED}Miner not installed. Run: $0 install${NC}"
                exit 1
            fi
            cd "$MINER_DIR"
            ./start-mining.sh start
            ;;
        "screen")
            if [ ! -f "$MINER_DIR/cpuminer" ]; then
                echo -e "${RED}Miner not installed. Run: $0 install${NC}"
                exit 1
            fi
            cd "$MINER_DIR"
            ./start-mining.sh screen
            ;;
        "status")
            cd "$MINER_DIR" 2>/dev/null && ./start-mining.sh status || echo -e "${RED}Miner not installed${NC}"
            ;;
        "stop")
            cd "$MINER_DIR" 2>/dev/null && ./start-mining.sh stop || echo -e "${YELLOW}No mining process found${NC}"
            ;;
        "logs")
            cd "$MINER_DIR" 2>/dev/null && ./start-mining.sh logs || echo -e "${RED}No logs available${NC}"
            ;;
        "uninstall")
            echo -e "${YELLOW}Removing RTM mining setup...${NC}"
            pkill -f cpuminer 2>/dev/null || true
            screen -S rtm-mining -X quit 2>/dev/null || true
            rm -rf "$MINER_DIR" "$LOG_DIR"
            echo -e "${GREEN}✓ RTM mining setup removed${NC}"
            ;;
        "help"|*)
            echo -e "${PURPLE}RTM Mining Setup Script${NC}"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo -e "${BLUE}Setup Commands:${NC}"
            echo "  install      - Install and setup RTM miner (first time)"
            echo "  uninstall    - Remove RTM mining setup"
            echo ""
            echo -e "${BLUE}Mining Commands:${NC}"
            echo "  start        - Start mining (foreground)"
            echo "  screen       - Start mining in background"
            echo "  stop         - Stop mining"
            echo "  status       - Show mining status"
            echo "  logs         - Show live mining logs"
            echo ""
            echo -e "${BLUE}Configuration:${NC}"
            echo "  Wallet: $RTM_WALLET"
            echo "  Pool: $POOL_PRIMARY"
            echo "  Miner: Wyvern CPU Miner (GhostRider optimized)"
            echo ""
            echo -e "${YELLOW}Examples:${NC}"
            echo "  $0 install       # First-time setup"
            echo "  $0 screen        # Start mining in background"
            echo "  $0 status        # Check if mining"
            echo "  $0 stop          # Stop mining"
            ;;
    esac
}

# Run main function
main "$@"
