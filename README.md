
# Ephys
working on ephys data analysis rotation proj.

# Data acquisition

Recordings from rats performing PWM task with 32 tetrode, 128 channel recordings targeting mPFC.

**fill in more here eventually**

----------------------------------
# TODO
- adjust kilosort parameters to 'good' data & then reassess on 'bad' data
- fill in step 7 of "running on spock" with function information. what is this function doing/how. What is it calling?
---
- determine 'protocol' for phy
- Post-processinga
------------------------------------

# Analysis

## Pre-processing

### Running on Spock:

#### .rec, .dat, .mda --> .bin

1. Sign into spock
```
ssh yourid@spock
password
```
2. In scratch make sure there is a folder with your name and subfolder with ephys info. This is where you will clone the repo to, add unprocessed data into & use as input_folder for SLURM script

```
/jukebox/scratch/*your folder*/ephys
```
- note: you will need to get permission access to scratch from pnihelp via Chuck

3. Clone Brody_lab_ephys git hub repo to your scratch folder, or copy it over from other directory if you already have it. Just note: repo & data files to be processed need to be in the same directory.

```
cd /jukebox/scratch/*your folder*/ephys
git clone https://github.com/jess-breda/Brody_Lab_Ephys
```
or
 ```
 cp </path/to/cloned/repo> /jukebox/scratch/*your folder*/ephys
 ```

4. Move files you want to process into `/jukebox/scratch/*your folder*/ephys` (**do this on globus!**)

5. Open & interactive screen & grab a Brody lab node

```
tmux new -s DescriptiveSessionName salloc -p Brody -t 11:00:00 -c 11 srun -J <DescriptiveJobName> -pty bash
```
- Creates a new shell on the node  with 11 cores & reserves for 11 hours
- To exit screen: `Ctrl+b + d` See [Tmux cheatsheet](https://tmuxcheatsheet.com/) for more info

6. Open kilosort_slurm.sh & edit input & output folders. Additionally, adjust paths in the header for job output/errors & email for job updates.
```
cd /jukebox/scratch/*your folder*/ephys
nano kilosort_slurm.sh
 --- in nano ---
input_folder="/jukebox/scratch/*your folder*/ephys"
output_folder="/jukebox/wherever/you/store/your/processed/data"

!!!also adjust header for your ID!!!
```

7. Run kilosort_slurm.sh to convert any .dat, .rec and .mda files into .bin files for kilosort

`sbatch bash kilosort_slurm.sh`

8. (optional) link your working repo to this directory. Git add, commit & push `kilosort_slurm.sh` with job ID for your records


### Local step by step:

#### Prepare for Kilosort

Steps modified from [here](https://brodylabwiki.princeton.edu/wiki/index.php?title=Internal:Wireless_Ephys_Instructions). 1-2 only needed for first time use

1. In scratch make sure there is a folder with your name and subfolder with ephys info. This is where you will run and save your data from/to

`/jukebox/scratch/*your folder*/ephys`
- note: you will need to get permission access to scratch from pnihelp via Chuck

**this might need to be done into the Brody_Lab_Ephys repo, update once pipeline is completed**

2. Clone brody_lab_ephys git hub repo to your scratch folder

`git clone https://github.com/jess-breda/Brody_Lab_Ephys`

Function highlights:
- `pipeline_fork2.sh` converts .dat or .rec files to .mda files
- `tetrode_32_mdatobin` converts .mda files into .bin files and splits 32 tetrodes into groups of 8 to reduce processing time
- `kilosort_preprocess` removes large noise artifacts & persistent noise from .bin files so they don't eat up templates in kilosort


3. In globus, take a .dat or .rec file(s) from archive and copy it into your scratch folder

Stored in: `/jukebox/archive/brody/RATTER/PhysData/Raw/*your folder*/*your rat*/*session file*`
Move to: `/jukebox/scratch/*your folder*/ephys`

File format:
- previous pipeline.sh versions needed file in specific naming format (see wiki for more info)
- this is no longer the case, just needs to be `.dat` or `.rec`
- Brody lab naming conventions = `{session}.dat` or `{session}.rec` where `{session}` = `data_sdX_date_tetrodenums.dat` or `data_sdX_date_tetrodenums_fromSD.rec` where `X = c or b`

4. Sign into spock and create a new tmux screen in the repo.

```
ssh yourid@spock
password

cd  /jukebox/scratch/*your folder*/ephys/Brody_Lab_Ephys

tmux new -s pipeline
```
To exit screen: `Ctrl+b + d` See [Tmux cheatsheet](https://tmuxcheatsheet.com/) for more info

5. Grab a Brody lab node

`salloc -p Brody -t 4:00:00 -c 11 srun --pty bash`
  - Creates a new shell on the node  with 11 cores & reserves for 4 hours

6. Run the pipeline_fork2.sh (pipeline for kilosort 2) `pipeline_fork2 "{session}.dat"` OR `pipeline_fork2 "{session}.rec"`

**overall:** converts .dat or .rec files to .mda files
  - This is a modified version of pipeline.sh written by Marino

*this function takes:*
- a .dat or .rec file in strings
- ex: `pipeline_fork2 "{session}.dat"` OR `pipeline_fork2 "{session}.rec"`

*this function performs:*
- Step 1 converts from .dat → .rec (skipped if .rec file is passed)
  - Using sdtorec from [trodes](https://bitbucket.org/mkarlsso/trodes/wiki/SDFunctions/)
  - takes number of channels and [trodes configuration settings](https://bitbucket.org/mkarlsso/trodes/wiki/Configuration/) as inputs
- Step 2 converts from .rec → .mda
  - Using exportdio and export from [trodes & ,mountainlab](https://bitbucket.org/mkarlsso/trodes/wiki/ExportFunctions/)

*this function returns:*
- In `/jukebox/scratch/*your folder*/ephys/Brody_Lab_Ephys` there will be a directory named `{session}.mda`
- `{session}.mda` will contain .mda files, .matlab files and results files
- we only care about the .mda files that have the naming convention:
  - `{session}.ntX.referenced` where `X = channel number`
  - they will all be the same size and there will be 32 of them

#### In matlab:

7. Run `tetrode_32_mdatobin.m`

**overall:** takes 32 channel .mda files and converts them to 4 .bin files in groups of 8 tetrodes

*this function optionally takes:*
- a directory containing output(s) from pipeline function above, or current working directory with no argument
  - multiple mda output folders can be in directory (ie multiple sessions can be run at the same time)
      - mda folder format: `/jukebox/scratch/*your folder*/ephys/{session}.mda/*32_mda_files_here*`
        - for this example, you'd want to run the function from the directory `/jukebox/scratch/*your folder*/ephys`
  - note: the .mda files **must** all be the same size for this function to properly work/for you to be running it on the correct files
  - directory is flexible for mac or pc

*this function performs:*
- `readmda` from MountainSort repo see [here](https://github.com/flatironinstitute/mountainlab-js/blob/master/utilities/matlab/mdaio/readmda.m/)
- uses base functions to bundle tetrodes in groups of 8

*this function returns:*
- a folder with `binfilesforkilsort2` located in `/jukebox/scratch/*your folder*/ephys`
- for each session, 4 .bin files in groups of 8 tetrodes will be created with the naming scheme `{session}_Nbundle.bin`
- returns to the directory is starts in

**Jess working here/cluster stops here**

9. Run `kilosort_preprocess.m`

**for cluster: need to cd into `binfilesforkilsort2`**

**overall:** this function takes .bin files, identifies large noise artifacts & low frequency noise using a butterworth filter, and zeros them out in a new .bin file that can be passed into kilosort

*this function optionally takes:*
- directory containing .bin files(s) to process (cwd), number of channels (32), butterworth parameters (sample rate = 32000, highpass = 300)
  - for this example, you'd run from the directory `/jukebox/scratch/*your folder*/ephys/binfilesforkilsort2`

*this function performs:*
- loops over portions of the data, reads them in, applies the filter
- finds the moving mean of the filtered data and zeros out voltages where filter is greater than 0.01
- writes into a new file `{session}_Nbundle_forkilosort.bin`

*this function returns:*
- for X .bin files in the `binfilesforkilsort2`, X pre-processed .bin files in `binfilesforkilsort2` with the `_forkilsort` suffix

**for cluster:
- how does kilosort handle a directory with many .bin files?
- function to loop over file in a directory that have 'for kilosort in them, generate a new folder with {session} info, pass single bundle into kilosort, save file in {session} dir'**



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
