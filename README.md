# pomodoro - Version 1.0.0

```bash
# [!] Usage: ./pomodoro.sh
#
# [i] The script will start a pomodoro timer with 25 minutes of work and 5 minutes of break
# [i] You can change the work and break time with the -w and -b options respectively
#
# [!] Example: ./pomodoro.sh  -w 25 -b 5
#
# [i] Each 4 modules (By default), the break time will be 4 times longer than the break time by default
#
# [!] Options:
#
# 	-w Set the work time in minutes (If not, will be 25 minutes)
# 	-b Set the break time in minutes (If not, will be 5 minutes)
# 	-l Set the long break time in minutes (If not, will be 4 times the break time)
# 	-m Set the total number of modules (If not, will be 4 modules)
# 	-d Enable debug mode (For testing and develop)
# 	-r Enable reverse mode (Starts with a break)
# 	-c Enable CLI mode / Disables TUI mode
# 	-h Show this help panel

```
## ToDo:

- [X] Add a TUI
- [X] Add option to modify the quantity of modules before long break
- [X] Reduce/Check dependencies
- [ ] ?
