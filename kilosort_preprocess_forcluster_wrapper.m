
% ---------------------
% written by Jess Breda
% purpose is to run kilosort_preprocess function on SLURM cluster. Currently used
% as a wrapper for a fx to convert preprocess.bin To be run
% with <ENTER SLURM SCRIPT HERE>
% **Assumes that bin files and repo are in same directory**
%
%
% TODO:
% - work into previous part of pipeline(.dat/.rec to .bin) and future
% - work into future part of pipeline (actually pass these preproces into KS2 

% INPUT PARAMETERS:
% - input_folder = folder containin .bin files to preprocess. will be
% harded coded into SLURM script
% - repo_name = 'Brody_Lab_Ephys' or name of repo with
% 'kilosort_preprocess_forcluster.m'
%
% OPTIONAL PARAMETERS:
% - none
% 
% RETURNS:
% - none
% 
% = EXAMPLE CALLS:
% (in SLURM script)
% matlab -nosplash -nodisplay -nodesktop -r "kilosortpreprocess_forcluster_wrapper
%('${input_folder}','${repo}');exit"
% ---------------------
%
%%
function kilosort_preprocess_forcluster_wrapper(input_folder, repo_name)

% slurm script will take a 'bin files for kilosort folder as an input
% folder. this input folder needs to be added to the path along with the
% repo. similar structure to mda_to_bin.sh


% print things to verify what is being passed into the function
fprintf(input_folder)

% add paths
repo_path = fullfile(input_folder, sprintf('/%s', repo_name))
addpath(repo_path);
addpath(input_folder);
cd(input_folder) % need to get into data folder b/c called from repo folder


% call preprocess function (can take additional arguments, see
% documentation for mor info)
kilosort_preprocess_forcluster(input_folder)

%helpful for later 
%test = genpath('C:\Users\jbred\Github\Brody_Lab_Ephys')
%addpath(test) adds all the paths underneath the subfolder.

% message complete
disp('completed succesffully')


end



