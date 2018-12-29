#!/bin/bash

# That file needs to be launched in filler/resources folder
# Usage: ./test.zsh

TEST_D="testing/"
MY_FILLER="./azavrazh.filler"
PLAYERS_D="players/"; PLAYERS="abanlin carli champely grati hcao superjeannot"
MAPS_D="maps/"; MAPS="map00 map01 map02"
NUM_TESTS=5


print_results()
{
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

FILES1=$(ls -1 $TEST_D | grep -E ".*_.*_p1")
FILES2=$(ls -1 $TEST_D | grep -E ".*_.*_p2")
cd $TEST_D

put_all()
{
	res_me=($1)
	res_evil=($2)

	me_strs=${#res_me[@]}
	evil_strs=${#res_evil[@]}
	if [[ $me_strs != $evil_strs ]];
	then
		echo $me_strs
		echo $evil_strs
		echo "ACHTUNG!!!"
		return
	fi

	me_count=0
	for (( i=0; i<$me_strs; i++ ));
	do
		if [[ ${res_me[i]} -gt ${res_evil[i]} ]];
		then
			let me_count++;
		fi
	done
	if [[ $me_count -gt $(($me_strs/2)) ]];
	then
		printf $GREEN
	else
		printf $RED
	fi
	echo "In $fname I win $me_count/$me_strs"
}

	for	fname in $FILES1;
	do
		res_me=$(cat $fname | grep "== O" | cut -d: -f2)
		res_evil=$(cat $fname | grep "== X" | cut -d: -f2)
		put_all "$res_me" "$res_evil"
	done

	for	fname in $FILES2;
	do
		res_me=$(cat $fname | grep "== X" | cut -d: -f2)
		res_evil=$(cat $fname | grep "== O" | cut -d: -f2)
		put_all "$res_me" "$res_evil"
	done

cd ..
printf $RESET
}

wait_for_all()
{
	sleep_val=10
	while [[ $(pgrep ruby | wc -l) -gt 0 ]];
	do
		echo -n "Waiting... for "
		echo -n $(pgrep ruby | wc -l)
		echo " proccesses"
		sleep $sleep_val
	done
}
sychronize()
{
	magic_num="1"
	proc_num=$(pgrep ruby | wc -l)
	formula_num=$(echo $(echo $MAPS | wc -w) \* $NUM_TESTS \* 2 \* $magic_num - 1 | bc | cut -d. -f1)
	if [[ $proc_num -gt $formula_num ]];
	then
		wait_for_all
	fi
}

rm -rf $TEST_D
mkdir -p $TEST_D
for	pname in $PLAYERS;
do
	for (( i=0; i<$NUM_TESTS; i++ ));
	do
		for mapname in $MAPS;
		do
			echo -n > $TEST_D/${pname}_${mapname}_p1
			echo -n > $TEST_D/${pname}_${mapname}_p2
			echo "Testing -p1 $MY_FILLER -p2 players/${pname}.filler ON $mapname"
			./filler_vm -f ${MAPS_D}$mapname -p1 $MY_FILLER -p2 ${PLAYERS_D}${pname}.filler | grep "==" >> ${TEST_D}${pname}_${mapname}_p1 &
			echo "Testing -p2 $MY_FILLER -p1 players/${pname}.filler ON $mapname"
			./filler_vm -f ${MAPS_D}$mapname -p2 $MY_FILLER -p1 ${PLAYERS_D}${pname}.filler | grep "==" >> ${TEST_D}${pname}_${mapname}_p2 &
			sychronize
		done
	done
done
wait_for_all
print_results
