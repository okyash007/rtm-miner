#!/bin/bash

# RTM Mining VM Monitor Script
# Monitor your VM miner status remotely

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration - UPDATE THESE VALUES (same as deploy-to-vm.sh)
VM_IP="YOUR_VM_IP_ADDRESS"
VM_USER="YOUR_VM_USERNAME"
VM_PATH="/home/$VM_USER/rtm-mining"

# Check if VM details are configured
if [[ "$VM_IP" == "YOUR_VM_IP_ADDRESS" || "$VM_USER" == "YOUR_VM_USERNAME" ]]; then
    echo -e "${RED}ERROR: Please configure VM_IP and VM_USER in this script${NC}"
    echo "Edit both deploy-to-vm.sh and monitor-vm.sh with your VM details"
    exit 1
fi

show_help() {
    echo "RTM Mining VM Monitor"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status    - Show mining status (default)"
    echo "  start     - Start mining on VM"
    echo "  stop      - Stop mining on VM"
    echo "  restart   - Restart mining on VM"
    echo "  logs      - Show live mining logs"
    echo "  stats     - Show detailed mining statistics"
    echo "  deploy    - Deploy configuration to VM"
    echo ""
}

check_vm_connection() {
    if ! ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "echo 'connected'" &>/dev/null; then
        echo -e "${RED}ERROR: Cannot connect to VM $VM_IP${NC}"
        echo "Please check VM is running and SSH access is configured"
        exit 1
    fi
}

show_status() {
    echo -e "${BLUE}=== RTM Mining VM Status ===${NC}"
    echo -e "${BLUE}VM: $VM_USER@$VM_IP${NC}"
    echo ""
    
    check_vm_connection
    
    # Check if mining process is running
    if ssh "$VM_USER@$VM_IP" "pgrep -f 'cpuminer' > /dev/null"; then
        echo -e "${GREEN}✓ Mining process is RUNNING${NC}"
        
        # Get process info
        PROCESS_INFO=$(ssh "$VM_USER@$VM_IP" "ps aux | grep cpuminer | grep -v grep | head -1")
        if [[ -n "$PROCESS_INFO" ]]; then
            echo -e "${BLUE}Process: ${NC}$PROCESS_INFO"
        fi
        
        # Show recent mining activity
        echo ""
        echo -e "${YELLOW}Recent mining activity:${NC}"
        ssh "$VM_USER@$VM_IP" "cd $VM_PATH && tail -10 mining-daemon.log 2>/dev/null | grep -E '(Accepted|H/s|Stratum)' | tail -5" || echo "No recent logs found"
        
    else
        echo -e "${RED}✗ Mining process is NOT RUNNING${NC}"
    fi
    
    # Show system info
    echo ""
    echo -e "${YELLOW}VM System Info:${NC}"
    ssh "$VM_USER@$VM_IP" "echo 'CPU Cores: '$(nproc) && echo 'Load Average: '$(uptime | awk -F'load average:' '{print \$2}') && echo 'Memory: '$(free -h | grep Mem | awk '{print \$3\"/\"\$2}')"
}

start_mining() {
    echo -e "${BLUE}Starting mining on VM...${NC}"
    check_vm_connection
    
    ssh "$VM_USER@$VM_IP" "cd $VM_PATH && nohup ./start-mining.sh > mining-daemon.log 2>&1 &"
    sleep 3
    show_status
}

stop_mining() {
    echo -e "${BLUE}Stopping mining on VM...${NC}"
    check_vm_connection
    
    ssh "$VM_USER@$VM_IP" "pkill -f cpuminer"
    echo -e "${GREEN}Mining stopped${NC}"
}

restart_mining() {
    stop_mining
    sleep 2
    start_mining
}

show_logs() {
    echo -e "${BLUE}=== Live Mining Logs (Ctrl+C to exit) ===${NC}"
    check_vm_connection
    
    ssh "$VM_USER@$VM_IP" "cd $VM_PATH && tail -f mining-daemon.log 2>/dev/null || echo 'No logs found. Start mining first.'"
}

show_stats() {
    echo -e "${BLUE}=== Detailed Mining Statistics ===${NC}"
    check_vm_connection
    
    # Mining process details
    echo -e "${YELLOW}Mining Process:${NC}"
    ssh "$VM_USER@$VM_IP" "ps aux | grep cpuminer | grep -v grep || echo 'Not running'"
    
    echo ""
    echo -e "${YELLOW}Network Connections:${NC}"
    ssh "$VM_USER@$VM_IP" "netstat -tn | grep 3052 || echo 'No pool connections found'"
    
    echo ""
    echo -e "${YELLOW}Recent Performance (last 20 lines):${NC}"
    ssh "$VM_USER@$VM_IP" "cd $VM_PATH && tail -20 mining-daemon.log 2>/dev/null | grep -E '(H/s|Accepted|yes!)' || echo 'No performance data found'"
    
    echo ""
    echo -e "${YELLOW}Configuration Check:${NC}"
    echo "Wallet: RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU"
    echo "Pool: rtm-stratum.pukkapool.com:3052"
}

deploy_to_vm() {
    echo -e "${BLUE}Deploying to VM...${NC}"
    ./deploy-to-vm.sh
}

# Main script logic
case "${1:-status}" in
    "status"|"")
        show_status
        ;;
    "start")
        start_mining
        ;;
    "stop")
        stop_mining
        ;;
    "restart")
        restart_mining
        ;;
    "logs")
        show_logs
        ;;
    "stats")
        show_stats
        ;;
    "deploy")
        deploy_to_vm
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
