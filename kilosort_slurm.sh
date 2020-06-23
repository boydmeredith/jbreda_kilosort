#!/usr/bin/env bash
#SBATCH --nodes=1                            # node count
#SBATCH -o jukebox/scratch/jbreda/ephys/Brody_Lab_Ephys/ephys_jess.out  # where to save the output files of the job
#SBATCH -e jukebox/scratch/jbreda/ephys/Brody_Lab_Ephys/ephys_jess.err  # where to save the error files of the job
#SBATCH -t 840                               # 14 hour time limit
#SBATCH --mem=32000 # 32GB of RAM
#SBATCH --mail-type=all
#SBATCH --mail-user=jbreda@princeton.edu
#SBATCH --cpus-per-task=11                   # 11 cores requested



# Step 1 pipeline_fork2
# cd into dir with .dat or .rec file, pass into pipeline_fork2.sh
cd /jukebox/scratch/jbreda/ephys/Brody_Lab_Ephys/
bash pipeline_fork2 "data_sdc_20190902_145404.dat"



# Step 2 tetrode_32_mdatobin
# cd into folder containing mda folder (only want 1 here probably?)
# run tetrode_32_mdatobin on mda folder
# 4 .bin outputs in mda folder

# Step 3 kilosort_preprocess
# cd (maybe?) into mda folder with .bin bundles
# run kilosort_preprocess on each .bin
# make 'binfilesforkilsort2' directory
