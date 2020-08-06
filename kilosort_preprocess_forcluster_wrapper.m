
% ---------------------
% written by Jess Breda 20200731
% purpose is to run kilosort_preprocess function on SLURM cluster. Currently used
% as a wrapper for a fx to convert preprocess.bin To be run
% with kilosort_preprocess_to_sort.sh
% 
%
% TODO:
% - work into previous part of pipeline(.dat/.rec to .bin) and future
% - work into future part of pipeline (actually pass these preproces into KS2 
% - change this to take a repo path so the repo doesn't need to be cloned
% again into the fx, but can be used from previous path steps

% INPUT PARAMETERS: (hard coded into slurm script)
% - input_path = folder containing .bin files to preprocess. will be
% harded coded into SLURM script
% - repo_path = path where repo is located. Usually located in the same
% folder as the raw data from .dat/.rec conversion step
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
function kilosort_preprocess_forcluster_wrapper(input_path, repo_path)

% slurm script will take a 'bin files for kilosort folder as an input
% folder. this input folder needs to be added to the path along with the
% repo. similar structure to mda_to_bin.sh


% print things to verify what is being passed into the function
fprintf(input_path)
fprintf(repo_path)

% add paths
addpath(input_path);
addpath(repo_path);

cd(repo_path) % might be redundant, but just need to make sure we here to call the next function


% call preprocess function (can take additional arguments, see
% documentation for mor info)
kilosort_preprocess_forcluster(input_path)


% message complete
disp('completed succesffully')


end



