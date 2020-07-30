#!/usr/bin/env bash
#SBATCH --nodes=1                            # node count
#SBATCH -o /jukebox/scratch/jbreda/ephys/W122/Kilosort_preprocess_testing/output.out  # where to save the output files of the job
#SBATCH -e /jukebox/scratch/jbreda/ephys/W122/Kilosort_preprocess_testing/error.err   # where to save the error files of the job
#SBATCH -t 1440                               # 24 hour time limit
#SBATCH --mem=64000 # 64GB of RAM
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jbreda@princeton.edu
#SBATCH --cpus-per-task=11                   # 11 cores requested
#SBATCH --partition=Brody                    # run on brodylab parition

# hard coding input folder for git documentation, this should be where your raw .bin bundles are
input_folder="/jukebox/scratch/jbreda/ephys/W122/Kilosort_preprocess_testing"

# repo should be in input_folder, grab its name to add path in matlab
repo="Brody_Lab_Ephys"
echo $repo
cd $repo

# open matlab
module load matlab/R2019b5

# call kilosort_preprocess_forcluster_wrapper
	matlab -nosplash -nodisplay -nodesktop -r "kilosort_preprocess_forcluster_wrapper('${input_folder}','${repo}');exit"
