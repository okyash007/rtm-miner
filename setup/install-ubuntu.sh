#!/bin/bash

# RTM Mining Setup - Ubuntu/Debian Installation Script
# This script installs all dependencies and sets up RTM mining on Ubuntu/Debian systems

set -e

echo "=== RTM Mining Setup for Ubuntu/Debian ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Error: Do not run this script as root${NC}"
    echo "Run as a regular user. The script will use sudo when needed."
    exit 1
fi

# Check if running on supported system
if ! command -v apt &> /dev/null; then
    echo -e "${RED}Error: This script is for Ubuntu/Debian systems only${NC}"
    exit 1
fi

echo -e "${BLUE}Updating package lists...${NC}"
sudo apt update

echo -e "${BLUE}Installing essential dependencies...${NC}"
sudo apt install -y \
    build-essential \
    libssl-dev \
    libcurl4-openssl-dev \
    libjansson-dev \
    libgmp-dev \
    automake \
    autotools-dev \
    libtool \
    pkg-config \
    wget \
    curl \
    git \
    htop \
    screen \
    unzip

echo -e "${BLUE}Installing additional libraries for cpuminer-opt...${NC}"
sudo apt install -y \
    libc6-dev \
    libstdc++6 \
    libgcc-s1 \
    zlib1g-dev

# Check CPU capabilities
echo -e "${BLUE}Checking CPU capabilities...${NC}"
CPU_INFO=$(cat /proc/cpuinfo)

if echo "$CPU_INFO" | grep -q "sse2"; then
    echo -e "${GREEN}✓ SSE2 support detected${NC}"
else
    echo -e "${RED}✗ SSE2 support not found - your CPU may not be compatible${NC}"
fi

if echo "$CPU_INFO" | grep -q "aes"; then
    echo -e "${GREEN}✓ AES-NI support detected${NC}"
else
    echo -e "${YELLOW}! AES-NI support not found - reduced performance expected${NC}"
fi

if echo "$CPU_INFO" | grep -q "avx2"; then
    echo -e "${GREEN}✓ AVX2 support detected${NC}"
elif echo "$CPU_INFO" | grep -q "avx"; then
    echo -e "${GREEN}✓ AVX support detected${NC}"
else
    echo -e "${YELLOW}! AVX support not found - reduced performance expected${NC}"
fi

# Check RAM
echo -e "${BLUE}Checking system RAM...${NC}"
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$RAM_GB" -ge 16 ]; then
    echo -e "${GREEN}✓ RAM: ${RAM_GB}GB (sufficient)${NC}"
elif [ "$RAM_GB" -ge 8 ]; then
    echo -e "${YELLOW}! RAM: ${RAM_GB}GB (minimum, 16GB+ recommended)${NC}"
else
    echo -e "${RED}✗ RAM: ${RAM_GB}GB (insufficient, 16GB+ required)${NC}"
fi

# Note: This script is deprecated. Use rtm-mining-setup.sh instead
echo -e "${YELLOW}⚠️  This script is deprecated.${NC}"
echo -e "${YELLOW}Use the new automated script: rtm-mining-setup.sh${NC}"
echo -e "${GREEN}Run: ./rtm-mining-setup.sh install${NC}"
exit 1

# Create mining user (optional but recommended)
echo -e "${BLUE}Setting up mining environment...${NC}"

# Create systemd service file
echo -e "${BLUE}Creating systemd service template...${NC}"
sudo tee /etc/systemd/system/rtm-mining@.service > /dev/null << 'EOF'
[Unit]
Description=RTM Mining Service for %i
After=network.target

[Service]
Type=simple
User=%i
WorkingDirectory=/home/%i/mine
ExecStart=/home/%i/mine/scripts/start-mining.sh
ExecStop=/home/%i/mine/scripts/stop-mining.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=rtm-mining

[Install]
WantedBy=multi-user.target
EOF

# Set up log rotation
echo -e "${BLUE}Setting up log rotation...${NC}"
sudo tee /etc/logrotate.d/rtm-mining > /dev/null << 'EOF'
/home/*/mine/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644
    copytruncate
}
EOF

# Set up mining directory permissions
echo -e "${BLUE}Setting up directory permissions...${NC}"
cd /Users/yashverma/Desktop/yash/mine
chmod +x setup/*.sh
chmod +x scripts/*.sh 2>/dev/null || true

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Next steps:"
echo "1. Get your Raptoreum wallet address"
echo "2. Edit miners/config.json with your wallet address"
echo "3. Choose a mining pool (see docs/pools.md)"
echo "4. Run: ./scripts/start-mining.sh"
echo ""
echo "Optional - Enable as system service:"
echo "sudo systemctl enable rtm-mining@$(whoami)"
echo "sudo systemctl start rtm-mining@$(whoami)"
echo ""
echo "Monitor mining:"
echo "tail -f logs/mining.log"
echo "htop"
echo ""
echo -e "${YELLOW}Important: Monitor CPU temperatures during mining!${NC}"

