# RTM (Raptoreum) Mining Setup Commands for Ubuntu VM

## 1. Initial System Setup

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential dependencies
sudo apt install -y build-essential libssl-dev libcurl4-openssl-dev libjansson-dev \
    libgmp-dev automake autotools-dev libtool pkg-config wget curl git htop \
    screen unzip libc6-dev libstdc++6 libgcc-s1 zlib1g-dev

# Check CPU capabilities (important for RTM mining)
cat /proc/cpuinfo | grep -E "(sse2|aes|avx)"
```

## 2. Download cpuminer-opt for RTM

```bash
# Create mining directory
mkdir -p ~/rtm-mining
cd ~/rtm-mining

# Download the latest cpuminer-opt release (Linux x64)
wget https://github.com/JayDDee/cpuminer-opt/releases/download/v3.21.0/cpuminer-opt-3.21.0-linux.tar.gz

# Extract the files
tar -xzf cpuminer-opt-3.21.0-linux.tar.gz
cd cpuminer-opt-3.21.0

# Make the binary executable
chmod +x cpuminer

# Test if it works
./cpuminer --help
```

## 3. Basic Mining Command (GhostRider Algorithm)

```bash
# Replace YOUR_RTM_WALLET_ADDRESS with your actual Raptoreum wallet address
./cpuminer -a gr -o stratum+tcp://pool.raptoreum.com:3333 -u YOUR_RTM_WALLET_ADDRESS -t 0
```

## 4. Optimized Mining Commands

### For Maximum Performance (All CPU cores)
```bash
./cpuminer -a gr -o stratum+tcp://rtm-stratum.pukkapool.com:3052 -u RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU -t 0 --cpu-priority=5
```

### For Balanced Usage (Leave some CPU for system)
```bash
# Use 75% of CPU cores (adjust based on your VM specs)
CORES=$(nproc)
MINING_THREADS=$((CORES * 3 / 4))
./cpuminer -a gr -o stratum+tcp://rtm-stratum.pukkapool.com:3052 -u RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU -t $MINING_THREADS
```

## 5. Pool Options

### Primary Pool (PukkaPool - Recommended)
```bash
./cpuminer -a gr -o stratum+tcp://rtm-stratum.pukkapool.com:3052 -u YOUR_WALLET -t 0
```

### Official Raptoreum Pool
```bash
./cpuminer -a gr -o stratum+tcp://pool.raptoreum.com:3333 -u YOUR_WALLET -t 0
```

### Suprnova Pool
```bash
./cpuminer -a gr -o stratum+tcp://rtm.suprnova.cc:7019 -u YOUR_WALLET -t 0
```

## 6. Run Mining in Background (Recommended)

```bash
# Create a screen session for mining
screen -S rtm-mining

# Inside screen, run the miner
./cpuminer -a gr -o stratum+tcp://rtm-stratum.pukkapool.com:3052 -u RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU -t 0

# Detach from screen: Ctrl+A, then D
# Reattach later: screen -r rtm-mining
```

## 7. Create Automated Mining Script

```bash
# Create mining script
cat > ~/rtm-mining/start-mining.sh << 'EOF'
#!/bin/bash

# RTM Mining Configuration
WALLET="RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU"  # Replace with your wallet
POOL="stratum+tcp://rtm-stratum.pukkapool.com:3052"
THREADS=0  # 0 = auto-detect all cores
LOG_FILE="mining.log"

echo "Starting RTM Mining..."
echo "Wallet: $WALLET"
echo "Pool: $POOL"
echo "Threads: $THREADS"
echo "Log: $LOG_FILE"
echo "===================="

# Start mining with logging
./cpuminer -a gr -o $POOL -u $WALLET -t $THREADS --cpu-priority=5 2>&1 | tee $LOG_FILE
EOF

# Make it executable
chmod +x ~/rtm-mining/start-mining.sh

# Run the script
cd ~/rtm-mining/cpuminer-opt-3.21.0
../start-mining.sh
```

## 8. Monitor Mining Performance

```bash
# Check CPU usage
htop

# View mining logs
tail -f ~/rtm-mining/mining.log

# Check mining status
ps aux | grep cpuminer
```

## 9. System Optimization for Mining

```bash
# Increase VM performance (if applicable)
echo 'vm.swappiness=1' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_ratio=5' | sudo tee -a /etc/sysctl.conf

# Apply changes
sudo sysctl -p

# Set CPU governor to performance (if available)
sudo apt install -y cpufrequtils
sudo cpufreq-set -g performance
```

## 10. Important Notes

### Wallet Address
- Replace `RBg88PoU3GLTV9UqfkqCHSZ5ncoMWWQ7zU` with your actual Raptoreum wallet address
- Get a wallet from: https://raptoreum.com/wallet/

### Algorithm
- Always use `-a gr` for Raptoreum (GhostRider algorithm)
- This is specific to RTM and won't work with other algorithms

### Thread Count
- `-t 0` = Use all CPU cores (maximum performance)
- `-t 1` = Use 1 core (minimal impact on system)
- `-t $(nproc)` = Use all available cores explicitly

### CPU Priority
- `--cpu-priority=5` = Highest priority (may impact system responsiveness)
- `--cpu-priority=0` = Normal priority (default)

## 11. Troubleshooting

### If miner doesn't start:
```bash
# Check dependencies
ldd ./cpuminer

# Install missing libraries if needed
sudo apt install -y libc6 libgcc-s1 libssl1.1 libcurl4
```

### If getting connection errors:
```bash
# Test pool connectivity
telnet rtm-stratum.pukkapool.com 3052
```

### Performance Issues:
```bash
# Check CPU temperature
sudo apt install -y lm-sensors
sensors

# Monitor system resources
htop
iostat 1
```

## 12. Expected Output

When mining successfully, you should see output like:
```
[2024-01-01 12:00:00] CPU #0: 125.5 H/s
[2024-01-01 12:00:00] CPU #1: 128.2 H/s
[2024-01-01 12:00:00] Total: 253.7 H/s
[2024-01-01 12:00:05] Accepted 1/1 (100.00%), 253.7 H/s
```

## Quick Start Command (Copy & Paste Ready)

```bash
# Complete setup in one go
cd ~
mkdir rtm-mining && cd rtm-mining
wget https://github.com/JayDDee/cpuminer-opt/releases/download/v3.21.0/cpuminer-opt-3.21.0-linux.tar.gz
tar -xzf cpuminer-opt-3.21.0-linux.tar.gz
cd cpuminer-opt-3.21.0
chmod +x cpuminer

# Start mining (replace YOUR_WALLET with your actual wallet address)
./cpuminer -a gr -o stratum+tcp://rtm-stratum.pukkapool.com:3052 -u YOUR_WALLET_ADDRESS -t 0
```

Remember to:
1. Replace wallet addresses with your own
2. Monitor CPU temperatures during mining
3. Consider using screen/tmux for persistent mining sessions
4. Check pool status and switch if needed
