function kilosort_ops_sweep(varargin)
%---------------------
% written by Jess Breda 20200720
% purpose is to run kilosort on single file with multiple different ops
% configurations
%
% TODO:
% - update input parameters 
% - update README
%
% INPUT PARAMETERS:
% Ths =
% lams = 
% spkThs = 
%
% OPTIONAL PARAMETERS:
% - homedirectory = string directing us to a folder that contains:
% 1) preprocessed .bin file
% 2) channel_map.mat
% 3) Standard_config.m with ops that are not being changed
%
% RETURNS:
% - none, but calls kilosort & runs on file of interest with associted
% configurations & creates a folder for each sweep. Need to document sweeps
% in other source to track
%
% = EXAMPLE CALLS:
% - kilosort_ops_sweep(Ths, lams, spkThs, 'directory/with/config/folders/here')
% Ths= {[2 2 2] [3 6 6]}
% lams = ][20 25 35 40]
% spkThs = {[-0.5 -0.75 -1 -2 -4]}
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
bininfo = dir('*.bin');

% for updating purposes
cur_sweep = 0;
Nsweeps = length(Ths) * length(lams) * length(spkThs);

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
            
            pwd 
            
            % move .bin file back to home directory for next sweep
            movefile(fullfile(sweep_directory, bininfo.name), homedirectory)
            
            % update human on progress
            cur_sweep = cur_sweep + 1;
            sprintf('Sweep %d of %d completed',cur_sweep , Nsweeps);    
       
        end
    end
end

end

