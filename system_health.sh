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

#functions


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
}

check_disk() {
	echo "cecking disk usage...."
}

check_services() {
	echo "checking critical services...."
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


