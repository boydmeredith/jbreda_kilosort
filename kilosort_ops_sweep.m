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
% - kilosort_ops_sweep(Thlist, lamlist, spkTh, 'directory/with/config/folders/here')
% ---------------------
%% inputs (new code)
if length(varargin) == 3
    Ths = varargin{1}
    lams = varargin{2}
    spkThs = varargin{3}
    homedirectory = pwd; %if no directory is passed, use current directory
elseif length(varargin)==4
    
    Ths = varargin{1}
    lams = varargin{2}
    spkThs = varagin{3}
    
    if isfolder(varargin{4})  
        homedirectory=pwd;
        homedirectory=varargin{1}; %#ok<NASGU>
        cd homedirectory
    else
        error('input must be in the format of a string leading to a directory')
    end    
else
    error('Incorrect inputs- must pass in Th, lam, spkTh. Directory string optional.')
end 

%% initialize
%determine computer type
if ispc
    delim='\';
else
    delim='/';
end

% grab the name of the .bin file to use it later
bininfo = dir('*.bin')

% for updating purposes
cur_sweep = 0
Nsweeps = length(Ths) * length(lams) * length(spkThs)
% movefile(bininfo.name, pathtonextfolder)
%%% Should pass in a directory that is empty except for .bin file and
%%% standard configs/channel map. In this directory, I want to generate a
%%% folder for the ith sweep. Then, I want to put the .bin file in that
%%% folder. Then, I want to run kilosort with the i,j,kth parameters. For
%%% kilosort function, I will need to pass in the home directory (config
%%% dir), and the current directory (.bin dir) as well as the Th, lam and
%%% spk.th I want. After kilosort has run, I want to move the .bin file
%%% back to the home directory (because the next folder isn't generated
%%% yet).

%% main loop
for Th_idx=1:length(Ths)
    for lam_idx=1:length(lams)
        for spkTh_idx=1:length(spkThs)
            
            % first, make a folder, add it to the path, and move the .bin
            % file into the folder
            mkdir(fullfile(homedirectory, sprintf('sweep_%d_%d_%d', ...
                Th_idx, lam_idx, spkTh_idx)))
            sweep_directory = [homedirectory, delim, sprintf('sweep_%d_%d_%d', ...
                Th_idx, lam_idx, spkTh_idx)]
            addpath(sweep_directory)
            movefile(bininfo.name, sweep_directory)
            
            % now that the .bin file is in a directory, run kilosort from
            % it. Assumes that config file and channel map are in home
            % direcory
            
            main_kilosort_fx(sweep_directory, homedirectory, Ths{Th_idx}, ...
                lams(lam_idx), spkThs(spkTh_idx))
            
            % move back to home directory & move .bin file there for next
            % loop
            movefile(bininfo.name, homedirectory)
            cd .. 
            
            % update human
            sprintf('Sweep %d of %d completed',cur_sweep , Nsweeps)
            cur_sweep = cur_sweep + 1       
       
        end
    end
end

%%   
% %% inputs (old code)
% if isempty(varargin)
%     homedirectory = pwd;
% else
%     if isfolder(varargin{1})
%         homedirectory = pwd;
%         directorywithbinarys =varargin{1}
%         cd directorywithbindaries
%     else
%         error('input must be in the format of a string leading to a dir')
%     end
% end




% % make list of folders to processs
% listoffolders = dir()
% listoffolders(ismember( {listoffolders.name}, {'.', '..'})) = []; %remove . and ..
% 
% num_folders = length(listoffolders)
% sprintf('There are %d folders to process', num_folders)
% 
% %% loop over folders
% 
% for i=1:num_folders
%     % cd into ith sweep folder, there should be two config files and a .bin
%     % file in here, grab the directory string
%     cd(listoffolders(i).name)
%     pathtobin = pwd
%    
%     % grab the name of the .bin file to use it later
%     bininfo = dir('*.bin')
%  
%     % run kilosort (assumes same path for config and .bin file)
%     sprintf('passing file %d of %d into kilosort',i,num_folders)
%     main_kilosort_fx(pathtobin)
%     sprintf('file %d of %d processed inkilosort',i,num_folders)
%     
%     %move bin file into next folder (except for on last loop)
% 
%     if i < num_folders
%         pathtonextfolder = fullfile(listoffolders(i+1).folder, listoffolders(i+1).name)
%         movefile(bininfo.name, pathtonextfolder)
%     else
%         sprintf('.bin located in final folder')
%     end    
%     
%     % return to directory with other folders
%     cd ..
%     
%     % update user
%     
%     
% end

end

