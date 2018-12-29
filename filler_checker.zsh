#!/bin/zsh

PLAYERS="abanlin carli champely grati hcao superjeannot"
MAPS="map00"

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

fill_arg()
{
	if [[ ! $2 ]]; then
		echo -n "Input path to the $3 path: "; read -r tmp
	else
		tmp=$2
	fi

	ls $tmp &> /dev/null
	if (( $? )); then
		echo "${RED}Error: wrong path: $tmp"
		echo "${BLUE}Usage: $1 [xlogin.filler name] [filler_vm path]"
		exit 1;
	fi

	eval "$4=$tmp"
}
fill_arg $0 "$1" "xlogin.filler" FILE_TO_CHECK
fill_arg $0 "$2" "./filler_vm" VM_PATH

PLAYERS_D="$VM_PATH/players/"
MAPS_D="$VM_PATH/maps/"

(( formula_num = ($(echo $MAPS | wc -w) * $(echo $PLAYERS | wc -w) * $NUM_TESTS) / 5 ))
sychronize()
{
	for (( i=$(pgrep ruby | wc -l); i>$1; i=$(pgrep ruby | wc -l) )); do
		echo "${YELLOW}Waiting... for $i proccesses"
		sleep 5
	done
}

echo -n > $TEMPFILE
for mapname in `echo $MAPS`; do
	for (( i = 0; i < $NUM_TESTS; i++ )); do
		for	pname in `echo $PLAYERS`; do
			$VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p1 ./$FILE_TO_CHECK -p2 ./${PLAYERS_D}${pname}.filler | grep -B 2 "==" >> $TEMPFILE &
			$VM_PATH/filler_vm -q -f ${MAPS_D}$mapname -p2 ./$FILE_TO_CHECK -p1 ./${PLAYERS_D}${pname}.filler | grep -B 2 "==" >> $TEMPFILE &
			sychronize $formula_num
		done
	done
done
sychronize 0

correct=0
all=0
i=1
while read -r line; do
	if (( i==1 )); then
		p1=$(echo $line | cut -d' ' -f2)
	elif (( i==2 )); then
		p2=$(echo $line | cut -d' ' -f2)
	elif (( i==3 )); then
		score1=$(echo "$line" | cut -d' ' -f4)
	elif (( i==4 )); then
		score2=$(echo "$line" | cut -d' ' -f4)
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
