#!/bin/bash
#SBATCH -p all                # partition (queue)
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks-per-socket=1
#SBATCH --gres=gpu:1
#SBATCH --contiguous
#SBATCH --mem=128000         # 128 GB RAM 
#SBATCH -t 60                # time (minutes)
#SBATCH -o /jukebox/scratch/jbreda/ephys/logs/val_%j.out
#SBATCH -e /jukebox/scratch/jbreda/ephys/logs/val_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jbreda@princeton.edu

# input_folder = path to folder
# config folder = path to folder with config and channel map info

# load matlab

# call main kilosort_wrapper

repo="Brody_Lab_Ephys"
echo $repo
