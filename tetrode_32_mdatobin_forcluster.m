%% 
% goal: to become a function for taking 32 tetrode wireless ephys data from
% spikegadgets and turn it into binary files formatted for kilosort2
%%
% ---------------------
% created by EJ Dennis 20190823 & modified by J Breda 20200707
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
%- jobid: job number from slurm submission, if no argument is entered, will
% attach 'nojobid' to directory name
%
% assumed working directory format is from pipe_fork2.sh function. 
% Ex: your/data/directory/dir_w_mda_folders_for_N_sessions
% where N is >= 1
%
% in each mda session folder, there should be X .mda files all of the same
% size where X = number of channels
% Ex: your/data/directory/dir_w_mda_files_for_1_session/*files here*
% 
% RETURNS:
% - creates a folder in working directory with .mda files called
% 'binfilesforkilosort2_jobid'. Four .bin files will be created corresponding to
% groups of 8 tetrodes for each sesssion. 

% 
% = EXAMPLE CALLS:
% - tetrode_32_mdatobin_forcluster('C:\Users\jbred\Github\Brody_Lab_Ephys\data', '20002')
% ---------------------

function [allfoldernames] = tetrode_32_mdatobin_forcluster(varargin)


if isempty(varargin)
    myparentfolder=pwd;
    jobid = 'nojobid' % will name binfileforkilosort2_noid
    
elseif length(varargin)==1
    if isdir(varargin{1})
            cd(varargin{1})
            myparentfolder = pwd;
    else
            error('input should be empty or contain a valid directory')
    end   
    jobid = 'nojobid';
else
    if isdir(varargin{1})
            cd(varargin{1})
            myparentfolder = pwd;
    else
            error('input should be empty or contain a valid directory')
    end
    jobid = varargin{2};
end

    
% check if on pc or mac & adjust file names accordingly
if ispc
    delim='\';
else
    delim='/';
end

% make a new folder for the bin files we will make today and add it to your
% path 
mkdir(fullfile(myparentfolder, delim, sprintf('binfilesforkilosort2_%s',jobid)))
binfolder = [myparentfolder, delim, sprintf('binfilesforkilosort2_%s',jobid)]
addpath(binfolder)


% in my directory, find all the mda folders
folderpattern=fullfile(myparentfolder,'*.mda*');
thefolders = dir(folderpattern);

%save a list of the names of each mda folder
allfoldernames = {thefolders.name};

% for each mda folder, make groups of eight tetrodes into binary files for
% kilosort2 processing save these into the binfolder

% for debugging
N_channels = 32
% N_folders = 1  % so I can run debug and only run one folder at a time

% for i = 1:length(allfoldernames)
% % for i = 1:length(N_folders) % debugging
% 
% 
%     % datafolder = [allfoldernames{i} '/results']; this wasn't working
%     % because the way the data is stored, the result file does not actually
%     % contain the .mda files we want. They are all different sizes and
%     % break the function.
%     
%     datafolder = [allfoldernames{i}]
%     cd(datafolder)
%     
%     % note this makes a 1 X 2 array with the second being empty, so we grab
%     % the first, otherwise this will break the fopen function below
%     genericfilename = strsplit(allfoldernames{i},'.mda');
%     genericfilename = genericfilename{1}
%     
%     firstbundle=[];
%     secondbundle=[];
%     thirdbundle=[];
%     fourthbundle=[];
%     
%     %load the first bundle of tetrodes
%     for j = 1:N_channels
%         % If you get readmda errors here, check to make sure the file
%         % suffix is correct (JB).
%         % genericfilename{i} was here before. may
%         % need to return if running with more than one folder?
%         
%         thisfilename = [genericfilename sprintf('.nt%d.referenced.mda',j)];
%         if j < 9
%             firstbundle = [firstbundle;int16(readmda(thisfilename))];
%         elseif j > 24
%             fourthbundle = [fourthbundle;int16(readmda(thisfilename))];
%         elseif j < 17
%             secondbundle = [secondbundle;int16(readmda(thisfilename))];
%         else
%             thirdbundle = [thirdbundle;int16(readmda(thisfilename))];
%         end
%     end
%    
% 
%     sprintf('folder %n of %d is now saving...',i,length(allfoldernames))
%     
%     
%     
%     fname = [binfolder, delim genericfilename, '_firstbundle.bin']
%     fid = fopen(fname,'w');
%     fwrite(fid,firstbundle,'int16');
%     fclose(fid);
%     sprintf('bundle 1 of 4 of folder %n of %d is now saving...',i,length(allfoldernames))
%     
%     fname = [binfolder, '\', genericfilename, '_secondbundle.bin']
%     fid = fopen(fname,'w');
%     fwrite(fid,secondbundle,'int16');
%     fclose(fid);
%     sprintf('bundle 2 of 4 of folder %n of %d is now saving...',i,length(allfoldernames))
%    
%     fname = [binfolder, '\', genericfilename, '_thirdbundle.bin']
%     fid = fopen(fname,'w');
%     fwrite(fid,thirdbundle,'int16');
%     fclose(fid);
%     sprintf('bundle 3 of 4 of folder %n of %d is now saving...',i,length(allfoldernames))
% 
%     fname = [binfolder, '\', genericfilename, '_fourthbundle.bin']
%     fid = fopen(fname,'w');
%     fwrite(fid,fourthbundle,'int16');
%     fclose(fid);
%     sprintf('bundle 4 of 4 of folder %n of %d is now saving...',i,length(allfoldernames))
%     
%     pwd
%     % head back to the parent folder so we can tackle the next recording
%     cd ..
%     pwd
%     % cd myparent folder %% this does not work, just need to step back one
%     % directory
%     %tell the user something is happening
%     sprintf('folder %n of %d done processing',i,length(allfoldernames))
% 
% end
% end
