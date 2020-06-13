#!/bin/bash

session=$1

step=$2

echo "Processing Session $session"


if [[ $step < 2 ]]; then
	echo "Step 1: Creating rec file from dat file"
	sdtorec -sd ${session}.dat -numchan 128 -mergeconf 128_Tetrodes_Sensors_CustomRF.trodesconf
#	rm ${session}.dat
else
	echo "Skipping step 1: creation rec file"
fi

session=${session}_fromSD

	echo "Step 2: Creating mda files from rec file"
#	exportdio -rec ${session}.rec
	./exportmda -rec ${session}.rec
#	mv ${session}.rec recs
#	mv ${session}.DIO/* ${session}.mda
#	rmdir ${session}.DIO
