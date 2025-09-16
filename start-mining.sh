#!/bin/bash

# RTM Mining Control Script - All-in-One
# Usage: ./start-mining.sh [start|stop|status|logs|restart]

RTM_WALLET="RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU"
POOL="stratum+tcp://rtm-stratum.pukkapool.com:3052"
LOG_FILE="mining.log"
PID_FILE="mining.pid"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "RTM Mining Control Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start    - Start mining in background (default)"
    echo "  stop     - Stop mining"
    echo "  status   - Show mining status"
    echo "  logs     - Show live mining logs"
    echo "  restart  - Restart mining"
    echo ""
    echo "Configuration:"
    echo "  Wallet: $RTM_WALLET"
    echo "  Pool: $POOL"
}

start_mining() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo -e "${YELLOW}Mining is already running (PID: $(cat $PID_FILE))${NC}"
        return 1
    fi
    
    echo -e "${BLUE}=== Starting RTM Mining ===${NC}"
    echo "Wallet: $RTM_WALLET"
    echo "Pool: $POOL"
    echo "Time: $(date)"
    echo "Log: $LOG_FILE"
    echo "=========================="
    echo ""
    
    # Start mining in background
    nohup ./cpuminer -a gr -o $POOL -u $RTM_WALLET -t 0 > $LOG_FILE 2>&1 &
    echo $! > $PID_FILE
    
    echo -e "${GREEN}✓ Mining started (PID: $!)${NC}"
    echo "Use './start-mining.sh logs' to watch progress"
}

stop_mining() {
    echo -e "${BLUE}Stopping RTM mining...${NC}"
    
    # Kill cpuminer processes
    pkill -f cpuminer
    
    # Remove PID file
    rm -f "$PID_FILE"
    
    echo -e "${GREEN}✓ Mining stopped${NC}"
}

show_status() {
    echo -e "${BLUE}=== RTM Mining Status ===${NC}"
    
    if pgrep -f "cpuminer" > /dev/null; then
        PID=$(pgrep -f "cpuminer")
        echo -e "${GREEN}✓ Mining is RUNNING (PID: $PID)${NC}"
        
        # Show process info
        echo -e "${YELLOW}Process Info:${NC}"
        ps aux | grep cpuminer | grep -v grep | head -1
        
        # Show recent activity
        echo ""
        echo -e "${YELLOW}Recent Activity:${NC}"
        if [ -f "$LOG_FILE" ]; then
            tail -5 "$LOG_FILE" | grep -E "(Accepted|H/s|Stratum)" | tail -3 || echo "No recent mining activity"
        else
            echo "No log file found"
        fi
    else
        echo -e "${RED}✗ Mining is NOT RUNNING${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    echo "Wallet: $RTM_WALLET"
    echo "Pool: $POOL"
    echo "Log: $LOG_FILE"
}

show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "${BLUE}=== Live Mining Logs (Ctrl+C to exit) ===${NC}"
        tail -f "$LOG_FILE"
    else
        echo -e "${RED}No log file found. Start mining first.${NC}"
    fi
}

restart_mining() {
    stop_mining
    sleep 2
    start_mining
}

# Main script logic
case "${1:-start}" in
    "start"|"")
        start_mining
        ;;
    "stop")
        stop_mining
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "restart")
        restart_mining
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac
