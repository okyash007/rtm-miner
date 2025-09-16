#!/bin/bash

# Simple RTM Mining Start Script
# Edit the variables below with your details

# Your RTM wallet address (CHANGE THIS!)
RTM_WALLET="RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU"

# Mining pool (change if needed) - MUST match your dashboard pool
POOL_URL="stratum+tcp://rtm-stratum.pukkapool.com:3052"

# Number of CPU threads (0 = auto-detect all cores)
THREADS=0

# Start mining
echo "Starting RTM mining..."
echo "Wallet: $RTM_WALLET"
echo "Pool: $POOL_URL"
echo "Threads: $THREADS"
echo ""

cd ../miners/cpuminer-opt
./cpuminer -a gr -o $POOL_URL -u $RTM_WALLET -t $THREADS

