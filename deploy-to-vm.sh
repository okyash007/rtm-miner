#!/bin/bash

# RTM Mining VM Deployment Script
# This script deploys your mining configuration to your VM

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== RTM Mining VM Deployment ===${NC}"
echo ""

# Configuration - UPDATE THESE VALUES
VM_IP="YOUR_VM_IP_ADDRESS"
VM_USER="YOUR_VM_USERNAME"
VM_PATH="/home/$VM_USER/rtm-mining"

# Check if VM details are configured
if [[ "$VM_IP" == "YOUR_VM_IP_ADDRESS" || "$VM_USER" == "YOUR_VM_USERNAME" ]]; then
    echo -e "${RED}ERROR: Please configure VM_IP and VM_USER in this script${NC}"
    echo ""
    echo "Edit this file and set:"
    echo "VM_IP=\"192.168.1.100\"  # Your VM's IP address"
    echo "VM_USER=\"ubuntu\"       # Your VM username"
    exit 1
fi

echo -e "${BLUE}Target VM: $VM_USER@$VM_IP${NC}"
echo -e "${BLUE}Remote path: $VM_PATH${NC}"
echo ""

# Test SSH connection
echo -e "${YELLOW}Testing SSH connection...${NC}"
if ! ssh -o ConnectTimeout=5 "$VM_USER@$VM_IP" "echo 'SSH connection successful'" 2>/dev/null; then
    echo -e "${RED}ERROR: Cannot connect to VM${NC}"
    echo "Please ensure:"
    echo "1. VM is running and accessible"
    echo "2. SSH key is set up (run: ssh-copy-id $VM_USER@$VM_IP)"
    echo "3. VM IP address is correct"
    exit 1
fi

echo -e "${GREEN}✓ SSH connection successful${NC}"

# Create remote directory
echo -e "${YELLOW}Creating remote directory...${NC}"
ssh "$VM_USER@$VM_IP" "mkdir -p $VM_PATH/{miners,scripts,setup,logs}"

# Copy files to VM
echo -e "${YELLOW}Copying configuration files...${NC}"
scp -r miners/ "$VM_USER@$VM_IP:$VM_PATH/"
scp -r scripts/ "$VM_USER@$VM_IP:$VM_PATH/"
scp -r setup/ "$VM_USER@$VM_IP:$VM_PATH/"

echo -e "${YELLOW}Copying mining scripts...${NC}"
scp start-mining.sh "$VM_USER@$VM_IP:$VM_PATH/"

# Make scripts executable
echo -e "${YELLOW}Setting permissions...${NC}"
ssh "$VM_USER@$VM_IP" "chmod +x $VM_PATH/*.sh $VM_PATH/scripts/*.sh $VM_PATH/setup/*.sh"

# Check if cpuminer exists, if not, guide user to download it
echo -e "${YELLOW}Checking for cpuminer...${NC}"
if ! ssh "$VM_USER@$VM_IP" "test -f $VM_PATH/miners/cpuminer-opt/cpuminer"; then
    echo -e "${YELLOW}cpuminer not found. Setting up...${NC}"
    
    # Run the download script
    ssh "$VM_USER@$VM_IP" "cd $VM_PATH/setup && ./download-miner.sh"
    
    if ! ssh "$VM_USER@$VM_IP" "test -f $VM_PATH/miners/cpuminer-opt/cpuminer"; then
        echo -e "${RED}WARNING: cpuminer installation failed${NC}"
        echo "Please manually download cpuminer-opt to your VM:"
        echo "1. SSH to your VM: ssh $VM_USER@$VM_IP"
        echo "2. Go to mining directory: cd $VM_PATH"
        echo "3. Run setup: ./setup/download-miner.sh"
    fi
fi

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo ""
echo "Next steps:"
echo "1. SSH to your VM: ssh $VM_USER@$VM_IP"
echo "2. Go to mining directory: cd $VM_PATH"
echo "3. Start mining: ./start-mining.sh"
echo ""
echo "Or use the monitoring script: ./monitor-vm.sh"
