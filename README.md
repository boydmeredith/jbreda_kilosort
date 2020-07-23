
# Ephys
working on ephys data analysis rotation proj.

# Data acquisition

Recordings from rats performing PWM task with 32 tetrode, 128 channel recordings targeting mPFC.

**fill in more here eventually**

----------------------------------
# TODO
- kilosort parameter sweeps
---
- determine 'protocol' for phy
- Post-processing

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
2. In scratch make sure there is a folder with your name and subfolder(s) with ephys/rat info. This is where you will clone the repo to, add unprocessed data into & use as input_folder for SLURM script

```
/jukebox/scratch/*your folder*/ephys/*folder for raw data*
```
- note: you will need to get permission access to scratch from pnihelp via Chuck

3. Move files you want to process into `/jukebox/scratch/*your folder*/ephys/*folder for raw data*` (**do this on globus!**)

4. Clone Brody_lab_ephys git hub repo to your scratch folder

```
cd /jukebox/scratch/*your folder*/ephys/*folder with raw data*
git clone https://github.com/jess-breda/Brody_Lab_Ephys
```

5. Open kilosort_slurm.sh & edit input & output folders. Additionally, adjust paths in the header for job output/errors & email for job updates.
```
cd /jukebox/scratch/*your folder*/ephys/*folder with raw data*/Brody_Lab_Ephys
nano kilosort_slurm.sh
 --- in nano ---
input_folder="/jukebox/scratch/*your folder*/ephys/*folder with raw data*"

!!!also adjust header for your ID!!!
```

slurm notes:
- 1. this is set to run on a Brody lab partition, remove the --partition line if this does not apply to you
- 2. rather than running on slurm via sbatch (step 7 below), if the job is small enough, you can allocate a node instead:
```
tmux new -s DescriptiveSessionName salloc -p Brody -t 11:00:00 -c 11 srun -J <DescriptiveJobName> -pty bash
```
  - Creates a new shell on the node  with 11 cores & reserves for 11 hours
  - To exit screen: `Ctrl+b + d` See [Tmux cheatsheet](https://tmuxcheatsheet.com/) for more info


7. Run `kilosort_slurm.sh` to convert any .dat, .rec files --> .mda files --> .bin bundles for kilosort

```
cd /jukebox/scratch/*your folder*/ephys/*folder with raw data*/Brody_Lab_Ephys
sbatch ./kilosort_slurm.sh
```

Function highlights:
- 1. cds into input_folder directory and makes an array of file names with .rec or .dat extension
- 2. Loops over file names and passes each into `pipeline_fork2` to create .mda files
  - a. this function converts .dat and .rec files into .mda files
- 3. in input_folder with new .mda folders, passes them into `kilosortpipelineforcluster.m` along with the repo name and jobid
  - a. This function adds all needed paths & cds into correct directory before passing .mda folders into `tetrode_32_mdatobin_forcluster.m`
  - b. `tetrode_32_mdatobin_forcluster.m` takes directory of .mda folders, makes a new directory with jobid appended and converts each recording session into .bin files split into 4 groups of 8 tetrodes for each session


8. OPTIONAL .dat and .rec --> .mda or .mda --> .bin bundles

To break up conversion process you can run:

`datrec_to_mda.sh` and `mda_to_bin.sh`

**TODO make kilosort_slurm take an argument that stop and start at different parts of conversion**

8. (optional) link your working repo to this directory. Git add, commit & push `kilosort_slurm.sh` with job ID for your records

9. Go to step 8 in local step by step and run `kilosort_preprocess.m` & onward

-----------------------
### Local step by step:

#### Prepare for Kilosort

Steps modified from [here](https://brodylabwiki.princeton.edu/wiki/index.php?title=Internal:Wireless_Ephys_Instructions). 1-2 only needed for first time use

1. In scratch make sure there is a folder with your name and subfolder with ephys/rat info. This is where you will run and save your data from/to

`/jukebox/scratch/*your folder*/ephys/*folder for raw data*`
- note: you will need to get permission access to scratch from pnihelp via Chuck


2. Clone Brody_Lab_Ephys github repo into your scratch data folder

```
cd /jukebox/scratch/*your folder*/ephys/*folder for raw data*
git clone https://github.com/jess-breda/Brody_Lab_Ephys
```

Then, copy the trodes config file up out of the repo and into the folder so it is on the same level as the data (this is automatically done if running `kilosort_slurm.sh`). It's okay if it is already there, it will be copied over.
```
cd /jukebox/scratch/*your folder*/ephys/*folder for raw data*
cp Brody_Lab_Ephys/128_Tetrodes_Sensors_CustomRF.trodesconf .  
```

Repo function highlights:
- `pipeline_fork2.sh` converts .dat or .rec files to .mda files
- `tetrode_32_mdatobin` converts .mda files into .bin files and splits 32 tetrodes into groups of 8 to reduce processing time
- `kilosort_preprocess` removes large noise artifacts & persistent noise from .bin files so they don't eat up templates in kilosort


3. In globus, take a .dat or .rec file(s) from archive and copy it into your scratch folder

Stored in: `/jukebox/archive/brody/RATTER/PhysData/Raw/*your folder*/*your rat*/*session file*`
Move to: `/jukebox/scratch/*your folder*/ephys/*folder for raw data*`

File format:
- previous pipeline.sh versions needed file in specific naming format (see wiki for more info)
- this is no longer the case, just needs to be `.dat` or `.rec`
- Brody lab naming conventions = `{session}.dat` or `{session}.rec` where `{session}` = any string with data/tetrode/rat information

4. Sign into spock and create a new tmux screen in the repo.

```
ssh yourid@spock
password

cd  /jukebox/scratch/*your folder*/ephys/*folder with raw data*

tmux new -s <DescriptiveSessionName>
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
- In `/jukebox/scratch/*your folder*/ephys/*folder with raw data*` there will be a directory named `{session}.mda`
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
      - mda folder format: `/jukebox/scratch/*your folder*/ephys/*folder with raw data*/{session}.mda/*32_mda_files_here*`
        - for this example, you'd want to run the function from the directory `/jukebox/scratch/*your folder*/ephys/*folder with raw data*`
  - note: the .mda files **must** all be the same size for this function to properly work/for you to be running it on the correct files
  - directory is flexible for mac or pc

*this function performs:*
- `readmda` from MountainSort repo see [here](https://github.com/flatironinstitute/mountainlab-js/blob/master/utilities/matlab/mdaio/readmda.m/)
- uses base functions to bundle tetrodes in groups of 8

*this function returns:*
- a folder with `binfilesforkilsort2` located in `/jukebox/scratch/*your folder*/ephys/*folder with raw data*`
- for each session, 4 .bin files in groups of 8 tetrodes will be created with the naming scheme `{session}_Nbundle.bin`
- returns to the directory is starts in

**cluster stops here**

8. Run `kilosort_preprocess.m`


**overall:** this function takes .bin files, applies a butterworth filter and then creates a mask for large amplitude noise and zeros it out. Creates a new directory with containing a processed .bin file that can be passed into kilosort

*this function optionally takes:*
- directory containing .bin files(s) to process (cwd), number of channels (32), butterworth parameters (sample rate = 32000, highpass = 300)
  - for this example, you'd run from the directory `/jukebox/scratch/*your folder*/ephys/*folder with raw data*/binfilesforkilsort2`

  *things that are currently hardcoded & worth playing with:*
  - `threshold` = the voltage threshold at which to mask at (0.3 seems too low, 1 seems too high for our data)
  - `window` = the window size for the rolling mean. The larger it is, the more that will be clipped for large noise events, but small noise events may not be seen.

*this function performs:*
- loops over portions of the data, reads them in, applies the high pass butterworth filter
- finds the absolute means of the filtered data, (ie noise = large deviation from the mean), finds a rolling mean of the absolute means with windowsize = window, creates binary mask for any mean voltage > Threshold, applies mask and zeros out noise
- writes into a new file `{session}_Nbundle_forkilosort.bin` under the new directory `{job_id}_{session}_{Threshold}_{Windowsize}_forkilosort`

*this function returns:*
- for X .bin files in the `binfilesforkilsort2`, X pre-processed .bin files the `_forkilsort` suffix in X directories within `binfilesforkilsort2`

### 2. kilosort

**See `utils` folder for kilosort2 git submodule.** I am running functions from `local_kilosort`.

`main_kilosort_fx.m` takes main_kilosort script and turns into function. Takes a path to binary file as input. Assumes that .bin file, config file and channel map are in a directory by themselves. Will populate that directory with kilosort/phy output

- I use `8tetrode_channelmap.mat` created by `maketetrodemap.m`
- Config file is not set, see optimization below

#### Parameter Optimization
These functions were crated to sweep over different kilosort .ops. Can easily be adjusted to work with variety of ops.

1. `main_kilosort_fx_sweeps.m`

**overall** Takes a .bin path, .config path and parameters being swept over (currently ops.Th, ops.lam, ops.AUCsplit, but subject to change!!) and runs kilosort on them. *NOTE* make sure your parameters being passed in are assigned within the function and commented out in the config file!

2. `kilosort_ops_sweeps.m`

**overall** Iterates over arrays of 3 kilosort parameters (currently ops.Th, ops.lam, ops.AUCsplit, but subject to change!!) and iteratively passes into `main_kilosort_fx_sweeps`.

*To run*
- create a new directory ex: `{date}_sweeps`
- in dir, place the kilosort config file (with parameters you're sweeping over commented out!), the channel map you're using and the .bin file you're testing. Add to path.
- Initialize values to test in matlab & then run from `{date}_sweeps` dir. Ex:
```
Thresholds = {[2 3 3] [6 2 2]}
Lams = [4 10 15]
AUCs = [0.2 0.9]

kilosort_ops_sweeps(Thresholds, Lams, AUCs)
```
- will create a folder for each sweep and populate with kilosort output for Phy
- folder naming is done based on sweep index. For the example above `sweep_2_3_1` would have `ops.Th = [6 2 2]`, `ops.lam = 15`, and `ops.AUCsplit = 0.2`

**TODO** fill in finalized setting information

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
