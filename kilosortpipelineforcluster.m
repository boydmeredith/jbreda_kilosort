
% ---------------------
% written by Jess Breda
% purpose is to run pre-kilosort function on SLURM cluster. Currently used
% as a wrapper for a fx to convert .mda files to .bin bundles. To be run
% with kilosort_slurm.sh or mda_to_bin.sh
%
%
% TODO:
% - add preproccessing fx when ready
%
% INPUT PARAMETERS:
% all predefined in SLURM script
% - input_folder = folder where data to be converted/analyzed and github repo
% folder are located
% - repo_name = name of the github repo
% - jobid = SLURM job id
%
% OPTIONAL PARAMETERS:
% - none
% 
% RETURNS:
% - none
% 
% = EXAMPLE CALLS:
% (in SLURM script)
% matlab -nosplash -nodisplay -nodesktop -r "kilosortpipelineforcluster('${input_folder}','${repo}','${jobid}');exit"
% ---------------------
%
%%
function kilosortpipelineforcluster(input_folder, repo_name, jobid)

% print things to verify what is being passed into the function
fprintf(jobid)
fprintf(input_folder)

% add paths
repo_path = fullfile(input_folder, sprintf('/%s', repo_name))
addpath(repo_path);
addpath(input_folder);
cd(input_folder) % should already be here but want to make sure


% call mda to bin funcion
tetrode_32_mdatobin_forcluster(input_folder, jobid)


% --- run kilosortpreprocess.m
% cd into 'binfilesforkilsort2_jobid'
% iterates over each .bin file, preprocess it and then makes
% fname_forkilsort.bin
% TODO: add all the 'X_forkilosort.bin' files into a folder to keep things
% organized by session
%----

% message complete
disp('completed succesffully')


end



