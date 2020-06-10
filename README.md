# Ephys
working on ephys data analysis rotation proj.

# Data acquisition

Recordings from rats performing PWM task with 32 tetrode recordings in mPFC.
**fill in more here eventually**

# Analysis

## Pre-processing

### 1. Prepare for Kilosort

**currently working**

Steps 1-8 taken & modified from [here](https://brodylabwiki.princeton.edu/wiki/index.php?title=Internal:Wireless_Ephys_Instructions)

1. First time: In scratch make sure there is a folder with your name and subfolder with ephys info. This is where you will run and save your data from/to

- '/jukebox/scratch/*your folder*/ephys'
- note: you will need to get permission access to scratch from pnihelp via Chuck

2. On globus, take a .dat or .rec file(s) from archive and copy it into your scratch folder

- Stored in: `/jukebox/archive/brody/RATTER/PhysData/Raw/*your folder*/*your rat*/*session file*`
- `cp /jukebox/archive/brody/RATTER/PhysData/Raw/*your folder*/*your rat*/*session file* /jukebox/scratch/*your folder*/ephys`

- File format
  - For .dat must be in:
    - `data_sdc_20190821_123456.dat`
    - `{session} = data_sdc_20190821_123456`
  - For .rec must be in:
    - `data_sdc_20190821_123456_fromSD.rec`
    - `{session} = data_sdc_20190821_123456_fromSD`

3. Copy important scripts to folder that you will need for processing pipeline

- `cp /usr/people/ejdennis/phys/scripts/linux /jukebox/scratch/*your folder*/ephys`
- For this project:
    - main script being used is the bash pipeline_forkilosort2.sh
    - this function calls `sdtorec`, `exportdio` and `exportmda`
    - these are written by Marino in bash (I think? Might be from mountainsort?) *TODO*

4. Add an export path to your bashrc file, explanation of this [here](https://unix.stackexchange.com/questions/129143/what-is-the-purpose-of-bashrc-and-how-does-it-work)

- ``` nano .bashrc
 export PATH=$PATH:/jukebox/scratch/*your folder*/ephys```

5. Login to Spock
- `ssh PUID@spock`
-  `password`

6. Create new screen

- ```cd  /jukebox/scratch/*your folder*/ephys`
tmux new -s pipeline```
- To exit screen: `Ctrl+b + d`

7. Grab a Brody lab node

- `salloc -p Brody -t 4:00:00 -c 44 srun --pty bash`
  - Creates a new shell on the node & reserved for 4 hours

8. Run the pipeline_forkilosort2.sh 

- This is a modified version of pipeline.sh where we only have steps 1 & 2. Further steps were specific to mountainsort & other analyses. The purpose of this script is to convert .dat or .rec → .mda
  - Step 1 converts from .dat → .rec
    - Using sdtorec
    - Removes .dat
  - Step 2 converts from .rec → .mda
    - Using exportdio, exportmda
    - moves .rec to `rec` and .DIO to `{session}.mda`
    - Some files don't have DIO, will need to make an exceptional statement for this *TODO*
  - If .dat file: `./pipeline.sh data_sdc_20190821_123456 1`
  - If .rec file  `./pipeline.sh data_sdc_20190821_123456 2`
  - Returns:
    - In your folder export folder, there will be a directory with session info and this will contain .mda file
    - Might contain other things? Maybe dio info? * *TODO*

Further steps in matlab found in `pre_kilosort_functions` **fill in more here**

9. Run `tetrode_32_mdatobin.m`

- this function takes a folder containing mda file(s) as inputs
- it returns:
  - a folder with `binfilesforkilsort2`
  - for each .mda file containing 32 tetrodes, 4 .bin files in groups of 8 tetrodes

10. Run `rmArtifacts.m`, `find_artifacts.m`

- these functions are supposed to:
  - 1. find large artifacts in the recording (ex: rat hits head on side)
  - 2. remove these artifacts so that they don't consume templates in Kilosort
- how this happens
  - I actually can't tell. It seems like rmArtifacts shoudl call find_artifacts, but that isn't the case? need to look more into this & ask emily *TODO*


### 2. kilosort

- run pre-processed .bin files in Kilosort
**fill in setting information**

### 3. Phy Validation

- run kilosort output in phy and determine valid units
**expand**

## Post-processing

### Initial Steps

- bdata integration
- behavior alignment
- PSTHs/spike trig avgs/etc. *think on this more later*
- Running in cluster
- Combine w/ preprocess & run on tigress

----------------------------------
# TODO
-  run file through scotty to test
  - do this either 1. permission is granted to scratch or 2. copy .dat file locally & run
- non-dio file exception
- get more information on rmArtifacts/find_artifacts
- update `pre_kilosort_functions` folder w/ correct functions & documentation
---
- determine 'protocol' for phy
- Post-processing




 
