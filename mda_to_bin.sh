#!/usr/bin/env bash
#SBATCH --nodes=1                            # node count
#SBATCH -o /jukebox/scratch/jbreda/ephys/W122/mdatobin.out  # where to save the output files of the job
#SBATCH -e /jukebox/scratch/jbreda/ephys/W122/mdatobin.err  # where to save the error files of the job
#SBATCH -t 840                               # 14 hour time limit
#SBATCH --mem=128000                         # 128 GB of RAM
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jbreda@princeton.edu
#SBATCH --cpus-per-task=11                   # 11 cores requested
#SBATCH --partition=Brody                    # run on brodylab parition

# pick up from where you left of in previous script & move into repo
input_folder="/jukebox/scratch/jbreda/ephys/Tyler_FOF"
cd $input_folder
repo="Brody_Lab_Ephys"
cd $repo
pwd

# grab the current jobid and print it
jobid=$SLURM_JOB_ID
echo $jobid

# open matlab etc
module load matlab/R2019b5

# call kilosortpipelineforcluster
	matlab -nosplash -nodisplay -nodesktop -r "kilosortpipelineforcluster('${input_folder}','${repo}','${jobid}');exit"


# echo "Done"
