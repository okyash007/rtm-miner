# RTM (Raptoreum) Mining Setup

**Working solution using Wyvern CPU Miner with GhostRider algorithm support**

## 🚀 Quick Start

### **Step 1: Copy script to your Ubuntu VM**
Transfer `rtm-mining-setup.sh` to your Ubuntu VM

### **Step 2: Install everything**
```bash
chmod +x rtm-mining-setup.sh
./rtm-mining-setup.sh install
```

### **Step 3: Start mining**
```bash
# Start mining in background
./rtm-mining-setup.sh screen

# OR start mining in foreground
./rtm-mining-setup.sh start
```

## 📋 Management Commands

```bash
./rtm-mining-setup.sh status    # Check mining status
./rtm-mining-setup.sh logs      # View live logs
./rtm-mining-setup.sh stop      # Stop mining
./rtm-mining-setup.sh help      # Show all options
```

## ⚡ Direct Mining Commands

```bash
cd ~/cpuminer-gr-avx2

# Quick start (uses all CPU cores)
./quick-start.sh

# Manual control
./cpuminer -a gr -o stratum+tcp://rtm-stratum.pukkapool.com:3052 -u YOUR_WALLET -t 0

# Background mining
./start-mining.sh screen
```

## 🔧 Configuration

### **Wallet Address**
Edit the wallet address in `rtm-mining-setup.sh`:
```bash
RTM_WALLET="YOUR_RTM_WALLET_ADDRESS"
```

### **Pool Settings**
- **Primary**: `rtm-stratum.pukkapool.com:3052`
- **Backup**: `pool.raptoreum.com:3333`

### **Thread Configuration**
- `-t 0` = Use all CPU cores (maximum performance)
- `-t 4` = Use 4 cores (balanced)
- `-t 2` = Use 2 cores (minimal impact)

## 📊 Expected Performance

- **AMD EPYC 7713**: ~66.8 H/s per thread
- **Auto-tuning**: First run optimizes for ~154 minutes
- **Algorithm**: GhostRider (gr) - specifically for RTM

## ✅ What This Setup Provides

1. **✅ Working GhostRider Algorithm** - Wyvern CPU Miner with RTM support
2. **✅ Automatic Tuning** - Optimizes performance for your specific CPU
3. **✅ Background Mining** - Screen sessions for persistent mining
4. **✅ Easy Management** - Simple start/stop/status commands
5. **✅ Logging** - All mining activity logged for monitoring

## 🔍 Troubleshooting

### **If mining doesn't start:**
```bash
cd ~/cpuminer-gr-avx2
./cpuminer --help | grep "Ghost Rider"
```

### **Check system resources:**
```bash
htop              # Monitor CPU usage
free -h           # Check RAM usage
sensors           # Check CPU temperature (if lm-sensors installed)
```

### **View mining logs:**
```bash
tail -f ~/rtm-logs/mining.log
```

## 📝 Mining Pool Information

### **PukkaPool (Primary)**
- **URL**: `stratum+tcp://rtm-stratum.pukkapool.com:3052`
- **Fee**: Low fees, reliable
- **Location**: Multiple regions

### **Official Raptoreum Pool (Backup)**
- **URL**: `stratum+tcp://pool.raptoreum.com:3333`
- **Fee**: Official pool
- **Location**: Global

## ⚠️ Important Notes

1. **Replace wallet address** with your actual RTM wallet
2. **Monitor CPU temperatures** during mining
3. **First run takes ~154 minutes** for auto-tuning
4. **Use screen sessions** for persistent mining
5. **Check pool status** if connection issues occur

## 🎯 Why This Works

- **Wyvern CPU Miner**: Specifically designed for RTM GhostRider
- **Complete GhostRider Implementation**: Unlike public cpuminer-opt
- **Optimized for Modern CPUs**: AVX2, VAES, SHA support
- **Auto-tuning**: Finds optimal settings for your hardware

---

**Previous scripts (deprecated):**
- ~~`ubuntu-vm-mining-script.sh`~~ - Removed (cpuminer-opt doesn't work)
- ~~`ubuntu-vm-setup-commands.md`~~ - Removed (outdated instructions)
- ~~`start-mining.sh`~~ - Deprecated (points to new script)
- ~~`setup/install-ubuntu.sh`~~ - Deprecated (points to new script)
