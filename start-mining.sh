#!/bin/bash

# RTM Mining Script with Live Logging

RTM_WALLET="RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU"
POOL="stratum+tcp://pool.raptoreum.com:3333"

echo "=== RTM Mining Started ==="
echo "Wallet: $RTM_WALLET"
echo "Pool: $POOL"
echo "Time: $(date)"
echo "=========================="
echo ""

# Start mining with live output (no log file, direct to terminal)
./cpuminer -a gr -o $POOL -u $RTM_WALLET -t 0
