#!/bin/bash
#
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks-per-socket=1
#SBATCH --gres=gpu:1
#SBATCH --mem=20000          # 20 GB RAM 
#SBATCH -t 60                # time (minutes)
#SBATCH -o /scratch/gpfs/jbreda/ephys/kilosort/logs/output_%a_%j.out
#SBATCH -e /scratch/gpfs/jbreda/ephys/kilosort/logs/error_%a_%j.err


# where the directorys containing .bin files are 
input_folders="/scratch/gpfs/jbreda/ephys/kilosort/kilosort_array_test" 

# where the Brody_Lab_Ephys repo is
repo_path="/scratch/gpfs/jbreda/ephys/kilosort/Brody_Lab_Ephys"

# where the config and channel map info are (inputs to main_kilosort fx)
config_path="/scratch/gpfs/jbreda/ephys/kilosort/Brody_Lab_Ephys/utils/cluster_kilosort"
 
# step 1: get list of all directories & array index

echo "Array Index: $SLURM_ARRAY_TASK_ID"

cd $input_folders
bin_folders=`ls -d */`
bin_folders_arr=($bin_folders)

# need to find a way to make a full file path from list and base input_folders and then pass that into next fx


cd $config_path

# load matlab
module purge
module load matlab/R2018b

# call main kilosort_wrapper the 500 = time in seconds where the sorting starts, skipping first chunck bc very noisy
	matlab -singleCompThread -nosplash -nodisplay -nodesktop -r "main_kilosort_forcluster_wrapper('${input_path}','${config_path}','${repo_path}', 500);exit"

