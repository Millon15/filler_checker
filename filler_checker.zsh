#!/bin/zsh

PLAYERS="abanlin"
# carli champely grati hcao superjeannot"
MAPS="map00"
# map01 map02"

MAX_NUM_OF_FILLER_VM_PRCS=20
NUM_TESTS=5
TEMPFILE=".tmpfile"

#### Colors definitions
GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[93m'
CYAN='\e[96m'
MAG='\e[95m'
BLUE='\e[1;34m'
RESET='\e[0m'

check_arg()
{
	eval "$1 &> /dev/null"
	if (( $? != $2 )); then
		echo "${RED}Error: wrong path: $tmp"
		echo "${BLUE}Usage: $1 [xlogin.filler name] [filler_vm path]"
		exit 1;
	fi
}

fill_arg()
{
	if [[ ! $2 ]]; then
		echo -n "Input path to the $3 path: "; read -r tmp
	else
		tmp=$2
	fi

	check_arg "ls $tmp" 0

	eval "$4=$tmp"
}
fill_arg $0 "$1" "xlogin.filler" FILE_TO_CHECK
fill_arg $0 "$2" "./filler_vm" VM_PATH

check_arg "ls $VM_PATH/players/" 0
PLAYERS_D="$VM_PATH/players/"
check_arg "ls $VM_PATH/players/" 0
MAPS_D="$VM_PATH/maps/"


sychronize()
{
	for (( l = $(pgrep ruby | wc -l); l > $1; l = $(pgrep ruby | wc -l) )); do
		echo "${YELLOW}Waiting... for $l proccesses"
		sleep 5
	done
}


check_arg "./$VM_PATH/filler_vm -q -f ${MAPS_D}$(echo $MAPS | cut -d' ' -f1) -p1 ./$FILE_TO_CHECK -p2 ./${PLAYERS_D}$(echo $PLAYERS | cut -d' ' -f1).filler" 1
echo -n > $TEMPFILE
for	pname in `echo $PLAYERS`; do
	for mapname in `echo $MAPS`; do
		for (( i = 0; i < $NUM_TESTS; i++ )); do
			./$VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p2 ./$FILE_TO_CHECK -p1 ./${PLAYERS_D}${pname}.filler | grep -B 2 "==" >> $TEMPFILE &
			./$VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p1 ./$FILE_TO_CHECK -p2 ./${PLAYERS_D}${pname}.filler | grep -B 2 "==" >> $TEMPFILE &
			sychronize $MAX_NUM_OF_FILLER_VM_PRCS
		done
	done
done
sychronize 0

correct=0
all=0
i=1
while read -r line; do
	if (( i==1 )); then
		p1=$(echo $line | cut -d' ' -f2 )
	elif (( i==2 )); then
		p2=$(echo $line | cut -d' ' -f2 )
	elif (( i==3 )); then
		score1=$(echo $line | cut -d' ' -f4 )
	elif (( i==4 )); then
		score2=$(echo $line | cut -d' ' -f4 )
		i=0
	fi

	if (( i==0 )); then
		if [[ $(echo $p1 | grep "$FILE_TO_CHECK") ]]; then
			if (( $score1 >= $score2 )); then color=$GREEN; let correct++; else color=$RED; fi
		elif [[ $(echo $p2 | grep "$FILE_TO_CHECK") ]]; then
			if (( $score2 >= $score1 )); then color=$GREEN; let correct++; else color=$RED; fi
		fi
		let all++
		echo "${color}$p1 VS $p2 => $score1 VS $score2${RESET}"
	fi
	let i++;

done < "$TEMPFILE"

echo "${BLUE}Your result: $correct/$all"
