#!/bin/bash

# Simple RTM Mining Start Script
# Edit the variables below with your details

# Your RTM wallet address (CHANGE THIS!)
RTM_WALLET="YOUR_RTM_WALLET_ADDRESS_HERE"

# Mining pool (change if needed)
POOL_URL="stratum+tcp://pool.raptoreum.com:3333"

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

