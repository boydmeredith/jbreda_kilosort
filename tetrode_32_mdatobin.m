%%
% goal: to become a function for taking 32 tetrode wireless ephys data from
% spikegadgets and turn it into binary files formatted for kilosort2
%%
% ---------------------
% created by EJ Dennis 20190823 & modified by J Breda 20200612
%
% purpose is to take a folder(s) of .mda files corresponding to a 32 tetrode
% recording session, convert them to .bin files for kilsort and separate
% them into four bundles of 8 tetrodes.
%
% TODO:
% -
% - add an option to have a file with bad tetrodes (EJD)
% - ideally make something that allows for easy in/out from EIB testing
% (EJD)
% - example calls
%
% INPUT PARAMETERS:
% - none
%
% OPTIONAL PARAMETERS:
% - workspace: directory in which your .mda files are, if no
% argument is entered, will use current working directory.
%
% assumed working directory format is from pipe_fork2.sh function.
% Ex: your/data/directory/dir_w_mda_folders_for_N_sessions
% where N is >= 1
%
% in each mda session folder, there should be N .mda files all of the same
% size
% Ex: your/data/directory/dir_w_mda_files_for_1_session/*files here*
%
% RETURNS:
% - creates a folder in working directory with .mda files called
% 'binfilesforkilosort2'. Four .bin files will be created corresponding to
% groups of 8 tetrodes for each sesssion.

%
% = EXAMPLE CALLS:
% -
% ---------------------

function tetrode_32_mdatobin(mdadir, savedir)

if nargin < 1
    fprintf('no mdadir supplied. Will look for .mda files in current directory.\n')
    mdadir = pwd;
end

if nargin < 2
    fprintf('no savedir supplied. Will save .bin files in mdadir.\n')
    savedir = mdadir;
end

% in my directory, find all the mda folders
ntfilepattern   = fullfile(mdadir,'*nt??.mda');
ntfiles         = dir(ntfilepattern);
[~, genericfilename] = fileparts(mdadir);
% for each mda folder, make groups of eight tetrodes into binary files for
% kilosort2 processing save these into the binfolder

% for debugging
N_tetrodes = 32;
N_bundles  = 4;
N_tt_per_bundle = N_tetrodes/N_bundles;
N_ch_per_bundle = N_tt_per_bundle * 4;
assert(length(ntfiles)==N_tetrodes);
% N_folders = 1  % so I can run debug and only run one folder at a time

%load the first bundle of tetrodes
for bb = 1:N_bundles
    tic
    fprintf('working on bundle %i...\n',bb)
    tic
    clear bundle
    for tt = 1:N_tt_per_bundle
        this_tetrode = N_tt_per_bundle*(bb-1)+tt;
        thisfn       = [genericfilename sprintf('.nt%d.mda',this_tetrode)];
        thisfilename = fullfile(mdadir, thisfn);
        this_dat     = readmda(thisfilename);
        if tt == 1
            bundle = zeros(N_ch_per_bundle,length(this_dat),'int16');
        end
        this_ch = (tt-1)*4 + (1:4);
        bundle(this_ch,:) = int16(this_dat);
        clear this_dat
    end
    this_name = sprintf('%s_bundle%i',genericfilename,bb)
    fn  = [this_name '.bin'];
    bundledir = fullfile(savedir,this_name);
    if ~exist(bundledir)
        mkdir(bundledir);
    end
    fpath = fullfile(bundledir, fn);
    fid = fopen(fpath,'w');
    fwrite(fid,bundle,'int16');
    fclose(fid);
    fprintf('bundle %i of 4 saving in %s ...\n',bb,fpath)
    toc
end
    

