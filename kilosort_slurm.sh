#!/bin/bash
#SBATCH --job-name=prekilosort_slurm     # create a short name for your job
#SBATCH --output=logs/slurm-%N.%j.out # STDOUT file
#SBATCH --error=logs/slurm-%N.%j.err  # STDERR file
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=11        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --time=10:00:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=all
#SBATCH --mail-user=jbreda@princeton.edu

echo "my pwd is $PWD"

# Step 1 pipeline_fork2
# cd into dir with .dat or .rec file, pass into pipeline_fork2.sh
# cd /scratch/jbreda/ephys/Brody_Lab_Ephys
bash pipeline_fork2.sh "data_sdc_20190902_145404.dat"



# Step 2 tetrode_32_mdatobin
# cd into folder containing mda folder (only want 1 here probably?)
# run tetrode_32_mdatobin on mda folder
# 4 .bin outputs in mda folder

# Step 3 kilosort_preprocess
# cd (maybe?) into mda folder with .bin bundles
# run kilosort_preprocess on each .bin
# make 'binfilesforkilsort2' directory
