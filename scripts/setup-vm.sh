#!/bin/bash

# Quick RTM Mining Setup for Linux VM

echo "=== RTM Mining VM Setup ==="

# Install basic dependencies
sudo apt update
sudo apt install -y wget curl build-essential

# Download cpuminer-opt (you'll need to get the latest release URL)
mkdir -p ../miners/cpuminer-opt
cd ../miners/cpuminer-opt

# Download latest release (check GitHub for current URL)
echo "Download cpuminer-opt from: https://github.com/Raptor3um/cpuminer-opt/releases"
echo "Save it as 'cpuminer' in this directory"
echo "Then run: chmod +x cpuminer"

echo ""
echo "Next steps:"
echo "1. Download cpuminer-opt binary"
echo "2. Edit scripts/start-mining.sh with your RTM wallet address"
echo "3. Run: ./scripts/start-mining.sh"

