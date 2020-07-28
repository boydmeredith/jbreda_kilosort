#!/usr/bin/env bash
#SBATCH --nodes=1                            # node count
#SBATCH -o /jukebox/scratch/jbreda/ephys/ephys_tyler_FOF.out  # where to save the output files of the job
#SBATCH -e /jukebox/scratch/jbreda/ephys/ephys_tyler_FOF.err  # where to save the error files of the job
#SBATCH -t 1440                               # 24 hour time limit
#SBATCH --mem=64000 # 64GB of RAM
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jbreda@princeton.edu
#SBATCH --cpus-per-task=11                   # 11 cores requested
#SBATCH --partition=Brody                    # run on brodylab parition


# Step 1: hardcode input and output folders (this assumes you have copied necessary functions to input folder)
# necessary fx: pipeline_fork2.sh, exportdio, exportmda, sdtorec, trodes.config, readmda, tetrode_32_mdatobin.m
# input folder needs to have data & repo folder

input_folder="/jukebox/scratch/jbreda/ephys/Tyler_FOF"
# output_folder="/jukebox/brody/jbreda/ephys"

# Step 2: grab jobid and repo folder for later steps
repo="Brody_Lab_Ephys"
echo $repo

jobid=$SLURM_JOB_ID
echo $jobid

# Step 3: in input folder, look for files with .rec and .dat extension, add their names to a list & print to output
cd $input_folder
files=$( ls *{.dat,.rec})
echo $files

# Step 4: iterate over the list and pass each file name as a string into pipeline_fork2.sh.
# Also make sure trodes configuration file is in current directory.
cp Brody_Lab_Ephys/128_Tetrodes_Sensors_CustomRF.trodesconf .
ls

for file in ${files[@]}; do ./Brody_Lab_Ephys/pipeline_fork2.sh "$file"; done

# Step 5: now everything in input_folder has associated .mda folder, cd into repo and call matlab fx for mda to bin conversion
cd $repo
pwd

# open matlab
module load matlab/R2019b5

# call kilosortpipelineforcluster
	matlab -nosplash -nodisplay -nodesktop -r "kilosortpipelineforcluster('${input_folder}','${repo}','${jobid}');exit"


# TODO move files to bucket
