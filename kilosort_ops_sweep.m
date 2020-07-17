function kilosort_ops_sweep(varargin)
%---------------------
% written by Jess Breda 20200717
% purpose is to run kilosort on single file with multiple different ops
% configurations
%
% TODO:
% - adjust kilosort main into fx
% 
%
% INPUT PARAMETERS:
% none
%
% OPTIONAL PARAMETERS:
% - string directing us to a folder with subfolders containing config files
% to sweep over
% note: .bin file should be in the first folder in the directory with
% config files
% note: config files = StandardConfig_8tetrodes_ParamSweeps.m (edit ops in this) and
% 8tetrode_channelmap.mat (just leave this along)
%
% RETURNS:
% - none, but calls kilosort & runs on file of interest with associted
% configurations
%
% 
%
% = EXAMPLE CALLS:
% - kilosort_ops_sweep('directory/with/config/folders/here')
% ---------------------
%% inputs
if isempty(varargin)
    homedirectory = pwd;
else
    if isfolder(varargin{1})
        homedirectory = pwd;
        directorywithbinarys =varargin{1}
        cd directorywithbindaries
    else
        error('input must be in the format of a string leading to a dir')
    end
end
%% initialize
%determine computer type
if ispc
    delim='\';
else
    delim='/';
end

% make list of folders to processs
listoffolders = dir()
listoffolders(ismember( {listoffolders.name}, {'.', '..'})) = []; %remove . and ..

num_folders = length(listoffolders)
sprintf('There are %d folders to process', num_folders)

%% loop over folders

for i=1:num_folders
    % cd into ith sweep folder, there should be two config files and a .bin
    % file in here, grab the directory string
    cd(listoffolders(i).name)
    pathtobin = pwd
   
    % grab the name of the .bin file to use it later
    bininfo = dir('*.bin')
 
%     % run kilosort (assumes same path for config and .bin file)
%     sprintf('passing file %d of %d into kilosort',i,num_folders)
%     main_kilosort_fx(pathtobin)
%     sprintf('file %d of %d processed inkilosort',i,num_folders)
    
    %move bin file into next folder (except for on last loop)

    if i < num_folders
        pathtonextfolder = fullfile(listoffolders(i+1).folder, listoffolders(i+1).name)
        movefile(bininfo.name, pathtonextfolder)
    else
        sprintf('.bin located in final folder')
    end    
    
    % return to directory with other folders
    cd ..
    
end

end

