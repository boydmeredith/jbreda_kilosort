#!/bin/bash

lengthofstring=${"#1"}
session={$1:0:lengthofstring-4}
typeoffile={$1:lengthofstring-3:3}

echo "Processing Session $session"


if [ typeoffile = ".dat" ]; then
	echo "Step 1: Creating rec file from dat file"
	sdtorec -sd $1 -numchan 128 -mergeconf 128_Tetrodes_Sensors_CustomRF.trodesconf
#	rm ${session}.dat
else
	echo "Skipping step 1: creation rec file"
fi

	echo "Step 2: Creating mda files from rec file"
	exportdio -rec $1
	exportmda -rec $1
#	mv ${session}.rec recs
#	mv ${session}.DIO/* ${session}.mda
#	rmdir ${session}.DIO
