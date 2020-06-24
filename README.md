
# Ephys
working on ephys data analysis rotation proj.

# Data acquisition

Recordings from rats performing PWM task with 32 tetrode, 128 channel recordings targeting mPFC.

**fill in more here eventually**

# Analysis

## Pre-processing

### 1. Prepare for Kilosort

Steps modified from [here](https://brodylabwiki.princeton.edu/wiki/index.php?title=Internal:Wireless_Ephys_Instructions). 1-3 only needed for first time use

1.In scratch make sure there is a folder with your name and subfolder with ephys info. This is where you will run and save your data from/to

- '/jukebox/scratch/*your folder*/ephys'
- note: you will need to get permission access to scratch from pnihelp via Chuck

-*this might need to be done into the Brody_Lab_Ephys repo*

2. Clone brody_lab_ephys git hub repo to your scratch folder

- `git clone https://github.com/jess-breda/Brody_Lab_Ephys`

- Function highlights:
    - `pipeline_fork2.sh` converts .dat or .rec files to .mda files
    - `tetrode_32_mdatobin` converts .mda files into .bin files and splits 32 tetrodes into groups of 8 to reduce processing time
    - `kilosort_preprocess` removes large noise artifacts from .bin fem

3. In spock, add an export path to your bashrc file, explanation of this [here](https://unix.stackexchange.com/questions/129143/what-is-the-purpose-of-bashrc-and-how-does-it-work)

```
ssh PUID@spock
password

cd /jukebox/scratch/*your folder*/
```

- ``` nano .bashrc
 export PATH=$PATH:/jukebox/scratch/*your folder*/ephys```
-----

4. In globus, take a .dat or .rec file(s) from archive and copy it into your scratch folder

- Stored in: `/jukebox/archive/brody/RATTER/PhysData/Raw/*your folder*/*your rat*/*session file*`
- move to: `/jukebox/scratch/*your folder*/ephys`

- File format
  - previous pipeline.sh versions needed file in specific naming format (see wiki for more info)
  - this is no longer the case
5. In spock, Create new screen

- ```cd  /jukebox/scratch/*your folder*/ephys/Brody_Lab_Ephys`
tmux new -s pipeline```
- To exit screen: `Ctrl+b + d`

6. Grab a Brody lab node

- `salloc -p Brody -t 4:00:00 -c 44 srun --pty bash`
  - Creates a new shell on the node & reserved for 4 hours

7. Run the pipeline_fork2.sh (pipeline for kilosort 2)
    `pipeline_fork2 nameoffile.dat` OR `pipeline_fork2 nameoffile.rec`

- This is a modified version of pipeline.sh written by Marino
  - Step 1 converts from .dat → .rec (skipped if .rec file is passed)
    - Using sdtorec from [here](https://bitbucket.org/mkarlsso/trodes/wiki/SDFunctions
    - Using 128_Tetrodes_Sensors_CustomRF.trodesconf from ?? Trodes **TODO**
  - Step 2 converts from .rec → .mda
    - Using exportdio, exportmda
    - Some files don't have DIO, will need to make an exceptional statement for this *TODO*
  - Returns:
    - In your folder export folder, there will be a directory with `nameoffile`and this will contain .mda file
    - Might contain other things? * *TODO*

In matlab:

8. Run `tetrode_32_mdatobin.m`

- overall: takes 32 channel .mda files and converts them to 4 .bin files in groups of 8 tetordes

- this function takes:
    - a directory containing output(s) from pipeline function above, or current working dirctory with no argument
      - multiple mda output folders can be in directory (ie multiple sessions can be run at the same time)
          - folder format: `/jukebox/scratch/*your folder*/ephys/{session}.mda/*32_mda_files_here*`
            - note: folder name has `.mda` in title
            - you want to run the function from the directory `/jukebox/scratch/*your folder*/ephys` (or the directory that has the .mda folders in it)
      - note: the .mda files **must** all be the same size for this function to properly work/for you to be running it on the correct files
      - directory is flexible for mac or pc

- this function calls:
  - `read.mda` from MountainSort repo see [here] (https://github.com/flatironinstitute/mountainlab-js/blob/master/utilities/matlab/mdaio/readmda.m)

- this function returns:
  - a folder with `binfilesforkilsort2` located in `/jukebox/scratch/*your folder*/ephys`
  - for each session, 4 .bin files in groups of 8 tetrodes will be created with the naming scheme `{session}_Nbundle.bin`

**Jess working here**

9. Run `kilosort_preprocess.m`

- overall: this function takes .bin files, identifies large noise artifacts using a butterworth filter, and zeros them out in a new .bin file that can be passed into kilsort

- this function optionally takes:
  - directory containing .bin files(s) to process (cwd), number of channels (32), butterworth parameters (sample, highpass)

- this function performs:
  - takes
  - 1. find large artifacts in the recording (ex: rat hits head on side) that are above a predetermined threshold *TODO*
  - 2. remove these artifacts so that they don't consume templates, and interpolate in its place so temporal structure of recording is maintained

- this function returns:


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
-  troubleshoot pipeline fxs
- run `tetrode_32_mdatobin.m`
- re-arrange `pre_process.m` into function format
- update `pre_kilosort_functions` folder w/ correct functions & documentation
---
- determine 'protocol' for phy
- Post-processing