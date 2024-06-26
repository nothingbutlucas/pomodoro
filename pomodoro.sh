#!/usr/bin/bash -e

# Note: The -e flag will cause the script to exit if any command fails.

# Description: Simple pomodoro timer script
# Author: @nothingbutlucas
# Version: 1.0.0
# License: GNU General Public License v3.0

# Colours and uses

red='\033[0;31m'    # Something went wrong
green='\033[0;32m'  # Something went well
yellow='\033[0;33m' # Warning
blue='\033[0;34m'   # Info
purple='\033[0;35m' # When asking something to the user
cyan='\033[0;36m'   # Something is happening
grey='\033[0;37m'   # Show a command to the user
nc='\033[0m'        # No Color

sign_wrong="${red}[-]${nc}"
sign_good="${green}[+]${nc}"
sign_warn="${yellow}[!]${nc}"
sign_info="${blue}[i]${nc}"
sign_ask="${purple}[?]${nc}"
sign_doing="${cyan}[~]${nc}"
sign_cmd="${grey}[>]${nc}"
sign_debug="${yellow}[d]${nc}"

wrong="${red}"
good="${green}"
warn="${yellow}"
info="${blue}"
ask="${purple}"
doing="${cyan}"
cmd="${grey}"

WIDTH=50
HEIGHT=15

trap ctrl_c INT

function ctrl_c() {
	exit_script
}

function exit_script() {
	if [[ $modules_worked -gt 0 ]]; then
		work_time=$((work_time / 60))
		minutes_worked=$((work_time * modules_worked))
		if [ $cli == true ]; then
			echo ""
			echo -e "${sign_info}Exiting script\nYou worked ${modules_worked} modules\nLike $((minutes_worked / 60)):$((minutes_worked % 60)) hs"
		else
			/bin/dialog --infobox "Exiting script\nYou worked ${modules_worked} modules\nLike $((minutes_worked / 60)):$((minutes_worked % 60)) hs" $HEIGHT $WIDTH
		fi
	fi
	tput cnorm
	exit 0
}

function check_dependencies() {
	for dependencies in "/bin/dialog" "/bin/play"; do
		if ! command -v $dependencies >/dev/null 2>&1; then
			echo -e "${sign_wrong} $dependencies is not installed"
			# If dialog is not present, show a warning and proceed with cli=true
			if [[ $dependencies == "/bin/dialog" ]]; then
				cli=true
			fi
		else
			echo_debug "Dependency $dependencies is installed"
		fi
	done
}

function start_script() {
	if [ "$cli" == true ]; then
		tput civis
		echo -e "${sign_good} Starting script"
	else
		/bin/dialog --infobox "Starting script" $HEIGHT $WIDTH
	fi
}

function help_panel() {
	echo -e "\n${sign_warn} Usage: ${good}$0\n"
	echo -e "${sign_info} The script will start a pomodoro timer with 25 minutes of work and 5 minutes of break"
	echo -e "${sign_info} You can change the work and break time with the -w and -b options respectively"
	echo -e "\n${sign_warn} Example: ${good}$0 ${info} -w ${nc}25 ${info}-b ${nc}5 ${cmd}\n"
	echo -e "${sign_info} Each 4 modules (By default), the break time will be 4 times longer than the break time by default"
	echo -e "\n${sign_warn} Options:\n"
	echo -e "\t${info} -w ${nc}Set the work time in minutes (If not, will be 25 minutes)"
	echo -e "\t${info} -b ${nc}Set the break time in minutes (If not, will be 5 minutes)"
	echo -e "\t${info} -l ${nc}Set the long break time in minutes (If not, will be 4 times the break time)"
	echo -e "\t${info} -m ${nc}Set the total number of modules (If not, will be 4 modules)"
	echo -e "\t${info} -d ${nc}Enable debug mode (For testing and develop)"
	echo -e "\t${info} -r ${nc}Enable reverse mode (Starts with a break)"
	echo -e "\t${info} -c ${nc}Enable CLI mode / Disables TUI mode"
	echo -e "\t${info} -h ${nc}Show this help panel"

	exit_script
}

function break_sound() {
	local sound=340
	for x in {1..6}; do
		sound=$((sound + 100))
		/bin/play -n synth 0.15 sine $sound &>/dev/null
	done
}

function work_sound() {
	local sound=1040
	for x in {1..6}; do
		sound=$((sound - 100))
		/bin/play -n synth 0.15 sine $sound &>/dev/null
	done
}

function echo_debug() {
	if [[ $debug == true ]]; then
		echo -e "${sign_debug} $1"
		set -x
	fi
}

# Main function

function main() {
	count=0
	modules_worked=0
	work_time=$((work_time * 60))
	break_time=$((break_time * 60))
	long_break_time=$((long_break_time * 60))
	if [[ $reverse == true ]]; then
		action="Working"
	else
		action="Resting"
	fi

	echo_debug "Work time: $work_time"
	echo_debug "Break time: $break_time"
	echo_debug "Long break time: $long_break_time"

	while true; do
		echo_debug "Looping"
		echo_debug "Action: $action"
		echo_debug "Work time: $work_time"
		echo_debug "Break time: $break_time"
		echo_debug "Long break time: $long_break_time"
		if [[ $action == "Resting" ]]; then
			echo_debug "Working"
			secs=$((work_time))
			action="Working"
			work_sound
		elif [[ $action == "Working" ]]; then
			echo_debug "Resting"
			secs=$((break_time))
			action="Resting"
			count=$((count + 1))
			modules_worked=$((modules_worked + 1))
			echo_debug "Count: $count"
			echo_debug "Modules worked: $modules_worked"
			echo_debug "Modules: $((count))"
			if [ $cli == true ]; then
				echo ""
				echo -e "${sign_info} Module $count/$total_modules"
			else
				/bin/dialog --infobox "Module $count/$total_modules. On module $total_modules will be a long break" $HEIGHT $WIDTH
			fi
			if [[ $count == "$total_modules" ]]; then
				echo_debug "$count is equal $total_modules"
				if [ $cli == true ]; then
					echo -e "${sign_good} Long break"
					echo ""
				else
					/bin/dialog --infobox "Module $total_modules/$total_modules. Long break" $HEIGHT $WIDTH
				fi
				secs=$((long_break_time))
				break_sound
				count=0
			else
				secs=$((break_time))
			fi
			break_sound
		else
			action="Working"
			secs=$((work_time))
		fi
		if [ $cli == true ]; then
			echo ""
			while [ $secs -ge 0 ]; do
				echo -ne "${sign_doing} ${action}... $((secs / 60)) min $((secs % 60)) sec\033[0K\r"
				sleep 1
				secs=$((secs - 1))
			done
		else
			/bin/dialog --pause "\n${action} for $((secs / 60)) minutes." $HEIGHT $WIDTH "$secs"
		fi
		echo_debug "The finalized action is ${action}"
	done
}

# Define variables
work_time=25
break_time=5
modules_worked=0
long_break_time=false
debug=false
reverse=false
cli=false

# Script starts here
while getopts ":w:b:l:m:hdrc" arg; do
	case $arg in
	w) work_time=$OPTARG ;;
	b) break_time=$OPTARG ;;
	m) total_modules=$OPTARG ;;
	l) long_break_time=$OPTARG ;;
	d) debug=true ;;
	r) reverse=true ;;
	c) cli=true ;;
	h) help_panel ;;
	?)
		echo -e "${sign_wrong} Invalid option: -$OPTARG"
		help_panel
		;;
	esac
done

start_script


check_dependencies

if [[ "$long_break_time" == false ]]; then
	long_break_time=$((break_time * total_modules))
fi

echo_debug "Work time: $work_time"
echo_debug "Break time: $break_time"
echo_debug "Long break time: $long_break_time"
echo_debug "Reverse: $reverse"

main
