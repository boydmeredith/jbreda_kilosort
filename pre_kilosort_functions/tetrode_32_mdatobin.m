%% 
% goal: to become a function for taking 32 tetrode wireless ephys data from
% spikegadgets and turn it into binary files formatted for kilosort2
% created by EJ Dennis 20190823
%%
% todo: add an option to have a file with bad tetrodes
% ideally make something that allows for easy in/out from EIB testing

function tetrode_32_mdatobin(workspace)

    if nargin < 1
    % where are we?
        myparentfolder = pwd;
    end

    if nargin > 0
        if isdir(workspace)
            cd workspace
            myparentfolder = pwd;
        else
            error('input should be empty or contain a valid directory')
        end
    end

%make a new folder for the bin files we will make today and add it to your
%path
mkdir(myparentfolder,'/binfilesforkilosort2');
binfolder = [myparentfolder '/binfilesforkilosort2'];
addpath(binfolder);

% in my directory, find all the mda folders
folderpattern=fullfile(myparentfolder,'*.mda*');
thefolders = dir(folderpattern);

%save a list of the names of each mda folder
allfoldernames = {thefolders.name};

% for each mda folder, go to the results folder and make groups of eight
% tetrodes into binary files for kilosort2 processing
% save these into the binfolder

for i = 1:length(allfilenames)

    datafolder = [allfilenames{1} '/results'];
    cd(datafolder)
    genericfilename = strsplit(allfilenames{1},'.mda');
    firstbundle=[];
    secondbundle=[];
    thirdbundle=[];
    fourthbundle=[];
    
    %load the first bundle of tetrodes
    for j = 1:32
        thisfilename = [genericfilename{i} sprintf('.nt%d.reference.mda',j)];
        if j < 9
            firstbundle = [firstbundle;int16(readmda(thisfilename))];
        elseif j > 24
            fourthbundle = [fourthbundle;int16(readmda(thisfilename))];
        elseif j < 17
            secondbundle = [secondbundle;int16(readmda(thisfilename))];
        else
            thirdbundle = [thirdbundle;int16(readmda(thisfilename))];
        end
    end

    sprintf('folder %n of %d is now saving...',i,length(allfilenames))    
    fid = fopen([binfolder genericfilename '_firstbundle.bin'],'w');
    fwrite(fid,firstbundle,'int16');
    fclose(fid);
    sprintf('bundle 1 of 4 of folder %n of %d is now saving...',i,length(allfilenames))
    
    fid = fopen([binfolder genericfilename '_secondbundle.bin'],'w');
    fwrite(fid,secondbundle,'int16');
    fclose(fid);
    sprintf('bundle 2 of 4 of folder %n of %d is now saving...',i,length(allfilenames))
   
    fid = fopen([binfolder genericfilename '_thirdbundle.bin'],'w');
    fwrite(fid,thirdbundle,'int16');
    fclose(fid);
    sprintf('bundle 3 of 4 of folder %n of %d is now saving...',i,length(allfilenames))

    fid = fopen([binfolder genericfilename '_fourthbundle.bin'],'w');
    fwrite(fid,fourthbundle,'int16');
    fclose(fid);
    sprintf('bundle 4 of 4 of folder %n of %d is now saving...',i,length(allfilenames))
    
    % head back to the parent folder so we can tackle the next recording
    cd myparentfolder
    %tell the user something is happening
    sprintf('folder %n of %d done processing',i,length(allfilenames))

end
end
