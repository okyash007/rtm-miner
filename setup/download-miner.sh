#!/bin/bash

# RTM Mining Setup - Download cpuminer-opt
# This script downloads the latest official cpuminer-opt release for Raptoreum

set -e

echo "=== RTM Mining Setup - Downloading cpuminer-opt ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

echo -e "${BLUE}Detected system: $OS $ARCH${NC}"

# Check if system is supported
if [[ "$ARCH" != "x86_64" ]]; then
    echo -e "${RED}Error: Only x86_64 architecture is supported${NC}"
    echo "Your system: $ARCH"
    exit 1
fi

# Create miners directory if it doesn't exist
mkdir -p ../miners/cpuminer-opt
cd ../miners/cpuminer-opt

# GitHub repository for releases
REPO_URL="https://api.github.com/repos/Raptor3um/cpuminer-opt/releases/latest"

echo -e "${BLUE}Fetching latest release information...${NC}"

# Get latest release info
LATEST_RELEASE=$(curl -s $REPO_URL)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to fetch release information${NC}"
    echo "Please check your internet connection and try again"
    exit 1
fi

# Extract download URL based on OS
if [[ "$OS" == "Linux" ]]; then
    DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep -o '"browser_download_url": "[^"]*linux[^"]*"' | head -1 | sed 's/"browser_download_url": "//;s/"//')
    FILENAME="cpuminer-linux"
elif [[ "$OS" == "Darwin" ]]; then
    echo -e "${RED}Error: macOS is not supported by cpuminer-opt${NC}"
    echo "Please use a Linux system or Windows with WSL"
    exit 1
else
    echo -e "${RED}Error: Unsupported operating system: $OS${NC}"
    echo "Supported systems: Linux (64-bit)"
    exit 1
fi

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}Error: Could not find download URL for your system${NC}"
    echo "Please visit https://github.com/Raptor3um/cpuminer-opt/releases manually"
    exit 1
fi

echo -e "${GREEN}Found download URL: $DOWNLOAD_URL${NC}"
echo -e "${BLUE}Downloading cpuminer-opt...${NC}"

# Download the binary
wget -O cpuminer "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Download failed${NC}"
    echo "Please check your internet connection and try again"
    exit 1
fi

# Make executable
chmod +x cpuminer

# Verify the binary
echo -e "${BLUE}Verifying binary...${NC}"
if ./cpuminer --help > /dev/null 2>&1; then
    echo -e "${GREEN}✓ cpuminer-opt downloaded and verified successfully${NC}"
else
    echo -e "${YELLOW}Warning: Binary verification failed${NC}"
    echo "The binary may be missing dependencies"
    echo "Run: ldd cpuminer (on Linux) to check dependencies"
fi

echo ""
echo -e "${GREEN}=== Download Complete ===${NC}"
echo "Binary location: $(pwd)/cpuminer"
echo ""
echo "Next steps:"
echo "1. Set up your Raptoreum wallet"
echo "2. Choose a mining pool"
echo "3. Configure mining settings"
echo "4. Start mining!"
echo ""
echo -e "${YELLOW}Note: You may need to install additional libraries${NC}"
echo -e "${YELLOW}If you get library errors, run: sudo apt install build-essential${NC}"

