# 🖥️ System Health Monitor

A production-ready bash script for monitoring Linux system health metrics with real-time alerts, logging, and HTML reporting.

![System Health Monitor](https://img.shields.io/badge/bash-5.0%2B-green)
![License](https://img.shields.io/badge/license-MIT-blue)


## ✨ Features

- **Real-time Monitoring**: CPU, Memory, Disk, and Service status checks
- **Color-coded Alerts**: Visual indicators (Green/Yellow/Red) based on thresholds
- **Automated Logging**: Daily timestamped logs for historical tracking
- **HTML Reports**: Beautiful web-based dashboards
- **Flexible CLI**: Command-line arguments for customization
- **Service Monitoring**: Track critical system services (ssh, cron, NetworkManager)

## 🚀 Quick Start
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/system-health-monitor.git
cd system-health-monitor

# Make executable
chmod +x system_health.sh

# Run
./system_health.sh
```

## 📋 Requirements

- Linux (Ubuntu/Debian/Kali/Fedora)
- Bash 4.0+
- Standard utilities: `top`, `free`, `df`, `systemctl`

## 🎯 Usage

### Basic Usage
```bash
./system_health.sh
```

### Available Options
```bash
./system_health.sh --help              # Show help
./system_health.sh --report-only       # Generate HTML only
./system_health.sh --no-log           # Skip logging
./system_health.sh --cpu-threshold 90  # Custom threshold
```

### Examples
```bash
# Run with custom thresholds
./system_health.sh --cpu-threshold 90 --mem-threshold 85

# Generate report without terminal output
./system_health.sh --report-only

# Run without logging
./system_health.sh --no-log
```

## 📊 What It Monitors

| Component | Metrics | Thresholds |
|-----------|---------|------------|
| **CPU** | Usage percentage | <70% Good, 70-89% Warning, ≥90% Critical |
| **Memory** | RAM utilization | <70% Good, 70-89% Warning, ≥90% Critical |
| **Disk** | Space usage per partition | <70% Good, 70-89% Warning, ≥90% Critical |
| **Services** | Status of critical services | Running/Not Running |

## 📁 Project Structure
```
system-health-monitor/
├── system_health.sh      # Main script
├── logs/                 # Daily log files
│   └── health_YYYY-MM-DD.log
├── reports/              # HTML reports
│   └── health_report_YYYY-MM-DD_HH-MM-SS.html
├── README.md
└── screenshots/
    ├── terminal.png
    └── html-report.png
```

## 🔧 Configuration

Edit these variables at the top of `system_health.sh`:
```bash
# Thresholds (percentage)
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Services to monitor
SERVICES=("ssh" "cron" "NetworkManager")
```

## 📝 Output Examples

### Terminal Output
```
==========================================
    SYSTEM HEALTH MONITOR
    Date: Wed Feb 26 13:19:58 GMT 2026
==========================================

checking cpu usage....
CPU USAGE: 1% [GOOD]
checking memory usage....
Memory Usage: 4739MB / 15723MB (30%) [GOOD]
checking disk usage....
  /: 303G/452G (71%) [Warning]
  /boot/efi: 4.3M/975M (1%) [GOOD]
checking critical services....
 ssh is not running
 cron is running
 NetworkManager is running

Health check complete!
```

### Log File (`logs/health_2026-02-26.log`)
```
[2026-02-26 13:19:58] ==========================================
[2026-02-26 13:19:58] SYSTEM HEALTH CHECK STARTED
[2026-02-26 13:19:58] CPU Usage: 1% [GOOD]
[2026-02-26 13:19:58] Memory Usage: 4739MB / 15723MB (30%) [GOOD]
[2026-02-26 13:19:58] Disk /: 303G/452G (71%) [Warning]
[2026-02-26 13:19:58] Service ssh: NOT RUNNING
[2026-02-26 13:19:58] Health check completed
```

## 🎓 What I Learned

Building this project taught me:
- Bash scripting fundamentals (variables, loops, functions, arguments)
- System monitoring with `top`, `free`, `df`, and `systemctl`
- Text processing with `awk`, `sed`, and `grep`
- HTML generation with here-documents
- Error handling and logging best practices
- Command-line argument parsing

## 🚀 Future Enhancements

- [ ] Email alerts for critical thresholds
- [ ] Integration with monitoring platforms (Prometheus)
- [ ] Database storage for historical data
- [ ] API endpoint for remote monitoring
- [ ] Docker containerization
- [ ] Custom notification channels (Slack, Discord)

## 📄 License

MIT License - feel free to use and modify

## 👤 Author

**Siddharth**
- GitHub: (https://github.com/mr-ionator)
- LinkedIn: (https://linkedin.com/in/siddharth-verma-697794251/)
---

**⭐ If you find this useful, please star the repo!**
