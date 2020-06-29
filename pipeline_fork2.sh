#/bin/bash

stringinputfromuser=$1
echo $stringinputfromuser
lengthofstring=${#stringinputfromuser}
echo $lengthofstring

# directorystring=$2 don't think this is needed for cluster

session=${stringinputfromuser:0:lengthofstring-4}
echo $session
typeoffile=${stringinputfromuser:lengthofstring-4:4}
echo $typeoffile

echo "Processing Session $session"

# mv ${directorystring} /jukebox/scratch/jbreda/ephys/Brody_Lab_Ephys don't think this is needed for cluster

if ["$typeoffile" == ".dat"]; then
	echo "Step 1: Creating rec file from dat file"
	./sdtorec -sd $stringinputfromuser -numchan 128 -mergeconf 128_Tetrodes_Sensors_CustomRF.trodesconf
#	rm ${session}.dat
# the above step appends a _fromSD to the filename
	 

	stringinputfromuser=${session}_fromSD.rec 
else
	echo "Skipping step 1: creation rec file"
fi

	echo "Step 2: Creating mda files from rec file"
	./exportdio -rec $stringinputfromuser
	./exportmda -rec $stringinputfromuser
#	mv ${session}.rec recs
#	mv ${session}.DIO/* ${session}.mda
#	rmdir ${session}.DIO
