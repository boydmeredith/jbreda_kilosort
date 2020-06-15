
# Ephys
working on ephys data analysis rotation proj.

# Data acquisition

Recordings from rats performing PWM task with 32 tetrode, 128 channel recordings targeting mPFC.

**fill in more here eventually**

# Analysis

## Pre-processing

### 1. Prepare for Kilosort

**currently working**

Steps 1-8 taken & modified from [here](https://brodylabwiki.princeton.edu/wiki/index.php?title=Internal:Wireless_Ephys_Instructions)

1. First time: In scratch make sure there is a folder with your name and subfolder with ephys info. This is where you will run and save your data from/to

- '/jukebox/scratch/*your folder*/ephys'
- note: you will need to get permission access to scratch from pnihelp via Chuck

2. In globus, take a .dat or .rec file(s) from archive and copy it into your scratch folder

- Stored in: `/jukebox/archive/brody/RATTER/PhysData/Raw/*your folder*/*your rat*/*session file*`
- `cp /jukebox/archive/brody/RATTER/PhysData/Raw/*your folder*/*your rat*/*session file* /jukebox/scratch/*your folder*/ephys`

- File format
  - For .dat must be in:
    - `data_sdc_20190821_123456.dat`
    - `{session} = data_sdc_20190821_123456`
  - For .rec must be in:
    - `data_sdc_20190821_123456_fromSD.rec`
    - `{session} = data_sdc_20190821_123456_fromSD`

3. In globus, copy important scripts to folder that you will need for processing pipeline (can also do this in spock but might run into permission issues)

- scripts found in:
  - `jukebox/brody/ejdennis/ephys/Mountainsort/*fillhere*`
- transfer files to:
  - `/jukebox/scratch/*your folder*/ephys`

- For this project:
    - main script being used is the bash pipeline_fork2.sh
    - this function calls `sdtorec`, `exportdio` and `exportmda`
    - these are written by Marino in bash (I think? Might be from mountainsort?) *TODO*

4. In spock, add an export path to your bashrc file, explanation of this [here](https://unix.stackexchange.com/questions/129143/what-is-the-purpose-of-bashrc-and-how-does-it-work)

```
ssh PUID@spock
password

cd /jukebox/scratch/*your folder*/
```

- ``` nano .bashrc
 export PATH=$PATH:/jukebox/scratch/*your folder*/ephys```
-----

6. In spock, Create new screen

- ```cd  /jukebox/scratch/*your folder*/ephys`
tmux new -s pipeline```
- To exit screen: `Ctrl+b + d`

7. Grab a Brody lab node

- `salloc -p Brody -t 4:00:00 -c 44 srun --pty bash`
  - Creates a new shell on the node & reserved for 4 hours

8. Run the pipeline_fork2.sh (pipeline for kilosort 2)
    `pipeline_fork2 nameoffile.dat` OR `pipeline_fork2 nameoffile.rec`

- This is a modified version of pipeline.sh where we only have steps 1 & 2. Further steps were specific to mountainsort & other analyses. The purpose of this script is to convert .dat or .rec → .mda
  - Step 1 converts from .dat → .rec
    - Using sdtorec from [here](https://bitbucket.org/mkarlsso/trodes/wiki/SDFunctions)
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


  **Current Error** Emily working here

  ```bash pipeline_fork2.sh "data_sdb_20190722_131813.dat" 1
  Processing Session
  data_sdb_20190722_131813.dat                                                          
Step 1: Creating rec file from dat file                                                                                   
sdtorec: sdtorec: cannot execute binary file                                                                                   
rm: cannot remove 'data_sdb_20190722_131813.dat.dat': No such file or directory                                                                              
Step 2: Creating mda files from rec file                                                                                   
exportmda: exportmda: cannot execute binary file
```
```
  bash pipeline.sh "data_sdb_20190722_131813.dat"                                                         
  Processing Session data_sdb_20190722_131813.dat                                                          
   Step 1: Creating rec file from dat file                                                                                   
   pipeline.sh: line 12: sdtorec: command not found                                                                                  
   rm: cannot remove 'data_sdb_20190722_131813.dat.dat': No such file or directory                                                                              
   Step 2: Creating mda files from rec file                                                                                   
   pipeline.sh: line 22: exportdio: command not found                                                                                  
   .sh: line 23: exportmda: command not found
  mv: cannot stat 'data_sdb_20190722_131813.dat_fromSD.rec': No such file or directory                                                                             
  mv: cannot stat 'data_sdb_20190722_131813.dat_fromSD.DIO/*': No such file or directory                                                                                
  rmdir: failed to remove 'data_sdb_20190722_131813.dat_fromSD.DIO': No such file or directory
  ```                                                                         



**Jess working here**
Further steps in matlab found in `pre_kilosort_functions`

9. Run `tetrode_32_mdatobin.m`

- this function takes a directory (mda_dir) containing output(s) from pipeline fx above
    - multiple mda output folders can be in directory (ie multiple sessions can be run at the same time)
        - folder format: `mda_dir/data_sdb_date_nums_fromSD.mda` or `mda_dir/data_sdb_date_nums_dat_fromSD.mda`
    - within each mda output directory should be 32 .mda file all of the same size
        - folder format: `mda_dir/data_sdb_date_nums_fromSD.mda/*32_mda_files_here*`
- it returns:
  - a folder with `binfilesforkilsort2` located in `mda_dir`
  - for each sesssion, 4 .bin files in groups of 8 tetrodes will be created

06/12/2020 notes on `tetrode_32_mdatobin.m`
- updated function info on template
- thisfilename adjusted to prevent readmda errors
- `allfilesnames` --> `allfoldernames`
- N_folders and N_channels need to be set w/i function, currently used to debug on smaller sets of data
- currently set to run on a PC

Tested on: `X:\physdata\Emily\ephys\data_sdb_20190609_123456_fromSD.mda`

10. Run `pre_process.m`

- this function is supposed to:
  - 1. find large artifacts in the recording (ex: rat hits head on side) that are above a predetermined threshold *TODO*
  - 2. remove these artifacts so that they don't consume templates, and interpolate in its place so temporal structure of recording is maintained


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





