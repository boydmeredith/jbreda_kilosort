function main_kilosort_fx(binfldr,pathtoconfig)
% 

% setup paths - user should edit the path config file
p   =  path_config();
if nargin < 2
    ops = p.default_ks_ops;
    fprintf('Using default kilosort configuration')
else
    ops = pathtoconfig;
end

rootH = binfldr; % path to temporary binary file (same size as data, should be on fast SSD)
ops.fproc       = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD

%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', binfldr)

% if there isn't already a specified channel map, look for one in the
% folder containing the binary file
if ~exist(ops.chanMap) | isempty(ops.chanMap)
    % is there a channel map file in this folder?
    fs = dir(fullfile(binfldr, 'chan*.mat'));
    if ~isempty(fs)
        ops.chanMap = fullfile(binfldr, fs(1).name);
    end
end

% find the binary file
%fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
fnfilter    = fullfile(binfldr, '*.bin');
files       = dir(fnfilter);
% if the directory has multiple bin files, let user choose
curdir = pwd;
if length(files) == 1
    ops.fbinary = fullfile(binfldr, files(1).name);
else
    cd(binfldr)
    [fn fp] = uigetfile(fnfilter,'Pick file to sort');
    ops.fbinary = fullfile(fp,fn)
end
cd(curdir)

% preprocess data to create temp_wh.dat
rez = preprocessDataSub(ops);

% time-reordering as a function of drift
rez = clusterSingleBatches(rez);

% saving here is a good idea, because the rest can be resumed after loading rez
save(fullfile(binfldr, 'rez.mat'), 'rez', '-v7.3');

% main tracking and template matching algorithm
rez = learnAndSolve8b(rez);

% final merges
rez = find_merges(rez, 1);


% final splits by SVD
rez = splitAllClusters(rez, 1);

% final splits by amplitudes
rez = splitAllClusters(rez, 0);

% decide on cutoff
rez = set_cutoff(rez);

fprintf('found %d good units \n', sum(rez.good>0))

% write to Phy
fprintf('Saving results to Phy  \n')
rezToPhy(rez, binfldr);

%% if you want to save the results to a Matlab file...

% discard features in final rez file (too slow to save)
rez.cProj = [];
rez.cProjPC = [];

% final time sorting of spikes, for apps that use st3 directly
[~, isort]   = sortrows(rez.st3);
rez.st3      = rez.st3(isort, :);

% save final results as rez2
fprintf('Saving final results in rez2  \n')
fname = fullfile(binfldr, 'rez2.mat');
save(fname, 'rez', '-v7.3');


