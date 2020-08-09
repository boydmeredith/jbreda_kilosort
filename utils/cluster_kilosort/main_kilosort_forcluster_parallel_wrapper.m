
%% ---------------------
% written by Jess Breda 20200803
% purpose is to add paths to call kilosort to be run on TigerGPU in the
% kilosort.sh function
%
% TODO:
% - work into previous part of pipeline(.dat/.rec to .bin) & preprocess
%
% INPUT PARAMETERS:
% - input_folder = path to folder containin .bin files to pass into kilosort. will
% be hard coded in SLURM script
% - config_folder = path to foldering containing channel map and config
% file to use with KS2. Note these names are hard-coded in to
% main_kilosort_fx_cluster and will need to align
% - repo_folder = path to folder where "Brody_Lab_Ephys" github repo is
% located. Most of the functions to be used are located in repo/utils
%
% OPTIONAL PARAMETERS:
% - none
% 
% RETURNS:
% - none
% 
% = EXAMPLE CALLS:
% (in SLURM script)
% matlab -nosplash -nodisplay -nodesktop -r "main_kilosort_forcluster_wrapper
%('${input_folder}','${config_folder}','${repo_folder}');exit"
% ---------------------
%%
function main_kilosort_forcluster_parallel_wrapper(job_folder, input_base_path, config_path, repo_path, start_time)

% printing test for cluster
% fprintf(input_base_path)
% fprintf(config_path)
% fprintf(repo_path)
% fprintf(job_folder)


% generate folder to process
if ispc
    delim='\';
else
    delim='/';
end

input_path = (fullfile(input_base_path, delim, job_folder));

fprintf(input_path)

% add paths
addpath(input_path); %where bin file is
repo_and_subfolders = genpath(repo_path); %where everything else is (including config files)
addpath(repo_and_subfolders);


disp('Passing into Kilosort')
% call main_kilosort_fx
main_kilosort_fx_cluster(input_path, config_path, start_time)
disp('Kilosort Completed Successfully')

end
