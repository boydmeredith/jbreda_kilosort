
% ---------------------
% written by Jess Breda
% purpose is to run pre-kilosort function on cluster
%
%
% TODO:
% - 
%
% INPUT PARAMETERS:
% - foldername:
% - inscratch:
%
%
% OPTIONAL PARAMETERS:
% - none
% 
% RETURNS:
% - none but creates folders
% 
% = EXAMPLE CALLS:
% - 
% ---------------------
%
%%
function kilosortpipelineforcluster(input_folder, repo_name, jobid)

% --- add paths
% need a path for the data
% need a path for the repo with the other mat functions

% --- get into proper directory
% assuming this is written once .mda files are made..?
% get into directory with .mda folders

% --- makke sure github is there, display error messages if not

% --- run tetrode_32_mdatobin.m
% take the directory wtih .mda folders, convert to .bin and bundle them
% this will create a folder in dir with .mda folders 'binfilesforkilosort2'
% TODO: need to figure out where tetrode_32_mdatobin.m puts you when run on
% multiple folders

% --- run kilosortpreprocess.m
% cd into 'binfilesforkilsort2'
% iterates over each .bin file, preprocess it and then makes
% fname_forkilsort.bin
% TODO: add all the 'X_forkilosort.bin' files into a folder to keep things
% organized
%----



% addpath(input_folder);
% 
% addpath(fullfile(input_folder, sprintf('/%s', repo_name))
% 
% cd(input_folder) %not necessary, but just being explicit

% if ~exist(input_folder,'dir')
%     error('no cscope folder')
% end
% if ~exist('/mnt/sink/scratch/ejdennis/W128/NoRMCorre','dir')
%     error('no normcorre folder')
% end

fprintf(jobid)
fprintf(input_folder)
repo_path = fullfile(input_folder, sprintf('/%s', repo_name))
addpath(repo_path)
addpath(input_folder)

% tetrode_32_mdatobin_forcluster(input_folder, jobid)
% 

disp('completed succesffully')


end