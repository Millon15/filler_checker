#!/bin/zsh

GREEN='\e[0;32m'
RED='\e[0;31m'
YELLOW='\e[93m'
CYAN='\e[96m'
MAG='\e[95m'
BLUE='\e[1;34m'
RESET='\e[0m'

PLAYERS="abanlin carli champely grati hcao superjeannot"
MAPS="map00 map01 map02"

NUM_TESTS=5
TEMPFILE=".tmpfile"
MAX_NUM_OF_FILLER_VM_PROCESSES=$(( $NUM_TESTS * 2 ))


put_usage()
{
	echo "${YELLOW}List of maps and players to test you can always change in the head of the ./filler_checker.zsh file"
	echo "${YELLOW}Be aware! Checker folder must contain the filler's resources/ directory"
	echo "${BLUE}Usage: ./filler_checker.zsh [xlogin.filler]"
	echo "Example: ./filler_checker.zsh ../filler/vbrazas.filler"
	exit 1;
}
check_arg()
{
	eval "$1 &> /dev/null"
	if (( $? != $2 )); then
		put_usage
	fi
}
fill_arg()
{
	if [[ ! "$2" ]]; then
		echo -n "Input path to the $3 path: "; read -r tmp
	else
		tmp=$2
	fi

	if [[ ! -f $tmp ]]; then
		echo "${RED}Error - path not found: $tmp"
		put_usage
	fi

	eval "$4=$tmp"
}
fill_arg $0 "$1" "xlogin.filler" FILE_TO_CHECK
VM_PATH=resources/

if [[ ! -d $VM_PATH/players/ ]]; then
	echo "${RED}Error - path not found: $VM_PATH/players/"
	put_usage
fi
PLAYERS_D="$VM_PATH/players/"
if [[ ! -d $VM_PATH/maps/ ]]; then
	echo "${RED}Error - path not found: $VM_PATH/maps/"
	put_usage
fi
MAPS_D="$VM_PATH/maps/"


sychronize()
{
	for (( l = $(pgrep ruby | wc -l); l > 0; l = $(pgrep ruby | wc -l) )); do
		echo "Waiting... for $l proccesses"
		sleep 5
	done
}

if ./$VM_PATH/filler_vm -q -f ${MAPS_D}$(echo $MAPS | cut -d' ' -f1) -p1 ./$FILE_TO_CHECK -p2 ./${PLAYERS_D}$(echo $PLAYERS | cut -d' ' -f1).filler 1> /dev/null; then
	echo "${RED}Error - when try to execute test command, check ./$VM_PATH/filler_vm file!"
	put_usage
fi
echo -n > $TEMPFILE
echo -n $BLUE
for mapname in `echo $MAPS`; do
	for	pname in `echo $PLAYERS`; do
		for (( i = 0; i < $NUM_TESTS; i++ )); do
			(./$VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p2 ./$FILE_TO_CHECK -p1 ./${PLAYERS_D}${pname}.filler | grep -B 2 "==" >> $TEMPFILE; echo $mapname >> $TEMPFILE) &
			(./$VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p1 ./$FILE_TO_CHECK -p2 ./${PLAYERS_D}${pname}.filler | grep -B 2 "==" >> $TEMPFILE; echo $mapname >> $TEMPFILE) &
			if (( $(pgrep ruby | wc -l) + 1 >= $MAX_NUM_OF_FILLER_VM_PROCESSES )); then sychronize; fi
		done
	done
done
sychronize

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
	elif (( i==5 )); then
		map=$line
		i=0
	fi

	if (( i==0 )); then
		if [[ $(echo $p1 | grep "$FILE_TO_CHECK") ]]; then
			(( $score1 >= $score2 )) && { color=$GREEN; let correct++; } || { color=$RED; }
		elif [[ $(echo $p2 | grep "$FILE_TO_CHECK") ]]; then
			(( $score2 >= $score1 )) && { color=$GREEN; let correct++; } || { color=$RED; }
		fi
		let all++
		echo "${color}ON MAP $map FOUGHT $p1 VS $p2 => $score1 VS $score2${RESET}"
	fi
	let i++;

done < "$TEMPFILE"

echo "${BLUE}Your result: $correct/$all"
rm -f filler.trace $TEMPFILE
