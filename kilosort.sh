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

# input_folder = path to folder
# config folder = path to folder with config and channel map info

# load matlab

# call main kilosort_wrapper

repo="Brody_Lab_Ephys"
echo $repo
