
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
function kilosortpipelineforcluster(foldername,inscratch)

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

disp('completed succesffully')


end