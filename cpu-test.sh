#!/bin/bash
# Runs a CPU test on Raspberry Pis using sysbench

if hash sysbench 2>/dev/null; then

	z="1"

	re='^[0-9]+$'

	FILE=/tmp/average-temps.txt

	if test -f "$FILE"; then
		z="1"
	else
		touch /tmp/average-temps.txt
	fi

	echo How many times would you like to run the test?

	read t

	while ! [[ $t =~ $re ]]; do
		echo "Error: please enter a valid integer for test runs"
		read t
	done

	echo "How long in seconds do you want the test to run? (Max time is about 30s)"

	read f

	while ! [[ $f =~ $re ]]; do
		echo "Error: please enter a valid integer for time"
		read f
	done

	echo "How many threads would you like to run the test on?"

	read c

	while ! [[ $c =~ $re ]]; do
		echo "Error: please enter a valid integer for thread count"
		read c
	done

	u=$[ $t +1 ]

	while [ $z -lt $u ]; do
		echo -e "\e[31;1mRun number $z/$t\e[0m"
		sysbench --threads=$c --time=$f --test=cpu run
		z=$[ $z + 1 ]
		vcgencmd measure_temp | sed 's/[^0-9\.]*//g' >> /tmp/average-temps.txt
	done

	# Find Average Temp
	awk '{s+=$1}END{print"\033[1;97mAverage CPU Temp:",(NR?s/NR:"NaN"),"C"}' RS=" " /tmp/average-temps.txt

	printf "\n"

	# Find Highest Temp
	perl -MList::Util=max -anle '$tmp = max @f; $max = $tmp if $max < $tmp; END { print"Highest Temp: @F C"}' /tmp/average-temps.txt

	printf "\n"
	rm /tmp/average-temps.txt

else
	printf >&2 "This tool requires sysbench which does not appear to be installed, \nplease install sysbench before running again.\n"
fi