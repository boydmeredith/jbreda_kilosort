#!/bin/bash
#
#SBATCH -p all                # partition (queue)
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks-per-socket=1
#SBATCH --gres=gpu:1
#SBATCH --contiguous
#SBATCH --mem=5000         # 5 GB RAM 
#SBATCH -t 60                # time (minutes)
#SBATCH -o /scratch/gpfs/jbreda/ephys/kilosort/logs/output.out
#SBATCH -e /scratch/gpfs/jbreda/ephys/kilosort/logs/error.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jbreda@princeton.edu


# where the .bin file is
input_folder="/scratch/gpfs/jbreda/ephys/kilosort/data_sdb_20190724_193007_fromSD_firstbundle_T5_W10000_forkilosort" 

# where the Brody_Lab_Ephys repo is
repo_folder="/scratch/gpfs/jbreda/ephys/kilosort/Brody_Lab_Ephys"

# where the config and channel map info are (inputs to main_kilosort fx)
config_folder="/scratch/gpfs/jbreda/ephys/kilosort/Brody_Lab_Ephys/utils/cluster_kilosort"
 
# load matlab
module load matlab/R2019b

# call main kilosort_wrapper
	matlab -nosplash -nodisplay -nodesktop -r "main_kilosort_forcluster_wrapper('${input_folder}','${config_folder}','${repo_folder}');exit"

