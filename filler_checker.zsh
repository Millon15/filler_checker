#!/bin/zsh

# That checker needs to be launched in filler/resources folder
# Usage: ./filler_checker.zsh

#### Colors definitions
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[93m'
CYAN='\e[96m'
MAG='\e[95m'
BLUE='\e[1;34m'
RESET='\e[0m'

fill_arg()
{
	if [[ ! $2 ]]; then
		echo -n "Input path to the $3 path: "; read -r tmp
		ls $tmp &> /dev/null
		if (( $? )); then
			echo "${RED}Error: wrong path: $tmp"
			echo "${BLUE}Usage: $1 [xlogin.filler name] [filler_vm path]"
			exit 1;
		fi
	else
		tmp=$2
	fi
	eval "$4=$tmp"
}
fill_arg $0 "$1" "xlogin.filler" FILE_TO_CHECK
fill_arg $0 "$2" "./filler_vm" VM_PATH

PLAYERS_D="$VM_PATH/players/"; PLAYERS="abanlin carli champely grati hcao superjeannot"
MAPS_D="$VM_PATH/maps/"; MAPS="map00 map01 map02"
NUM_TESTS=5

(( formula_num = ($(echo $MAPS | wc -w) * $(echo $PLAYERS | wc -w) * $NUM_TESTS) / 3 ))
sychronize()
{
	for (( i=$(pgrep ruby | wc -l); i>$1; i=$(pgrep ruby | wc -l) )); do
		echo "Waiting... for $i proccesses"
		sleep 10
	done
}

check_winner()
{
	if [[ $1 -eq "O" ]]; then
		if (( $2 >= $3 )); then color=$GREEN; else color=$RED; fi
	elif [[ $1 -eq "X" ]]; then
		if (( $3 >= $2 )); then color=$GREEN; else color=$RED; fi
	fi
	echo $4
	echo $color "$2 VS $3" $RESET
}

for mapname in `echo $MAPS`; do
	for (( i = 0; i < $NUM_TESTS; i++ )); do
		for	pname in `echo $PLAYERS`; do
			check_winner O $($VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p1 ./$FILE_TO_CHECK -p2 ${PLAYERS_D}${pname}.filler | grep "==" | awk '{printf $4 " "}') "$FILE_TO_CHECK VS ${pname}.filler ON $mapname" &
			check_winner X $($VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p2 ./$FILE_TO_CHECK -p1 ${PLAYERS_D}${pname}.filler | grep "==" | awk '{printf $4 " "}') "${pname}.filler VS $FILE_TO_CHECK ON $mapname" &
			# sychronize $formula_num
		done
	done
done
sychronize 0
