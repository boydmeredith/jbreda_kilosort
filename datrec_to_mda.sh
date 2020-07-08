#!/usr/bin/env bash
#SBATCH --nodes=1                            # node count
#SBATCH -o /jukebox/scratch/jbreda/ephys/ephys_W122.out  # where to save the output files of the job
#SBATCH -e /jukebox/scratch/jbreda/ephys/ephys_W122.err  # where to save the error files of the job
#SBATCH -t 840                               # 14 hour time limit
#SBATCH --mem=32000 # 32GB of RAM
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jbreda@princeton.edu
#SBATCH --cpus-per-task=11                   # 11 cores requested
#SBATCH --partition=Brody                    # run on brodylab parition


# Step 1: hardcode input and output folders (this assumes you have copied necessary functions to input folder)
# necessary fx: pipeline_fork2.sh, exportdio, exportmda, sdtorec, trodes.config, readmda, tetrode_32_mdatobin.m
# input folder needs to have data & functions!!

input_folder="/jukebox/scratch/jbreda/ephys/W122"
# output_folder="/jukebox/brody/jbreda/ephys"

# Step 2: in input folder, look for files with .rec and .dat extension, add their names to a list & print to output
cd $input_folder
files=$( ls *{.dat,.rec})
echo $files

# Step 3: iterate over the list and pass each file name as a string into pipeline_fork2.sh.
# Also make sure trodes configuration file is in current directory.

cp Brody_Lab_Ephys/128_Tetrodes_Sensors_CustomRF.trodesconf .
ls

for file in ${files[@]}; do ./Brody_Lab_Ephys/pipeline_fork2.sh "$file"; done


