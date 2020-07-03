#/bin/bash

stringinputfromuser=$1
echo $stringinputfromuser
lengthofstring=${#stringinputfromuser}
echo $lengthofstring



session=${stringinputfromuser:0:lengthofstring-4}
echo $session
typeoffile=${stringinputfromuser:lengthofstring-4:4}
echo $typeoffile

echo "Processing Session $session"



if [ "$typeoffile" == ".dat" ]; then
	echo "Step 1: Creating rec file from dat file"
	./Brody_Lab_Ephys/sdtorec -sd $stringinputfromuser -numchan 128 -mergeconf 128_Tetrodes_Sensors_CustomRF.trodesconf

# the above step appends a _fromSD to the filename
	 

	stringinputfromuser=${session}_fromSD.rec 
else
	echo "Skipping step 1: creation rec file"
fi

	echo "Step 2: Creating mda files from rec file"
	./Brody_Lab_Ephys/exportdio -rec $stringinputfromuser
	./Brody_Lab_Ephys/exportmda -rec $stringinputfromuser

