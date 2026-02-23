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


LOG_DIR="./.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/health_$(date +%Y-%m-%d).log"

log_message() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
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
        done
	
}

check_services() {
	echo "checking critical services...."
	for service in "${SERVICES[@]}"; do
		if systemctl is-active --quiet "$service"; then
			echo -e "${GREEN} $service is running${NC}"
		else
			echo -e "${RED} $service is not running${NC}"
		fi
 	done
}

gen_report() {
	echo "generating HTML report...."
}

main() {
	echo "======================================================================================================"
	echo "	SYSTEM HEALTH MONITOR"
	echo "	Date:$(date)"
	echo "======================================================================================================"
	echo ""

	check_cpu
	check_memory
	check_disk
	check_services
	gen_report
}



main


