#!/bin/bash

####################################
# A health monitor for your system
# Author: mr-ionator
# Date: 27-01-2026
####################################


#color codes for output


RED='\e[31m'
GREEN='\e[32m'
YELLOW="\[33m"
NC="\e[0m"
SERVICES=("ssh" "cron" "NetworkManager")

#functions

# Default settings
SHOW_OUTPUT=true
ENABLE_LOGGING=true
GENERATE_HTML=true

# Help function
show_help() {
    cat << EOF
System Health Monitor - Usage:

./system_health.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -r, --report-only       Generate HTML report only (no terminal output)
    -n, --no-log            Skip logging to file
    -s, --silent            Silent mode (no HTML report)
    -c, --cpu-threshold N   Set CPU threshold (default: 80)
    -m, --mem-threshold N   Set memory threshold (default: 80)
    -d, --disk-threshold N  Set disk threshold (default: 80)

EXAMPLES:
    ./system_health.sh                      # Normal run
    ./system_health.sh --help               # Show help
    ./system_health.sh --report-only        # HTML only
    ./system_health.sh --cpu-threshold 90   # Custom threshold

EOF
    exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -r|--report-only)
            SHOW_OUTPUT=false
            shift
            ;;
        -n|--no-log)
            ENABLE_LOGGING=false
            shift
            ;;
        -s|--silent)
            GENERATE_HTML=false
            shift
            ;;
        -c|--cpu-threshold)
            CPU_THRESHOLD="$2"
            shift 2
            ;;
        -m|--mem-threshold)
            MEMORY_THRESHOLD="$2"
            shift 2
            ;;
        -d|--disk-threshold)
            DISK_THRESHOLD="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done


LOG_DIR="./.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/health_$(date +%Y-%m-%d).log"

log_message() {
	if [ "$ENABLE_LOGGING" = true ]; then
		echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
	fi
}

check_cpu() {
	echo "checking cpu usage...."
	idle=$(top -bn1 | awk '/id,/ {print $8}')
	idle_int=${idle%.*}
	cpu_usage=$((100 - idle_int))
	if [ $cpu_usage -lt 70 ]; then
		color=$GREEN
		status="GOOD"
	elif [ $cpu_usage -lt 90 ]; then
		color=$YELLOW
		status="WARNING"
	else
		color=$RED
		status="CRITICAL"
	fi
	echo -e "${color}CPU USAGE: ${cpu_usage}% [${status}]${NC}"
	echo $cpu_usage > /tmp/health_cpu.tmp
	log_message "CPU:USAGE ${cpu_usage}% [${status}]"
}

check_memory() {
	echo "checking memory usage...."
	T_mem=$(free -m | awk '/Mem:/ {print $2}')
	u_mem=$(free -m | awk '/Mem:/ {print $3}')
	T_mem_i=${T_mem%.*}
	u_mem_i=${u_mem%.*}
	percentage=$((u_mem_i * 100 / T_mem_i))
	if [ $percentage -lt 70 ]; then
		color=$GREEN
		status="GOOD"
	elif [ $percentage -lt 90 ]; then
		color=$YELLOW
		status="WARNING"
	else
		color=$RED
		status="CRITICAL"
	fi
	echo -e "${color}Memory Usage: ${u_mem_i}MB / ${T_mem_i}MB (${percentage}%) [${status}]${NC}"
	echo $percentage > /tmp/health_memory.tmp
	log_message "Memory:USAGE ${u_mem_i}MB [${status}]"
}

check_disk() {
	echo "checking disk usage...."
	df -h | grep -vE 'tmpfs|loop|udev' | tail -n +2 | while read line; do
		filesystem=$(echo $line | awk '{print $1}')
		usage=$(echo $line | awk '{print $5}' | sed 's/%//')
		mount=$(echo $line | awk '{print $6}')
		size=$(echo $line | awk '{print $2}')
		used=$(echo $line | awk '{print $3}')
		if [ $usage -lt 70 ]; then
			color=$GREEN
			status="GOOD"
		elif [ $usage -lt 90 ]; then
			color=$YELLOW
			status="Warning"
		else
			color=$RED
			status="CRITICAL"
		fi
		echo -e "${color} ${mount}: ${used}/${size} (${usage}%) [${status}]${NC}"
		log_message "Disk ${mount}: ${used}/${size} (${usage}%) [${status}]${NC}"
        done
		
}

check_services() {
	echo "checking critical services...."
	for service in "${SERVICES[@]}"; do
		if systemctl is-active --quiet "$service"; then
			echo -e "${GREEN} $service is running${NC}"
			log_message "$service is RUNNING"
		else
			echo -e "${RED} $service is not running${NC}"
			log_message "$service is not RUNNING"
		fi
 	done
}

gen_report() {
    echo "Generating HTML report..."
    
    # Create reports directory
    REPORT_DIR="./reports"
    mkdir -p "$REPORT_DIR"
    
    # Report filename with date
    REPORT_FILE="$REPORT_DIR/health_report_$(date +%Y-%m-%d_%H-%M-%S).html"
    
    # Get current values (we saved them to temp files!)
    CPU=$(cat /tmp/health_cpu.tmp 2>/dev/null || echo "N/A")
    MEMORY=$(cat /tmp/health_memory.tmp 2>/dev/null || echo "N/A")
    
    # Generate HTML
    cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>System Health Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 30px;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #667eea;
            color: white;
        }
        .status-good {
            color: #28a745;
            font-weight: bold;
        }
        .status-warning {
            color: #ffc107;
            font-weight: bold;
        }
        .status-critical {
            color: #dc3545;
            font-weight: bold;
        }
        .metric {
            font-size: 24px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖥️ System Health Monitor</h1>
        <p>Generated: TIMESTAMP_PLACEHOLDER</p>
    </div>
    
    <div class="container">
        <h2>System Metrics</h2>
        <table>
            <tr>
                <th>Component</th>
                <th>Status</th>
                <th>Details</th>
            </tr>
            <tr>
                <td><strong>CPU Usage</strong></td>
                <td class="STATUS_CPU_CLASS">CPU_STATUS</td>
                <td><span class="metric">CPU_VALUE%</span></td>
            </tr>
            <tr>
                <td><strong>Memory Usage</strong></td>
                <td class="STATUS_MEMORY_CLASS">MEMORY_STATUS</td>
                <td><span class="metric">MEMORY_VALUE%</span></td>
            </tr>
            <tr>
                <td><strong>Disk Usage (/)</strong></td>
                <td class="STATUS_DISK_CLASS">DISK_STATUS</td>
                <td><span class="metric">DISK_VALUE%</span></td>
            </tr>
        </table>
        
        <h2>Services Status</h2>
        <ul>
            SERVICES_LIST
        </ul>
    </div>
</body>
</html>
EOF

    # Replace placeholders with actual values
    sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/" "$REPORT_FILE"
    sed -i "s/CPU_VALUE/$CPU/" "$REPORT_FILE"
    
    # Determine CPU status class
    if [ $CPU -lt 70 ]; then
        sed -i "s/STATUS_CPU_CLASS/status-good/" "$REPORT_FILE"
        sed -i "s/CPU_STATUS/GOOD/" "$REPORT_FILE"
    elif [ $CPU -lt 90 ]; then
        sed -i "s/STATUS_CPU_CLASS/status-warning/" "$REPORT_FILE"
        sed -i "s/CPU_STATUS/WARNING/" "$REPORT_FILE"
    else
        sed -i "s/STATUS_CPU_CLASS/status-critical/" "$REPORT_FILE"
        sed -i "s/CPU_STATUS/CRITICAL/" "$REPORT_FILE"
    fi
    
    # TODO: Add similar logic for MEMORY and DISK\
    
    sed -i "s/MEMORY_VALUE/$MEMORY/" "$REPORT_FILE"
    if [ $MEMORY -lt 70 ]; then
   	 sed -i "s/STATUS_MEMORY_CLASS/status-good/" "$REPORT_FILE"
    	sed -i "s/MEMORY_STATUS/GOOD/" "$REPORT_FILE"
    elif [ $MEMORY -lt 90 ]; then
    	sed -i "s/STATUS_MEMORY_CLASS/status-warning/" "$REPORT_FILE"
    	sed -i "s/MEMORY_STATUS/WARNING/" "$REPORT_FILE"
    else
    	sed -i "s/STATUS_MEMORY_CLASS/status-critical/" "$REPORT_FILE"
    	sed -i "s/MEMORY_STATUS/CRITICAL/" "$REPORT_FILE"
    fi

# Get root disk usage
	ROOT_DISK=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# Replace disk value
	sed -i "s/DISK_VALUE/$ROOT_DISK/" "$REPORT_FILE"

# Determine disk status class
    if [ $ROOT_DISK -lt 70 ]; then
    	sed -i "s/STATUS_DISK_CLASS/status-good/" "$REPORT_FILE"
    	sed -i "s/DISK_STATUS/GOOD/" "$REPORT_FILE"
    elif [ $ROOT_DISK -lt 90 ]; then
    	sed -i "s/STATUS_DISK_CLASS/status-warning/" "$REPORT_FILE"
    	sed -i "s/DISK_STATUS/WARNING/" "$REPORT_FILE"
    else
    	sed -i "s/STATUS_DISK_CLASS/status-critical/" "$REPORT_FILE"
    	sed -i "s/DISK_STATUS/CRITICAL/" "$REPORT_FILE"
    fi
# TODO: Generate services list
# Build services HTML list
SERVICES_HTML=""
for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        SERVICES_HTML="${SERVICES_HTML}<li class='status-good'>✓ $service is running</li>"
    else
        SERVICES_HTML="${SERVICES_HTML}<li class='status-critical'>✗ $service is NOT running</li>"
    fi
done

# Replace services list (use different delimiter because HTML has slashes)
sed -i "s|SERVICES_LIST|$SERVICES_HTML|" "$REPORT_FILE"
    echo "Report generated: $REPORT_FILE"
    log_message "HTML report generated: $REPORT_FILE"
}
main() {
	log_message "=========================================================================================="
	log_message "SYSTEM HEALTH CHECK STARTED"
	log_message "=========================================================================================="
	echo "======================================================================================================"
	echo "	SYSTEM HEALTH MONITOR"
	echo "	Date:$(date)"
	echo "======================================================================================================"
	echo ""

	check_cpu
	check_memory
	check_disk
	check_services
	if [ "$GENERATE_HTML" = true ]; then
		generate_report
	fi
	
	if [ "$SHOW_OUTPUT" = true ]; then
		echo ""
		echo " Health Check Complete"
	fi
	gen_report

	echo ""
	log_message "Health Check Completed"
}



main


