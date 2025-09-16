#!/bin/bash

# RTM (Raptoreum) Mining Script for Ubuntu VM
# Optimized for GhostRider algorithm with automatic configuration

set -e

# Configuration
RTM_WALLET="RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU"  # Replace with your wallet
POOL_PRIMARY="stratum+tcp://rtm-stratum.pukkapool.com:3052"
POOL_BACKUP="stratum+tcp://pool.raptoreum.com:3333"
ALGORITHM="gr"  # GhostRider for Raptoreum
LOG_DIR="$HOME/rtm-logs"
MINER_DIR="$HOME/rtm-mining"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create directories
mkdir -p "$LOG_DIR"
mkdir -p "$MINER_DIR"

show_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}    RTM Mining Script for Ubuntu VM   ${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
}

check_system() {
    echo -e "${BLUE}Checking system requirements...${NC}"
    
    # Check CPU cores
    CPU_CORES=$(nproc)
    echo -e "${GREEN}✓ CPU Cores: $CPU_CORES${NC}"
    
    # Check RAM
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$RAM_GB" -ge 8 ]; then
        echo -e "${GREEN}✓ RAM: ${RAM_GB}GB (sufficient)${NC}"
    else
        echo -e "${YELLOW}! RAM: ${RAM_GB}GB (8GB+ recommended for optimal performance)${NC}"
    fi
    
    # Check CPU features
    CPU_INFO=$(cat /proc/cpuinfo)
    if echo "$CPU_INFO" | grep -q "sse2"; then
        echo -e "${GREEN}✓ SSE2 support detected${NC}"
    else
        echo -e "${RED}✗ SSE2 support missing - mining may not work${NC}"
        exit 1
    fi
    
    if echo "$CPU_INFO" | grep -q "aes"; then
        echo -e "${GREEN}✓ AES-NI support detected${NC}"
    else
        echo -e "${YELLOW}! AES-NI not found - reduced performance expected${NC}"
    fi
    
    echo ""
}

install_dependencies() {
    echo -e "${BLUE}Installing dependencies...${NC}"
    
    # Update package list
    sudo apt update
    
    # Install required packages
    sudo apt install -y \
        wget curl unzip \
        build-essential \
        libssl-dev \
        libcurl4-openssl-dev \
        libjansson-dev \
        libgmp-dev \
        screen htop
    
    echo -e "${GREEN}✓ Dependencies installed${NC}"
    echo ""
}

download_miner() {
    echo -e "${BLUE}Downloading cpuminer-opt...${NC}"
    
    cd "$MINER_DIR"
    
    # Download latest cpuminer-opt
    MINER_URL="https://github.com/JayDDee/cpuminer-opt/releases/download/v3.21.0/cpuminer-opt-3.21.0-linux.tar.gz"
    
    if [ ! -f "cpuminer" ]; then
        wget -O cpuminer-opt.tar.gz "$MINER_URL"
        tar -xzf cpuminer-opt.tar.gz --strip-components=1
        chmod +x cpuminer
        rm cpuminer-opt.tar.gz
    fi
    
    # Test miner
    if ./cpuminer --help > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Miner downloaded and ready${NC}"
    else
        echo -e "${RED}✗ Miner test failed${NC}"
        exit 1
    fi
    
    echo ""
}

calculate_optimal_threads() {
    local cpu_cores=$(nproc)
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    
    # RTM (GhostRider) is memory-intensive
    # Optimal: 1 thread per 2GB RAM, but not more than CPU cores
    local ram_threads=$((ram_gb / 2))
    local optimal_threads=$cpu_cores
    
    if [ $ram_threads -lt $cpu_cores ]; then
        optimal_threads=$ram_threads
    fi
    
    # Minimum 1 thread
    if [ $optimal_threads -lt 1 ]; then
        optimal_threads=1
    fi
    
    echo $optimal_threads
}

start_mining() {
    local pool="$1"
    local threads="$2"
    local log_file="$3"
    
    echo -e "${BLUE}Starting RTM mining...${NC}"
    echo "Wallet: $RTM_WALLET"
    echo "Pool: $pool"
    echo "Algorithm: $ALGORITHM"
    echo "Threads: $threads"
    echo "Log: $log_file"
    echo ""
    
    # Start mining
    cd "$MINER_DIR"
    ./cpuminer \
        -a "$ALGORITHM" \
        -o "$pool" \
        -u "$RTM_WALLET" \
        -p x \
        -t "$threads" \
        --cpu-priority=3 \
        --retry-pause=10 \
        --max-temp=85 \
        2>&1 | tee "$log_file"
}

main() {
    show_header
    
    # Parse command line arguments
    local action="${1:-start}"
    local use_backup_pool="${2:-false}"
    
    case "$action" in
        "install")
            check_system
            install_dependencies
            download_miner
            echo -e "${GREEN}Installation complete! Run './ubuntu-vm-mining-script.sh start' to begin mining.${NC}"
            ;;
            
        "start")
            check_system
            
            # Select pool
            local pool="$POOL_PRIMARY"
            if [ "$use_backup_pool" = "backup" ]; then
                pool="$POOL_BACKUP"
                echo -e "${YELLOW}Using backup pool${NC}"
            fi
            
            # Calculate optimal threads
            local threads=$(calculate_optimal_threads)
            echo -e "${BLUE}Calculated optimal threads: $threads${NC}"
            
            # Create log file with timestamp
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            local log_file="$LOG_DIR/mining_$timestamp.log"
            
            # Check if miner exists
            if [ ! -f "$MINER_DIR/cpuminer" ]; then
                echo -e "${YELLOW}Miner not found. Installing...${NC}"
                install_dependencies
                download_miner
            fi
            
            # Start mining
            start_mining "$pool" "$threads" "$log_file"
            ;;
            
        "screen")
            # Start mining in screen session
            echo -e "${BLUE}Starting mining in screen session...${NC}"
            
            local threads=$(calculate_optimal_threads)
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            local log_file="$LOG_DIR/mining_$timestamp.log"
            
            screen -dmS rtm-mining bash -c "
                cd '$MINER_DIR'
                ./cpuminer -a '$ALGORITHM' -o '$POOL_PRIMARY' -u '$RTM_WALLET' -p x -t $threads --cpu-priority=3 2>&1 | tee '$log_file'
            "
            
            echo -e "${GREEN}✓ Mining started in screen session 'rtm-mining'${NC}"
            echo "Use 'screen -r rtm-mining' to attach to the session"
            echo "Use 'screen -list' to see all sessions"
            ;;
            
        "status")
            if pgrep -f "cpuminer" > /dev/null; then
                echo -e "${GREEN}✓ Mining is running${NC}"
                ps aux | grep cpuminer | grep -v grep
                
                # Show latest log if available
                local latest_log=$(ls -t "$LOG_DIR"/mining_*.log 2>/dev/null | head -1)
                if [ -n "$latest_log" ]; then
                    echo ""
                    echo -e "${BLUE}Recent mining activity:${NC}"
                    tail -5 "$latest_log" | grep -E "(Accepted|H/s|Total)" || echo "No recent activity"
                fi
            else
                echo -e "${RED}✗ Mining is not running${NC}"
            fi
            ;;
            
        "stop")
            echo -e "${BLUE}Stopping mining...${NC}"
            pkill -f cpuminer || true
            screen -S rtm-mining -X quit 2>/dev/null || true
            echo -e "${GREEN}✓ Mining stopped${NC}"
            ;;
            
        "logs")
            local latest_log=$(ls -t "$LOG_DIR"/mining_*.log 2>/dev/null | head -1)
            if [ -n "$latest_log" ]; then
                echo -e "${BLUE}Showing latest mining log (Ctrl+C to exit):${NC}"
                tail -f "$latest_log"
            else
                echo -e "${RED}No log files found${NC}"
            fi
            ;;
            
        "help"|*)
            echo "RTM Mining Script for Ubuntu VM"
            echo ""
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  install          - Install dependencies and download miner"
            echo "  start            - Start mining (foreground)"
            echo "  start backup     - Start mining with backup pool"
            echo "  screen           - Start mining in screen session (background)"
            echo "  status           - Show mining status"
            echo "  stop             - Stop mining"
            echo "  logs             - Show live mining logs"
            echo "  help             - Show this help"
            echo ""
            echo "Configuration:"
            echo "  Wallet: $RTM_WALLET"
            echo "  Primary Pool: $POOL_PRIMARY"
            echo "  Backup Pool: $POOL_BACKUP"
            echo ""
            echo "Examples:"
            echo "  $0 install       # First-time setup"
            echo "  $0 screen        # Start mining in background"
            echo "  $0 status        # Check if mining is running"
            echo "  $0 stop          # Stop mining"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
